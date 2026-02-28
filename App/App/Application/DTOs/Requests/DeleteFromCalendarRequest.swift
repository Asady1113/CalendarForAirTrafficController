import Foundation

struct DeleteFromCalendarRequest {
    let startDate: Date
    let endDate: Date
    let deleteAll: Bool

    init(startDate: Date, endDate: Date, deleteAll: Bool = false) {
        self.startDate = startDate
        self.endDate = endDate
        self.deleteAll = deleteAll
    }
}
