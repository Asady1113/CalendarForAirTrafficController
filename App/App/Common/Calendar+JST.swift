import Foundation

extension Calendar {
    /// アプリ全体で使う日本時間固定のグレゴリオ暦カレンダー
    static let jst: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }()
}

extension TimeZone {
    static let jst = TimeZone(identifier: "Asia/Tokyo")!
}
