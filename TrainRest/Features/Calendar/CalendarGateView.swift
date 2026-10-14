import SwiftUI

struct CalendarGateView: View {
    @StateObject private var pro = ProAccess.shared
    @StateObject private var soreStore = SoreSpotStore()
    @StateObject private var callStore = DailyCallStore.shared
    @State private var selectedDay = Date()

    var body: some View {
        NavigationStack {
            Group {
                if pro.isPro {
                    calendarContent
                } else {
                    ProUnlockPanel(
                        headline: "See daily calls and sore-spot notes",
                        bodyText: "One-time unlock opens your calendar timeline on this device."
                    )
                }
            }
            .navigationTitle("Calendar")
        }
    }

    private var calendarContent: some View {
        List {
            Section {
                DatePicker(
                    "Day",
                    selection: $selectedDay,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
            }

            Section("That day’s call") {
                if let stored = callStore.call(on: selectedDay) {
                    Text(stored.verdict.rawValue)
                        .font(.title2.bold())
                    ForEach(Array(stored.reasons.enumerated()), id: \.offset) { _, reason in
                        Text("• \(reason)")
                    }
                } else {
                    Text("No saved call for this day yet. Open Today to generate one.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Sore-spot notes") {
                let dayEntries = soreStore.entries.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDay) }
                if dayEntries.isEmpty {
                    Text("None for this day.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(dayEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.bodyArea).font(.headline)
                            Text("Soreness \(entry.intensity)/5")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let note = entry.note {
                                Text(note).font(.subheadline)
                            }
                        }
                    }
                }
            }

            Section {
                DisclaimerView()
            }
        }
        .onAppear { soreStore.load() }
    }
}

#Preview {
    CalendarGateView()
}
