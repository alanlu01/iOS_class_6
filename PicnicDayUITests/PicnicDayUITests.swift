import XCTest

final class PicnicDayUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEmptyTitleShowsValidationAlert() {
        let app = XCUIApplication()
        app.launch()

        capture("iphone-schedule")
        app.buttons["picnic-show-summary"].tap()

        let alert = app.alerts["請輸入野餐名稱"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["輸入名稱"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
    }

    func testInputsAppearInSummaryAndCard() {
        let app = XCUIApplication()
        app.launch()

        let title = app.textFields["picnic-title"]
        title.tap()
        title.typeText("Sunday Picnic")
        app.buttons["完成編輯"].tap()

        let stepper = app.steppers["picnic-guest-stepper"]
        if !stepper.isHittable { app.swipeUp() }
        stepper.buttons.element(boundBy: 1).tap()
        XCTAssertEqual(app.staticTexts["picnic-total"].label, "NT$1,250")

        app.scrollViews.firstMatch.swipeUp()
        let budget = app.sliders["picnic-budget"]
        let thumb = budget.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.5))
        let halfway = budget.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        thumb.press(forDuration: 0.1, thenDragTo: halfway)
        let updatedTotal = app.staticTexts["picnic-total"].label
        XCTAssertNotEqual(updatedTotal, "NT$1,250")
        capture("iphone-budget")

        app.buttons["準備"].tap()
        let blanket = app.switches["picnic-blanket"]
        blanket.tap()
        XCTAssertEqual(blanket.value as? String, "0")

        let notes = app.textViews["picnic-notes"]
        notes.tap()
        notes.typeText("Meet at the park gate.")
        app.buttons["完成編輯"].tap()
        capture("iphone-preparation")

        app.buttons["picnic-show-summary"].tap()
        let alert = app.alerts["野餐行程摘要"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", updatedTotal)).firstMatch.exists)
        capture("iphone-alert")
        alert.buttons["查看行程卡"].tap()

        let coverTitle = app.staticTexts["picnic-cover-title"]
        XCTAssertEqual(coverTitle.label, "Sunday Picnic")
        XCTAssertEqual(app.staticTexts["picnic-blanket-summary"].label, "無須攜帶野餐墊")
        XCTAssertEqual(app.staticTexts["picnic-notes-summary"].label, "Meet at the park gate.")
        capture("iphone-card")

        coverTitle.press(forDuration: 1)
        XCTAssertTrue(app.buttons["複製行程摘要"].waitForExistence(timeout: 5))
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
