import Foundation

/// 勤務予定
/// 都度計算される日ごとの勤務予定
struct WorkSchedule {
    /// 日付
    let date: Date

    /// 勤務種別
    let shiftType: ShiftType

    init(date: Date, shiftType: ShiftType) {
        self.date = date
        self.shiftType = shiftType
    }
}