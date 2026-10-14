import SwiftUI

/// M0 placeholder. M1–M2 will wire HealthKit + decision engine.
struct TodayView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Rest")
                    .font(.largeTitle.bold())
                    .accessibilityLabel("Today's call: Rest")

                VStack(alignment: .leading, spacing: 8) {
                    Text("• Placeholder — HealthKit not connected yet")
                    Text("• Open the app on a Mac build to continue M1")
                    Text("• This is a training preference hint, not a prescription")
                }
                .font(.body)

                Spacer()
                DisclaimerView()
            }
            .padding()
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
