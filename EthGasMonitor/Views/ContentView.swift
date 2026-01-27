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
        switch selectedSpeed {
        case .slow: return "GOOD TO TRANSACT"
        case .standard: return "MODERATE"
        case .fast: return "AVOID TRANSACTING"
        }
    }

    var body: some View {
        ZStack {
            // Background color - white like the design
            Color.white
                .ignoresSafeArea()

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
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Hero gas display
                GasStatusView(gweiValue: gweiValue, statusMessage: statusMessage)
                    .padding(.top, 24)

                // Speed toggle
                SpeedToggleView(selectedSpeed: $selectedSpeed)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                // Metadata row
                Text("UPDATED: 00:00:12")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)

                // Transaction costs card
                TransactionCostsCard()
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
