import Foundation

/// サイクル構成
/// セルに紐づく7ラウンドの構成
struct CycleConfiguration {
    /// 7つのラウンド種別の配列（順序付き）
    let rounds: [RoundType]

    init(rounds: [RoundType]) {
        self.rounds = rounds
    }
}
