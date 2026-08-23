import Testing
import Foundation
@testable import App

struct ExportApplicationServiceTests {
    private func makeService(
        cellRepository: InMemoryCellRepository = InMemoryCellRepository(),
        crewRepository: InMemoryCrewRepository = InMemoryCrewRepository(),
        calendarExportService: CalendarExportServiceProtocol? = nil
    ) -> ExportApplicationService {
        ExportApplicationService(
            cellRepository: cellRepository,
            crewRepository: crewRepository,
            icsGenerator: IcsGenerator(),
            calendarExportService: calendarExportService
        )
    }

    @Test func nonExistentCellIdThrowsCellNotFound() {
        let service = makeService()
        let request = ExportScheduleRequest(cellId: UUID(), startDate: Date(), endDate: Date())

        #expect(throws: ExportApplicationServiceError.cellNotFound) {
            _ = try service.generateIcsFile(request: request)
        }
    }

    @Test func cellExistsButCrewMissingThrowsCrewNotFound() {
        let cellRepo = InMemoryCellRepository()
        let crewRepo = InMemoryCrewRepository()
        // crewIdに対応するCrewをcrewRepoに保存しない
        let cell = Cell(name: "Cell", crewId: UUID(), cycleConfiguration: CycleConfiguration(rounds: Array(repeating: .withNight, count: 7)))
        cellRepo.save(cell)

        let service = makeService(cellRepository: cellRepo, crewRepository: crewRepo)
        let request = ExportScheduleRequest(cellId: cell.id, startDate: Date(), endDate: Date())

        #expect(throws: ExportApplicationServiceError.crewNotFound) {
            _ = try service.generateIcsFile(request: request)
        }
    }

    @Test func startDateAfterEndDateThrowsInvalidPeriod() {
        let cellRepo = InMemoryCellRepository()
        let crewRepo = InMemoryCrewRepository()
        let crew = Crew(name: "Crew", cycleStartDate: Date())
        crewRepo.save(crew)
        let cell = Cell(name: "Cell", crewId: crew.id, cycleConfiguration: CycleConfiguration(rounds: Array(repeating: .withNight, count: 7)))
        cellRepo.save(cell)

        let service = makeService(cellRepository: cellRepo, crewRepository: crewRepo)
        let end = Date()
        let start = end.addingTimeInterval(60 * 60 * 24)
        let request = ExportScheduleRequest(cellId: cell.id, startDate: start, endDate: end)

        #expect(throws: ExportApplicationServiceError.invalidPeriod) {
            _ = try service.generateIcsFile(request: request)
        }
    }

    @Test func nilCalendarExportServiceReturnsCalendarServiceNotAvailable() {
        let service = makeService(calendarExportService: nil)
        let request = DeleteFromCalendarRequest(startDate: Date(), endDate: Date(), deleteAll: false)

        var capturedResult: Result<Void, Error>?
        service.deleteFromCalendar(request: request) { result in
            capturedResult = result
        }

        switch capturedResult {
        case .failure(let error as ExportApplicationServiceError):
            #expect(error == .calendarServiceNotAvailable)
        default:
            Issue.record("calendarServiceNotAvailable が返されるべき")
        }
    }

    @Test func deleteAllTrueCallsDeleteAllEvents() {
        let spy = SpyCalendarExportService()
        let service = makeService(calendarExportService: spy)
        let request = DeleteFromCalendarRequest(startDate: Date(), endDate: Date(), deleteAll: true)

        service.deleteFromCalendar(request: request) { _ in }

        #expect(spy.deleteAllEventsCalled == true)
        #expect(spy.deleteEventsCalled == false)
    }

    @Test func deleteAllFalseCallsDeleteEventsWithCorrectPeriod() {
        let spy = SpyCalendarExportService()
        let service = makeService(calendarExportService: spy)
        let start = Date()
        let end = start.addingTimeInterval(60 * 60 * 24 * 5)
        let request = DeleteFromCalendarRequest(startDate: start, endDate: end, deleteAll: false)

        service.deleteFromCalendar(request: request) { _ in }

        #expect(spy.deleteEventsCalled == true)
        #expect(spy.deleteAllEventsCalled == false)
        #expect(spy.deleteEventsStart == start)
        #expect(spy.deleteEventsEnd == end)
    }
}
