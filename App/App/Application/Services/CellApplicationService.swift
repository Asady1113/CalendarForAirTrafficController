import Foundation

class CellApplicationService: CellApplicationServiceProtocol {
    private let cellRepository: CellRepositoryProtocol

    init(cellRepository: CellRepositoryProtocol) {
        self.cellRepository = cellRepository
    }

    func listCellsByCrewId(crewId: UUID) -> [CellResponse] {
        let cells = cellRepository.findByCrewId(crewId)
        return cells.map { CellResponse(from: $0) }
    }

    func createCell(request: CreateCellRequest) throws -> CellResponse {
        let cycleConfiguration = CycleConfiguration(rounds: request.rounds)

        let cell = Cell(
            id: UUID(),
            name: request.name,
            crewId: request.crewId,
            cycleConfiguration: cycleConfiguration
        )
        cellRepository.save(cell)
        return CellResponse(from: cell)
    }

    func updateCell(request: UpdateCellRequest) throws -> CellResponse {
        guard let existingCell = cellRepository.findById(request.id) else {
            throw CellApplicationServiceError.cellNotFound
        }

        let cycleConfiguration = CycleConfiguration(rounds: request.rounds)

        let updatedCell = Cell(
            id: existingCell.id,
            name: request.name,
            crewId: existingCell.crewId,
            cycleConfiguration: cycleConfiguration
        )
        cellRepository.save(updatedCell)
        return CellResponse(from: updatedCell)
    }

    func deleteCell(cellId: UUID) {
        cellRepository.delete(cellId)
    }
}
