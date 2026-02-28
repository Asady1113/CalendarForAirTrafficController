import Foundation

protocol CrewRepositoryProtocol {
    func save(_ crew: Crew)
    func findById(_ id: UUID) -> Crew?
    func findAll() -> [Crew]
    func delete(_ id: UUID)
}