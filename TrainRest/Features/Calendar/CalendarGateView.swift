import SwiftUI

/// M0: Pro gate shell. M4 implements the timeline.
struct CalendarGateView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Calendar is a Pro feature")
                    .font(.headline)
                Text("See daily calls and pain entries after a one-time unlock.")
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
            .navigationTitle("Calendar")
        }
    }
}

#Preview {
    CalendarGateView()
}
