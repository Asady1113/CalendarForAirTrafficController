import Testing
import Foundation
@testable import App

private func jstDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.jst.date(from: DateComponents(year: year, month: month, day: day))!
}

private func icsDateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd'T'HHmmss"
    formatter.timeZone = TimeZone.jst
    return formatter.string(from: date)
}

struct IcsGeneratorTests {
    private let generator = IcsGenerator()

    private func generateString(_ schedules: [WorkSchedule], appName: String = "AeroRota") -> String {
        let data = generator.generate(schedules: schedules, appName: appName)
        return String(data: data, encoding: .utf8) ?? ""
    }

    @Test func outputStartsAndEndsWithVCalendar() {
        let schedules = [WorkSchedule(date: jstDate(2026, 3, 1), shiftType: .e1)]
        let content = generateString(schedules)

        #expect(content.hasPrefix("BEGIN:VCALENDAR"))
        #expect(content.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("END:VCALENDAR"))
    }

    @Test func offAndPostNightAreNotOutputAsEvents() {
        let schedules = [
            WorkSchedule(date: jstDate(2026, 3, 1), shiftType: .off),
            WorkSchedule(date: jstDate(2026, 3, 2), shiftType: .postNight),
            WorkSchedule(date: jstDate(2026, 3, 3), shiftType: .e1)
        ]
        let content = generateString(schedules)

        let eventCount = content.components(separatedBy: "BEGIN:VEVENT").count - 1
        #expect(eventCount == 1)
        #expect(!content.contains("休み"))
        #expect(!content.contains("明け"))
    }

    @Test func eventTitleUsesAppNameAndJapaneseName() {
        let schedules = [WorkSchedule(date: jstDate(2026, 3, 1), shiftType: .c)]
        let content = generateString(schedules)

        #expect(content.contains("SUMMARY:AeroRota_夜勤"))
    }

    @Test func nightShiftEndsAtNextDay0815() {
        let date = jstDate(2026, 3, 1)
        let schedules = [WorkSchedule(date: date, shiftType: .c)]
        let content = generateString(schedules)

        let nextDay = Calendar.jst.date(byAdding: .day, value: 1, to: date)!
        var expectedEndComponents = Calendar.jst.dateComponents([.year, .month, .day], from: nextDay)
        expectedEndComponents.hour = 8
        expectedEndComponents.minute = 15
        let expectedEnd = Calendar.jst.date(from: expectedEndComponents)!

        #expect(content.contains("DTEND:\(icsDateString(expectedEnd))"))
    }

    @Test func e1ShiftHasCorrectStartAndEndTimes() {
        let date = jstDate(2026, 3, 1)
        let schedules = [WorkSchedule(date: date, shiftType: .e1)]
        let content = generateString(schedules)

        var startComponents = Calendar.jst.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = 6
        startComponents.minute = 45
        let expectedStart = Calendar.jst.date(from: startComponents)!

        var endComponents = Calendar.jst.dateComponents([.year, .month, .day], from: date)
        endComponents.hour = 15
        endComponents.minute = 0
        let expectedEnd = Calendar.jst.date(from: endComponents)!

        #expect(content.contains("DTSTART:\(icsDateString(expectedStart))"))
        #expect(content.contains("DTEND:\(icsDateString(expectedEnd))"))
    }
}
