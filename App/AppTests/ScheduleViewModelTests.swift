import Testing
import Foundation
@testable import App

/// ScheduleViewModel のタイムゾーン回帰テスト。
///
/// ScheduleCalculator は JST 固定で日付を生成する一方、表示側が端末TZで日付を読むと
/// 日本国外でカレンダーの日付番号が1日ずれる（例: JSTの2/1 00:00 は米国西海岸では1/31）。
/// ここでは端末TZを意図的に非JSTへ差し替え、表示側がJST基準を保つことを検証する。
///
/// `NSTimeZone.default` をプロセス全体で書き換えるため `.serialized` で直列化する。
@Suite(.serialized)
@MainActor
struct ScheduleViewModelTests {

    /// 端末TZを一時的に差し替えて処理を実行する
    private func withDeviceTimeZone<T>(_ identifier: String, _ body: () throws -> T) rethrows -> T {
        let original = NSTimeZone.default
        NSTimeZone.default = TimeZone(identifier: identifier)!
        defer { NSTimeZone.default = original }
        return try body()
    }

    private func makeViewModel(
        year: Int,
        month: Int,
        schedules: [WorkSchedule]
    ) -> ScheduleViewModel {
        let crew = Crew(name: "TestCrew", cycleStartDate: Calendar.jst.date(from: DateComponents(year: 2026, month: 1, day: 1))!)
        let cell = Cell(
            name: "TestCell",
            crewId: crew.id,
            cycleConfiguration: CycleConfiguration(rounds: Array(repeating: .withNight, count: 7))
        )
        let viewModel = ScheduleViewModel(
            crew: CrewResponse(from: crew),
            cell: CellResponse(from: cell),
            scheduleService: StubScheduleApplicationService(schedulesToReturn: schedules)
        )
        viewModel.currentYear = year
        viewModel.currentMonth = month
        return viewModel
    }

    /// 指定月の全日分の勤務予定をJSTで生成する
    private func jstSchedules(year: Int, month: Int) -> [WorkSchedule] {
        let firstDay = Calendar.jst.date(from: DateComponents(year: year, month: month, day: 1))!
        let dayCount = Calendar.jst.range(of: .day, in: .month, for: firstDay)!.count
        return (1...dayCount).map { day in
            let date = Calendar.jst.date(from: DateComponents(year: year, month: month, day: day))!
            return WorkSchedule(date: date, shiftType: .a)
        }
    }

    // MARK: - CalendarDay.dayNumber

    @Test func dayNumberUsesJSTRegardlessOfDeviceTimeZone() {
        // JSTの2026年2月1日 00:00（＝米国西海岸では1月31日 07:00）
        let date = Calendar.jst.date(from: DateComponents(year: 2026, month: 2, day: 1))!

        withDeviceTimeZone("America/Los_Angeles") {
            let day = CalendarDay(date: date, schedule: nil)
            // Calendar.current で読むと 31 になる
            #expect(day.dayNumber == 1)
        }
    }

    @Test func dayNumberIsNilWhenDateIsNil() {
        let day = CalendarDay(date: nil, schedule: nil)
        #expect(day.dayNumber == nil)
    }

    // MARK: - 初期表示月

    @Test func initialMonthFollowsJSTNotDeviceTimeZone() {
        let expected = Calendar.jst.dateComponents([.year, .month], from: Date())

        withDeviceTimeZone("America/Los_Angeles") {
            let crew = Crew(name: "TestCrew", cycleStartDate: Date())
            let cell = Cell(
                name: "TestCell",
                crewId: crew.id,
                cycleConfiguration: CycleConfiguration(rounds: Array(repeating: .withNight, count: 7))
            )
            let viewModel = ScheduleViewModel(
                crew: CrewResponse(from: crew),
                cell: CellResponse(from: cell),
                scheduleService: StubScheduleApplicationService()
            )
            // 月境界において端末TZだと前月/翌月になる
            #expect(viewModel.currentYear == expected.year)
            #expect(viewModel.currentMonth == expected.month)
        }
    }

    // MARK: - カレンダーグリッド

    @Test func calendarDaysCoverEveryDayOfMonthUnderNonJSTDevice() {
        let viewModel = makeViewModel(year: 2026, month: 2, schedules: jstSchedules(year: 2026, month: 2))

        withDeviceTimeZone("America/Los_Angeles") {
            let dated = viewModel.calendarDays.filter { $0.date != nil }
            // 2026年2月は28日
            #expect(dated.count == 28)
            #expect(dated.map { $0.dayNumber } == Array(1...28).map { Optional($0) })
        }
    }

    @Test func everyDayHasScheduleMatchedUnderNonJSTDevice() {
        let viewModel = makeViewModel(year: 2026, month: 2, schedules: jstSchedules(year: 2026, month: 2))
        viewModel.loadSchedule()

        withDeviceTimeZone("America/Los_Angeles") {
            let dated = viewModel.calendarDays.filter { $0.date != nil }
            // 日付照合がJST基準でないと、いずれかの日でscheduleがnilになる
            #expect(dated.allSatisfy { $0.schedule != nil })
            #expect(viewModel.errorMessage == nil)
        }
    }

    @Test func leapYearFebruaryHas29Days() {
        let viewModel = makeViewModel(year: 2028, month: 2, schedules: jstSchedules(year: 2028, month: 2))

        withDeviceTimeZone("America/Los_Angeles") {
            let dated = viewModel.calendarDays.filter { $0.date != nil }
            #expect(dated.count == 29)
        }
    }

    // MARK: - 月の切り替え

    @Test func goToPreviousMonthWrapsToDecemberOfPreviousYear() {
        let viewModel = makeViewModel(year: 2026, month: 1, schedules: [])
        viewModel.goToPreviousMonth()

        #expect(viewModel.currentYear == 2025)
        #expect(viewModel.currentMonth == 12)
    }

    @Test func goToNextMonthWrapsToJanuaryOfNextYear() {
        let viewModel = makeViewModel(year: 2026, month: 12, schedules: [])
        viewModel.goToNextMonth()

        #expect(viewModel.currentYear == 2027)
        #expect(viewModel.currentMonth == 1)
    }
}
