import Foundation
import SwiftData

/// SwiftDataを使用したセルリポジトリ実装
final class SwiftDataCellRepository: CellRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ cell: Cell) {
        // 既存のモデルを検索
        let id = cell.id
        let descriptor = FetchDescriptor<CellModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let existingModels = try modelContext.fetch(descriptor)
            if let existingModel = existingModels.first {
                // 更新
                existingModel.name = cell.name
                existingModel.roundTypes = cell.cycleConfiguration.rounds.map { $0.rawValue }
            } else {
                // 新規作成
                let model = CellModel(from: cell)
                modelContext.insert(model)
            }
            try modelContext.save()
        } catch {
            print("Failed to save cell: \(error)")
        }
    }

    func findById(_ id: UUID) -> Cell? {
        let descriptor = FetchDescriptor<CellModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let models = try modelContext.fetch(descriptor)
            return models.first?.toDomain()
        } catch {
            print("Failed to find cell by id: \(error)")
            return nil
        }
    }

    func findByCrewId(_ crewId: UUID) -> [Cell] {
        let descriptor = FetchDescriptor<CellModel>(
            predicate: #Predicate { $0.crewId == crewId },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let models = try modelContext.fetch(descriptor)
            return models.map { $0.toDomain() }
        } catch {
            print("Failed to find cells by crew id: \(error)")
            return []
        }
    }

    func findAll() -> [Cell] {
        let descriptor = FetchDescriptor<CellModel>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let models = try modelContext.fetch(descriptor)
            return models.map { $0.toDomain() }
        } catch {
            print("Failed to find all cells: \(error)")
            return []
        }
    }

    func delete(_ id: UUID) {
        let descriptor = FetchDescriptor<CellModel>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            let models = try modelContext.fetch(descriptor)
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        } catch {
            print("Failed to delete cell: \(error)")
        }
    }

    func deleteByCrewId(_ crewId: UUID) {
        let descriptor = FetchDescriptor<CellModel>(
            predicate: #Predicate { $0.crewId == crewId }
        )

        do {
            let models = try modelContext.fetch(descriptor)
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        } catch {
            print("Failed to delete cells by crew id: \(error)")
        }
    }
}
