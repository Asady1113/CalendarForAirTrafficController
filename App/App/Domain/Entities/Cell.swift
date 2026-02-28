import Foundation

/// セル
/// クルーに紐づく勤務パターン単位
final class Cell {
    /// 一意識別子
    let id: UUID

    /// セル名
    var name: String

    /// 所属クルーへの参照
    let crewId: UUID

    /// サイクル構成
    var cycleConfiguration: CycleConfiguration

    init(id: UUID = UUID(), name: String, crewId: UUID, cycleConfiguration: CycleConfiguration) {
        self.id = id
        self.name = name
        self.crewId = crewId
        self.cycleConfiguration = cycleConfiguration
    }
}