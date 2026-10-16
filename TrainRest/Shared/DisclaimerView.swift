import SwiftUI

enum Copy {
    static let disclaimer =
        "Train / Rest offers training preference hints only. It does not diagnose, treat, or provide medical advice. Sore-spot notes are a personal log, not a clinical record."
}

struct DisclaimerView: View {
    var body: some View {
        Text(Copy.disclaimer)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .accessibilityLabel("Non-medical disclaimer")
    }
}
