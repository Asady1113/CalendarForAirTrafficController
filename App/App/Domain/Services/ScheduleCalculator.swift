import Foundation

class ScheduleCalculator {
    func calculateForMonth(cell: Cell, crew: Crew, year: Int, month: Int) -> [WorkSchedule] {
        let calendar = Calendar.jst

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
        let calendar = Calendar.jst

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
        // 1. 対象日とサイクル開始日の差分を計算（時刻を除いた日付のみで比較）
        let cycleStart = calendar.startOfDay(for: crew.cycleStartDate)
        let daysDiff = calendar.dateComponents([.day], from: cycleStart, to: date).day ?? 0

        // 2. 差分を42で割った余りでサイクル内の日目を特定
        var dayInCycle = daysDiff % 42
        if dayInCycle < 0 {
            dayInCycle += 42
        }

        // 3. 日目を6で割ってラウンド番号と日番号を特定
        let roundIndex = dayInCycle / 6
        let dayInRound = dayInCycle % 6

        // 4. CycleConfigurationから該当ラウンドの種別を取得
        guard cell.cycleConfiguration.rounds.indices.contains(roundIndex) else { return .off }
        let roundType = cell.cycleConfiguration.rounds[roundIndex]

        // 5. RoundTypeから該当日の勤務種別を取得
        guard roundType.shiftPattern.indices.contains(dayInRound) else { return .off }
        return roundType.shiftPattern[dayInRound]
    }
}
