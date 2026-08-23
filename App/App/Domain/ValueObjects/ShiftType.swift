import Foundation

/// 勤務種別
/// E1, A, B, C, E2, POST_NIGHT, OFF, B4 の8種類
enum ShiftType: String {
    case e1 = "E1"           // 早番①
    case a = "A"             // 早番②
    case b = "B"             // 遅番①
    case e2 = "E2"           // 遅番②
    case c = "C"             // 夜勤
    case postNight = "POST_NIGHT"  // 明け
    case off = "OFF"         // 休み
    case b4 = "B4"           // 遅番①（B4）

    /// 日本語名
    var japaneseName: String {
        switch self {
        case .e1: return "早番①"
        case .a: return "早番②"
        case .b: return "遅番①"
        case .e2: return "遅番②"
        case .c: return "夜勤"
        case .postNight: return "明け"
        case .off: return "休み"
        case .b4: return "遅番①（B4）"
        }
    }

    /// 勤務開始時刻（明け・休みはnil）
    var startTime: DateComponents? {
        switch self {
        case .e1:
            return DateComponents(hour: 6, minute: 45)
        case .a:
            return DateComponents(hour: 7, minute: 30)
        case .b:
            return DateComponents(hour: 12, minute: 0)
        case .e2:
            return DateComponents(hour: 14, minute: 0)
        case .c:
            return DateComponents(hour: 19, minute: 30)
        case .postNight:
            return nil
        case .off:
            return nil
        case .b4:
            return DateComponents(hour: 12, minute: 0)
        }
    }

    /// 勤務終了時刻（明け・休みはnil）
    var endTime: DateComponents? {
        switch self {
        case .e1:
            return DateComponents(hour: 15, minute: 0)
        case .a:
            return DateComponents(hour: 16, minute: 45)
        case .b:
            return DateComponents(hour: 21, minute: 15)
        case .e2:
            return DateComponents(hour: 22, minute: 15)
        case .c:
            // 08:15（時刻のみ。日をまたぐ勤務は呼び出し側で日付を進める）
            return DateComponents(hour: 8, minute: 15)
        case .postNight:
            return nil
        case .off:
            return nil
        case .b4:
            return DateComponents(hour: 21, minute: 15)
        }
    }
}