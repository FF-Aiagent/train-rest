import SwiftUI

/// M0: Pro gate shell. M3 implements the camera → body part → 1–5 → note flow.
struct LogGateView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Injury log is a Pro feature")
                    .font(.headline)
                Text("Unlock once to save photo-first pain entries on this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Unlock Pro") {
                    // M4.5 StoreKit
                }
                .buttonStyle(.borderedProminent)
                DisclaimerView()
            }
            .padding()
            .navigationTitle("Log")
        }
    }
}

#Preview {
    LogGateView()
}
