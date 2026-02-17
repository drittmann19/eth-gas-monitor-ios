//
//  GasMetrics.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/9/26.
//

import Foundation

enum GasMetrics {

    /// Calculates the percentage change in gas price over the last 30 minutes
    /// - Parameter gasPrices24h: Array of gas prices at 1-minute intervals
    /// - Returns: Percentage change (can be negative)
    static func calculateRecentSpike(_ gasPrices24h: [Double]) -> Double {
        guard gasPrices24h.count >= 30 else { return 0 }

        let current = gasPrices24h[gasPrices24h.count - 1]
        let thirtyMinAgo = gasPrices24h[gasPrices24h.count - 30]

        guard thirtyMinAgo > 0 else { return 0 }

        let change = ((current - thirtyMinAgo) / thirtyMinAgo) * 100
        return change.rounded()
    }

    /// Calculates how many consecutive minutes gas has been above 40 Gwei
    /// - Parameter gasPrices24h: Array of gas prices at 1-minute intervals
    /// - Returns: Number of consecutive minutes with elevated gas
    static func calculateHighDuration(_ gasPrices24h: [Double]) -> Int {
        var duration = 0

        for i in stride(from: gasPrices24h.count - 1, through: 0, by: -1) {
            if gasPrices24h[i] > 40 {
                duration += 1
            } else {
                break
            }
        }

        return duration
    }

    /// Calculates standard deviation of gas prices over the last N minutes
    /// Used for confidence band width in forecasting
    static func standardDeviation(_ prices: [Double], lastN: Int = 120) -> Double {
        let slice = Array(prices.suffix(lastN))
        guard slice.count > 1 else { return 0 }
        let mean = slice.reduce(0, +) / Double(slice.count)
        let variance = slice.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(slice.count - 1)
        return sqrt(variance)
    }
}
