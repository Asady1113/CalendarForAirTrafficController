import Foundation

enum CrewApplicationServiceError: Error {
    case crewNotFound
}

enum CellApplicationServiceError: Error {
    case invalidCycleConfiguration
    case cellNotFound
    case crewNotFound
}

enum ScheduleApplicationServiceError: Error {
    case cellNotFound
    case crewNotFound
}

enum ExportApplicationServiceError: Error {
    case cellNotFound
    case crewNotFound
    case invalidPeriod
    case calendarServiceNotAvailable
}
