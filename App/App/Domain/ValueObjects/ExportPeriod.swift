import Foundation

/// エクスポート期間
/// エクスポート対象の開始日・終了日
struct ExportPeriod {
    /// エクスポート開始日
    let startDate: Date

    /// エクスポート終了日
    let endDate: Date

    /// 開始日 ≤ 終了日 を検証する
    var isValid: Bool {
        return startDate <= endDate
    }

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}