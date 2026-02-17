//
//  GasDataManager.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/16/26.
//

import Combine
import Foundation

@MainActor
class GasDataManager: ObservableObject {
    // MARK: - Published State

    @Published var networkData: NetworkData = .normalActivity
    @Published var slowGwei: Double = 0
    @Published var standardGwei: Double = 0
    @Published var fastGwei: Double = 0
    @Published var ethUsdPrice: Double = 0
    @Published var congestionPercent: Int = 0
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?

    // MARK: - Internal State

    private var gasPriceHistory: [Double] = []
    private var hourlyBaselines: [Double] = []
    private var hourlyAccumulator: [Int: [Double]] = [:]
    private var consecutiveFailures: Int = 0

    private var gasPollingTask: Task<Void, Never>?
    private var ethPricePollingTask: Task<Void, Never>?
    private var feeHistoryPollingTask: Task<Void, Never>?
    private var persistTask: Task<Void, Never>?

    private var lastPersistDate: Date = .distantPast

    // MARK: - Constants

    private static let historyCapacity = 1440 // 24 hours at 1-minute resolution
    private static let gasPollingInterval: TimeInterval = 15
    private static let ethPricePollingInterval: TimeInterval = 60
    private static let feeHistoryPollingInterval: TimeInterval = 300 // 5 minutes

    // MARK: - Lifecycle

    func startPolling() {
        NSLog("[GasDataManager] startPolling called")
        loadPersistedState()

        // Initial fetch
        gasPollingTask = Task {
            NSLog("[GasDataManager] initialFetch starting")
            await initialFetch()

            // Gas price polling loop (every 15s)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(Self.gasPollingInterval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await fetchGasPrice()
            }
        }

        ethPricePollingTask = Task {
            // ETH price polling loop (every 60s)
            // Initial fetch is handled in initialFetch, so wait first
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(Self.ethPricePollingInterval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await fetchETHPrice()
            }
        }

