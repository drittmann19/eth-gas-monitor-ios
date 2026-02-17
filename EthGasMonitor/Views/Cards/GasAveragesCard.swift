//
//  GasAveragesCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/31/26.
//

import SwiftUI

struct GasAveragesCard: View {
    // MARK: - Properties
    let cost1d: Double?
    let cost3d: Double?
    let cost7d: Double?

    var body: some View {
        HStack(spacing: 0) {
            AverageColumn(period: "1 DAY", cost: cost1d)

            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            AverageColumn(period: "3 DAY", cost: cost3d)

            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            AverageColumn(period: "7 DAY", cost: cost7d)
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
            Text("SWAP AVERAGES")
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

// MARK: - Average Column Component
struct AverageColumn: View {
    let period: String
    let cost: Double?

    var body: some View {
        VStack(spacing: 4) {
            Text(period)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.gray)

            if let cost = cost {
                Text(String(format: "$%.2f", cost))
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black)
            } else {
                Text("--")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        GasAveragesCard(
            cost1d: 3.90, cost3d: 2.85, cost7d: nil
        )
        .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
