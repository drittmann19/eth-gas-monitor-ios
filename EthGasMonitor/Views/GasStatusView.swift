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

    var body: some View {
        VStack(spacing: 0) {
            // Info badge - bordered pill
            Text(String(format: "%.1f GWEI | CONGESTION %d%%", gweiValue, congestionPercent))
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
                .foregroundStyle(.orange)
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
