import Foundation
import GoogleSignIn
import UIKit

/// Google Calendar APIを使った外部カレンダー連携
final class GoogleCalendarService: CalendarExportServiceProtocol {

    private let clientID = Secrets.googleClientID
    private let calendarScope = "https://www.googleapis.com/auth/calendar"
    private let calendarAPIBase = "https://www.googleapis.com/calendar/v3"

    // MARK: - CalendarExportServiceProtocol

    func exportEvents(_ schedules: [WorkSchedule], appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        signInIfNeeded { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let accessToken):
                self?.insertEvents(schedules, appName: appName, accessToken: accessToken, completion: completion)
            }
        }
    }

    func deleteEvents(from startDate: Date, to endDate: Date, appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        signInIfNeeded { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let accessToken):
                self?.fetchAndDeleteEvents(from: startDate, to: endDate, appName: appName, accessToken: accessToken, completion: completion)
            }
        }
    }

    func deleteAllEvents(appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 過去5年〜未来5年を対象に削除
        let past = Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()
        let future = Calendar.current.date(byAdding: .year, value: 5, to: Date()) ?? Date()
        deleteEvents(from: past, to: future, appName: appName, completion: completion)
    }

    // MARK: - Sign In

    private func signInIfNeeded(completion: @escaping (Result<String, Error>) -> Void) {
        // 既存のサインインセッションを確認
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
                user.refreshTokensIfNeeded { user, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let accessToken = user?.accessToken.tokenString else {
                        completion(.failure(GoogleCalendarError.authenticationFailed))
                        return
                    }
                    completion(.success(accessToken))
                }
                return
            }

            // 新規サインイン
            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController else {
                completion(.failure(GoogleCalendarError.noRootViewController))
                return
            }

            let config = GIDConfiguration(clientID: self.clientID)
            GIDSignIn.sharedInstance.configuration = config

            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootVC,
                hint: nil,
                additionalScopes: [self.calendarScope]
            ) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let accessToken = result?.user.accessToken.tokenString else {
                    completion(.failure(GoogleCalendarError.authenticationFailed))
                    return
                }
                completion(.success(accessToken))
            }
        }
    }

    // MARK: - Insert Events

    private let batchSize = 5
    private let batchInterval: TimeInterval = 0.5

    private func insertEvents(_ schedules: [WorkSchedule], appName: String, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let filtered = schedules.filter { $0.shiftType != .off && $0.shiftType != .postNight }
        let batches = stride(from: 0, to: filtered.count, by: batchSize).map {
            Array(filtered[$0..<min($0 + batchSize, filtered.count)])
        }

        sendBatches(batches, appName: appName, accessToken: accessToken, batchIndex: 0, failedSchedules: []) { [weak self] failedSchedules in
            guard !failedSchedules.isEmpty else {
                DispatchQueue.main.async { completion(.success(())) }
                return
            }
            // 失敗分をリトライ
            let retryBatches = stride(from: 0, to: failedSchedules.count, by: self?.batchSize ?? 5).map {
                Array(failedSchedules[$0..<min($0 + (self?.batchSize ?? 5), failedSchedules.count)])
            }
            self?.sendBatches(retryBatches, appName: appName, accessToken: accessToken, batchIndex: 0, failedSchedules: []) { stillFailed in
                DispatchQueue.main.async {
                    if stillFailed.isEmpty {
                        completion(.success(()))
                    } else {
                        completion(.failure(GoogleCalendarError.apiError(statusCode: 403)))
                    }
                }
            }
        }
    }

    private func sendBatches(_ batches: [[WorkSchedule]], appName: String, accessToken: String, batchIndex: Int, failedSchedules: [WorkSchedule], completion: @escaping ([WorkSchedule]) -> Void) {
        guard batchIndex < batches.count else {
            completion(failedSchedules)
            return
        }

        let batch = batches[batchIndex]
        let group = DispatchGroup()
        let lock = NSLock()
        var batchFailed: [WorkSchedule] = []

        for schedule in batch {
            group.enter()
            sendEvent(schedule: schedule, appName: appName, accessToken: accessToken) { error in
                if error != nil {
                    lock.lock()
                    batchFailed.append(schedule)
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .global()) { [weak self] in
            let delay = self?.batchInterval ?? 0.5
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                self?.sendBatches(batches, appName: appName, accessToken: accessToken, batchIndex: batchIndex + 1, failedSchedules: failedSchedules + batchFailed, completion: completion)
            }
        }
    }

    private func sendEvent(schedule: WorkSchedule, appName: String, accessToken: String, completion: @escaping (Error?) -> Void) {
        let event = buildEventBody(schedule: schedule, appName: appName)
        var request = URLRequest(url: URL(string: "\(calendarAPIBase)/calendars/primary/events")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: event)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(GoogleCalendarError.apiError(statusCode: httpResponse.statusCode))
                return
            }
            completion(nil)
        }.resume()
    }

    private func buildEventBody(schedule: WorkSchedule, appName: String) -> [String: Any] {
        let title = "\(appName)_\(schedule.shiftType.japaneseName)"
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let start = shiftStartDate(for: schedule),
              let end = shiftEndDate(for: schedule) else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let dateStr = dateFormatter.string(from: schedule.date)
            return [
                "summary": title,
                "start": ["date": dateStr],
                "end": ["date": dateStr]
            ]
        }
        formatter.formatOptions = [.withInternetDateTime]
        return [
            "summary": title,
            "start": ["dateTime": formatter.string(from: start), "timeZone": "Asia/Tokyo"],
            "end": ["dateTime": formatter.string(from: end), "timeZone": "Asia/Tokyo"]
        ]
    }

    private func shiftStartDate(for schedule: WorkSchedule) -> Date? {
        guard let startTime = schedule.shiftType.startTime else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        var components = calendar.dateComponents([.year, .month, .day], from: schedule.date)
        components.hour = startTime.hour
        components.minute = startTime.minute
        return calendar.date(from: components)
    }

    private func shiftEndDate(for schedule: WorkSchedule) -> Date? {
        guard let endTime = schedule.shiftType.endTime else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        var components = calendar.dateComponents([.year, .month, .day], from: schedule.date)
        components.hour = endTime.hour
        components.minute = endTime.minute
        var endDate = calendar.date(from: components)
        // 夜勤（C）は翌日終了
        if schedule.shiftType == .c {
            endDate = endDate.flatMap { calendar.date(byAdding: .day, value: 1, to: $0) }
        }
        return endDate
    }

    // MARK: - Delete Events

    private func fetchAndDeleteEvents(from startDate: Date, to endDate: Date, appName: String, accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(identifier: "UTC")

        var components = URLComponents(string: "\(calendarAPIBase)/calendars/primary/events")!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: formatter.string(from: startDate)),
            URLQueryItem(name: "timeMax", value: formatter.string(from: endDate)),
            URLQueryItem(name: "maxResults", value: "2500")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let items = json["items"] as? [[String: Any]] else {
                DispatchQueue.main.async { completion(.success(())) }
                return
            }

            let filtered = items.filter { item in
                guard let summary = item["summary"] as? String else { return false }
                return summary.hasPrefix("\(appName)_")
            }
            let eventIDs = filtered.compactMap { $0["id"] as? String }
            self?.deleteEventsByIDs(eventIDs, accessToken: accessToken, completion: completion)
        }.resume()
    }

    private func deleteEventsByIDs(_ ids: [String], accessToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !ids.isEmpty else {
            DispatchQueue.main.async { completion(.success(())) }
            return
        }

        let batches = stride(from: 0, to: ids.count, by: batchSize).map {
            Array(ids[$0..<min($0 + batchSize, ids.count)])
        }

        deleteBatches(batches, accessToken: accessToken, batchIndex: 0, failedIDs: []) { [weak self] failedIDs in
            guard !failedIDs.isEmpty else {
                DispatchQueue.main.async { completion(.success(())) }
                return
            }
            // 失敗分を1回リトライ
            let retryBatches = stride(from: 0, to: failedIDs.count, by: self?.batchSize ?? 5).map {
                Array(failedIDs[$0..<min($0 + (self?.batchSize ?? 5), failedIDs.count)])
            }
            self?.deleteBatches(retryBatches, accessToken: accessToken, batchIndex: 0, failedIDs: []) { stillFailed in
                DispatchQueue.main.async {
                    if stillFailed.isEmpty {
                        completion(.success(()))
                    } else {
                        completion(.failure(GoogleCalendarError.apiError(statusCode: 403)))
                    }
                }
            }
        }
    }

    private func deleteBatches(_ batches: [[String]], accessToken: String, batchIndex: Int, failedIDs: [String], completion: @escaping ([String]) -> Void) {
        guard batchIndex < batches.count else {
            completion(failedIDs)
            return
        }

        let batch = batches[batchIndex]
        let group = DispatchGroup()
        let lock = NSLock()
        var batchFailed: [String] = []

        for id in batch {
            group.enter()
            var request = URLRequest(url: URL(string: "\(calendarAPIBase)/calendars/primary/events/\(id)")!)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { _, response, error in
                if error != nil {
                    lock.lock()
                    batchFailed.append(id)
                    lock.unlock()
                } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    lock.lock()
                    batchFailed.append(id)
                    lock.unlock()
                }
                group.leave()
            }.resume()
        }

        group.notify(queue: .global()) { [weak self] in
            let delay = self?.batchInterval ?? 0.5
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                self?.deleteBatches(batches, accessToken: accessToken, batchIndex: batchIndex + 1, failedIDs: failedIDs + batchFailed, completion: completion)
            }
        }
    }
}

// MARK: - Errors

enum GoogleCalendarError: LocalizedError {
    case authenticationFailed
    case noRootViewController
    case apiError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .authenticationFailed: return "Google認証に失敗しました"
        case .noRootViewController: return "画面の取得に失敗しました"
        case .apiError(let statusCode): return "Google Calendar APIエラー (HTTP \(statusCode))"
        }
    }
}
