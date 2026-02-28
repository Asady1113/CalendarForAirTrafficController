import Foundation

struct CrewResponse {
    let id: UUID
    let name: String
    let cycleStartDate: Date

    init(from crew: Crew) {
        self.id = crew.id
        self.name = crew.name
        self.cycleStartDate = crew.cycleStartDate
    }
}
