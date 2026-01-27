//
//  TransactionCostsCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct TransactionCostsCard: View {
    // MARK: - Static Data (will be dynamic later)
    let transferCost: Double = 6.50
    let swapCost: Double = 42.00
    let mintCost: Double = 85.00

    var body: some View {
        // Card content
        HStack(spacing: 0) {
            // Transfer column
            CostColumn(label: "TRANSFER", cost: transferCost)

            // Divider
            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            // Swap column
            CostColumn(label: "SWAP", cost: swapCost)

            // Divider
            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            // Mint column
            CostColumn(label: "MINT", cost: mintCost)
        }
        .padding(.vertical, 16)
        .fixedSize(horizontal: false, vertical: true)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 2)
        )
        .background(
            Rectangle()
                .fill(.black)
                .offset(x: 4, y: 4)
        )
    }
}

// MARK: - Cost Column Component
struct CostColumn: View {
    let label: String
    let cost: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.black)

            Text(String(format: "$%.2f", cost))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        TransactionCostsCard()
            .padding(.horizontal, 16)
        Spacer()
    }
    .background(.white)
}
