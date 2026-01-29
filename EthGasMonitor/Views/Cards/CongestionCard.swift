//
//  CongestionCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/29/26.
//

import SwiftUI

struct CongestionCard: View {
    // MARK: - Static Data (will be dynamic later)
    let level: String = "HIGH"
    let percentage: Double = 0.88

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text("CONGESTION")
                .font(.system(size: 11, weight: .bold, design: .monospaced))

            // Thick divider
            Rectangle()
                .fill(.black)
                .frame(width: 70, height: 3)

            // Level label
            Text(level)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(.black)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.15))

                    Rectangle()
                        .fill(.black)
                        .frame(width: geo.size.width * percentage)
                }
            }
            .frame(height: 10)

            // Percentage label
            Text("\(Int(percentage * 100))%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
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

#Preview {
    VStack {
        CongestionCard()
            .padding(.horizontal, 16)
        Spacer()
    }
    .background(.white)
}
