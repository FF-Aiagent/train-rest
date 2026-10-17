import Foundation

enum CallVerdict: String, CaseIterable, Codable {
    case train = "Train"
    case easy = "Easy"
    case rest = "Rest"
    /// Authorized/partial but no usable samples — non-conclusion title (QA + Critiquito F7).
    case notEnoughData = "Not enough data"
}

struct DailyCall: Equatable {
    let verdict: CallVerdict
    let reasons: [String]
    let asOf: Date
}

struct HealthSnapshot: Equatable {
    var authorization: AuthorizationState
    var recentRunMinutes: Double?
    var sleepHours: Double?
    var hrvMs: Double?
    var restingHR: Double?

    enum AuthorizationState: Equatable {
        case notDetermined
        case denied
        case partial
        case authorized
        case unavailable
    }
}
