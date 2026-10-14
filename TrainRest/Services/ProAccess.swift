import Foundation

/// Local entitlement flag. StoreKitPro sets this after verified purchase / restore.
@MainActor
final class ProAccess: ObservableObject {
    static let shared = ProAccess()

    @Published private(set) var isPro: Bool

    private let key = "trainrest.isPro"

    private init() {
        isPro = UserDefaults.standard.bool(forKey: key)
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
