import Foundation

/// エクスポート機能のApplication Serviceプロトコル
/// UI層はこのプロトコルに依存し、具体的な実装には依存しない
protocol ExportApplicationServiceProtocol {
    /// ICSファイルを生成する
    func generateIcsFile(request: ExportScheduleRequest) throws -> Data

    /// 外部カレンダーにエクスポートする
    func exportToCalendar(request: ExportScheduleRequest, completion: @escaping (Result<Void, Error>) -> Void)

    /// 外部カレンダーから予定を削除する
    func deleteFromCalendar(request: DeleteFromCalendarRequest, completion: @escaping (Result<Void, Error>) -> Void)
}
