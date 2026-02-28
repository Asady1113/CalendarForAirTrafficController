import Foundation

struct UpdateCellRequest {
    let id: UUID
    let name: String
    let rounds: [RoundType]
}
