//
//  GasAveragesCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/31/26.
//

import SwiftUI

struct GasAveragesCard: View {
    // MARK: - Properties
    let avg1d: Double
    let avg3d: Double
    let avg7d: Double
    let cost1d: Double
    let cost3d: Double
    let cost7d: Double

    var body: some View {
        HStack(spacing: 0) {
            AverageColumn(period: "1 DAY", gwei: avg1d, cost: cost1d)

            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            AverageColumn(period: "3 DAY", gwei: avg3d, cost: cost3d)

            Rectangle()
                .fill(.black.opacity(0.2))
                .frame(width: 1)

            AverageColumn(period: "7 DAY", gwei: avg7d, cost: cost7d)
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
            Text("GAS AVERAGES")
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
    let gwei: Double
    let cost: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(period)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.black)

            Text("\(Int(gwei)) GWEI")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange)

            Text(String(format: "~$%.2f", cost))
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.black.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        GasAveragesCard(
            avg1d: 24, avg3d: 18, avg7d: 15,
            cost1d: 0.60, cost3d: 0.45, cost7d: 0.38
        )
        .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
