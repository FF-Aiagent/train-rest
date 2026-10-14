import SwiftUI

struct AboutPrivacyView: View {
    var body: some View {
        List {
            Section("What we use") {
                Text("Apple Health (if you allow): recent runs, sleep, HRV, resting heart rate — to suggest today’s Train / Easy / Rest call on this device.")
                Text("Camera & Photos (optional): sore-spot notes you add. Stored on this device only.")
                Text("Purchases: one-time Pro unlock for Log and Calendar.")
            }
            Section("What we don’t do") {
                Text("No account. No backend. No tracking. Not a medical device — training preference hints only.")
            }
            Section {
                DisclaimerView()
            }
        }
        .navigationTitle("Privacy")
    }
}
