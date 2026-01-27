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
        GasStatusView(gweiValue: 128.5, statusMessage: "AVOID TRANSACTING")
        Spacer()
    }
    .background(.white)
}
