import SwiftUI

/// カレンダー表示画面
/// デザイン: Calendar.png, Export.png 参照
struct ScheduleView: View {
    @StateObject private var viewModel: ScheduleViewModel
    @StateObject private var exportViewModel: ExportViewModel
    @EnvironmentObject private var diContainer: DIContainer

    init(crew: CrewResponse, cell: CellResponse, diContainer: DIContainer) {
        _viewModel = StateObject(wrappedValue: ScheduleViewModel(
            crew: crew,
            cell: cell,
            scheduleService: diContainer.scheduleService
        ))
        _exportViewModel = StateObject(wrappedValue: ExportViewModel(
            cell: cell,
            exportService: diContainer.exportService
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // カレンダー
                calendarCard

                // エクスポート設定
                exportCard
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("\(viewModel.crew.name) - \(viewModel.cell.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadSchedule()
        }
        .sheet(isPresented: $exportViewModel.isShowingShareSheet) {
            if let url = exportViewModel.icsFileURL {
                ShareSheet(items: [url])
            }
        }
    }

    // MARK: - Calendar Card

    private var calendarCard: some View {
        VStack(spacing: 12) {
            // 月切り替えヘッダー
            HStack {
                Button(action: { viewModel.goToPreviousMonth() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(viewModel.monthDisplayString)
                    .font(.headline)

                Spacer()

                Button(action: { viewModel.goToNextMonth() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // 曜日ヘッダー
            HStack(spacing: 0) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(dayHeaderColor(for: day))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)

            // カレンダーグリッド
            let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.calendarDays) { day in
                    CalendarDayCell(
                        day: day,
                        isToday: day.date.map { viewModel.isToday($0) } ?? false,
                        isSunday: day.date.map { viewModel.isSunday($0) } ?? false,
                        isSaturday: day.date.map { viewModel.isSaturday($0) } ?? false
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Export Card

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("エクスポート設定")
                .font(.headline)

            Text("指定した期間のスケジュールをエクスポートまたは同期します。")
                .font(.caption)
                .foregroundColor(.secondary)

            // 期間選択
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("開始日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $exportViewModel.startDate, displayedComponents: .date)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("終了日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $exportViewModel.endDate, displayedComponents: .date)
                        .labelsHidden()
                }
            }

            // エラー/成功メッセージ
            if let error = exportViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            if let success = exportViewModel.successMessage {
                Text(success)
                    .font(.caption)
                    .foregroundColor(.green)
            }

            // Googleカレンダー同期ボタン
            Button(action: { exportViewModel.exportToGoogleCalendar() }) {
                HStack {
                    if exportViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                        Text("エクスポート中...")
                    } else {
                        Image(systemName: "g.circle.fill")
                        Text("Googleカレンダーに同期")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(exportViewModel.isLoading ? Color.gray : AppColors.accent)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(exportViewModel.isLoading || !exportViewModel.isValidPeriod)

            // 全期間一括削除トグル
            VStack(alignment: .leading, spacing: 4) {
                Toggle("全期間の予定を一括削除", isOn: $exportViewModel.isDeletingAllPeriod)
                Text("アプリが作成した予定（AeroRota_ で始まる予定）のみが対象です")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Googleカレンダーから削除ボタン
            Button(action: { exportViewModel.requestDelete() }) {
                HStack {
                    if exportViewModel.isDeleting {
                        ProgressView()
                            .tint(.red)
                        Text("削除中...")
                    } else {
                        Image(systemName: "trash")
                        Text(exportViewModel.isDeletingAllPeriod ? "Googleカレンダーから全期間削除" : "Googleカレンダーから削除")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
            .disabled(exportViewModel.isLoading || exportViewModel.isDeleting || (!exportViewModel.isDeletingAllPeriod && !exportViewModel.isValidPeriod))
            .alert("予定を削除しますか？", isPresented: $exportViewModel.isShowingDeleteConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) {
                    exportViewModel.deleteFromCalendar()
                }
            } message: {
                Text(exportViewModel.isDeletingAllPeriod
                     ? "Googleカレンダーから全期間の予定（AeroRota_ で始まる予定）を削除します。この操作は取り消せません。"
                     : "指定した期間のGoogleカレンダーの予定を削除します。この操作は取り消せません。")
            }

            // ICSファイル保存ボタン
            Button(action: { exportViewModel.generateAndShareIcsFile() }) {
                HStack {
                    Image(systemName: "arrow.down.circle")
                    Text("ICSファイル (.ics) を保存")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            .disabled(exportViewModel.isLoading || !exportViewModel.isValidPeriod)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Helper

    private func dayHeaderColor(for day: String) -> Color {
        switch day {
        case "日": return AppColors.sunday
        case "土": return AppColors.saturday
        default: return .primary
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let day: CalendarDay
    let isToday: Bool
    let isSunday: Bool
    let isSaturday: Bool

    var body: some View {
        if let dayNumber = day.dayNumber {
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(.caption2)
                    .foregroundColor(dayNumberColor)

                if let schedule = day.schedule {
                    Text(schedule.shiftType.shortName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(schedule.shiftType.textColor)

                    if !schedule.shiftType.subLabel.isEmpty {
                        Text(schedule.shiftType.subLabel)
                            .font(.system(size: 8))
                            .foregroundColor(schedule.shiftType.textColor.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(cellBackgroundColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isToday ? AppColors.accent : Color.clear, lineWidth: 2)
            )
        } else {
            Color.clear
                .frame(height: 60)
        }
    }

    private var dayNumberColor: Color {
        if isSunday { return AppColors.sunday }
        if isSaturday { return AppColors.saturday }
        return .primary
    }

    private var cellBackgroundColor: Color {
        if let schedule = day.schedule {
            return schedule.shiftType.backgroundColor
        }
        return Color(.systemGray6)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
