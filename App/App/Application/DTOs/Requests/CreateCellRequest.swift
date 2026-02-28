import Foundation

struct CreateCellRequest {
    let crewId: UUID
    let name: String
    let rounds: [RoundType]
}
