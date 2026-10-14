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
                    paywall
                }
            }
            .navigationTitle("Log")
            .sheet(isPresented: $showAdd) {
                AddSoreSpotView(store: store)
            }
        }
    }

    private var paywall: some View {
        VStack(spacing: 16) {
            Text("Photo log for sore spots")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Unlock once to save photo-first notes on this device — body area, how sore (1–5), optional one-line note.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Unlock Pro — $4.99") {
                // M4.5 StoreKit; DEBUG unlock so UI can be tested now
                pro.unlockForDebugOrStoreKit()
            }
            .buttonStyle(.borderedProminent)
            DisclaimerView()
        }
        .padding()
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
