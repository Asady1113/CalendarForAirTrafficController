import Foundation
import SwiftData

/// SwiftDataを使用したクルーリポジトリ実装
final class SwiftDataCrewRepository: CrewRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ crew: Crew) {
        // 既存のモデルを検索
        let id = crew.id
        let descriptor = FetchDescriptor<CrewModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let existingModels = try modelContext.fetch(descriptor)
            if let existingModel = existingModels.first {
                // 更新
                existingModel.name = crew.name
                existingModel.cycleStartDate = crew.cycleStartDate
            } else {
                // 新規作成
                let model = CrewModel(from: crew)
                modelContext.insert(model)
            }
            try modelContext.save()
        } catch {
            print("Failed to save crew: \(error)")
        }
    }

    func findById(_ id: UUID) -> Crew? {
        let descriptor = FetchDescriptor<CrewModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let models = try modelContext.fetch(descriptor)
            return models.first?.toDomain()
        } catch {
            print("Failed to find crew by id: \(error)")
            return nil
        }
    }

    func findAll() -> [Crew] {
        let descriptor = FetchDescriptor<CrewModel>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let models = try modelContext.fetch(descriptor)
            return models.map { $0.toDomain() }
        } catch {
            print("Failed to find all crews: \(error)")
            return []
        }
    }

    func delete(_ id: UUID) {
        let descriptor = FetchDescriptor<CrewModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let models = try modelContext.fetch(descriptor)
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        } catch {
            print("Failed to delete crew: \(error)")
        }
    }
}
