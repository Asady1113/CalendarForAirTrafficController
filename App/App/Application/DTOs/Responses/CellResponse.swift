import Foundation

struct CellResponse {
    let id: UUID
    let name: String
    let crewId: UUID
    let rounds: [RoundType]

    init(from cell: Cell) {
        self.id = cell.id
        self.name = cell.name
        self.crewId = cell.crewId
        self.rounds = cell.cycleConfiguration.rounds
    }
}
