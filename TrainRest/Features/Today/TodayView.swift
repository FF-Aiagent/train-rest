import SwiftUI

struct TodayView: View {
    @StateObject private var model = TodayViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if model.isLoading && model.call == nil {
                    ProgressView("Loading today’s call…")
                } else if let call = model.call {
                    callContent(call)
                } else {
                    Text("Can’t make today’s call yet — try Refresh.")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink("Privacy") { AboutPrivacyView() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task { await model.refresh(requestAuthIfNeeded: false) }
                    }
                }
            }
            .onAppear { model.onAppear() }
        }
    }

    @ViewBuilder
    private func callContent(_ call: DailyCall) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(call.verdict.rawValue)
                .font(.largeTitle.bold())
                .accessibilityLabel("Today's call: \(call.verdict.rawValue)")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(call.reasons.enumerated()), id: \.offset) { _, reason in
                    Text("• \(reason)")
                        .font(.body)
                }
            }

            Text("Training preference hint — not a prescription.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
            DisclaimerView()
        }
    }
}

#Preview {
    TodayView()
}
