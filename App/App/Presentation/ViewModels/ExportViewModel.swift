import Foundation
import SwiftUI

/// エクスポート画面のViewModel
/// 対応US: US-4.1, US-4.2, US-4.3, US-4.4
@MainActor
final class ExportViewModel: ObservableObject {
    // MARK: - Dependencies
    private let exportService: ExportApplicationServiceProtocol

    // MARK: - Context
    let cell: CellResponse

    // MARK: - Published State
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Share Sheet
    @Published var icsFileURL: URL?
    @Published var isShowingShareSheet: Bool = false

    // MARK: - Initialization
    init(cell: CellResponse, exportService: ExportApplicationServiceProtocol) {
        self.cell = cell
        self.exportService = exportService

        // デフォルト期間: 今日から3ヶ月後
        let today = Date()
        self.startDate = today
        self.endDate = Calendar.current.date(byAdding: .month, value: 3, to: today) ?? today
    }

    // MARK: - Actions

    /// ICSファイルを生成して共有
    func generateAndShareIcsFile() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let request = ExportScheduleRequest(
                cellId: cell.id,
                startDate: startDate,
                endDate: endDate
            )
            let icsData = try exportService.generateIcsFile(request: request)

            // 一時ファイルに保存
            let fileName = "schedule_\(cell.name).ics"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try icsData.write(to: tempURL)

            icsFileURL = tempURL
            isShowingShareSheet = true
        } catch {
            errorMessage = "ICSファイルの生成に失敗しました"
        }

        isLoading = false
    }

    /// Googleカレンダーにエクスポート
    func exportToGoogleCalendar() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        let request = ExportScheduleRequest(
            cellId: cell.id,
            startDate: startDate,
            endDate: endDate
        )

        exportService.exportToCalendar(request: request) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success:
                    self?.successMessage = "Googleカレンダーへのエクスポートが完了しました"
                case .failure(let error):
                    self?.errorMessage = "エクスポートに失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }

    /// カレンダーから予定を削除
    func deleteFromCalendar() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        let request = DeleteFromCalendarRequest(
            startDate: startDate,
            endDate: endDate,
            deleteAll: false
        )

        exportService.deleteFromCalendar(request: request) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success:
                    self?.successMessage = "カレンダーからの削除が完了しました"
                case .failure(let error):
                    self?.errorMessage = "削除に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }

    /// 期間のバリデーション
    var isValidPeriod: Bool {
        startDate <= endDate
    }
}
