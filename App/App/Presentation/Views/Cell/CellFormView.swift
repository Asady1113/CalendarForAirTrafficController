import SwiftUI

/// セル作成・編集フォーム
/// デザイン: AddCell.png 参照
struct CellFormView: View {
    @ObservedObject var viewModel: CellListViewModel
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool {
        viewModel.editingCell != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // セル名入力
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("新規セル名", text: $viewModel.formName)
                                .font(.title3)
                                .fontWeight(.medium)

                            Button(action: {
                                viewModel.saveCell()
                                if viewModel.errorMessage == nil {
                                    dismiss()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.square")
                                    Text("完了")
                                }
                                .foregroundColor(AppColors.accent)
                            }
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)

                        // エラーメッセージ
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)

                    // サイクル構成
                    VStack(alignment: .leading, spacing: 12) {
                        Text("サイクル構成 (42日間)")
                            .font(.subheadline)
                            .foregroundColor(AppColors.accent)

                        ForEach(0..<viewModel.formRounds.count, id: \.self) { index in
                            RoundPickerRow(
                                roundNumber: index + 1,
                                selectedType: $viewModel.formRounds[index]
                            )
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "セル編集" : "新規セル")
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
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

// MARK: - Round Picker Row

struct RoundPickerRow: View {
    let roundNumber: Int
    @Binding var selectedType: RoundType

    var body: some View {
        HStack {
            Text("ラウンド\(roundNumber)")
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            Picker("", selection: $selectedType) {
                Text("夜勤あり").tag(RoundType.withNight)
                Text("夜勤なし").tag(RoundType.withoutNight)
                Text("夜勤なし（B4あり）").tag(RoundType.withoutNightB4)
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
