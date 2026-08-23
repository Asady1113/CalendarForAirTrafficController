import Testing
import Foundation
@testable import App

struct ExportPeriodTests {
    @Test func startBeforeEndIsValid() {
        let start = Date()
        let end = start.addingTimeInterval(60 * 60 * 24)
        let period = ExportPeriod(startDate: start, endDate: end)

        #expect(period.isValid == true)
    }

    @Test func startEqualsEndIsValid() {
        let date = Date()
        let period = ExportPeriod(startDate: date, endDate: date)

        #expect(period.isValid == true)
    }

    @Test func startAfterEndIsInvalid() {
        let end = Date()
        let start = end.addingTimeInterval(60 * 60 * 24)
        let period = ExportPeriod(startDate: start, endDate: end)

        #expect(period.isValid == false)
    }
}
