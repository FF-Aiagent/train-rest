import XCTest

final class SmokeShotsUITests: XCTestCase {
    // Host /tmp is writable from the UITest runner; Projects path is not.
    private let outDir = "/tmp/trainrest-smoke"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: outDir),
            withIntermediateDirectories: true
        )
    }

    private func save(_ name: String) throws {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: "\(outDir)/\(name).png")
        try data.write(to: url, options: .atomic)
    }

    func testSmokeFourShots() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 15))
        sleep(2)
        try save("01-today")

        let privacy = app.buttons["Privacy"].firstMatch
        XCTAssertTrue(privacy.waitForExistence(timeout: 5))
        privacy.tap()
        sleep(2)
        try save("04-privacy")
        // Back to Today
        if app.navigationBars.buttons["Today"].exists {
            app.navigationBars.buttons["Today"].tap()
        } else if app.buttons["Today"].exists {
            app.buttons["Today"].firstMatch.tap()
        } else {
            app.swipeRight()
        }
        sleep(1)

        XCTAssertTrue(app.tabBars.buttons["Log"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Log"].tap()
        sleep(2)
        try save("02-log-locked")

        app.tabBars.buttons["Calendar"].tap()
        sleep(2)
        try save("03-calendar-locked")
    }

    /// Debug/Simulator fake Health: Train / Easy / Rest / insufficient / CTA.
    func testFakeHealthVerdictShots() throws {
        let cases: [(file: String, scenario: String, expect: String)] = [
            ("10-today-train", "train", "Train"),
            ("11-today-easy", "easy", "Easy"),
            ("12-today-rest", "rest", "Rest"),
            ("13-today-insufficient", "insufficient", "Not enough data"),
            ("14-today-not-granted", "notGranted", "Allow Apple Health"),
        ]

        for item in cases {
            let app = XCUIApplication()
            app.launchArguments = ["-FakeHealth", item.scenario]
            app.launch()
            XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 15))
            sleep(2)

            if item.scenario == "notGranted" {
                XCTAssertTrue(
                    app.buttons["Allow Apple Health"].waitForExistence(timeout: 8),
                    "CTA missing for notGranted"
                )
            } else {
                // accessibilityLabel overrides visible text for XCUI
                let labeled = app.staticTexts["Today's call: \(item.expect)"].firstMatch
                let plain = app.staticTexts[item.expect].firstMatch
                let ok = labeled.waitForExistence(timeout: 8) || plain.waitForExistence(timeout: 2)
                XCTAssertTrue(ok, "Expected verdict \(item.expect) for scenario \(item.scenario)")
            }

            try save(item.file)
            app.terminate()
        }
    }

    /// ASO / App Store placeholders: Fake Health data ON, Fake Health chrome OFF (`-StoreShots`).
    func testASOStoreShots() throws {
        let asoDir = "/tmp/trainrest-aso"
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: asoDir),
            withIntermediateDirectories: true
        )
        func asoSave(_ name: String) throws {
            let data = XCUIScreen.main.screenshot().pngRepresentation
            try data.write(to: URL(fileURLWithPath: "\(asoDir)/\(name).png"), options: .atomic)
        }

        // 1 Today call (Train) — no Fake Health toolbar
        var app = XCUIApplication()
        app.launchArguments = ["-StoreShots", "-FakeHealth", "train"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 15))
        sleep(2)
        XCTAssertFalse(app.buttons["fakeHealthDebug"].exists, "Fake Health chrome must be hidden for StoreShots")
        let trainLabeled = app.staticTexts["Today's call: Train"].firstMatch
        let trainPlain = app.staticTexts["Train"].firstMatch
        XCTAssertTrue(
            trainLabeled.waitForExistence(timeout: 8) || trainPlain.waitForExistence(timeout: 2),
            "Expected Train verdict"
        )
        try asoSave("01-today-call")

        // 3 Log locked
        XCTAssertTrue(app.tabBars.buttons["Log"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Log"].tap()
        sleep(2)
        try asoSave("03-log-locked")

        // 4 Calendar locked
        app.tabBars.buttons["Calendar"].tap()
        sleep(2)
        try asoSave("04-calendar-locked")

        // 5 Privacy
        app.tabBars.buttons["Today"].tap()
        sleep(1)
        let privacy = app.buttons["Privacy"].firstMatch
        XCTAssertTrue(privacy.waitForExistence(timeout: 5))
        privacy.tap()
        sleep(2)
        try asoSave("05-privacy")
        app.terminate()

        // 2 Not enough data
        app = XCUIApplication()
        app.launchArguments = ["-StoreShots", "-FakeHealth", "insufficient"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 15))
        sleep(2)
        XCTAssertFalse(app.buttons["fakeHealthDebug"].exists)
        let insufLabeled = app.staticTexts["Today's call: Not enough data"].firstMatch
        let insufPlain = app.staticTexts["Not enough data"].firstMatch
        XCTAssertTrue(
            insufLabeled.waitForExistence(timeout: 8) || insufPlain.waitForExistence(timeout: 2),
            "Expected Not enough data verdict"
        )
        try asoSave("02-today-insufficient")
        app.terminate()
    }

}
