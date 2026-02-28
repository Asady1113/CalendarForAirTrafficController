import Foundation

struct MonthlyScheduleResponse {
    let year: Int
    let month: Int
    let schedules: [WorkScheduleResponse]

    init(year: Int, month: Int, schedules: [WorkSchedule]) {
        self.year = year
        self.month = month
        self.schedules = schedules.map { WorkScheduleResponse(from: $0) }
    }
}
