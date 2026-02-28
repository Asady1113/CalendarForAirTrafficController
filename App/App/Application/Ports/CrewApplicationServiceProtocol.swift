import Foundation

/// クルー管理のApplication Serviceプロトコル
/// UI層はこのプロトコルに依存し、具体的な実装には依存しない
protocol CrewApplicationServiceProtocol {
    /// 全クルー一覧を取得する
    func listCrews() -> [CrewResponse]

    /// 新しいクルーを作成する
    func createCrew(request: CreateCrewRequest) -> CrewResponse

    /// 既存のクルーを更新する
    func updateCrew(request: UpdateCrewRequest) -> CrewResponse?

    /// クルーを削除する（紐づくセルも連鎖削除）
    func deleteCrew(crewId: UUID)
}
