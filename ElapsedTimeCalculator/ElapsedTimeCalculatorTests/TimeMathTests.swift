//
//  TimeMathTests.swift
//  ElapsedTimeCalculatorTests
//
//  Unit tests for the core math logic in TimeMath.swift.
//  Every test maps to a rule in REQUIREMENTS.md or a known JS edge case.

import XCTest
@testable import ElapsedTimeCalculator

final class TimeMathTests: XCTestCase {

    // MARK: - Helper

    /// Build a TimeRow from raw strings, mirroring what the user types.
    private func row(_ h: String, _ m: String, _ s: String,
                     subtract: Bool = false) -> TimeRow {
        let r = TimeRow()
        r.hours = h; r.minutes = m; r.seconds = s
        r.isSubtracting = subtract
        return r
    }

    // MARK: - Basic arithmetic

    func testAddTwoRows() {
        let result = calcTotal(rows: [row("1", "0", "0"), row("0", "30", "0")])
        XCTAssertEqual(result.hours,   1)
        XCTAssertEqual(result.minutes, 30)
        XCTAssertEqual(result.seconds, 0)
    }

    func testSubtractOneRow() {
        let result = calcTotal(rows: [row("2", "0", "0"), row("0", "30", "0", subtract: true)])
        XCTAssertEqual(result.hours,   1)
        XCTAssertEqual(result.minutes, 30)
        XCTAssertEqual(result.seconds, 0)
    }

    func testMixedAddAndSubtract() {
        // 1:00:00 + 0:45:00 - 0:15:00 = 1:30:00
        let result = calcTotal(rows: [
            row("1", "0",  "0"),
            row("0", "45", "0"),
            row("0", "15", "0", subtract: true)
        ])
        XCTAssertEqual(result.hours,   1)
        XCTAssertEqual(result.minutes, 30)
        XCTAssertEqual(result.seconds, 0)
    }

    func testAllZeros() {
        let result = calcTotal(rows: [row("0", "0", "0"), row("0", "0", "0")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 0)
    }

    // MARK: - Negative totals (all fields carry the sign)

    func testNegativeTotalAllFieldsNegative() {
        // 0:30:00 - 1:00:00 = -0:30:00  → hours -0, minutes -30, seconds -0
        let result = calcTotal(rows: [
            row("0", "30", "0"),
            row("1", "0",  "0", subtract: true)
        ])
        XCTAssertEqual(result.hours,   0)    // -0 must display as 0
        XCTAssertEqual(result.minutes, -30)
        XCTAssertEqual(result.seconds, 0)    // -0 must display as 0
    }

    func testNegativeTotalWithHours() {
        // 0:00:00 - 2:15:30 = -2:15:30
        let result = calcTotal(rows: [row("2", "15", "30", subtract: true)])
        XCTAssertEqual(result.hours,   -2)
        XCTAssertEqual(result.minutes, -15)
        XCTAssertEqual(result.seconds, -30)
    }

    // MARK: - Decimal inputs

    func testDecimalHours() {
        // 1.5 hours = 1h 30m 0s
        let result = calcTotal(rows: [row("1.5", "0", "0")])
        XCTAssertEqual(result.hours,   1)
        XCTAssertEqual(result.minutes, 30)
        XCTAssertEqual(result.seconds, 0)
    }

    func testDecimalMinutes() {
        // 1.5 minutes = 0h 1m 30s
        let result = calcTotal(rows: [row("0", "1.5", "0")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 1)
        XCTAssertEqual(result.seconds, 30)
    }

    func testDecimalSeconds() {
        // 90.5 seconds = 0h 1m 30.5s
        let result = calcTotal(rows: [row("0", "0", "90.5")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 1)
        XCTAssertEqual(result.seconds, 30.5)
    }

    // MARK: - Floating point precision

    func testFloatingPointPrecision() {
        // 1.1 hours previously produced 4.547e-13 seconds in JS — must be 0
        let result = calcTotal(rows: [row("1.1", "0", "0")])
        XCTAssertEqual(result.hours,   1)
        XCTAssertEqual(result.minutes, 6)
        XCTAssertEqual(result.seconds, 0)   // NOT 4.547e-13
    }

    // MARK: - Blank / special inputs treated as zero

    func testEmptyStringsAreZero() {
        let result = calcTotal(rows: [row("", "", "")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 0)
    }

    func testDashIsZero() {
        let result = calcTotal(rows: [row("-", "-", "-")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 0)
    }

    func testDotIsZero() {
        let result = calcTotal(rows: [row(".", ".", ".")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 0)
    }

    func testWhitespaceIsZero() {
        let result = calcTotal(rows: [row("  ", "  ", "  ")])
        XCTAssertEqual(result.hours,   0)
        XCTAssertEqual(result.minutes, 0)
        XCTAssertEqual(result.seconds, 0)
    }

    // MARK: - Negative zero never appears

    func testNoNegativeZeroHours() {
        // Subtracting a pure-minutes row: hours result would be -0 without the fix
        let result = calcTotal(rows: [row("0", "30", "0", subtract: true)])
        XCTAssertFalse(result.hours.sign == .minus && result.hours == 0,
                       "hours should not be -0")
    }

    func testNoNegativeZeroSeconds() {
        let result = calcTotal(rows: [row("0", "30", "0", subtract: true)])
        XCTAssertFalse(result.seconds.sign == .minus && result.seconds == 0,
                       "seconds should not be -0")
    }
}
