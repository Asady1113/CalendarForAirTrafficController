import Foundation

protocol CellRepositoryProtocol {
    func save(_ cell: Cell)
    func findById(_ id: UUID) -> Cell?
    func findByCrewId(_ crewId: UUID) -> [Cell]
    func findAll() -> [Cell]
    func delete(_ id: UUID)
    func deleteByCrewId(_ crewId: UUID)
}