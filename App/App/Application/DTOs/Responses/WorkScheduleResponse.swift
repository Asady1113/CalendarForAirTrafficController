import Foundation

struct WorkScheduleResponse {
    let date: Date
    let shiftType: ShiftType

    init(from workSchedule: WorkSchedule) {
        self.date = workSchedule.date
        self.shiftType = workSchedule.shiftType
    }
}
