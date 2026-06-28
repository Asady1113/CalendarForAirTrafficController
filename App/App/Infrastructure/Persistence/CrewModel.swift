import Foundation
import SwiftData

/// SwiftData用クルーモデル
@Model
final class CrewModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var cycleStartDate: Date

    init(id: UUID = UUID(), name: String, cycleStartDate: Date) {
        self.id = id
        self.name = name
        self.cycleStartDate = cycleStartDate
    }

    /// DomainエンティティからSwiftDataモデルを作成
    convenience init(from crew: Crew) {
        self.init(
            id: crew.id,
            name: crew.name,
            cycleStartDate: crew.cycleStartDate
        )
    }

    /// SwiftDataモデルからDomainエンティティに変換
    func toDomain() -> Crew {
        Crew(
            id: id,
            name: name,
            cycleStartDate: cycleStartDate
        )
    }
}
