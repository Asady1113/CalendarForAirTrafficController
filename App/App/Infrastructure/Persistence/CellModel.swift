import Foundation
import SwiftData

/// SwiftData用セルモデル
@Model
final class CellModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var crewId: UUID
    /// RoundTypeの文字列配列として保存
    var roundTypes: [String]

    init(id: UUID = UUID(), name: String, crewId: UUID, roundTypes: [String]) {
        self.id = id
        self.name = name
        self.crewId = crewId
        self.roundTypes = roundTypes
    }

    /// DomainエンティティからSwiftDataモデルを作成
    convenience init(from cell: Cell) {
        self.init(
            id: cell.id,
            name: cell.name,
            crewId: cell.crewId,
            roundTypes: cell.cycleConfiguration.rounds.map { $0.rawValue }
        )
    }

    /// SwiftDataモデルからDomainエンティティに変換
    func toDomain() -> Cell {
        let rounds = roundTypes.compactMap { RoundType(rawValue: $0) }
        let cycleConfiguration = CycleConfiguration(rounds: rounds)
        return Cell(
            id: id,
            name: name,
            crewId: crewId,
            cycleConfiguration: cycleConfiguration
        )
    }
}
