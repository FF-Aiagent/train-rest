import Foundation
import HealthKit

/// Reads workout / sleep / HRV / resting HR. Never blocks Today on deny or empty data.
@MainActor
final class HealthKitClient: ObservableObject {
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        types.insert(HKObjectType.workoutType())
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleep)
        }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrv)
        }
        if let rhr = HKObjectType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(rhr)
        }
        return types
    }

    func requestAuthorization() async {
        #if DEBUG
        if FakeHealth.isEnabled {
            FakeHealth.markAuthorized()
            return
        }
        #endif
        guard isAvailable else { return }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
        } catch {
            // Caller treats missing auth as degrade; do not crash.
        }
    }

    func loadSnapshot() async -> HealthSnapshot {
        #if DEBUG
        if let snap = FakeHealth.snapshotIfEnabled() {
            return snap
        }
        #endif
        guard isAvailable else {
            return HealthSnapshot(authorization: .unavailable)
        }

        let auth = currentAuthorizationState()
        async let runs = recentRunMinutes(days: 7)
        async let sleep = lastNightSleepHours()
        async let hrv = latestQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
        async let rhr = latestQuantity(.restingHeartRate, unit: .count().unitDivided(by: .minute()))

        return HealthSnapshot(
            authorization: auth,
            recentRunMinutes: await runs,
            sleepHours: await sleep,
            hrvMs: await hrv,
            restingHR: await rhr
        )
    }

    private func currentAuthorizationState() -> HealthSnapshot.AuthorizationState {
        // HealthKit does not reveal precise read status; use sharingAuthorizationStatus as a coarse signal
        // and treat empty reads as partial/empty at the decision layer.
        let statuses = readTypes.compactMap { type -> HKAuthorizationStatus? in
            store.authorizationStatus(for: type)
        }
        if statuses.isEmpty { return .notDetermined }
        if statuses.allSatisfy({ $0 == .sharingDenied }) { return .denied }
        if statuses.contains(where: { $0 == .notDetermined }) { return .notDetermined }
        if statuses.contains(where: { $0 == .sharingDenied }) { return .partial }
        return .authorized
    }

    private func recentRunMinutes(days: Int) async -> Double? {
        let workoutType = HKObjectType.workoutType()
        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        return await withCheckedContinuation { cont in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let workouts = (samples as? [HKWorkout]) ?? []
                let running = workouts.filter {
                    $0.workoutActivityType == .running || $0.workoutActivityType == .walking
                }
                let minutes = running.reduce(0.0) { $0 + $1.duration / 60.0 }
                cont.resume(returning: running.isEmpty ? nil : minutes)
            }
            store.execute(query)
        }
    }

    private func lastNightSleepHours() async -> Double? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let start = Calendar.current.date(byAdding: .hour, value: -36, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)

        return await withCheckedContinuation { cont in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let asleep: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]
                let seconds = (samples as? [HKCategorySample])?
                    .filter { asleep.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } ?? 0
                cont.resume(returning: seconds > 0 ? seconds / 3600.0 : nil)
            }
            store.execute(query)
        }
    }

    private func latestQuantity(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return nil }
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { cont in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    cont.resume(returning: nil)
                    return
                }
                cont.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }
}

#if DEBUG
/// Simulator / Debug-only fake Health snapshots. Never compiled into Release.
/// Flip with launch args: `-FakeHealth train|easy|rest|insufficient|notGranted|denied`
/// or UserDefaults `debug.fakeHealth` (same raw values). Clear key / omit arg for real HealthKit.
enum FakeHealth {
    static let defaultsKey = "debug.fakeHealth"
    private static let authorizedKey = "debug.fakeHealth.authorized"

    enum Scenario: String, CaseIterable, Identifiable {
        case notGranted
        case denied
        case train
        case easy
        case rest
        case insufficient

        var id: String { rawValue }

        var label: String {
            switch self {
            case .notGranted: return "Not granted (CTA)"
            case .denied: return "Denied"
            case .train: return "Train"
            case .easy: return "Easy"
            case .rest: return "Rest"
            case .insufficient: return "Insufficient data"
            }
        }
    }

    static var isEnabled: Bool { scenario != nil }

    static var scenario: Scenario? {
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "-FakeHealth"), args.index(after: idx) < args.endIndex {
            return Scenario(rawValue: args[args.index(after: idx)])
        }
        if let eq = args.first(where: { $0.hasPrefix("-FakeHealth=") }) {
            return Scenario(rawValue: String(eq.dropFirst("-FakeHealth=".count)))
        }
        if let raw = UserDefaults.standard.string(forKey: defaultsKey), !raw.isEmpty, raw != "off" {
            return Scenario(rawValue: raw)
        }
        return nil
    }

    static func setScenario(_ scenario: Scenario?) {
        if let scenario {
            UserDefaults.standard.set(scenario.rawValue, forKey: defaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: defaultsKey)
        }
        UserDefaults.standard.removeObject(forKey: authorizedKey)
    }

    static func markAuthorized() {
        UserDefaults.standard.set(true, forKey: authorizedKey)
    }

    static func snapshotIfEnabled() -> HealthSnapshot? {
        guard var active = scenario else { return nil }
        if active == .notGranted, UserDefaults.standard.bool(forKey: authorizedKey) {
            // After Allow, leave CTA and show an empty authorized state.
            active = .insufficient
        }
        return snapshot(for: active)
    }

    static func snapshot(for scenario: Scenario) -> HealthSnapshot {
        switch scenario {
        case .notGranted:
            return HealthSnapshot(authorization: .notDetermined)
        case .denied:
            return HealthSnapshot(authorization: .denied)
        case .train:
            // Light load + OK sleep + comfortable HRV → Train
            return HealthSnapshot(
                authorization: .authorized,
                recentRunMinutes: 60,
                sleepHours: 8.0,
                hrvMs: 70,
                restingHR: 52
            )
        case .easy:
            // Solid load + modest sleep → Easy
            return HealthSnapshot(
                authorization: .authorized,
                recentRunMinutes: 180,
                sleepHours: 6.5,
                hrvMs: 40,
                restingHR: 62
            )
        case .rest:
            // High load + short sleep + low HRV + elevated RHR → Rest
            return HealthSnapshot(
                authorization: .authorized,
                recentRunMinutes: 320,
                sleepHours: 5.0,
                hrvMs: 20,
                restingHR: 72
            )
        case .insufficient:
            // Authorized but no samples → DecisionEngine .notEnoughData (not Train/Easy/Rest)
            return HealthSnapshot(authorization: .authorized)
        }
    }
}
#endif
