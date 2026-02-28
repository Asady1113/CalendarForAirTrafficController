import Foundation

/// ラウンド種別
/// サイクル内の1ラウンド（6日間）の種別
enum RoundType: String {
    case withNight = "WITH_NIGHT"               // 夜勤ありラウンド
    case withoutNight = "WITHOUT_NIGHT"         // 夜勤なしラウンド
    case withoutNightB4 = "WITHOUT_NIGHT_B4"    // 夜勤なし・B4ありラウンド

    /// 日本語名
    var japaneseName: String {
        switch self {
        case .withNight: return "夜勤ありラウンド"
        case .withoutNight: return "夜勤なしラウンド"
        case .withoutNightB4: return "夜勤なし・B4ありラウンド"
        }
    }

    /// 6日間の勤務種別パターン
    var shiftPattern: [ShiftType] {
        switch self {
        case .withNight:
            // E1 → A → B → C → POST_NIGHT → OFF
            return [.e1, .a, .b, .c, .postNight, .off]
        case .withoutNight:
            // OFF → A → B → E2 → OFF → OFF
            return [.off, .a, .b, .e2, .off, .off]
        case .withoutNightB4:
            // OFF → A → B → E2 → B4 → OFF
            return [.off, .a, .b, .e2, .b4, .off]
        }
    }
}