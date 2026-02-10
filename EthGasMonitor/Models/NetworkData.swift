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
    let gasPrices24h: [Double]        // Array of gas prices for last 24 hours

    // MARK: - Static Mock Data for Testing

    /// Network congestion scenario
    static let congestedNetwork = NetworkData(
        gasPrice: 75,
        pendingTx: 250000,
        recentSpikePercent: 20,
        highDuration: 90,
        timeUTC: Date(),
        dayOfWeek: Calendar.current.component(.weekday, from: Date()) - 1,
        gasPrices24h: Array(repeating: 65.0, count: 1440)
    )

    /// Gas surging scenario
    static let surgingGas = NetworkData(
        gasPrice: 45,
        pendingTx: 180000,
        recentSpikePercent: 65,
        highDuration: 15,
        timeUTC: Date(),
        dayOfWeek: Calendar.current.component(.weekday, from: Date()) - 1,
        gasPrices24h: Array(repeating: 30.0, count: 1440)
    )

    /// Gas dropping scenario
    static let droppingGas = NetworkData(
        gasPrice: 25,
        pendingTx: 140000,
        recentSpikePercent: -35,
        highDuration: 0,
        timeUTC: Date(),
        dayOfWeek: Calendar.current.component(.weekday, from: Date()) - 1,
        gasPrices24h: Array(repeating: 40.0, count: 1440)
    )

    /// Optimal weekend scenario
    static let optimalWeekend = NetworkData(
        gasPrice: 6,
        pendingTx: 120000,
        recentSpikePercent: -5,
        highDuration: 0,
        timeUTC: Date(),
        dayOfWeek: 0, // Sunday
        gasPrices24h: Array(repeating: 8.0, count: 1440)
    )

    /// Normal activity scenario (should hide card)
    static let normalActivity = NetworkData(
        gasPrice: 15,
        pendingTx: 150000,
        recentSpikePercent: 5,
        highDuration: 0,
        timeUTC: Date(),
        dayOfWeek: 1,
        gasPrices24h: Array(repeating: 15.0, count: 1440)
    )
}
