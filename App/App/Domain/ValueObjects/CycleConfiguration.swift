import Foundation

/// サイクル構成
/// セルに紐づく7ラウンドの構成
struct CycleConfiguration {
    /// 7つのラウンド種別の配列（順序付き）
    let rounds: [RoundType]

    /// サイクル制約を満たすか検証する
    /// - 7ラウンド中、夜勤ありラウンドが1回だけ連続する箇所がある
    /// - 7ラウンド中、夜勤なし・B4ありラウンドが1回だけ出現する
    var isValid: Bool {
        guard rounds.count == 7 else { return false }

        // 夜勤なし・B4ありラウンドが1回だけ出現するか
        let b4Count = rounds.filter { $0 == .withoutNightB4 }.count
        guard b4Count == 1 else { return false }

        // 夜勤ありラウンドの連続出現をチェック
        let nightShiftIndices = rounds.enumerated()
            .filter { $0.element == .withNight }
            .map { $0.offset }

        guard !nightShiftIndices.isEmpty else { return false }

        // 連続しているか確認（インデックスが連番になっているか）
        var consecutiveGroups: [[Int]] = []
        var currentGroup: [Int] = []

        for index in nightShiftIndices {
            if currentGroup.isEmpty || index == currentGroup.last! + 1 {
                currentGroup.append(index)
            } else {
                if !currentGroup.isEmpty {
                    consecutiveGroups.append(currentGroup)
                }
                currentGroup = [index]
            }
        }
        if !currentGroup.isEmpty {
            consecutiveGroups.append(currentGroup)
        }

        // 連続グループが1つだけであること
        return consecutiveGroups.count == 1
    }

    init(rounds: [RoundType]) {
        self.rounds = rounds
    }
}