        feeHistoryPollingTask = Task {
            // Fee history polling loop (every 5 min)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(Self.feeHistoryPollingInterval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                await fetchFeeHistory()
            }
        }
    }

    func stopPolling() {
        gasPollingTask?.cancel()
        ethPricePollingTask?.cancel()
        feeHistoryPollingTask?.cancel()
        persistTask?.cancel()
        persistState()
    }

    // MARK: - Initial Fetch

    private func initialFetch() async {
        var gotGasPrice = false

        // Fetch gas price
        do {
            let price = try await EthereumService.fetchGasPrice()
            appendToHistory(price)
            gotGasPrice = true
            NSLog("[GasDataManager] Gas price: \(price) Gwei")
        } catch {
            NSLog("[GasDataManager] Gas price fetch failed: \(error)")
        }

        // Fetch fee history (independent — failure shouldn't block the app)
        do {
            let feeHistory = try await EthereumService.fetchFeeHistory()
            processFeeHistory(feeHistory)
            NSLog("[GasDataManager] Fee history: \(feeHistory.baseFeePerGas.count) blocks")
        } catch {
            NSLog("[GasDataManager] Fee history fetch failed: \(error)")
            // Seed tiers from gas price if feeHistory unavailable
            if gotGasPrice, let price = gasPriceHistory.last {
                slowGwei = price * 0.8
                standardGwei = price
                fastGwei = price * 1.25
            }
        }

        // Fetch ETH price (independent)
        do {
            let price = try await EthereumService.fetchETHPrice()
            ethUsdPrice = price
            NSLog("[GasDataManager] ETH price: $\(price)")
        } catch {
            NSLog("[GasDataManager] ETH price fetch failed: \(error)")
            ethUsdPrice = loadLastEthPrice()
        }

        // If we got at least the gas price, consider it a success
        if gotGasPrice {
            // Ensure history is padded to 1440 if feeHistory didn't seed it
            if gasPriceHistory.count < Self.historyCapacity {
                let firstValue = gasPriceHistory.first ?? 15
                let paddingCount = Self.historyCapacity - gasPriceHistory.count
                gasPriceHistory = Array(repeating: firstValue, count: paddingCount) + gasPriceHistory
            }

            rebuildNetworkData()
            isLoading = false
            lastUpdated = Date()
            errorMessage = nil
            consecutiveFailures = 0
            debouncedPersist()
        } else {
            consecutiveFailures += 1
            errorMessage = "UNABLE TO CONNECT"
            isLoading = false
        }
    }

    // MARK: - Polling Methods

    private func fetchGasPrice() async {
        do {
            let price = try await EthereumService.fetchGasPrice()
            appendToHistory(price)
            rebuildNetworkData()
            lastUpdated = Date()
            errorMessage = nil
            consecutiveFailures = 0
            debouncedPersist()
        } catch {
            NSLog("[GasDataManager] Gas poll failed: \(error)")
            consecutiveFailures += 1
            if consecutiveFailures >= 3 {
                errorMessage = "CONNECTION LOST"
            }
        }
    }

    private func fetchETHPrice() async {
        do {
            let price = try await EthereumService.fetchETHPrice()
            ethUsdPrice = price
            rebuildNetworkData()
        } catch {
            NSLog("[GasDataManager] ETH price poll failed: \(error)")
        }
    }

    private func fetchFeeHistory() async {
        do {
            let feeHistory = try await EthereumService.fetchFeeHistory()
            processFeeHistory(feeHistory)
            rebuildNetworkData()
        } catch {
            NSLog("[GasDataManager] Fee history poll failed: \(error)")
        }
    }

    // MARK: - Data Processing

    private func processFeeHistory(_ result: FeeHistoryResult) {
        // Convert hex base fees to Gwei
        let baseFees = result.baseFeePerGas.map { EthereumService.hexWeiToGwei($0) }

        // Derive speed tiers from reward percentiles + latest base fee
        if let rewards = result.reward, !rewards.isEmpty {
            let latestBaseFee = baseFees.last ?? baseFees.dropLast().last ?? 0

            // Collect priority fees at each percentile
            var p25Fees: [Double] = []
            var p50Fees: [Double] = []
            var p75Fees: [Double] = []

            for reward in rewards {
                if reward.count >= 3 {
                    p25Fees.append(EthereumService.hexWeiToGwei(reward[0]))
                    p50Fees.append(EthereumService.hexWeiToGwei(reward[1]))
                    p75Fees.append(EthereumService.hexWeiToGwei(reward[2]))
                }
            }

            // Use median of recent rewards (last 20 blocks) for stability
            let recentCount = min(20, p25Fees.count)
            let slowPriority = median(Array(p25Fees.suffix(recentCount)))
            let standardPriority = median(Array(p50Fees.suffix(recentCount)))
            let fastPriority = median(Array(p75Fees.suffix(recentCount)))

            let rawSlow = latestBaseFee + slowPriority
            let rawStandard = latestBaseFee + standardPriority
            let rawFast = latestBaseFee + fastPriority

            // Enforce minimum spread so tiers are visually distinct
            // When gas is very cheap, priority fees can be near-zero
            slowGwei = rawSlow
            standardGwei = max(rawStandard, rawSlow * 1.15)
            fastGwei = max(rawFast, standardGwei * 1.3)

            NSLog("[GasDataManager] Tiers — base: %.4f, slow: %.4f, standard: %.4f, fast: %.4f",
                  latestBaseFee, slowGwei, standardGwei, fastGwei)
        }

        // Compute congestion from gasUsedRatio
        if !result.gasUsedRatio.isEmpty {
            let recentRatios = Array(result.gasUsedRatio.suffix(100))
            let avgRatio = recentRatios.reduce(0, +) / Double(recentRatios.count)
            congestionPercent = Int((avgRatio * 100).rounded())
        }

        // Downsample block-level base fees to 1-minute resolution for history
        // ~1024 blocks at 12s/block = ~205 minutes → ~205 data points
        if baseFees.count > 1, gasPriceHistory.isEmpty {
            // On cold start, use feeHistory to seed price history
            let blocksPerMinute = 5.0 // ~12s per block
            var minutePrices: [Double] = []
            var i = 0
            while i < baseFees.count {
                let endIdx = min(i + Int(blocksPerMinute), baseFees.count)
                let slice = baseFees[i..<endIdx]
                let avg = slice.reduce(0, +) / Double(slice.count)
                minutePrices.append(avg)
                i = endIdx
            }

            // Pad front to fill 1440 entries
            let firstValue = minutePrices.first ?? 15
            let paddingCount = max(0, Self.historyCapacity - minutePrices.count)
            gasPriceHistory = Array(repeating: firstValue, count: paddingCount) + minutePrices
        }

        // Accumulate hourly baseline data
        accumulateBaseline(baseFees: baseFees)
    }

    private func appendToHistory(_ gwei: Double) {
        gasPriceHistory.append(gwei)
        if gasPriceHistory.count > Self.historyCapacity {
            gasPriceHistory.removeFirst(gasPriceHistory.count - Self.historyCapacity)
        }
    }

    private func rebuildNetworkData() {
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let dayOfWeek = calendar.component(.weekday, from: now) - 1

        let currentPrice = gasPriceHistory.last ?? standardGwei
        let spikePercent = GasMetrics.calculateRecentSpike(gasPriceHistory)
        let highDuration = GasMetrics.calculateHighDuration(gasPriceHistory)
        let pendingTx = derivePendingTx(congestionPercent: congestionPercent)

        // Use real baselines if accumulated, otherwise generate from current median
        let baselines: [Double]
        if hourlyBaselines.count == 168 {
            baselines = hourlyBaselines
        } else {
            let medianPrice = median(Array(gasPriceHistory.suffix(60)))
            baselines = NetworkData.generateMockBaselines(baseLevel: max(8, medianPrice))
        }

        networkData = NetworkData(
            gasPrice: currentPrice,
            pendingTx: pendingTx,
            recentSpikePercent: spikePercent,
            highDuration: highDuration,
            timeUTC: now,
            dayOfWeek: dayOfWeek,
            gasPrices24h: gasPriceHistory,
            hourlyBaselines: baselines
        )
    }

    private func derivePendingTx(congestionPercent: Int) -> Int {
        switch congestionPercent {
        case 91...100: return 250_000
        case 81...90: return 200_000
        case 71...80: return 170_000
        case 61...70: return 155_000
        case 51...60: return 145_000
        default: return 130_000
        }
    }

    // MARK: - Hourly Baseline Accumulation

    private func accumulateBaseline(baseFees: [Double]) {
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let dayOfWeek = calendar.component(.weekday, from: now) - 1
        let hour = calendar.component(.hour, from: now)
        let slot = dayOfWeek * 24 + hour

        let recentAvg = baseFees.suffix(50).reduce(0, +) / Double(min(50, baseFees.count))

        var samples = hourlyAccumulator[slot] ?? []
        samples.append(recentAvg)
        // Keep last 100 samples per slot
        if samples.count > 100 {
            samples = Array(samples.suffix(100))
        }
        hourlyAccumulator[slot] = samples

        // Rebuild baselines from accumulator
        var newBaselines = hourlyBaselines.count == 168 ? hourlyBaselines : NetworkData.generateMockBaselines(baseLevel: 15)
        for (s, vals) in hourlyAccumulator where !vals.isEmpty {
            newBaselines[s] = vals.reduce(0, +) / Double(vals.count)
        }
        hourlyBaselines = newBaselines
    }

    // MARK: - Swap Averages

    func averageSwapCost(days: Int) -> Double? {
        let minutesNeeded = days * 1440
        guard gasPriceHistory.count >= minutesNeeded else { return nil }

        let slice = Array(gasPriceHistory.suffix(minutesNeeded))
        let avgGwei = slice.reduce(0, +) / Double(slice.count)
        let swapGasUnits: Double = 130_000
        return avgGwei * swapGasUnits * 1e-9 * ethUsdPrice
    }

    // MARK: - Persistence

    private func loadPersistedState() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: "hourlyBaselines_v1"),
           let decoded = try? JSONDecoder().decode([Double].self, from: data),
           decoded.count == 168 {
            hourlyBaselines = decoded
        }

        if let data = defaults.data(forKey: "hourlyAccumulator_v1"),
           let decoded = try? JSONDecoder().decode([String: [Double]].self, from: data) {
            hourlyAccumulator = Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
                guard let intKey = Int(key) else { return nil }
                return (intKey, value)
            })
        }

        if let data = defaults.data(forKey: "gasPriceHistory_v1"),
           let decoded = try? JSONDecoder().decode([Double].self, from: data) {
            gasPriceHistory = Array(decoded.suffix(Self.historyCapacity))
        }

        let savedPrice = defaults.double(forKey: "lastEthUsdPrice")
        if savedPrice > 0 {
            ethUsdPrice = savedPrice
        }
    }

    private func loadLastEthPrice() -> Double {
        let saved = UserDefaults.standard.double(forKey: "lastEthUsdPrice")
        return saved > 0 ? saved : 0
    }

    private func persistState() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if hourlyBaselines.count == 168,
           let data = try? encoder.encode(hourlyBaselines) {
            defaults.set(data, forKey: "hourlyBaselines_v1")
        }

        let stringKeyedAccumulator = Dictionary(uniqueKeysWithValues: hourlyAccumulator.map { ("\($0.key)", $0.value) })
        if let data = try? encoder.encode(stringKeyedAccumulator) {
            defaults.set(data, forKey: "hourlyAccumulator_v1")
        }

        if let data = try? encoder.encode(gasPriceHistory) {
            defaults.set(data, forKey: "gasPriceHistory_v1")
        }

        if ethUsdPrice > 0 {
            defaults.set(ethUsdPrice, forKey: "lastEthUsdPrice")
        }
    }

    private func debouncedPersist() {
        let now = Date()
        guard now.timeIntervalSince(lastPersistDate) > 75 else { return }
        lastPersistDate = now
        persistState()
    }

    // MARK: - Helpers

    private func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[mid - 1] + sorted[mid]) / 2.0
        }
        return sorted[mid]
    }
}
