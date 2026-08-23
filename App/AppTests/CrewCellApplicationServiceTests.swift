import Testing
import Foundation
@testable import App

struct CrewCellApplicationServiceTests {
    @Test func deleteCrewCascadesToCells() {
        let cellRepo = InMemoryCellRepository()
        let crewRepo = InMemoryCrewRepository()
        let crewService = CrewApplicationService(crewRepository: crewRepo, cellRepository: cellRepo)
        let cellService = CellApplicationService(cellRepository: cellRepo)

        let crew = crewService.createCrew(request: CreateCrewRequest(name: "Crew", cycleStartDate: Date()))
        _ = try? cellService.createCell(request: CreateCellRequest(crewId: crew.id, name: "Cell1", rounds: Array(repeating: .withNight, count: 7)))
        _ = try? cellService.createCell(request: CreateCellRequest(crewId: crew.id, name: "Cell2", rounds: Array(repeating: .withNight, count: 7)))

        #expect(cellService.listCellsByCrewId(crewId: crew.id).count == 2)

        crewService.deleteCrew(crewId: crew.id)

        #expect(cellService.listCellsByCrewId(crewId: crew.id).isEmpty)
        #expect(crewRepo.findById(crew.id) == nil)
    }

    @Test func updateCellWithNonExistentIdThrowsCellNotFound() {
        let cellRepo = InMemoryCellRepository()
        let cellService = CellApplicationService(cellRepository: cellRepo)

        let request = UpdateCellRequest(id: UUID(), name: "Updated", rounds: Array(repeating: .withNight, count: 7))

        #expect(throws: CellApplicationServiceError.cellNotFound) {
            _ = try cellService.updateCell(request: request)
        }
    }

    @Test func listCellsByCrewIdReturnsOnlyThatCrewsCells() {
        let cellRepo = InMemoryCellRepository()
        let cellService = CellApplicationService(cellRepository: cellRepo)

        let crewAId = UUID()
        let crewBId = UUID()
        _ = try? cellService.createCell(request: CreateCellRequest(crewId: crewAId, name: "A-Cell", rounds: Array(repeating: .withNight, count: 7)))
        _ = try? cellService.createCell(request: CreateCellRequest(crewId: crewBId, name: "B-Cell", rounds: Array(repeating: .withNight, count: 7)))

        let crewACells = cellService.listCellsByCrewId(crewId: crewAId)

        #expect(crewACells.count == 1)
        #expect(crewACells.first?.name == "A-Cell")
    }
}
