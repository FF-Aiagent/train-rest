import SwiftUI

struct LogGateView: View {
    @StateObject private var pro = ProAccess.shared
    @StateObject private var store = SoreSpotStore()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if pro.isPro {
                    logList
                } else {
                    ProUnlockPanel(
                        headline: "Photo log for sore spots",
                        bodyText: "Unlock once to save photo-first notes on this device — body area, how sore (1–5), optional one-line note."
                    )
                }
            }
            .navigationTitle("Log")
            .sheet(isPresented: $showAdd) {
                AddSoreSpotView(store: store)
            }
        }
    }

    private var logList: some View {
        Group {
            if store.entries.isEmpty {
                ContentUnavailableView(
                    "No sore spots yet",
                    systemImage: "camera",
                    description: Text("Add a photo note — personal log only, not a clinical record.")
                )
            } else {
                List(store.entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.bodyArea)
                            .font(.headline)
                        Text("Soreness \(entry.intensity)/5 · \(entry.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let note = entry.note {
                            Text(note).font(.subheadline)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    LogGateView()
}
