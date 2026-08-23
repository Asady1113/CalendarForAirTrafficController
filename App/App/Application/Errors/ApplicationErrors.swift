import Foundation

enum CellApplicationServiceError: Error, Equatable {
    case cellNotFound
}

enum ScheduleApplicationServiceError: Error, Equatable {
    case cellNotFound
    case crewNotFound
}

enum ExportApplicationServiceError: Error, Equatable {
    case cellNotFound
    case crewNotFound
    case invalidPeriod
    case calendarServiceNotAvailable
}
