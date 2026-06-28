import Foundation
import SwiftUI

/// セル一覧画面のViewModel
/// 対応US: US-2.1, US-2.2, US-2.3, US-2.4, US-2.5, US-2.6
@MainActor
final class CellListViewModel: ObservableObject {
    // MARK: - Dependencies
    private let cellService: CellApplicationServiceProtocol

    // MARK: - Published State
    @Published var cells: [CellResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Context
    let crew: CrewResponse

    // MARK: - Form State
    @Published var isShowingForm: Bool = false
    @Published var editingCell: CellResponse?
    @Published var formName: String = ""
    @Published var formRounds: [RoundType] = Array(repeating: .withNight, count: 7)

    // MARK: - Delete Confirmation
    @Published var isShowingDeleteConfirmation: Bool = false
    @Published var cellToDelete: CellResponse?

    // MARK: - Navigation
    @Published var selectedCell: CellResponse?

    // MARK: - Initialization
    init(crew: CrewResponse, cellService: CellApplicationServiceProtocol) {
        self.crew = crew
        self.cellService = cellService
    }

    // MARK: - Actions

    /// セル一覧を読み込む
    func loadCells() {
        isLoading = true
        errorMessage = nil
        cells = cellService.listCellsByCrewId(crewId: crew.id)
        isLoading = false
    }

    /// 新規作成フォームを表示
    func showCreateForm() {
        editingCell = nil
        formName = ""
        formRounds = Array(repeating: .withNight, count: 7)
        isShowingForm = true
    }

    /// 編集フォームを表示
    func showEditForm(for cell: CellResponse) {
        editingCell = cell
        formName = cell.name
        formRounds = cell.rounds
        isShowingForm = true
    }

    /// フォームをキャンセル
    func cancelForm() {
        isShowingForm = false
        editingCell = nil
        formName = ""
        formRounds = Array(repeating: .withNight, count: 7)
    }

    /// セルを保存（新規作成または更新）
    func saveCell() {
        guard !formName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "セル名を入力してください"
            return
        }

        do {
            if let editing = editingCell {
                // 更新
                let request = UpdateCellRequest(
                    id: editing.id,
                    name: formName.trimmingCharacters(in: .whitespaces),
                    rounds: formRounds
                )
                _ = try cellService.updateCell(request: request)
            } else {
                // 新規作成
                let request = CreateCellRequest(
                    crewId: crew.id,
                    name: formName.trimmingCharacters(in: .whitespaces),
                    rounds: formRounds
                )
                _ = try cellService.createCell(request: request)
            }

            isShowingForm = false
            editingCell = nil
            errorMessage = nil
            loadCells()
        } catch CellApplicationServiceError.cellNotFound {
            errorMessage = "セルが見つかりませんでした"
        } catch {
            errorMessage = "保存に失敗しました"
        }
    }

    /// 削除確認を表示
    func showDeleteConfirmation(for cell: CellResponse) {
        cellToDelete = cell
        isShowingDeleteConfirmation = true
    }

    /// 削除をキャンセル
    func cancelDelete() {
        isShowingDeleteConfirmation = false
        cellToDelete = nil
    }

    /// セルを削除
    func deleteCell() {
        guard let cell = cellToDelete else { return }
        cellService.deleteCell(cellId: cell.id)
        isShowingDeleteConfirmation = false
        cellToDelete = nil
        loadCells()
    }

    /// セルを選択（カレンダー画面へ遷移）
    func selectCell(_ cell: CellResponse) {
        selectedCell = cell
    }

    /// ラウンド種別の短縮名を取得
    func roundShortName(_ roundType: RoundType) -> String {
        switch roundType {
        case .withNight: return "夜勤"
        case .withoutNight: return "夜勤なし"
        case .withoutNightB4: return "B4"
        }
    }
}
