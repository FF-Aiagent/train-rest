import Foundation

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var call: DailyCall?
    @Published private(set) var isLoading = false
    @Published private(set) var didAskAuth = false

    private let health = HealthKitClient()

    func onAppear() {
        Task { await refresh(requestAuthIfNeeded: true) }
    }

    func refresh(requestAuthIfNeeded: Bool) async {
        isLoading = true
        defer { isLoading = false }

        if requestAuthIfNeeded && !didAskAuth {
            didAskAuth = true
            await health.requestAuthorization()
        }

        let snap = await health.loadSnapshot()
        let decided = DecisionEngine.decide(from: snap)
        call = decided
        DailyCallStore.shared.save(decided)
    }
}
