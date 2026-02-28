import Foundation

class ScheduleApplicationService: ScheduleApplicationServiceProtocol {
    private let cellRepository: CellRepositoryProtocol
    private let crewRepository: CrewRepositoryProtocol
    private let scheduleCalculator: ScheduleCalculator

    init(
        cellRepository: CellRepositoryProtocol,
        crewRepository: CrewRepositoryProtocol,
        scheduleCalculator: ScheduleCalculator = ScheduleCalculator()
    ) {
        self.cellRepository = cellRepository
        self.crewRepository = crewRepository
        self.scheduleCalculator = scheduleCalculator
    }

    func getMonthlySchedule(request: GetMonthlyScheduleRequest) throws -> MonthlyScheduleResponse {
        guard let cell = cellRepository.findById(request.cellId) else {
            throw ScheduleApplicationServiceError.cellNotFound
        }

        guard let crew = crewRepository.findById(cell.crewId) else {
            throw ScheduleApplicationServiceError.crewNotFound
        }

        let schedules = scheduleCalculator.calculateForMonth(
            cell: cell,
            crew: crew,
            year: request.year,
            month: request.month
        )

        return MonthlyScheduleResponse(
            year: request.year,
            month: request.month,
            schedules: schedules
        )
    }
}
