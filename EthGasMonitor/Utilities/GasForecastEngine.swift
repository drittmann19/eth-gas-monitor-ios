//
//  GasForecastEngine.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/16/26.
//

import Foundation

// MARK: - Data Structures

struct ForecastPoint {
    let minutesFromNow: Int
    let predictedGwei: Double
    let confidenceLow: Double
    let confidenceHigh: Double
}

struct PredictedWindow {
    let startDate: Date
    let endDate: Date
    let estimatedGwei: Double
    let isNow: Bool
    let relativeLabel: String
}

struct GasForecast {
    let historicalNormalized: [Double]
    let forecastNormalized: [Double]
    let confidenceLowNormalized: [Double]
    let confidenceHighNormalized: [Double]
    let bestWindow: PredictedWindow
    let normMin: Double
    let normMax: Double
    let changePercent: String
    let trendLabel: String
}

// MARK: - Forecast Engine

enum GasForecastEngine {

    /// Main entry point: produces a complete forecast from raw network data
    static func generateForecast(
        currentGwei: Double,
        gasPrices24h: [Double],
        hourlyBaselines: [Double],
        currentTime: Date,
        dayOfWeek: Int
    ) -> GasForecast {
        // Extract last 2 hours of history (120 minutes)
        let historyCount = 120
        let historical: [Double]
        if gasPrices24h.count >= historyCount {
            historical = Array(gasPrices24h.suffix(historyCount))
        } else {
            historical = gasPrices24h
        }

        // Recent data for trend momentum (last 60 minutes)
        let recentPrices = Array(gasPrices24h.suffix(60))

        // Standard deviation for confidence bands
        let stdDev = GasMetrics.standardDeviation(gasPrices24h, lastN: 120)

        // Generate forecast points at 5-minute intervals for 2 hours
        var forecastPoints: [ForecastPoint] = []
        for i in 0...24 {
            let minutesForward = i * 5
            let futureTime = currentTime.addingTimeInterval(Double(minutesForward * 60))

            let baseline = hourlyBaseline(at: futureTime, dayOfWeek: dayOfWeek, baselines: hourlyBaselines)
            let momentum = trendProjection(gasPricesRecent: recentPrices, minutesForward: minutesForward)
            let predicted = blendedForecast(trendProjection: momentum, hourlyBaseline: baseline, minutesForward: minutesForward)

            let band = confidenceBand(predictedGwei: predicted, minutesForward: minutesForward, recentStdDev: stdDev)

            forecastPoints.append(ForecastPoint(
                minutesFromNow: minutesForward,
                predictedGwei: predicted,
                confidenceLow: band.low,
                confidenceHigh: band.high
            ))
        }

        // Ensure first forecast point matches current price for seamless connection
        let adjustedFirst = ForecastPoint(
            minutesFromNow: 0,
            predictedGwei: currentGwei,
            confidenceLow: currentGwei,
            confidenceHigh: currentGwei
        )
        forecastPoints[0] = adjustedFirst

        // Normalize everything on a shared scale
        let normalized = normalize(historical: historical, forecast: forecastPoints)

        // Find best transaction window
        let bestWindow = findBestWindow(
            hourlyBaselines: hourlyBaselines,
            currentTime: currentTime,
            dayOfWeek: dayOfWeek
        )

        // Compute trend label from recent spike
        let spikePercent = GasMetrics.calculateRecentSpike(gasPrices24h)
        let changePercent = String(format: "%+.0f%%", spikePercent)
        let trendLabel: String
        if spikePercent > 30 { trendLabel = "SURGING" }
        else if spikePercent > 10 { trendLabel = "RISING" }
        else if spikePercent < -30 { trendLabel = "DROPPING" }
        else if spikePercent < -10 { trendLabel = "FALLING" }
        else { trendLabel = "STABLE" }

        return GasForecast(
            historicalNormalized: normalized.histNorm,
            forecastNormalized: normalized.foreNorm,
            confidenceLowNormalized: normalized.lowNorm,
            confidenceHighNormalized: normalized.highNorm,
            bestWindow: bestWindow,
            normMin: normalized.min,
            normMax: normalized.max,
            changePercent: changePercent,
            trendLabel: trendLabel
        )
    }

    // MARK: - Layer 1: Time-of-day baseline

    static func hourlyBaseline(at futureTime: Date, dayOfWeek: Int, baselines: [Double]) -> Double {
        guard baselines.count == 168 else { return 20 }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let hour = calendar.component(.hour, from: futureTime)
        let futureWeekday = calendar.component(.weekday, from: futureTime)
        // Convert Calendar weekday (1=Sun) to our format (0=Sun)
        let futureDayOfWeek = futureWeekday - 1

        let index = futureDayOfWeek * 24 + hour
        guard index >= 0, index < 168 else { return 20 }
        return baselines[index]
    }

    // MARK: - Layer 2: Trend momentum

