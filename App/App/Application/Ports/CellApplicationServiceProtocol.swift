import Foundation

/// セル管理のApplication Serviceプロトコル
/// UI層はこのプロトコルに依存し、具体的な実装には依存しない
protocol CellApplicationServiceProtocol {
    /// 指定クルーに紐づくセル一覧を取得する
    func listCellsByCrewId(crewId: UUID) -> [CellResponse]

    /// 新しいセルを作成する
    func createCell(request: CreateCellRequest) throws -> CellResponse

    /// 既存のセルを更新する
    func updateCell(request: UpdateCellRequest) throws -> CellResponse

    /// セルを削除する
    func deleteCell(cellId: UUID)
}
