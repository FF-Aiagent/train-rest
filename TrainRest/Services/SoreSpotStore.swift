import Foundation
import UIKit

@MainActor
final class SoreSpotStore: ObservableObject {
    @Published private(set) var entries: [SoreSpotEntry] = []

    private let fileURL: URL
    private let photosDir: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let root = support.appendingPathComponent("TrainRest", isDirectory: true)
        photosDir = root.appendingPathComponent("SoreSpotPhotos", isDirectory: true)
        fileURL = root.appendingPathComponent("sore_spots.json")
        try? FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([SoreSpotEntry].self, from: data) else {
            entries = []
            return
        }
        entries = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    func add(bodyArea: String, intensity: Int, note: String?, image: UIImage?) throws {
        var fileName: String?
        if let image, let data = image.jpegData(compressionQuality: 0.85) {
            let name = UUID().uuidString + ".jpg"
            try data.write(to: photosDir.appendingPathComponent(name), options: .atomic)
            fileName = name
        }
        let entry = SoreSpotEntry(
            bodyArea: bodyArea,
            intensity: intensity,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            photoFileName: fileName
        )
        entries.insert(entry, at: 0)
        try persist()
    }

    func photoURL(for entry: SoreSpotEntry) -> URL? {
        guard let name = entry.photoFileName else { return nil }
        return photosDir.appendingPathComponent(name)
    }

    private func persist() throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: fileURL, options: .atomic)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
