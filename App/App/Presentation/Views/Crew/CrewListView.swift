import SwiftUI

/// クルー一覧画面
/// デザイン: CrewList.png 参照
struct CrewListView: View {
    @StateObject private var viewModel: CrewListViewModel
    @EnvironmentObject private var diContainer: DIContainer

    init(diContainer: DIContainer) {
        _viewModel = StateObject(wrappedValue: CrewListViewModel(
            crewService: diContainer.crewService,
            cellService: diContainer.cellService
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // ウェルカムメッセージ
                    welcomeCard

                    // セクションタイトル
                    HStack {
                        Text("登録済みクルー")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // クルー一覧
                    if viewModel.crews.isEmpty {
                        emptyStateView
                    } else {
                        crewList
                    }

                    // 追加ボタン
                    addButton
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("マイ スケジュール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.loadCrews()
            }
            .sheet(isPresented: $viewModel.isShowingForm) {
                CrewFormView(viewModel: viewModel)
            }
            .alert("クルーを削除", isPresented: $viewModel.isShowingDeleteConfirmation) {
                Button("キャンセル", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("削除", role: .destructive) {
                    viewModel.deleteCrew()
                }
            } message: {
                if let crew = viewModel.crewToDelete {
                    Text("\(crew.name)を削除しますか？\n紐づくセルも全て削除されます。")
                }
            }
            .navigationDestination(item: $viewModel.selectedCrew) { crew in
                CellListView(crew: crew, diContainer: diContainer)
            }
        }
    }

    // MARK: - Subviews

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ようこそ、管制官のみなさま。")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.accent)

            Text("勤務予定を管理するクルーを選択してください。クルーを選択すると、所属するセル（班）の構成設定やカレンダー表示ができます。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("クルーが登録されていません")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var crewList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.crews, id: \.id) { crew in
                CrewCardView(
                    crew: crew,
                    cellCount: viewModel.cellCount(for: crew),
                    onTap: { viewModel.selectCrew(crew) },
                    onEdit: { viewModel.showEditForm(for: crew) },
                    onDelete: { viewModel.showDeleteConfirmation(for: crew) }
                )
            }
        }
        .padding(.horizontal)
    }

    private var addButton: some View {
        Button(action: { viewModel.showCreateForm() }) {
            HStack {
                Image(systemName: "person.badge.plus")
                Text("クルーを追加")
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

// MARK: - Crew Card

struct CrewCardView: View {
    let crew: CrewResponse
    let cellCount: Int
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(crew.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        Text("\(cellCount) セル登録済み")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)

                        Text("開始日: \(dateFormatter.string(from: crew.cycleStartDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // アクションボタン
                HStack(spacing: 16) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                    }

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - CrewResponse Extension for Navigation

extension CrewResponse: Hashable {
    static func == (lhs: CrewResponse, rhs: CrewResponse) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
