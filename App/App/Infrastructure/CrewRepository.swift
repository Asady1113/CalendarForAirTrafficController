import Foundation

class CrewRepository: CrewRepositoryProtocol {
    private var storage: [UUID: Crew] = [:]
    private let cellRepository: CellRepositoryProtocol

    init(cellRepository: CellRepositoryProtocol) {
        self.cellRepository = cellRepository
    }

    func save(_ crew: Crew) {
        storage[crew.id] = crew
    }

    func findById(_ id: UUID) -> Crew? {
        return storage[id]
    }

    func findAll() -> [Crew] {
        return Array(storage.values)
    }

    func delete(_ id: UUID) {
        storage.removeValue(forKey: id)
    }
}
