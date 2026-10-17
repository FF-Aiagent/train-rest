import Foundation

/// Deterministic Train / Easy / Rest from available signals. Same inputs → same verdict.
enum DecisionEngine {
    static func decide(from snap: HealthSnapshot, now: Date = Date()) -> DailyCall {
        var reasons: [String] = []
        var score = 0 // higher → more rest bias

        switch snap.authorization {
        case .unavailable:
            reasons.append("Health data is not available on this device")
            return DailyCall(verdict: .easy, reasons: reasons + ["Showing Easy until HealthKit is available"], asOf: now)
        case .denied:
            reasons.append("Health access was declined — no workout or sleep data")
            return DailyCall(verdict: .easy, reasons: reasons + ["You can still train by feel; enable Health later in Settings"], asOf: now)
        case .notDetermined:
            reasons.append("Health access not granted yet")
        case .partial:
            reasons.append("Only some Health data types are available")
        case .authorized:
            break
        }

        let hasAnySignal = snap.recentRunMinutes != nil
            || snap.sleepHours != nil
            || snap.hrvMs != nil
            || snap.restingHR != nil
        if (snap.authorization == .authorized || snap.authorization == .partial), !hasAnySignal {
            reasons.append("No workout, sleep, or heart samples yet")
            return DailyCall(
                verdict: .notEnoughData,
                reasons: reasons + ["Not enough Health data yet — not guessing recovery"],
                asOf: now
            )
        }

        if let minutes = snap.recentRunMinutes {
            if minutes >= 300 {
                score += 2
                reasons.append(String(format: "High recent running load (%.0f min in 7 days)", minutes))
            } else if minutes >= 150 {
                score += 1
                reasons.append(String(format: "Solid recent load (%.0f min in 7 days)", minutes))
            } else {
                score -= 1
                reasons.append(String(format: "Light recent load (%.0f min in 7 days)", minutes))
            }
        } else {
            reasons.append("No recent run or walk workouts found")
        }

        if let sleep = snap.sleepHours {
            if sleep < 6 {
                score += 2
                reasons.append(String(format: "Short recent sleep (%.1f h)", sleep))
            } else if sleep < 7 {
                score += 1
                reasons.append(String(format: "Modest sleep (%.1f h)", sleep))
            } else {
                score -= 1
                reasons.append(String(format: "OK sleep window (%.1f h)", sleep))
            }
        } else {
            reasons.append("No sleep data — not guessing recovery")
        }

        if let hrv = snap.hrvMs {
            // Relative heuristic only; not a medical threshold.
            if hrv < 25 {
                score += 1
                reasons.append(String(format: "Recent HRV looks low (%.0f ms)", hrv))
            } else if hrv > 60 {
                score -= 1
                reasons.append(String(format: "Recent HRV looks comfortable (%.0f ms)", hrv))
            } else {
                reasons.append(String(format: "Recent HRV mid-range (%.0f ms)", hrv))
            }
        } else {
            reasons.append("No HRV sample — skipping that signal")
        }

        if let rhr = snap.restingHR {
            if rhr >= 70 {
                score += 1
                reasons.append(String(format: "Resting heart rate on the high side (%.0f bpm)", rhr))
            } else {
                reasons.append(String(format: "Resting heart rate noted (%.0f bpm)", rhr))
            }
        }

        let verdict: CallVerdict
        if score >= 3 {
            verdict = .rest
        } else if score >= 1 {
            verdict = .easy
        } else {
            verdict = .train
        }

        let trimmed = Array(reasons.prefix(3))
        return DailyCall(verdict: verdict, reasons: trimmed, asOf: now)
    }
}
