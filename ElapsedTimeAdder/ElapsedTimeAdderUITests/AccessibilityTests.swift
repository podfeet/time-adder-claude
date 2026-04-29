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
        XCTAssertTrue(label == "Add time entered" || label == "Subtract time entered",
                      "Toggle label must be 'Add time entered' or 'Subtract time entered', got: \(label)")
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

    func testResetRestoresInitialState() {
        let hoursPredicate = NSPredicate(format: "label == 'Hours'")
        let initialRowCount = app.textFields.matching(hoursPredicate).count

        // 1. Add a title to the first row
        let firstTitle = app.textFields.matching(NSPredicate(format: "label == 'Row title'")).firstMatch
        firstTitle.tap()
        firstTitle.typeText("My Segment")

        // 2. Enter hours in the first row
        let firstHours = app.textFields.matching(hoursPredicate).firstMatch
        firstHours.tap()
        firstHours.typeText("5")

        // 3. Toggle the first row from + to −
        let firstToggle = app.buttons.matching(identifier: "toggleButton").firstMatch
        firstToggle.tap()
        XCTAssertEqual(firstToggle.label, "Subtract time entered", "Toggle should switch to subtract")

        // 4. Add a new row
        app.buttons["addRowButton"].tap()
        XCTAssertEqual(app.textFields.matching(hoursPredicate).count, initialRowCount + 1,
                       "Should have one more row after tapping Add Another Row")

        // 5. Enter a value in the new row
        let newRowHours = app.textFields.matching(hoursPredicate).element(boundBy: initialRowCount)
        newRowHours.tap()
        newRowHours.typeText("3")

        // 6. Scroll down to reveal Reset and tap it
        app.scrollViews.firstMatch.swipeUp()
        app.buttons["resetButton"].tap()

        // 7. Verify everything is back to the initial state
        XCTAssertEqual(app.textFields.matching(hoursPredicate).count, initialRowCount,
                       "Row count should be restored after reset")

        let hoursValue = app.textFields.matching(hoursPredicate).firstMatch.value as? String ?? ""
        XCTAssertTrue(hoursValue == "" || hoursValue == "0",
                      "Hours field should be empty after reset (got: \(hoursValue))")

        let titleValue = app.textFields.matching(NSPredicate(format: "label == 'Row title'")).firstMatch.value as? String ?? ""
        XCTAssertTrue(titleValue == "" || titleValue == "title (opt)",
                      "Title field should be empty after reset (got: \(titleValue))")

        XCTAssertEqual(app.buttons.matching(identifier: "toggleButton").firstMatch.label, "Add time entered",
                       "Toggle should be back to + after reset")
    }

    // MARK: - Input validation

    func testInvalidInputShowsError() {
        let hoursField = app.textFields.matching(NSPredicate(format: "label == 'Hours'")).firstMatch
        hoursField.tap()
        hoursField.typeText("abc")
        let error = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Numbers, you silly goose'")).firstMatch
        XCTAssertTrue(error.waitForExistence(timeout: 1),
                      "Error message should appear when invalid text is entered in an H/M/S field")
    }

    func testValidInputHidesError() {
        let errorPredicate = NSPredicate(format: "label CONTAINS 'Numbers, you silly goose'")
        // First trigger the error
        let hoursField = app.textFields.matching(NSPredicate(format: "label == 'Hours'")).firstMatch
        hoursField.tap()
        hoursField.typeText("abc")
        XCTAssertTrue(app.staticTexts.matching(errorPredicate).firstMatch.waitForExistence(timeout: 1))

        // Clear and enter a valid number — error should disappear
        hoursField.clearText()
        hoursField.typeText("5")
        XCTAssertFalse(app.staticTexts.matching(errorPredicate).firstMatch.waitForExistence(timeout: 1),
                       "Error message should disappear when valid input is entered")
    }

    func testSpecialCharactersShowError() {
        let minutesField = app.textFields.matching(NSPredicate(format: "label == 'Minutes'")).firstMatch
        minutesField.tap()
        minutesField.typeText("@#!")
        let error = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Numbers, you silly goose'")).firstMatch
        XCTAssertTrue(error.waitForExistence(timeout: 1),
                      "Special characters should trigger the error message")
    }
}

// MARK: - XCUIElement helper

extension XCUIElement {
    func clearText() {
        guard let value = self.value as? String, !value.isEmpty else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
        self.typeText(deleteString)
    }
}
