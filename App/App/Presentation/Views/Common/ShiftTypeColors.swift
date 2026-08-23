import SwiftUI

/// 勤務種別の色定義
/// デザイン: Calendar.png 参照
extension ShiftType {
    /// 背景色
    var backgroundColor: Color {
        switch self {
        case .e1:
            return Color(red: 0.85, green: 0.94, blue: 0.98)  // 水色
        case .a:
            return Color(red: 0.85, green: 0.94, blue: 0.98)  // 水色
        case .b:
            return Color(red: 0.85, green: 0.95, blue: 0.85)  // 薄緑
        case .c:
            return Color(red: 0.35, green: 0.35, blue: 0.65)  // 青紫（濃い）
        case .e2:
            return Color(red: 0.90, green: 0.85, blue: 0.95)  // 薄紫
        case .postNight:
            return Color(red: 0.95, green: 0.95, blue: 0.95)  // 薄いグレー
        case .off:
            return Color(red: 0.98, green: 0.98, blue: 0.98)  // 白に近いグレー
        case .b4:
            return Color(red: 0.90, green: 0.85, blue: 0.95)  // 薄紫
        }
    }

    /// テキスト色
    var textColor: Color {
        switch self {
        case .c:
            return .white  // 濃い背景には白文字
        default:
            return .primary
        }
    }

    /// 表示用短縮名
    var shortName: String {
        switch self {
        case .e1: return "E1"
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .e2: return "E2"
        case .postNight: return "明け"
        case .off: return "休み"
        case .b4: return "B4"
        }
    }

    /// サブラベル（早番①など）
    var subLabel: String {
        switch self {
        case .e1: return "早番①"
        case .a: return "早番②"
        case .b: return "遅番①"
        case .c: return "夜勤"
        case .e2: return "遅番②"
        case .postNight: return ""
        case .off: return ""
        case .b4: return "遅番①"
        }
    }
}

/// アプリのテーマカラー
struct AppColors {
    /// プライマリカラー（ヘッダー等）
    static let primary = Color(red: 0.15, green: 0.20, blue: 0.35)

    /// アクセントカラー（ボタン等）
    static let accent = Color(red: 0.25, green: 0.35, blue: 0.75)

    /// 日曜日の色
    static let sunday = Color.red

    /// 土曜日の色
    static let saturday = Color.blue

    /// カード背景色
    static let cardBackground = Color.white

    /// 境界線色
    static let border = Color.gray.opacity(0.3)
}
