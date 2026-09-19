import Foundation

/// サイクル構成
/// セルに紐づく7ラウンドの構成
struct CycleConfiguration {
    /// 1サイクルを構成するラウンド数（7ラウンド × 6日 = 42日）
    static let roundCount = 7

    /// 7つのラウンド種別の配列（順序付き）
    let rounds: [RoundType]

    /// 常に7要素になるよう正規化する。
    /// 不足分は夜勤ありラウンドで埋め、超過分は切り捨てる。
    /// （サイクル制約の検証は仕様外。ここでは添字アクセスの安全性のみを保証する）
    init(rounds: [RoundType]) {
        var normalized = rounds.prefix(Self.roundCount).map { $0 }
        while normalized.count < Self.roundCount {
            normalized.append(.withNight)
        }
        self.rounds = normalized
    }
}
