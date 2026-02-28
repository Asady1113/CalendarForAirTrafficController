import Foundation

/// 勤務予定表示のApplication Serviceプロトコル
/// UI層はこのプロトコルに依存し、具体的な実装には依存しない
protocol ScheduleApplicationServiceProtocol {
    /// 指定月の勤務予定を取得する
    func getMonthlySchedule(request: GetMonthlyScheduleRequest) throws -> MonthlyScheduleResponse
}
