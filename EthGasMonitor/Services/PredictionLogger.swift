//
//  PredictionLogger.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/23/26.
//

import Foundation

// MARK: - Data Types

private struct PendingPrediction: Codable {
    let id: UUID
    let madeAt: Date
    let checkAt: Date
    let currentGwei: Double
    let predictedGwei: Double
    let trendLabel: String
}

private struct ValidationResult: Codable {
    let madeAt: Date
    let checkedAt: Date
    let currentGwei: Double
    let predictedGwei: Double
    let actualGwei: Double
    let percentError: Double
    let trendLabel: String
    let directionCorrect: Bool
}

// MARK: - Logger

final class PredictionLogger {
    static let shared = PredictionLogger()

    private var pending: [PendingPrediction] = []
    private var results: [ValidationResult] = []
    private var lastLogDate: Date = .distantPast

    private let pendingKey = "predLog_pending_v1"
    private let resultsKey = "predLog_results_v1"

    private init() { load() }

    // MARK: - Log

    /// Logs a 30-min ahead prediction, throttled to once per 5 minutes.
    func maybeLog(currentGwei: Double, predictedGwei30min: Double, trendLabel: String) {
        let now = Date()
        guard now.timeIntervalSince(lastLogDate) >= 300 else { return }
        lastLogDate = now

        let prediction = PendingPrediction(
            id: UUID(),
            madeAt: now,
            checkAt: now.addingTimeInterval(1800),
            currentGwei: currentGwei,
            predictedGwei: predictedGwei30min,
            trendLabel: trendLabel
        )
        pending.append(prediction)
        if pending.count > 200 { pending.removeFirst(pending.count - 200) }
        save()

        NSLog("[PredLog] Logged: now=%.2f gwei → predicted=%.2f in 30min (trend: %@)",
              currentGwei, predictedGwei30min, trendLabel)
    }

    // MARK: - Validate

    /// Checks whether any pending predictions have matured and validates them against actual gas.
    func checkMatured(actualGwei: Double) {
        let now = Date()
        let matured = pending.filter { $0.checkAt <= now }
        guard !matured.isEmpty else { return }

        for p in matured {
            let error = ((actualGwei - p.predictedGwei) / max(p.predictedGwei, 1)) * 100
            let actualChange = actualGwei - p.currentGwei

            let directionCorrect: Bool
            switch p.trendLabel {
            case "SURGING", "RISING":   directionCorrect = actualChange > 0
            case "DROPPING", "FALLING": directionCorrect = actualChange < 0
            case "STABLE":              directionCorrect = abs(actualChange / max(p.currentGwei, 1)) < 0.10
            default:                    directionCorrect = false
            }

            results.append(ValidationResult(
                madeAt: p.madeAt,
                checkedAt: now,
                currentGwei: p.currentGwei,
                predictedGwei: p.predictedGwei,
                actualGwei: actualGwei,
                percentError: error,
                trendLabel: p.trendLabel,
                directionCorrect: directionCorrect
            ))

            NSLog("[PredLog] Validated: predicted=%.2f → actual=%.2f | error=%+.1f%% | direction=%@ (%@)",
                  p.predictedGwei, actualGwei, error,
                  directionCorrect ? "✓" : "✗", p.trendLabel)
        }

        pending.removeAll { $0.checkAt <= now }
        if results.count > 500 { results.removeFirst(results.count - 500) }
        save()
        logSummary()
    }

    // MARK: - Summary

    private func logSummary() {
        guard results.count >= 2 else { return }

        let mape = results.map { abs($0.percentError) }.reduce(0, +) / Double(results.count)
        let bias = results.map { $0.percentError }.reduce(0, +) / Double(results.count)
        let dirAccuracy = Double(results.filter { $0.directionCorrect }.count) / Double(results.count) * 100

        NSLog("[PredLog] ─── SUMMARY (n=%d) ───────────────────────────────", results.count)
        NSLog("[PredLog] MAPE: %.1f%% | Bias: %+.1f%% (%@) | Direction: %.0f%% correct",
              mape, bias, bias > 0 ? "over-predicts" : "under-predicts", dirAccuracy)

        let groups = Dictionary(grouping: results, by: \.trendLabel)
        for (label, group) in groups.sorted(by: { $0.key < $1.key }) {
            let correct = group.filter { $0.directionCorrect }.count
            NSLog("[PredLog]   %-10@ %d/%d correct (%.0f%%)",
                  label as NSString, correct, group.count,
                  Double(correct) / Double(group.count) * 100)
        }
        NSLog("[PredLog] ─────────────────────────────────────────────────────")
    }

    // MARK: - Persistence

    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(pending) {
            UserDefaults.standard.set(data, forKey: pendingKey)
        }
        if let data = try? encoder.encode(results) {
            UserDefaults.standard.set(data, forKey: resultsKey)
        }
    }

    private func load() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: pendingKey),
           let decoded = try? decoder.decode([PendingPrediction].self, from: data) {
            pending = decoded
        }
        if let data = UserDefaults.standard.data(forKey: resultsKey),
           let decoded = try? decoder.decode([ValidationResult].self, from: data) {
            results = decoded
        }
        NSLog("[PredLog] Loaded state: %d pending, %d validated", pending.count, results.count)
    }
}
