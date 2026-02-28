import Foundation

class CrewApplicationService: CrewApplicationServiceProtocol {
    private let crewRepository: CrewRepositoryProtocol
    private let cellRepository: CellRepositoryProtocol

    init(crewRepository: CrewRepositoryProtocol, cellRepository: CellRepositoryProtocol) {
        self.crewRepository = crewRepository
        self.cellRepository = cellRepository
    }

    func listCrews() -> [CrewResponse] {
        let crews = crewRepository.findAll()
        return crews.map { CrewResponse(from: $0) }
    }

    func createCrew(request: CreateCrewRequest) -> CrewResponse {
        let crew = Crew(
            id: UUID(),
            name: request.name,
            cycleStartDate: request.cycleStartDate
        )
        crewRepository.save(crew)
        return CrewResponse(from: crew)
    }

    func updateCrew(request: UpdateCrewRequest) -> CrewResponse? {
        guard let existingCrew = crewRepository.findById(request.id) else {
            return nil
        }

        let updatedCrew = Crew(
            id: existingCrew.id,
            name: request.name,
            cycleStartDate: request.cycleStartDate
        )
        crewRepository.save(updatedCrew)
        return CrewResponse(from: updatedCrew)
    }

    func deleteCrew(crewId: UUID) {
        // ビジネスルール: クルー削除時に紐づくセルも削除する（連鎖削除）
        cellRepository.deleteByCrewId(crewId)
        crewRepository.delete(crewId)
    }
}
