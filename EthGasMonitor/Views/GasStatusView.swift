//
//  GasStatusView.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct GasStatusView: View {
    // MARK: - Static Data (will be dynamic later)
    let gweiValue: Double = 128.5
    let statusMessage: String = "AVOID TRANSACTING"

    var body: some View {
        VStack(spacing: 0) {
            // Status badge - bordered pill
            Text(statusMessage)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                )

            // Large gwei number - the hero element
            Text(String(format: "%.1f", gweiValue))
                .font(.system(size: 96, weight: .heavy, design: .monospaced))
                .foregroundStyle(.orange)
                .padding(.top, 16)

            // Gwei label - orange to match
            Text("GWEI")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .tracking(8)
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview {
    VStack {
        // Header preview
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

        GasStatusView()

        Spacer()
    }
    .background(.white)
}
