import XCTest
@testable import TrainRest

final class DecisionEngineTests: XCTestCase {
    func testDeniedYieldsEasy() {
        let snap = HealthSnapshot(authorization: .denied)
        let a = DecisionEngine.decide(from: snap, now: Date(timeIntervalSince1970: 0))
        let b = DecisionEngine.decide(from: snap, now: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(a.verdict, .easy)
        XCTAssertEqual(a, b)
    }

    func testHighLoadShortSleepPrefersRest() {
        let snap = HealthSnapshot(
            authorization: .authorized,
            recentRunMinutes: 320,
            sleepHours: 5.0,
            hrvMs: 20,
            restingHR: 72
        )
        let call = DecisionEngine.decide(from: snap, now: Date(timeIntervalSince1970: 1))
        XCTAssertEqual(call.verdict, .rest)
        XCTAssertLessThanOrEqual(call.reasons.count, 3)
    }

    func testLightLoadOKSleepPrefersTrain() {
        let snap = HealthSnapshot(
            authorization: .authorized,
            recentRunMinutes: 60,
            sleepHours: 8.0,
            hrvMs: 70,
            restingHR: 52
        )
        let call = DecisionEngine.decide(from: snap, now: Date(timeIntervalSince1970: 2))
        XCTAssertEqual(call.verdict, .train)
    }

    func testAuthorizedEmptySignalsYieldsNotEnoughData() {
        let snap = HealthSnapshot(authorization: .authorized)
        let call = DecisionEngine.decide(from: snap, now: Date(timeIntervalSince1970: 3))
        XCTAssertEqual(call.verdict, .notEnoughData)
        XCTAssertEqual(call.verdict.rawValue, "Not enough data")
        XCTAssertTrue(call.reasons.contains(where: { $0.contains("not guessing") || $0.contains("Not enough") }))
    }

    func testFakeHealthScenariosMapToVerdicts() {
        #if DEBUG
        XCTAssertEqual(DecisionEngine.decide(from: FakeHealth.snapshot(for: .train)).verdict, .train)
        XCTAssertEqual(DecisionEngine.decide(from: FakeHealth.snapshot(for: .easy)).verdict, .easy)
        XCTAssertEqual(DecisionEngine.decide(from: FakeHealth.snapshot(for: .rest)).verdict, .rest)
        XCTAssertEqual(DecisionEngine.decide(from: FakeHealth.snapshot(for: .insufficient)).verdict, .notEnoughData)
        XCTAssertEqual(DecisionEngine.decide(from: FakeHealth.snapshot(for: .denied)).verdict, .easy)
        #endif
    }
}
