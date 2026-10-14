import Foundation

struct SoreSpotEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let createdAt: Date
    let bodyArea: String
    let intensity: Int // 1...5
    let note: String?
    /// Relative filename under Application Support / SoreSpotPhotos
    let photoFileName: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        bodyArea: String,
        intensity: Int,
        note: String?,
        photoFileName: String?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.bodyArea = bodyArea
        self.intensity = min(5, max(1, intensity))
        self.note = note
        self.photoFileName = photoFileName
    }
}

enum BodyArea: String, CaseIterable, Identifiable {
    case foot = "Foot"
    case ankle = "Ankle"
    case calf = "Calf"
    case knee = "Knee"
    case quad = "Quad"
    case hamstring = "Hamstring"
    case hip = "Hip"
    case lowerBack = "Lower back"
    case other = "Other"

    var id: String { rawValue }
}
