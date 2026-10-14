import SwiftUI

struct ProUnlockPanel: View {
    let headline: String
    let bodyText: String

    @StateObject private var store = StoreKitPro.shared
    @StateObject private var pro = ProAccess.shared

    var body: some View {
        VStack(spacing: 16) {
            Text(headline)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await store.purchase() }
            } label: {
                if store.isPurchasing {
                    ProgressView()
                } else {
                    Text("Unlock Pro — \(store.priceText)")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.isPurchasing || pro.isPro)

            Button("Restore Purchase") {
                Task { await store.restore() }
            }
            .font(.subheadline)

            if let err = store.lastError {
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            DisclaimerView()
        }
        .padding()
        .task { await store.refresh() }
    }
}
