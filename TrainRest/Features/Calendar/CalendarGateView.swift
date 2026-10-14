import SwiftUI

/// M0/M4.5: Pro gate. M4 implements the timeline.
struct CalendarGateView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("See daily calls and sore-spot notes")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text("One-time unlock opens your calendar timeline on this device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Unlock Pro — $4.99") {
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
