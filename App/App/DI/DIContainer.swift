import Foundation
import SwiftData

/// 依存性注入コンテナ
/// Application ServiceとRepositoryを初期化・管理する
@MainActor
final class DIContainer: ObservableObject {
    // MARK: - Repositories
    let crewRepository: CrewRepositoryProtocol
    let cellRepository: CellRepositoryProtocol

    // MARK: - Application Services
    let crewService: CrewApplicationServiceProtocol
    let cellService: CellApplicationServiceProtocol
    let scheduleService: ScheduleApplicationServiceProtocol
    let exportService: ExportApplicationServiceProtocol

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        // Repositories
        let crewRepo = SwiftDataCrewRepository(modelContext: modelContext)
        let cellRepo = SwiftDataCellRepository(modelContext: modelContext)
        self.crewRepository = crewRepo
        self.cellRepository = cellRepo

        // Infrastructure Services
        let icsGenerator = IcsGenerator()

        // Application Services
        self.crewService = CrewApplicationService(
            crewRepository: crewRepo,
            cellRepository: cellRepo
        )

        self.cellService = CellApplicationService(
            cellRepository: cellRepo,
            crewRepository: crewRepo
        )

        self.scheduleService = ScheduleApplicationService(
            cellRepository: cellRepo,
            crewRepository: crewRepo
        )

        let googleCalendarService = GoogleCalendarService()

        self.exportService = ExportApplicationService(
            cellRepository: cellRepo,
            crewRepository: crewRepo,
            icsGenerator: icsGenerator,
            calendarExportService: googleCalendarService
        )
    }
}
