import Foundation
import StoreKit

/// Non-consumable Pro unlock ($4.99). Product id must match App Store Connect.
enum StoreProductID {
    static let pro = "app.trainrest.pro"
}

@MainActor
final class StoreKitPro: ObservableObject {
    static let shared = StoreKitPro()

    @Published private(set) var product: Product?
    @Published private(set) var isPurchasing = false
    @Published private(set) var lastError: String?
    @Published private(set) var priceText: String = "$4.99"

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { await listenForTransactions() }
        Task { await refresh() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refresh() async {
        lastError = nil
        do {
            let products = try await Product.products(for: [StoreProductID.pro])
            product = products.first
            if let product {
                priceText = product.displayPrice
            }
            await syncEntitlements()
        } catch {
            lastError = "Couldn’t load prices. You can still try Restore."
        }
    }

    func purchase() async {
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }

        do {
            if product == nil {
                await refresh()
            }
            guard let product else {
                lastError = "Pro isn’t available to buy yet."
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                ProAccess.shared.unlockForDebugOrStoreKit()
            case .userCancelled:
                break
            case .pending:
                lastError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            lastError = "Purchase didn’t go through. Nothing charged for a cancel."
        }
    }

    func restore() async {
        lastError = nil
        do {
            try await AppStore.sync()
            await syncEntitlements()
            if !ProAccess.shared.isPro {
                lastError = "No prior Pro purchase found for this Apple ID."
            }
        } catch {
            lastError = "Restore failed. Check your network and Apple ID."
        }
    }

    private func syncEntitlements() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == StoreProductID.pro {
                unlocked = true
                break
            }
        }
        if unlocked {
            ProAccess.shared.unlockForDebugOrStoreKit()
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result),
               transaction.productID == StoreProductID.pro {
                await transaction.finish()
                ProAccess.shared.unlockForDebugOrStoreKit()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
