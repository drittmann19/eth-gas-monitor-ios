//
//  ContentView.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State
    @StateObject private var gasManager = GasDataManager()
    @State private var selectedSpeed: GasSpeed = .fast
    @State private var testStatusIndex: Int = 0

    // Test status options
    private let testStatuses = ["OPTIMAL", "ACCEPTABLE", "COSTLY", "SEVERE"]

    // MARK: - Computed Properties
    private var gweiValue: Double {
        switch selectedSpeed {
        case .slow: return gasManager.slowGwei
        case .standard: return gasManager.standardGwei
        case .fast: return gasManager.fastGwei
        case .test: return 0
        }
    }

    private var statusMessage: String {
        if selectedSpeed == .test {
            return testStatuses[testStatusIndex]
        }
        switch gweiValue {
        case ..<8: return "OPTIMAL"
        case 8..<20: return "ACCEPTABLE"
        case 20..<50: return "COSTLY"
        default: return "SEVERE"
        }
    }

    private var statusColor: Color {
        StatusColor.color(for: statusMessage)
    }

    // MARK: - Network Data
    private var networkData: NetworkData {
        gasManager.networkData
    }

    // MARK: - Forecast
    private var forecast: GasForecast {
        GasForecastEngine.generateForecast(
            currentGwei: gweiValue,
            gasPrices24h: networkData.gasPrices24h,
            hourlyBaselines: networkData.hourlyBaselines,
            currentTime: networkData.timeUTC,
            dayOfWeek: networkData.dayOfWeek
        )
    }

    private var updatedText: String {
        if let error = gasManager.errorMessage {
            return error
        }
        guard let lastUpdated = gasManager.lastUpdated else {
            return "CONNECTING..."
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        return "UPDATED: \(formatter.string(from: lastUpdated))"
    }

    private func generateHourMarks(for currentTime: Date) -> [HourMark] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .current

        var marks: [HourMark] = []
        let calendar = Calendar.current
        for hourOffset in [-2, -1, 1, 2] {
            if let time = calendar.date(byAdding: .hour, value: hourOffset, to: currentTime) {
                let position = CGFloat(hourOffset + 2) / 4.0
                marks.append(HourMark(position: position, label: formatter.string(from: time)))
            }
        }
        return marks
    }

    var body: some View {
        ZStack {
            // Background color - white like the design
            Color.white
                .ignoresSafeArea()

            // Animated wave grid background
            WaveGridBackground(statusMessage: statusMessage)

            if gasManager.isLoading {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("FETCHING GAS DATA...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            } else {
                // Scrollable content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero gas display
                        GasStatusView(gweiValue: gweiValue, statusMessage: statusMessage, congestionPercent: gasManager.congestionPercent)
                            .padding(.top, 136)

                        // Metadata row
                        Text(updatedText)
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundStyle(gasManager.errorMessage != nil ? .red : .secondary)
                            .padding(.bottom, 96)

                        // Transaction costs card
                        TransactionCostsCard(
                            selectedSpeed: selectedSpeed,
                            statusColor: statusColor,
                            slowGwei: gasManager.slowGwei,
                            standardGwei: gasManager.standardGwei,
                            fastGwei: gasManager.fastGwei,
                            ethUsdPrice: gasManager.ethUsdPrice
                        )
                            .padding(.horizontal, 24)

                        // Gas trend card with forecast
                        GasTrendCard(
                            historicalData: forecast.historicalNormalized,
                            forecastData: forecast.forecastNormalized,
                            confidenceLow: forecast.confidenceLowNormalized,
                            confidenceHigh: forecast.confidenceHighNormalized,
                            changePercent: forecast.changePercent,
                            trendLabel: forecast.trendLabel,
                            hourMarks: generateHourMarks(for: networkData.timeUTC),
                            statusColor: statusColor
                        )
                            .padding(.horizontal, 24)
                            .padding(.top, 32)

                        // Swap averages card
                        GasAveragesCard(
                            cost1d: gasManager.averageSwapCost(days: 1),
                            cost3d: gasManager.averageSwapCost(days: 3),
                            cost7d: gasManager.averageSwapCost(days: 7)
                        )
                            .padding(.horizontal, 24)
                            .padding(.top, 32)

                        // Best window + Network status (side by side)
                        HStack(spacing: 12) {
                            BestWindowCard(
                                predictedWindow: forecast.bestWindow,
                                statusColor: statusColor
                            )

                            NetworkActivityCard(networkData: networkData, statusColor: statusColor)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    }
                    .padding(.bottom, 100)
                }
            }

            // Floating speed toggle
            VStack {
                Spacer()

                // Test status picker (only visible in test mode)
                if selectedSpeed == .test {
                    HStack(spacing: 8) {
                        ForEach(0..<testStatuses.count, id: \.self) { index in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    testStatusIndex = index
                                }
                            } label: {
                                Text(testStatuses[index])
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(testStatusIndex == index ?
                                                  StatusColor.color(for: testStatuses[index]) :
                                                  Color(white: 0.9))
                                    )
                                    .foregroundStyle(testStatusIndex == index ? .white : .black)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 12)
                }

                SpeedToggleView(selectedSpeed: $selectedSpeed)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }

            // Sticky floating header pill
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(.black)
                            .frame(width: 12, height: 12)
                        Text("ETH MAINNET")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .tracking(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.thickMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                    )

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }
        }
        .task {
            gasManager.startPolling()
        }
        .onDisappear {
            gasManager.stopPolling()
        }
    }
}

#Preview {
    ContentView()
}
