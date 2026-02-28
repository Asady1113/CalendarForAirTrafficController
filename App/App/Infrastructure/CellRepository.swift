import Foundation

class CellRepository: CellRepositoryProtocol {
    private var storage: [UUID: Cell] = [:]

    func save(_ cell: Cell) {
        storage[cell.id] = cell
    }

    func findById(_ id: UUID) -> Cell? {
        return storage[id]
    }

    func findByCrewId(_ crewId: UUID) -> [Cell] {
        return storage.values.filter { $0.crewId == crewId }
    }

    func findAll() -> [Cell] {
        return Array(storage.values)
    }

    func delete(_ id: UUID) {
        storage.removeValue(forKey: id)
    }

    func deleteByCrewId(_ crewId: UUID) {
        let idsToDelete = storage.values
            .filter { $0.crewId == crewId }
            .map { $0.id }
        for id in idsToDelete {
            storage.removeValue(forKey: id)
        }
    }
}
