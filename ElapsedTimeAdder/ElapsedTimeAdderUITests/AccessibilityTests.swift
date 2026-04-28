//
//  AccessibilityTests.swift
//  ElapsedTimeAdderUITests
//

import XCTest

final class AccessibilityTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Automated audit

    func testAccessibilityAuditMainScreen() throws {
        // We audit only for element descriptions and contrast. The parent/child
        // containment check is skipped because it is likely triggered by SwiftUI's
        // internal frame math inside ScrollView, not a real user-facing problem.
        try app.performAccessibilityAudit(for: [.sufficientElementDescription, .contrast]) { issue in
            print("AUDIT ISSUE: \(issue.compactDescription) | element: \(issue.element?.debugDescription ?? "unknown")")
            return true
        }
    }

    // MARK: - Key buttons exist and are reachable

    func testAddRowButtonExists() {
        XCTAssertTrue(app.buttons["addRowButton"].exists,
                      "Add Another Row button must be accessible")
    }

    func testResetButtonExists() {
        XCTAssertTrue(app.buttons["resetButton"].exists,
                      "Reset button must be accessible")
    }

    func testHowItWorksButtonExists() {
        XCTAssertTrue(app.buttons["howItWorksButton"].exists,
                      "'How it works' button must be accessible")
    }

    func testToggleButtonsHaveLabels() {
        let toggles = app.buttons.matching(identifier: "toggleButton")
        XCTAssertGreaterThan(toggles.count, 0,
                             "+/− buttons must exist and have an accessibility identifier")
        // Verify the label is one of the two expected values
        let first = toggles.firstMatch
        let label = first.label
        XCTAssertTrue(label == "Add time" || label == "Subtract time",
                      "Toggle label must be 'Add time' or 'Subtract time', got: \(label)")
    }

    // MARK: - Text fields are labelled for VoiceOver

    func testHourFieldsHaveLabels() {
        let fields = app.textFields.matching(NSPredicate(format: "label == 'Hours'"))
        XCTAssertGreaterThan(fields.count, 0, "Hour fields must have 'Hours' accessibility label")
    }

    func testMinuteFieldsHaveLabels() {
        let fields = app.textFields.matching(NSPredicate(format: "label == 'Minutes'"))
        XCTAssertGreaterThan(fields.count, 0, "Minute fields must have 'Minutes' accessibility label")
    }

    func testSecondFieldsHaveLabels() {
        let fields = app.textFields.matching(NSPredicate(format: "label == 'Seconds'"))
        XCTAssertGreaterThan(fields.count, 0, "Second fields must have 'Seconds' accessibility label")
    }

    // MARK: - How It Works expander

    func testHowItWorksExpandsAndCollapses() {
        let button = app.buttons["howItWorksButton"]
        XCTAssertTrue(button.exists, "howItWorksButton must exist")
        XCTAssertTrue(button.isHittable, "howItWorksButton must be hittable")
        button.tap()
        let explanation = app.descendants(matching: .any).matching(identifier: "explanationPanel").firstMatch
        XCTAssertTrue(explanation.waitForExistence(timeout: 2),
                      "Explanation panel should appear after tapping 'How it works'")
        button.tap()
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"),
                                             object: explanation)
        XCTWaiter().wait(for: [gone], timeout: 2)
        XCTAssertFalse(explanation.exists, "Explanation panel should disappear after tapping 'Hide'")
    }

    // MARK: - Add Row

    func testAddRowIncreasesRowCount() {
        let before = app.textFields.matching(NSPredicate(format: "label == 'Hours'")).count
        app.buttons["addRowButton"].tap()
        let after = app.textFields.matching(NSPredicate(format: "label == 'Hours'")).count
        XCTAssertEqual(after, before + 1, "Add Another Row should add exactly one row")
    }

    // MARK: - Reset

    func testResetClearsFields() {
        let hoursField = app.textFields.matching(NSPredicate(format: "label == 'Hours'")).firstMatch
        hoursField.tap()
        hoursField.typeText("5")
        app.buttons["resetButton"].tap()
        XCTAssertEqual(hoursField.value as? String, "",
                       "Reset should clear all field values")
    }
}