    static func trendProjection(gasPricesRecent: [Double], minutesForward: Int) -> Double {
        guard gasPricesRecent.count >= 2 else { return gasPricesRecent.last ?? 20 }

        // Exponentially weighted average with half-life of ~15 minutes
        let lambda = 0.046 // ln(2)/15
        var weightedSum: Double = 0
        var weightTotal: Double = 0

        for i in 0..<gasPricesRecent.count {
            let minutesAgo = Double(gasPricesRecent.count - 1 - i)
            let weight = exp(-lambda * minutesAgo)
            weightedSum += gasPricesRecent[i] * weight
            weightTotal += weight
        }

        let weightedAvg = weightedSum / weightTotal
        let current = gasPricesRecent.last!

        // Slope: difference between current and weighted average, projected forward
        let slope = (current - weightedAvg) / Double(gasPricesRecent.count)

        // Project forward, but decay the slope
        let decayedSlope = slope * exp(-0.02 * Double(minutesForward))
        return current + decayedSlope * Double(minutesForward)
    }

    // MARK: - Layer 3: Blended forecast

    static func blendedForecast(trendProjection: Double, hourlyBaseline: Double, minutesForward: Int) -> Double {
        // Momentum weight decays: 0.7 at t+0, ~0.45 at t+30, ~0.12 at t+120
        let momentumWeight = 0.7 * exp(-0.015 * Double(minutesForward))
        let baselineWeight = 1.0 - momentumWeight

        let blended = momentumWeight * trendProjection + baselineWeight * hourlyBaseline
        return max(1.0, blended)
    }

    // MARK: - Confidence band

    static func confidenceBand(predictedGwei: Double, minutesForward: Int, recentStdDev: Double) -> (low: Double, high: Double) {
        guard minutesForward > 0 else {
            return (low: predictedGwei, high: predictedGwei)
        }

        // Width grows with sqrt of time, scaled by recent volatility
        let baseUncertainty = max(1.0, recentStdDev * 0.5)
        let width = baseUncertainty * sqrt(Double(minutesForward) / 5.0)

        return (
            low: max(1.0, predictedGwei - width),
            high: predictedGwei + width
        )
    }

    // MARK: - Best window finder

    static func findBestWindow(
        hourlyBaselines: [Double],
        currentTime: Date,
        dayOfWeek: Int
    ) -> PredictedWindow {
        guard hourlyBaselines.count == 168 else {
            return PredictedWindow(
                startDate: currentTime,
                endDate: currentTime.addingTimeInterval(7200),
                estimatedGwei: 20,
                isNow: true,
                relativeLabel: "NOW"
            )
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let currentHour = calendar.component(.hour, from: currentTime)

        // Scan next 24 hours of baselines to find the lowest 2-hour window
        var bestStart = 0
        var bestAvg = Double.infinity

        for offset in 0..<24 {
            let futureTime = currentTime.addingTimeInterval(Double(offset * 3600))
            let futureWeekday = calendar.component(.weekday, from: futureTime) - 1
            let futureHour = calendar.component(.hour, from: futureTime)

            let idx1 = futureWeekday * 24 + futureHour
            let nextHour = (futureHour + 1) % 24
            let nextDay = futureHour == 23 ? (futureWeekday + 1) % 7 : futureWeekday
            let idx2 = nextDay * 24 + nextHour

            guard idx1 >= 0, idx1 < 168, idx2 >= 0, idx2 < 168 else { continue }

            let avg = (hourlyBaselines[idx1] + hourlyBaselines[idx2]) / 2.0
            if avg < bestAvg {
                bestAvg = avg
                bestStart = offset
            }
        }

        let startDate = currentTime.addingTimeInterval(Double(bestStart * 3600))
        let endDate = startDate.addingTimeInterval(7200) // 2-hour window
        let isNow = bestStart == 0
        let relativeLabel = TimeHelpers.relativeTimeLabel(from: currentTime, to: startDate)

        return PredictedWindow(
            startDate: startDate,
            endDate: endDate,
            estimatedGwei: bestAvg,
            isNow: isNow,
            relativeLabel: relativeLabel
        )
    }

    // MARK: - Normalization

    static func normalize(
        historical: [Double],
        forecast: [ForecastPoint]
    ) -> (histNorm: [Double], foreNorm: [Double], lowNorm: [Double], highNorm: [Double], min: Double, max: Double) {
        // Find global min/max across all data
        let histMin = historical.min() ?? 0
        let histMax = historical.max() ?? 100

        let forecastValues = forecast.map(\.predictedGwei)
        let forecastLow = forecast.map(\.confidenceLow)
        let forecastHigh = forecast.map(\.confidenceHigh)

        let allMin = Swift.min(histMin, forecastLow.min() ?? histMin)
        let allMax = Swift.max(histMax, forecastHigh.max() ?? histMax)

        // Add 10% padding
        let range = allMax - allMin
        let padding = range * 0.1
        let normMin = allMin - padding
        let normMax = allMax + padding
        let normRange = normMax - normMin

        guard normRange > 0 else {
            return (
                histNorm: historical.map { _ in 0.5 },
                foreNorm: forecastValues.map { _ in 0.5 },
                lowNorm: forecastLow.map { _ in 0.5 },
                highNorm: forecastHigh.map { _ in 0.5 },
                min: normMin,
                max: normMax
            )
        }

        let normalizer: (Double) -> Double = { value in
            (value - normMin) / normRange
        }

        return (
            histNorm: historical.map(normalizer),
            foreNorm: forecastValues.map(normalizer),
            lowNorm: forecastLow.map(normalizer),
            highNorm: forecastHigh.map(normalizer),
            min: normMin,
            max: normMax
        )
    }
}
