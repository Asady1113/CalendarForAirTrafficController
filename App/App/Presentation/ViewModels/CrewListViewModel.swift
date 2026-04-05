import Foundation
import SwiftUI

/// クルー一覧画面のViewModel
/// 対応US: US-1.1, US-1.2, US-1.3, US-1.4, US-1.5
@MainActor
final class CrewListViewModel: ObservableObject {
    // MARK: - Dependencies
    private let crewService: CrewApplicationServiceProtocol
    private let cellService: CellApplicationServiceProtocol

    // MARK: - Published State
    @Published var crews: [CrewResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Form State
    @Published var isShowingForm: Bool = false
    @Published var editingCrew: CrewResponse?
    @Published var formName: String = ""
    @Published var formCycleStartDate: Date = Date()

    // MARK: - Delete Confirmation
    @Published var isShowingDeleteConfirmation: Bool = false
    @Published var crewToDelete: CrewResponse?

    // MARK: - Navigation
    @Published var selectedCrew: CrewResponse?

    // MARK: - Initialization
    init(crewService: CrewApplicationServiceProtocol, cellService: CellApplicationServiceProtocol) {
        self.crewService = crewService
        self.cellService = cellService
    }

    // MARK: - Actions

    /// クルー一覧を読み込む
    func loadCrews() {
        isLoading = true
        errorMessage = nil
        crews = crewService.listCrews()
        isLoading = false
    }

    /// 指定クルーのセル数を取得
    func cellCount(for crew: CrewResponse) -> Int {
        cellService.listCellsByCrewId(crewId: crew.id).count
    }

    /// 新規作成フォームを表示
    func showCreateForm() {
        editingCrew = nil
        formName = ""
        formCycleStartDate = Date()
        isShowingForm = true
    }

    /// 編集フォームを表示
    func showEditForm(for crew: CrewResponse) {
        editingCrew = crew
        formName = crew.name
        formCycleStartDate = crew.cycleStartDate
        isShowingForm = true
    }

    /// フォームをキャンセル
    func cancelForm() {
        isShowingForm = false
        editingCrew = nil
        formName = ""
        formCycleStartDate = Date()
    }

    /// クルーを保存（新規作成または更新）
    func saveCrew() {
        guard !formName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "クルー名を入力してください"
            return
        }

        if let editing = editingCrew {
            // 更新
            let request = UpdateCrewRequest(
                id: editing.id,
                name: formName.trimmingCharacters(in: .whitespaces),
                cycleStartDate: formCycleStartDate
            )
            _ = crewService.updateCrew(request: request)
        } else {
            // 新規作成
            let request = CreateCrewRequest(
                name: formName.trimmingCharacters(in: .whitespaces),
                cycleStartDate: formCycleStartDate
            )
            _ = crewService.createCrew(request: request)
        }

        isShowingForm = false
        editingCrew = nil
        loadCrews()
    }

    /// 削除確認を表示
    func showDeleteConfirmation(for crew: CrewResponse) {
        crewToDelete = crew
        isShowingDeleteConfirmation = true
    }

    /// 削除をキャンセル
    func cancelDelete() {
        isShowingDeleteConfirmation = false
        crewToDelete = nil
    }

    /// クルーを削除
    func deleteCrew() {
        guard let crew = crewToDelete else { return }
        crewService.deleteCrew(crewId: crew.id)
        isShowingDeleteConfirmation = false
        crewToDelete = nil
        loadCrews()
    }

    /// クルーを選択（セル管理画面へ遷移）
    func selectCrew(_ crew: CrewResponse) {
        selectedCrew = crew
    }
}
