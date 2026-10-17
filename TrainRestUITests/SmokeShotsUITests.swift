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
            ("13-today-insufficient", "insufficient", "Easy"),
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
}
