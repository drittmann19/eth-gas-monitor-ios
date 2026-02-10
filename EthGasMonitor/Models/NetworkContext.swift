//
//  NetworkContext.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/9/26.
//

import Foundation

struct NetworkContext: Identifiable {
    let id: String
    let title: String
    let reason: String
    let duration: String?
    let priority: Int
    let condition: (NetworkData) -> Bool
}

// MARK: - Network Contexts

enum NetworkContexts {

    // MARK: - Context Definitions

    static let networkCongestion = NetworkContext(
        id: "NETWORK_CONGESTION",
        title: "NETWORK CONGESTION",
        reason: "High transaction volume detected",
        duration: "Typically lasts 1-4 hours",
        priority: 10,
        condition: { data in
            data.gasPrice > 50 && data.pendingTx > 200000
        }
    )

    static let gasPriceSurging = NetworkContext(
        id: "GAS_SURGING",
        title: "GAS PRICE SURGING",
        reason: "Sudden increase in network activity",
        duration: "Monitor for next 30-60 minutes",
        priority: 9,
        condition: { data in
            data.recentSpikePercent > 50
        }
    )

    static let gasPriceDropping = NetworkContext(
        id: "GAS_DROPPING",
        title: "GAS PRICE DROPPING",
        reason: "Network congestion clearing",
        duration: "Good time to prepare transactions",
        priority: 8,
        condition: { data in
            data.recentSpikePercent < -30
        }
    )

    static let sustainedHighGas = NetworkContext(
        id: "SUSTAINED_HIGH",
        title: "SUSTAINED HIGH GAS",
        reason: "Network activity remains elevated",
        duration: "Consider waiting if not urgent",
        priority: 7,
        condition: { data in
            data.gasPrice > 40 && data.highDuration > 120
        }
    )

    static let peakTradingHours = NetworkContext(
        id: "PEAK_HOURS",
        title: "PEAK TRADING HOURS",
        reason: "High activity during US/EU business hours",
        duration: "Usually drops after 9pm UTC",
        priority: 6,
        condition: { data in
            data.gasPrice > 25 && TimeHelpers.isPeakHours(data.timeUTC)
        }
    )

    static let optimalWeekend = NetworkContext(
        id: "OPTIMAL_WEEKEND",
        title: "OPTIMAL WEEKEND",
        reason: "Low activity on weekend mornings",
        duration: "Typically lasts until afternoon UTC",
        priority: 5,
        condition: { data in
            data.gasPrice < 10 && TimeHelpers.isWeekendMorning(data.timeUTC, dayOfWeek: data.dayOfWeek)
        }
    )

    static let lateNightLow = NetworkContext(
        id: "LATE_NIGHT",
        title: "LATE NIGHT LOW",
        reason: "Reduced trading during off-peak hours",
        duration: "Low gas typically lasts until 12pm UTC",
        priority: 4,
        condition: { data in
            data.gasPrice < 15 && TimeHelpers.isLateNight(data.timeUTC)
        }
    )

    static let normalActivity = NetworkContext(
        id: "NORMAL_ACTIVITY",
        title: "NORMAL ACTIVITY",
        reason: "Gas prices within typical range",
        duration: nil,
        priority: 1,
        condition: { _ in true }
    )

    // MARK: - All Contexts (sorted by priority)

    static let allContexts: [NetworkContext] = [
        networkCongestion,
        gasPriceSurging,
        gasPriceDropping,
        sustainedHighGas,
        peakTradingHours,
        optimalWeekend,
        lateNightLow,
        normalActivity
    ].sorted { $0.priority > $1.priority }

    // MARK: - Context Matching

    /// Returns the highest priority matching context for the given network data
    static func getContext(for data: NetworkData) -> NetworkContext? {
        for context in allContexts {
            if context.condition(data) {
                return context
            }
        }
        return nil // Should never happen since normalActivity always matches
    }
}
