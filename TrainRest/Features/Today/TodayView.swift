import SwiftUI

struct TodayView: View {
    @StateObject private var model = TodayViewModel()
    #if DEBUG
    @State private var showFakeHealthPicker = false
    #endif

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
                    Button(model.refreshIsSecondary ? "Retry" : "Refresh") {
                        Task { await model.refresh(requestAuthIfNeeded: false) }
                    }
                }
                #if DEBUG
                ToolbarItem(placement: .bottomBar) {
                    Button("Fake Health") {
                        showFakeHealthPicker = true
                    }
                    .accessibilityIdentifier("fakeHealthDebug")
                }
                #endif
            }
            #if DEBUG
            .confirmationDialog("Fake Health (Debug)", isPresented: $showFakeHealthPicker, titleVisibility: .visible) {
                Button("Off (real HealthKit)") {
                    FakeHealth.setScenario(nil)
                    Task { await model.refresh(requestAuthIfNeeded: false) }
                }
                ForEach(FakeHealth.Scenario.allCases) { scenario in
                    Button(scenario.label) {
                        FakeHealth.setScenario(scenario)
                        Task { await model.refresh(requestAuthIfNeeded: false) }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            #endif
            .onAppear { model.onAppear() }
        }
    }

    @ViewBuilder
    private func callContent(_ call: DailyCall) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if model.needsHealthCTA {
                Text("Connect Apple Health")
                    .font(.largeTitle.bold())

                Text("Train / Rest uses workouts, sleep, and heart data on this device to suggest today’s call. Nothing leaves your phone.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Button {
                    Task { await model.allowHealth() }
                } label: {
                    Text("Allow Apple Health")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Allow Apple Health")

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(call.reasons.enumerated()), id: \.offset) { _, reason in
                        Text("• \(reason)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text(call.verdict.rawValue)
                    .font(.largeTitle.bold())
                    .accessibilityLabel("Today's call: \(call.verdict.rawValue)")

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(call.reasons.enumerated()), id: \.offset) { _, reason in
                        Text("• \(reason)")
                            .font(.body)
                    }
                }

                if model.showsPrescriptionHint {
                    Text("Training preference hint — not a prescription.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
            DisclaimerView()
        }
    }
}

#Preview {
    TodayView()
}
