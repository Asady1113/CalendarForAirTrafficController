import Testing
@testable import App

struct CycleConfigurationTests {
    @Test func fewerThan7RoundsIsNormalizedTo7() {
        let config = CycleConfiguration(rounds: [.withNight, .withoutNight, .withoutNightB4])

        #expect(config.rounds.count == 7)
        // 不足分は夜勤ありラウンドで埋める
        #expect(config.rounds[3] == .withNight)
        #expect(config.rounds[6] == .withNight)
        // 元の要素は保持される
        #expect(config.rounds[0] == .withNight)
        #expect(config.rounds[1] == .withoutNight)
        #expect(config.rounds[2] == .withoutNightB4)
    }

    @Test func moreThan7RoundsIsTruncatedTo7() {
        let rounds: [RoundType] = [
            .withNight, .withoutNight, .withoutNightB4, .withNight,
            .withoutNight, .withoutNightB4, .withNight,
            .withoutNight, .withoutNightB4 // 8, 9番目
        ]
        let config = CycleConfiguration(rounds: rounds)

        #expect(config.rounds.count == 7)
        #expect(config.rounds == Array(rounds.prefix(7)))
    }

    @Test func exactly7RoundsIsKeptAsIs() {
        let rounds: [RoundType] = [
            .withNight, .withoutNight, .withoutNightB4, .withNight,
            .withoutNight, .withoutNightB4, .withNight
        ]
        let config = CycleConfiguration(rounds: rounds)

        #expect(config.rounds.count == 7)
        #expect(config.rounds == rounds)
    }
}
