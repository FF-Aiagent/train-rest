import Foundation

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var call: DailyCall?
    @Published private(set) var isLoading = false
    @Published private(set) var authorization: HealthSnapshot.AuthorizationState = .notDetermined

    private let health = HealthKitClient()

    /// Show primary Allow Health CTA (Critiquito F1).
    var needsHealthCTA: Bool {
        authorization == .notDetermined
    }

    /// Soften Refresh when Health still blocked.
    var refreshIsSecondary: Bool {
        switch authorization {
        case .notDetermined, .denied, .unavailable:
            return true
        default:
            return false
        }
    }

    /// Show "not a prescription" only for Train/Easy/Rest conclusions (hide on CTA + insufficient).
    var showsPrescriptionHint: Bool {
        switch call?.verdict {
        case .train, .easy, .rest:
            return true
        default:
            return false
        }
    }

    func onAppear() {
        Task { await refresh(requestAuthIfNeeded: false) }
    }

    func allowHealth() async {
        await refresh(requestAuthIfNeeded: true)
    }

    func refresh(requestAuthIfNeeded: Bool) async {
        isLoading = true
        defer { isLoading = false }

        if requestAuthIfNeeded {
            await health.requestAuthorization()
        }

        let snap = await health.loadSnapshot()
        authorization = snap.authorization
        let decided = DecisionEngine.decide(from: snap)
        call = decided
        DailyCallStore.shared.save(decided)
    }
}
