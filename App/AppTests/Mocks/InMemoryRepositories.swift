import Foundation
@testable import App

/// テスト用インメモリCrewリポジトリ
final class InMemoryCrewRepository: CrewRepositoryProtocol {
    private(set) var storage: [UUID: Crew] = [:]

    func save(_ crew: Crew) {
        storage[crew.id] = crew
    }

    func findById(_ id: UUID) -> Crew? {
        storage[id]
    }

    func findAll() -> [Crew] {
        Array(storage.values)
    }

    func delete(_ id: UUID) {
        storage.removeValue(forKey: id)
    }
}

/// テスト用インメモリCellリポジトリ
final class InMemoryCellRepository: CellRepositoryProtocol {
    private(set) var storage: [UUID: Cell] = [:]

    func save(_ cell: Cell) {
        storage[cell.id] = cell
    }

    func findById(_ id: UUID) -> Cell? {
        storage[id]
    }

    func findByCrewId(_ crewId: UUID) -> [Cell] {
        storage.values.filter { $0.crewId == crewId }
    }

    func delete(_ id: UUID) {
        storage.removeValue(forKey: id)
    }

    func deleteByCrewId(_ crewId: UUID) {
        storage = storage.filter { $0.value.crewId != crewId }
    }
}

/// テスト用スパイ: Google Calendar連携の呼び出しを記録する
final class SpyCalendarExportService: CalendarExportServiceProtocol {
    // 呼び出し記録
    private(set) var exportEventsCalled = false
    private(set) var exportedSchedules: [WorkSchedule]?
    private(set) var exportedAppName: String?

    private(set) var deleteEventsCalled = false
    private(set) var deleteEventsStart: Date?
    private(set) var deleteEventsEnd: Date?
    private(set) var deleteEventsAppName: String?

    private(set) var deleteAllEventsCalled = false
    private(set) var deleteAllEventsAppName: String?

    /// completionに渡す結果を差し替え可能にする
    var resultToReturn: Result<Void, Error> = .success(())

    func exportEvents(_ schedules: [WorkSchedule], appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        exportEventsCalled = true
        exportedSchedules = schedules
        exportedAppName = appName
        completion(resultToReturn)
    }

    func deleteEvents(from startDate: Date, to endDate: Date, appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteEventsCalled = true
        deleteEventsStart = startDate
        deleteEventsEnd = endDate
        deleteEventsAppName = appName
        completion(resultToReturn)
    }

    func deleteAllEvents(appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteAllEventsCalled = true
        deleteAllEventsAppName = appName
        completion(resultToReturn)
    }
}

/// テスト用スタブ: あらかじめ与えた勤務予定をそのまま返す
final class StubScheduleApplicationService: ScheduleApplicationServiceProtocol {
    var schedulesToReturn: [WorkSchedule] = []
    var errorToThrow: Error?

    init(schedulesToReturn: [WorkSchedule] = []) {
        self.schedulesToReturn = schedulesToReturn
    }

    func getMonthlySchedule(request: GetMonthlyScheduleRequest) throws -> MonthlyScheduleResponse {
        if let errorToThrow {
            throw errorToThrow
        }
        return MonthlyScheduleResponse(
            year: request.year,
            month: request.month,
            schedules: schedulesToReturn
        )
    }
}
