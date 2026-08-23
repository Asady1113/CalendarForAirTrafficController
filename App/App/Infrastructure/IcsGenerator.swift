import Foundation

class IcsGenerator: IcsGeneratorProtocol {
    private let calendar: Calendar
    private let dateFormatter: ISO8601DateFormatter

    init() {
        self.calendar = Calendar.jst

        self.dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withTimeZone]
        dateFormatter.timeZone = TimeZone.jst
    }

    func generate(schedules: [WorkSchedule], appName: String) -> Data {
        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//\(appName)//JP
        CALSCALE:GREGORIAN
        METHOD:PUBLISH

        """

        let filtered = schedules.filter { $0.shiftType != .off && $0.shiftType != .postNight }
        for schedule in filtered {
            let event = createEvent(for: schedule, appName: appName)
            icsContent += event
        }

        icsContent += "END:VCALENDAR\n"

        return icsContent.data(using: .utf8) ?? Data()
    }

    private func createEvent(for schedule: WorkSchedule, appName: String) -> String {
        let shiftType = schedule.shiftType
        let title = "\(appName)_\(shiftType.japaneseName)"
        let uid = UUID().uuidString

        let (startDate, endDate) = calculateEventDates(for: schedule)

        let startDateString = formatDateForIcs(startDate)
        let endDateString = formatDateForIcs(endDate)

        // 休み・明けは generate() の filter で除外済みのため、ここには終日イベント対象は来ない
        return """
        BEGIN:VEVENT
        UID:\(uid)
        DTSTART:\(startDateString)
        DTEND:\(endDateString)
        SUMMARY:\(title)
        END:VEVENT

        """
    }

    private func calculateEventDates(for schedule: WorkSchedule) -> (start: Date, end: Date) {
        let shiftType = schedule.shiftType
        let baseDate = schedule.date

        guard let startTimeComponents = shiftType.startTime,
              let endTimeComponents = shiftType.endTime else {
            // 終日イベントの場合
            return (baseDate, baseDate)
        }

        var startComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
        startComponents.hour = startTimeComponents.hour
        startComponents.minute = startTimeComponents.minute
        let startDate = calendar.date(from: startComponents) ?? baseDate

        var endComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
        endComponents.hour = endTimeComponents.hour
        endComponents.minute = endTimeComponents.minute

        // 夜勤（C）は翌日終了
        if shiftType == .c {
            endComponents.day = (endComponents.day ?? 0) + 1
        }

        let endDate = calendar.date(from: endComponents) ?? baseDate

        return (startDate, endDate)
    }

    private func formatDateForIcs(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        formatter.timeZone = TimeZone.jst
        return formatter.string(from: date)
    }
}
