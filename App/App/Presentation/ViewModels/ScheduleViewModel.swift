import Foundation
import SwiftUI

/// カレンダー表示画面のViewModel
/// 対応US: US-3.1, US-3.2, US-3.3, US-3.4, US-3.5
@MainActor
final class ScheduleViewModel: ObservableObject {
    // MARK: - Dependencies
    private let scheduleService: ScheduleApplicationServiceProtocol

    // MARK: - Context
    let crew: CrewResponse
    let cell: CellResponse

    // MARK: - Published State
    @Published var currentYear: Int
    @Published var currentMonth: Int
    @Published var schedules: [WorkScheduleResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Calendar Helper
    private let calendar = Calendar.jst

    // MARK: - Initialization
    init(crew: CrewResponse, cell: CellResponse, scheduleService: ScheduleApplicationServiceProtocol) {
        self.crew = crew
        self.cell = cell
        self.scheduleService = scheduleService

        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month], from: now)
        self.currentYear = components.year ?? 2026
        self.currentMonth = components.month ?? 1
    }

    // MARK: - Computed Properties

    /// 現在の月の表示文字列
    var monthDisplayString: String {
        "\(currentYear)年 \(currentMonth)月"
    }

    /// 今日の日付
    var today: Date {
        calendar.startOfDay(for: Date())
    }

    /// 月の最初の日
    var firstDayOfMonth: Date {
        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonth
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }

    /// 月の最初の日の曜日（0=日曜日）
    var firstWeekday: Int {
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return weekday - 1  // 0-indexed (0=Sunday)
    }

    /// 月の日数
    var daysInMonth: Int {
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)
        return range?.count ?? 30
    }

    /// カレンダーグリッド用の日付配列（前月・翌月の余白含む）
    var calendarDays: [CalendarDay] {
        var days: [CalendarDay] = []

        // 前月の空白
        for _ in 0..<firstWeekday {
            days.append(CalendarDay(date: nil, schedule: nil))
        }

        // 当月の日付
        for day in 1...daysInMonth {
            var components = DateComponents()
            components.year = currentYear
            components.month = currentMonth
            components.day = day
            if let date = calendar.date(from: components) {
                let schedule = schedules.first { calendar.isDate($0.date, inSameDayAs: date) }
                days.append(CalendarDay(date: date, schedule: schedule))
            }
        }

        return days
    }

    // MARK: - Actions

    /// スケジュールを読み込む
    func loadSchedule() {
        isLoading = true
        errorMessage = nil

        do {
            let request = GetMonthlyScheduleRequest(
                cellId: cell.id,
                year: currentYear,
                month: currentMonth
            )
            let response = try scheduleService.getMonthlySchedule(request: request)
            schedules = response.schedules
        } catch {
            errorMessage = "スケジュールの読み込みに失敗しました"
        }

        isLoading = false
    }

    /// 前月へ移動
    func goToPreviousMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        loadSchedule()
    }

    /// 翌月へ移動
    func goToNextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        loadSchedule()
    }

    /// 指定日付が今日かどうか
    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: today)
    }

    /// 指定日付が土曜日かどうか
    func isSaturday(_ date: Date) -> Bool {
        calendar.component(.weekday, from: date) == 7
    }

    /// 指定日付が日曜日かどうか
    func isSunday(_ date: Date) -> Bool {
        calendar.component(.weekday, from: date) == 1
    }
}

// MARK: - Supporting Types

/// カレンダーの1日分のデータ
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let schedule: WorkScheduleResponse?

    var dayNumber: Int? {
        guard let date = date else { return nil }
        return Calendar.current.component(.day, from: date)
    }
}
