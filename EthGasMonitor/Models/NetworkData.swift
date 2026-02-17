//
//  NetworkData.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/9/26.
//

import Foundation

struct NetworkData {
    let gasPrice: Double              // Current gas price in Gwei
    let pendingTx: Int                // Pending transaction count
    let recentSpikePercent: Double    // % change in last 30 min (can be negative)
    let highDuration: Int             // Minutes gas has been elevated (>40 Gwei)
    let timeUTC: Date                 // Current time in UTC
    let dayOfWeek: Int                // 0-6 (Sunday-Saturday)
    let gasPrices24h: [Double]        // Array of gas prices for last 24 hours (1440 elements, 1 per minute)
    let hourlyBaselines: [Double]     // 168 elements: 7-day hourly averages (dayOfWeek * 24 + hour)

    // MARK: - Mock Data Generators

    /// Generates a realistic 24h gas price array with daily cycles, trend, and deterministic noise
    static func generateMockPrices24h(
        basePrice: Double,
        volatility: Double,
        trendSlope: Double,
        spikeAtMinute: Int? = nil,
        spikeAmount: Double = 0
    ) -> [Double] {
        (0..<1440).map { minute in
            let trend = trendSlope * Double(minute) / 1440.0
            let dailyCycle = -cos(Double(minute) / 1440.0 * 2 * .pi) * volatility * 0.4
            let noise = sin(Double(minute) * 0.17) * volatility * 0.12
                      + sin(Double(minute) * 0.43) * volatility * 0.08
                      + cos(Double(minute) * 0.29) * volatility * 0.05
            var spike: Double = 0
            if let spikeStart = spikeAtMinute, minute >= spikeStart {
                let elapsed = Double(minute - spikeStart)
                spike = spikeAmount * exp(-elapsed / 40.0)
            }
            return max(1.0, basePrice + trend + dailyCycle + noise + spike)
        }
    }

    /// Generates realistic 168-hour baselines with weekday/weekend patterns
    static func generateMockBaselines(baseLevel: Double) -> [Double] {
        (0..<168).map { index in
            let day = index / 24    // 0=Sunday, 6=Saturday
            let hour = index % 24
            let isWeekend = (day == 0 || day == 6)

            // Daily cycle: low at UTC 2-6, peak at UTC 14-18
            let dailyCycle = -cos(Double(hour - 3) / 24.0 * 2 * .pi) * baseLevel * 0.3

            // Weekend discount
            let weekendFactor: Double = isWeekend ? 0.6 : 1.0

            // Weekday peak boost during US/EU business hours
            let peakBoost: Double = (!isWeekend && hour >= 13 && hour <= 18) ? baseLevel * 0.4 : 0

            return max(3.0, (baseLevel + dailyCycle + peakBoost) * weekendFactor)
        }
    }

    // MARK: - Static Mock Data for Testing

    /// Network congestion scenario - prices ramping up with a recent spike
    static let congestedNetwork = NetworkData(
        gasPrice: 75,
        pendingTx: 250000,
        recentSpikePercent: 20,
        highDuration: 90,
        timeUTC: Date(),
        dayOfWeek: Calendar.current.component(.weekday, from: Date()) - 1,
        gasPrices24h: generateMockPrices24h(basePrice: 45, volatility: 12, trendSlope: 30, spikeAtMinute: 1350, spikeAmount: 25),
        hourlyBaselines: generateMockBaselines(baseLevel: 35)
    )

    /// Gas surging scenario - sudden spike in last 30 minutes
    static let surgingGas = NetworkData(
        gasPrice: 45,
        pendingTx: 180000,
        recentSpikePercent: 65,
        highDuration: 15,
        timeUTC: Date(),
        dayOfWeek: Calendar.current.component(.weekday, from: Date()) - 1,
        gasPrices24h: generateMockPrices24h(basePrice: 22, volatility: 8, trendSlope: 10, spikeAtMinute: 1410, spikeAmount: 20),
        hourlyBaselines: generateMockBaselines(baseLevel: 22)
    )

    /// Gas dropping scenario - prices declining over last 2 hours
    static let droppingGas = NetworkData(
        gasPrice: 25,
        pendingTx: 140000,
        recentSpikePercent: -35,
        highDuration: 0,
        timeUTC: Date(),
        dayOfWeek: Calendar.current.component(.weekday, from: Date()) - 1,
        gasPrices24h: generateMockPrices24h(basePrice: 40, volatility: 10, trendSlope: -18),
        hourlyBaselines: generateMockBaselines(baseLevel: 28)
    )

    /// Optimal weekend scenario - low gas on a Sunday
    static let optimalWeekend = NetworkData(
        gasPrice: 6,
        pendingTx: 120000,
        recentSpikePercent: -5,
        highDuration: 0,
        timeUTC: Date(),
        dayOfWeek: 0, // Sunday
        gasPrices24h: generateMockPrices24h(basePrice: 7, volatility: 2, trendSlope: -1),
        hourlyBaselines: generateMockBaselines(baseLevel: 12)
    )

    /// Normal activity scenario (should hide network status card)
    static let normalActivity = NetworkData(
        gasPrice: 15,
        pendingTx: 150000,
        recentSpikePercent: 5,
        highDuration: 0,
        timeUTC: Date(),
        dayOfWeek: 1,
        gasPrices24h: generateMockPrices24h(basePrice: 14, volatility: 4, trendSlope: 2),
        hourlyBaselines: generateMockBaselines(baseLevel: 18)
    )
}
