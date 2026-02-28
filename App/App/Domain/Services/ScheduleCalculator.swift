import Foundation

class ScheduleCalculator {
    func calculateForMonth(cell: Cell, crew: Crew, year: Int, month: Int) -> [WorkSchedule] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }

        var schedules: [WorkSchedule] = []
        for day in range {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let shiftType = calculateShiftType(for: date, cell: cell, crew: crew, calendar: calendar)
                schedules.append(WorkSchedule(date: date, shiftType: shiftType))
            }
        }
        return schedules
    }

    func calculateForPeriod(cell: Cell, crew: Crew, period: ExportPeriod) -> [WorkSchedule] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        var schedules: [WorkSchedule] = []
        var currentDate = period.startDate

        while currentDate <= period.endDate {
            let shiftType = calculateShiftType(for: currentDate, cell: cell, crew: crew, calendar: calendar)
            schedules.append(WorkSchedule(date: currentDate, shiftType: shiftType))

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        return schedules
    }

    private func calculateShiftType(for date: Date, cell: Cell, crew: Crew, calendar: Calendar) -> ShiftType {
        // 1. 対象日とサイクル開始日の差分を計算
        let daysDiff = calendar.dateComponents([.day], from: crew.cycleStartDate, to: date).day ?? 0

        // 2. 差分を42で割った余りでサイクル内の日目を特定
        var dayInCycle = daysDiff % 42
        if dayInCycle < 0 {
            dayInCycle += 42
        }

        // 3. 日目を6で割ってラウンド番号と日番号を特定
        let roundIndex = dayInCycle / 6
        let dayInRound = dayInCycle % 6

        // 4. CycleConfigurationから該当ラウンドの種別を取得
        let roundType = cell.cycleConfiguration.rounds[roundIndex]

        // 5. RoundTypeから該当日の勤務種別を取得
        return roundType.shiftPattern[dayInRound]
    }
}
