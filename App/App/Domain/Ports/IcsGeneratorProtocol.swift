import Foundation

protocol IcsGeneratorProtocol {
    func generate(schedules: [WorkSchedule], appName: String) -> Data
}
