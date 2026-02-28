import Foundation

/// クルー
/// 勤務サイクルの基準となるグループ
final class Crew {
    /// 一意識別子
    let id: UUID

    /// クルー名
    var name: String

    /// サイクル開始日（42日サイクルの起算日）
    var cycleStartDate: Date

    init(id: UUID = UUID(), name: String, cycleStartDate: Date) {
        self.id = id
        self.name = name
        self.cycleStartDate = cycleStartDate
    }
}