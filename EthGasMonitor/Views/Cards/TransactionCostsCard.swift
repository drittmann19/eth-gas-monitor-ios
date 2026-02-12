//
//  TransactionCostsCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct TransactionCostsCard: View {
    // MARK: - Input
    let selectedSpeed: GasSpeed
    let statusColor: Color

    // MARK: - Computed Costs (based on speed)
    private var transferCost: Double {
        switch selectedSpeed {
        case .slow: return 0.40
        case .standard, .test: return 0.60
        case .fast: return 6.50
        }
    }

    private var swapCost: Double {
        switch selectedSpeed {
        case .slow: return 2.60
        case .standard, .test: return 3.90
        case .fast: return 42.00
        }
    }

    private var mintCost: Double {
        switch selectedSpeed {
        case .slow: return 5.30
        case .standard, .test: return 7.90
        case .fast: return 85.00
        }
    }

    var body: some View {
        // Card content
        HStack(spacing: 0) {
            // Transfer column
            CostColumn(label: "TRANSFER", cost: transferCost, costColor: .black)

            // Divider
            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            // Swap column
            CostColumn(label: "SWAP", cost: swapCost, costColor: statusColor)

            // Divider
            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            // Mint column
            CostColumn(label: "MINT", cost: mintCost, costColor: .black)
        }
        .padding(.vertical, 16)
        .padding(.top, 2)
        .fixedSize(horizontal: false, vertical: true)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 2)
        )
        .overlay(alignment: .topLeading) {
            Text("ESTIMATED COSTS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black)
                .offset(x: 12, y: -10)
        }
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
    var costColor: Color = .black

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.gray)

            Text(String(format: "$%.2f", cost))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(costColor)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        TransactionCostsCard(selectedSpeed: .fast, statusColor: StatusColor.color(for: "SEVERE"))
            .padding(.horizontal, 16)
        Spacer()
    }
    .background(.white)
}
