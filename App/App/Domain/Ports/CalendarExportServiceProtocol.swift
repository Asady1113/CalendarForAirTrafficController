import Foundation

protocol CalendarExportServiceProtocol {
    func exportEvents(_ schedules: [WorkSchedule], appName: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteEvents(from startDate: Date, to endDate: Date, appName: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAllEvents(appName: String, completion: @escaping (Result<Void, Error>) -> Void)
}
