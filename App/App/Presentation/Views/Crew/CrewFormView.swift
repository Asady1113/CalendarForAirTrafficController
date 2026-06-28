import SwiftUI

/// クルー作成・編集フォーム
/// デザイン: AddCrew.png 参照
struct CrewFormView: View {
    @ObservedObject var viewModel: CrewListViewModel
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool {
        viewModel.editingCrew != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // フォームカード
                    VStack(alignment: .leading, spacing: 20) {
                        Text(isEditing ? "クルー編集" : "新規クルー登録")
                            .font(.title2)
                            .fontWeight(.bold)

                        // クルー名
                        VStack(alignment: .leading, spacing: 8) {
                            Text("クルー名")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextField("例: クルー1", text: $viewModel.formName)
                                .textFieldStyle(.roundedBorder)
                        }

                        // サイクル開始基準日
                        VStack(alignment: .leading, spacing: 8) {
                            Text("サイクル開始基準日")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text("この日付を「サイクル1日目」として計算を開始します。")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            DatePicker(
                                "",
                                selection: $viewModel.formCycleStartDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }

                        // 注記
                        VStack(alignment: .leading, spacing: 4) {
                            Text("※セル（班）の設定について")
                                .font(.caption)
                                .fontWeight(.medium)

                            Text("クルーを作成後、クルー詳細画面からセルを追加・編集できます。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // エラーメッセージ
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // ボタン
                    HStack(spacing: 16) {
                        Button("キャンセル") {
                            viewModel.cancelForm()
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)

                        Button("保存") {
                            viewModel.saveCrew()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "クルー編集" : "新規クルー登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.cancelForm()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}
