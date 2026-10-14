import Foundation

/// M4.5 will flip this via StoreKit. Until then, DEBUG builds can unlock for UI work.
@MainActor
final class ProAccess: ObservableObject {
    static let shared = ProAccess()

    @Published private(set) var isPro: Bool

    private let key = "trainrest.isPro"

    private init() {
        #if DEBUG
        isPro = UserDefaults.standard.bool(forKey: key)
        #else
        isPro = UserDefaults.standard.bool(forKey: key)
        #endif
    }

    func unlockForDebugOrStoreKit() {
        isPro = true
        UserDefaults.standard.set(true, forKey: key)
    }

    func lockForDebug() {
        isPro = false
        UserDefaults.standard.set(false, forKey: key)
    }
}
