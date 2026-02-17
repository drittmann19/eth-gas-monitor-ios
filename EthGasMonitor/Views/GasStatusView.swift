//
//  GasStatusView.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct GasStatusView: View {
    // MARK: - Data (passed from parent)
    let gweiValue: Double
    let statusMessage: String
    let congestionPercent: Int

    // MARK: - Status Colors
    private var statusColor: Color {
        StatusColor.color(for: statusMessage)
    }

    private func formatGwei(_ value: Double) -> String {
        if value >= 100 { return String(format: "%.0f", value) }
        return String(format: "%.3f", value)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Info badge - bordered pill
            Text(String(format: "%@ GWEI | CONGESTION %d%%", formatGwei(gweiValue), congestionPercent))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                )

            // Large status name - the hero element
            Text(statusMessage)
                .font(.system(size: 56, weight: .heavy, design: .monospaced))
                .foregroundStyle(statusColor)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 4)
    }
}

#Preview {
    VStack {
        GasStatusView(gweiValue: 128.5, statusMessage: "SEVERE", congestionPercent: 88)
        Spacer()
    }
    .background(.white)
}
