import Foundation

class ExportApplicationService: ExportApplicationServiceProtocol {
    private let cellRepository: CellRepositoryProtocol
    private let crewRepository: CrewRepositoryProtocol
    private let scheduleCalculator: ScheduleCalculator
    private let icsGenerator: IcsGeneratorProtocol
    private let calendarExportService: CalendarExportServiceProtocol?

    private let appName = "TODO"

    init(
        cellRepository: CellRepositoryProtocol,
        crewRepository: CrewRepositoryProtocol,
        scheduleCalculator: ScheduleCalculator = ScheduleCalculator(),
        icsGenerator: IcsGeneratorProtocol,
        calendarExportService: CalendarExportServiceProtocol? = nil
    ) {
        self.cellRepository = cellRepository
        self.crewRepository = crewRepository
        self.scheduleCalculator = scheduleCalculator
        self.icsGenerator = icsGenerator
        self.calendarExportService = calendarExportService
    }

    func generateIcsFile(request: ExportScheduleRequest) throws -> Data {
        let schedules = try calculateSchedules(for: request)
        return icsGenerator.generate(schedules: schedules, appName: appName)
    }

    func exportToCalendar(request: ExportScheduleRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let schedules = try calculateSchedules(for: request)
            guard let calendarService = calendarExportService else {
                completion(.failure(ExportApplicationServiceError.calendarServiceNotAvailable))
                return
            }
            calendarService.exportEvents(schedules, appName: appName, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    func deleteFromCalendar(request: DeleteFromCalendarRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let calendarService = calendarExportService else {
            completion(.failure(ExportApplicationServiceError.calendarServiceNotAvailable))
            return
        }

        // アプリ名が接頭語としてついている予定のみを削除
        if request.deleteAll {
            calendarService.deleteAllEvents(appName: appName, completion: completion)
        } else {
            calendarService.deleteEvents(from: request.startDate, to: request.endDate, appName: appName, completion: completion)
        }
    }

    private func calculateSchedules(for request: ExportScheduleRequest) throws -> [WorkSchedule] {
        guard let cell = cellRepository.findById(request.cellId) else {
            throw ExportApplicationServiceError.cellNotFound
        }

        guard let crew = crewRepository.findById(cell.crewId) else {
            throw ExportApplicationServiceError.crewNotFound
        }

        let period = ExportPeriod(startDate: request.startDate, endDate: request.endDate)
        guard period.isValid else {
            throw ExportApplicationServiceError.invalidPeriod
        }

        return scheduleCalculator.calculateForPeriod(cell: cell, crew: crew, period: period)
    }
}
