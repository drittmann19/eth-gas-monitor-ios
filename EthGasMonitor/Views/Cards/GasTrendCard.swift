//
//  GasTrendCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/29/26.
//

import SwiftUI

struct GasTrendCard: View {
    // MARK: - Static Data (will be dynamic later)
    let trendData: [Double] = [0.15, 0.18, 0.25, 0.22, 0.35, 0.30, 0.42, 0.38, 0.48, 0.55, 0.70, 0.85]
    let changePercent: String = "+45%"
    let trendLabel: String = "SURGING"

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text("GAS TREND")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))

                Spacer()

                Text(changePercent)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black)
            }
            .padding(.bottom, 12)

            // Chart area
            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height

                ZStack(alignment: .topLeading) {
                    // Grid lines
                    ForEach(1..<4) { i in
                        Rectangle()
                            .fill(.black.opacity(0.08))
                            .frame(height: 1)
                            .offset(y: chartHeight * CGFloat(i) / 4.0)
                    }

                    // Trend line
                    TrendLineShape(data: trendData)
                        .stroke(.orange, lineWidth: 2.5)

                    // End dot
                    Circle()
                        .fill(.orange)
                        .frame(width: 12, height: 12)
                        .position(
                            x: chartWidth,
                            y: chartHeight * (1.0 - (trendData.last ?? 0))
                        )
                }
            }
            .frame(height: 140)
            .clipped()
            .padding(.bottom, 12)

            // Footer row
            HStack {
                Text("24H AGO")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black.opacity(0.4))

                Spacer()

                Text(trendLabel)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
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

// MARK: - Trend Line Shape
struct TrendLineShape: Shape {
    let data: [Double]

    func path(in rect: CGRect) -> Path {
        guard data.count >= 2 else { return Path() }

        let stepX = rect.width / CGFloat(data.count - 1)

        var path = Path()
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let y = rect.height * (1.0 - value)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

#Preview {
    VStack {
        GasTrendCard()
            .padding(.horizontal, 16)
        Spacer()
    }
    .background(.white)
}
