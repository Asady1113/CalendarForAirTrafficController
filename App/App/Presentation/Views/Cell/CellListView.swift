import SwiftUI

/// セル一覧画面
/// デザイン: CellList.png 参照
struct CellListView: View {
    @StateObject private var viewModel: CellListViewModel
    @EnvironmentObject private var diContainer: DIContainer

    init(crew: CrewResponse, diContainer: DIContainer) {
        _viewModel = StateObject(wrappedValue: CellListViewModel(
            crew: crew,
            cellService: diContainer.cellService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ヘッダー説明
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.secondary)
                        Text("\(viewModel.crew.name) のセル構成")
                            .font(.headline)
                    }

                    Text("このクルーに所属するセル（班）を登録・設定します。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // セル一覧
                if viewModel.cells.isEmpty {
                    emptyStateView
                } else {
                    cellList
                }

                // 追加ボタン
                addButton
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.crew.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadCells()
        }
        .sheet(isPresented: $viewModel.isShowingForm) {
            CellFormView(viewModel: viewModel)
        }
        .alert("セルを削除", isPresented: $viewModel.isShowingDeleteConfirmation) {
            Button("キャンセル", role: .cancel) {
                viewModel.cancelDelete()
            }
            Button("削除", role: .destructive) {
                viewModel.deleteCell()
            }
        } message: {
            if let cell = viewModel.cellToDelete {
                Text("\(cell.name)を削除しますか？")
            }
        }
        .navigationDestination(item: $viewModel.selectedCell) { cell in
            ScheduleView(crew: viewModel.crew, cell: cell, diContainer: diContainer)
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("セルが登録されていません")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var cellList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.cells, id: \.id) { cell in
                CellCardView(
                    cell: cell,
                    onCalendar: { viewModel.selectCell(cell) },
                    onEdit: { viewModel.showEditForm(for: cell) },
                    onDelete: { viewModel.showDeleteConfirmation(for: cell) },
                    roundShortName: viewModel.roundShortName
                )
            }
        }
        .padding(.horizontal)
    }

    private var addButton: some View {
        Button(action: { viewModel.showCreateForm() }) {
            HStack {
                Image(systemName: "plus")
                Text("新しいセルを追加")
            }
            .foregroundColor(AppColors.accent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8]))
                    .foregroundColor(AppColors.border)
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Cell Card

struct CellCardView: View {
    let cell: CellResponse
    let onCalendar: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let roundShortName: (RoundType) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Text(cell.name)
                    .font(.headline)

                Spacer()

                Button(action: onCalendar) {
                    HStack(spacing: 4) {
                        Text("カレンダー")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }

                Button(action: onEdit) {
                    Text("編集")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.secondary)
                }
            }

            // ラウンド表示
            HStack(spacing: 4) {
                ForEach(Array(cell.rounds.enumerated()), id: \.offset) { index, round in
                    VStack(spacing: 2) {
                        Text("R\(index + 1)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(roundShortName(round))
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CellResponse Extension for Navigation

extension CellResponse: Hashable {
    static func == (lhs: CellResponse, rhs: CellResponse) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
