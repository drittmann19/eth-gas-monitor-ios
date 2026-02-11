//
//  ContentView.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State
    @State private var selectedSpeed: GasSpeed = .fast

    // MARK: - Computed Properties
    private var gweiValue: Double {
        switch selectedSpeed {
        case .slow: return 8.0
        case .standard: return 12.0
        case .fast: return 128.5
        }
    }

    private var statusMessage: String {
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

    // MARK: - Network Data (mock for now, will be API-driven)
    private var networkData: NetworkData {
        // TODO: Replace with real API data
        // Using congested network mock for demo
        NetworkData.congestedNetwork
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background color - white like the design
            Color.white
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Rectangle()
                            .fill(.black)
                            .frame(width: 16, height: 16)
                        Text("ETH MAINNET")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .tracking(2)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Hero gas display
                    GasStatusView(gweiValue: gweiValue, statusMessage: statusMessage, congestionPercent: 88)
                        .padding(.top, 96)

                    // Metadata row
                    Text("UPDATED: 00:00:12")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 96)

                    // Transaction costs card
                    TransactionCostsCard(selectedSpeed: selectedSpeed, statusColor: statusColor)
                        .padding(.horizontal, 24)

                    // Gas trend card
                    GasTrendCard(
                        trendData: [0.30, 0.28, 0.32, 0.35, 0.33, 0.40, 0.45, 0.42, 0.50, 0.55, 0.62, 0.70],
                        changePercent: "+45%",
                        trendLabel: "SURGING",
                        hourMarks: [
                            HourMark(position: 0.111, label: "12:00"),
                            HourMark(position: 0.444, label: "13:00"),
                            HourMark(position: 0.778, label: "14:00")
                        ],
                        statusColor: statusColor
                    )
                        .padding(.horizontal, 24)
                        .padding(.top, 32)

                    // Swap averages card
                    GasAveragesCard(
                        cost1d: 3.90, cost3d: 2.85, cost7d: 2.40
                    )
                        .padding(.horizontal, 24)
                        .padding(.top, 32)

                    // Best window + Network status (side by side)
                    HStack(spacing: 12) {
                        BestWindowCard()

                        NetworkActivityCard(networkData: networkData, statusColor: statusColor)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
                .padding(.bottom, 100)
            }

            // Floating speed toggle
            SpeedToggleView(selectedSpeed: $selectedSpeed)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
    }
}

#Preview {
    ContentView()
}
