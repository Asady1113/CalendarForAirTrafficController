import Testing
import Foundation
@testable import App

/// JSTで日付を生成するテストヘルパー
private func jstDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.jst.date(from: DateComponents(year: year, month: month, day: day))!
}

private func makeCell(rounds: [RoundType], crewId: UUID = UUID()) -> Cell {
    Cell(name: "TestCell", crewId: crewId, cycleConfiguration: CycleConfiguration(rounds: rounds))
}

private func makeCrew(cycleStartDate: Date) -> Crew {
    Crew(name: "TestCrew", cycleStartDate: cycleStartDate)
}

struct ScheduleCalculatorTests {
    private let calculator = ScheduleCalculator()

    // MARK: - サイクル開始日

    @Test func cycleStartDateIsRound1Day1() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(rounds: Array(repeating: .withNight, count: 7), crewId: crew.id)

        let schedules = calculator.calculateForPeriod(
            cell: cell, crew: crew,
            period: ExportPeriod(startDate: cycleStart, endDate: cycleStart)
        )

        #expect(schedules.count == 1)
        #expect(schedules[0].shiftType == .e1)
    }

    // MARK: - ラウンドパターン

    @Test func withNightRoundPatternIsCorrect() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(rounds: Array(repeating: .withNight, count: 7), crewId: crew.id)

        let expected: [ShiftType] = [.e1, .a, .b, .c, .postNight, .off]
        for (offset, expectedType) in expected.enumerated() {
            let date = Calendar.jst.date(byAdding: .day, value: offset, to: cycleStart)!
            let schedules = calculator.calculateForPeriod(
                cell: cell, crew: crew,
                period: ExportPeriod(startDate: date, endDate: date)
            )
            #expect(schedules[0].shiftType == expectedType, "day \(offset)")
        }
    }

    @Test func withoutNightRoundPatternIsCorrect() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(rounds: Array(repeating: .withoutNight, count: 7), crewId: crew.id)

        let expected: [ShiftType] = [.off, .a, .b, .e2, .off, .off]
        for (offset, expectedType) in expected.enumerated() {
            let date = Calendar.jst.date(byAdding: .day, value: offset, to: cycleStart)!
            let schedules = calculator.calculateForPeriod(
                cell: cell, crew: crew,
                period: ExportPeriod(startDate: date, endDate: date)
            )
            #expect(schedules[0].shiftType == expectedType, "day \(offset)")
        }
    }

    @Test func withoutNightB4RoundPatternIsCorrect() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(rounds: Array(repeating: .withoutNightB4, count: 7), crewId: crew.id)

        let expected: [ShiftType] = [.off, .a, .b, .e2, .b4, .off]
        for (offset, expectedType) in expected.enumerated() {
            let date = Calendar.jst.date(byAdding: .day, value: offset, to: cycleStart)!
            let schedules = calculator.calculateForPeriod(
                cell: cell, crew: crew,
                period: ExportPeriod(startDate: date, endDate: date)
            )
            #expect(schedules[0].shiftType == expectedType, "day \(offset)")
        }
    }

    // MARK: - サイクル一巡

    @Test func after42DaysReturnsToSameShiftType() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(
            rounds: [.withNight, .withoutNight, .withoutNightB4, .withNight, .withoutNight, .withoutNightB4, .withNight],
            crewId: crew.id
        )

        let dateAfter42Days = Calendar.jst.date(byAdding: .day, value: 42, to: cycleStart)!

        let scheduleAtStart = calculator.calculateForPeriod(
            cell: cell, crew: crew, period: ExportPeriod(startDate: cycleStart, endDate: cycleStart)
        )[0]
        let scheduleAfter42Days = calculator.calculateForPeriod(
            cell: cell, crew: crew, period: ExportPeriod(startDate: dateAfter42Days, endDate: dateAfter42Days)
        )[0]

        #expect(scheduleAtStart.shiftType == scheduleAfter42Days.shiftType)
    }

    // MARK: - ラウンド境界

    @Test func roundSwitchesAtDay6Boundary() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        // ラウンド1: 夜勤なし（6日目=OFF）、ラウンド2: 夜勤あり（1日目=E1）
        let cell = makeCell(
            rounds: [.withoutNight, .withNight, .withNight, .withNight, .withNight, .withNight, .withNight],
            crewId: crew.id
        )

        let day5 = Calendar.jst.date(byAdding: .day, value: 5, to: cycleStart)! // ラウンド1の6日目
        let day6 = Calendar.jst.date(byAdding: .day, value: 6, to: cycleStart)! // ラウンド2の1日目

        let scheduleDay5 = calculator.calculateForPeriod(
            cell: cell, crew: crew, period: ExportPeriod(startDate: day5, endDate: day5)
        )[0]
        let scheduleDay6 = calculator.calculateForPeriod(
            cell: cell, crew: crew, period: ExportPeriod(startDate: day6, endDate: day6)
        )[0]

        #expect(scheduleDay5.shiftType == .off)   // withoutNightの6日目
        #expect(scheduleDay6.shiftType == .e1)    // withNightの1日目
    }

    // MARK: - サイクル開始日より前

    @Test func dateBeforeCycleStartIsCalculatedCorrectly() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        // 7ラウンド目（最後）を夜勤なしにしておき、開始日前日は7ラウンド目の6日目(OFF)になるはず
        let cell = makeCell(
            rounds: [.withNight, .withNight, .withNight, .withNight, .withNight, .withNight, .withoutNight],
            crewId: crew.id
        )

        let dayBeforeStart = Calendar.jst.date(byAdding: .day, value: -1, to: cycleStart)!

        let schedule = calculator.calculateForPeriod(
            cell: cell, crew: crew, period: ExportPeriod(startDate: dayBeforeStart, endDate: dayBeforeStart)
        )[0]

        // dayInCycle = -1 -> +42 = 41 -> roundIndex=6, dayInRound=5 -> withoutNightの6日目=OFF
        #expect(schedule.shiftType == .off)
    }

    // MARK: - calculateForMonth

    @Test func calculateForMonthReturnsCorrectDayCount() {
        let crew = makeCrew(cycleStartDate: jstDate(2026, 1, 1))
        let cell = makeCell(rounds: Array(repeating: .withNight, count: 7), crewId: crew.id)

        let januarySchedules = calculator.calculateForMonth(cell: cell, crew: crew, year: 2026, month: 1)
        #expect(januarySchedules.count == 31)

        let aprilSchedules = calculator.calculateForMonth(cell: cell, crew: crew, year: 2026, month: 4)
        #expect(aprilSchedules.count == 30)
    }

    @Test func calculateForMonthReturnsLeapYearFebruaryCount() {
        let crew = makeCrew(cycleStartDate: jstDate(2024, 1, 1))
        let cell = makeCell(rounds: Array(repeating: .withNight, count: 7), crewId: crew.id)

        // 2024年はうるう年 -> 2月は29日
        let schedules = calculator.calculateForMonth(cell: cell, crew: crew, year: 2024, month: 2)
        #expect(schedules.count == 29)
    }

    // MARK: - calculateForPeriod

    @Test func calculateForPeriodIncludesBothEndpoints() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(rounds: Array(repeating: .withNight, count: 7), crewId: crew.id)

        let start = jstDate(2026, 3, 1)
        let end = jstDate(2026, 3, 6)
        let schedules = calculator.calculateForPeriod(cell: cell, crew: crew, period: ExportPeriod(startDate: start, endDate: end))

        #expect(schedules.count == 6)
        #expect(schedules.first?.date == start)
        #expect(schedules.last?.date == end)
    }

    @Test func calculateForPeriodWithSameStartAndEndReturnsOne() {
        let cycleStart = jstDate(2026, 3, 1)
        let crew = makeCrew(cycleStartDate: cycleStart)
        let cell = makeCell(rounds: Array(repeating: .withNight, count: 7), crewId: crew.id)

        let date = jstDate(2026, 3, 15)
        let schedules = calculator.calculateForPeriod(cell: cell, crew: crew, period: ExportPeriod(startDate: date, endDate: date))

        #expect(schedules.count == 1)
    }
}
