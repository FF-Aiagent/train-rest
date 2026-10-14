import Foundation

@MainActor
final class DailyCallStore: ObservableObject {
    static let shared = DailyCallStore()

    struct StoredCall: Codable, Equatable, Identifiable {
        var id: String { dayKey }
        let dayKey: String // yyyy-MM-dd
        let verdict: CallVerdict
        let reasons: [String]
        let asOf: Date
    }

    @Published private(set) var byDay: [String: StoredCall] = [:]

    private let fileURL: URL
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let root = support.appendingPathComponent("TrainRest", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        fileURL = root.appendingPathComponent("daily_calls.json")
        load()
    }

    func dayKey(for date: Date) -> String { formatter.string(from: date) }

    func save(_ call: DailyCall) {
        let key = dayKey(for: call.asOf)
        byDay[key] = StoredCall(
            dayKey: key,
            verdict: call.verdict,
            reasons: call.reasons,
            asOf: call.asOf
        )
        persist()
    }

    func call(on date: Date) -> StoredCall? {
        byDay[dayKey(for: date)]
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: StoredCall].self, from: data) else {
            byDay = [:]
            return
        }
        byDay = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(byDay) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
