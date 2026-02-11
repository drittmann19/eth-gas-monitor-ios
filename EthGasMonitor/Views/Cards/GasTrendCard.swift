//
//  GasTrendCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/29/26.
//

import SwiftUI

struct HourMark: Identifiable {
    let id = UUID()
    let position: CGFloat
    let label: String
}

struct GasTrendCard: View {
    // MARK: - Properties
    let trendData: [Double]
    let changePercent: String
    let trendLabel: String
    let hourMarks: [HourMark]
    let statusColor: Color

    private let chartInset: CGFloat = 6

    var body: some View {
        VStack(spacing: 0) {
            // Trend label + change percent - right aligned
            HStack(spacing: 6) {
                Spacer()

                Text(trendLabel)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(statusColor)

                Text(changePercent)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(statusColor)
            }
            .padding(.bottom, 8)

            // Chart area
            GeometryReader { geo in
                let chartWidth = geo.size.width
                let chartHeight = geo.size.height
                let drawableWidth = chartWidth - chartInset * 2

                ZStack(alignment: .topLeading) {
                    // Vertical hour lines
                    ForEach(hourMarks) { mark in
                        Rectangle()
                            .fill(.black.opacity(0.08))
                            .frame(width: 1, height: chartHeight)
                            .offset(x: chartInset + drawableWidth * mark.position)
                    }

                    // Horizontal grid lines
                    ForEach(1..<4) { i in
                        Rectangle()
                            .fill(.black.opacity(0.08))
                            .frame(height: 1)
                            .offset(y: chartHeight * CGFloat(i) / 4.0)
                    }

                    // Trend line
                    TrendLineShape(data: trendData, horizontalInset: chartInset)
                        .stroke(statusColor, lineWidth: 2.5)

                    // End dot
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                        .position(
                            x: chartInset + drawableWidth,
                            y: chartHeight * (1.0 - (trendData.last ?? 0))
                        )
                }
            }
            .frame(height: 140)
            .clipped()
            .padding(.bottom, 4)

            // X-axis hour labels
            GeometryReader { geo in
                let drawableWidth = geo.size.width - chartInset * 2
                let nowX = chartInset + drawableWidth

                ForEach(hourMarks) { mark in
                    let markX = chartInset + drawableWidth * mark.position
                    if nowX - markX > 30 {
                        Text(mark.label)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.4))
                            .fixedSize()
                            .position(
                                x: markX,
                                y: geo.size.height / 2
                            )
                    }
                }

                Text("NOW")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.black.opacity(0.4))
                    .fixedSize()
                    .position(
                        x: nowX,
                        y: geo.size.height / 2
                    )
            }
            .frame(height: 14)
        }
        .padding(16)
        .padding(.top, 2)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 2)
        )
        // Title badge on top border
        .overlay(alignment: .topLeading) {
            Text("GAS TREND")
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

// MARK: - Trend Line Shape
struct TrendLineShape: Shape {
    let data: [Double]
    var horizontalInset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        guard data.count >= 2 else { return Path() }

        let drawableWidth = rect.width - horizontalInset * 2
        let stepX = drawableWidth / CGFloat(data.count - 1)

        var path = Path()
        for (index, value) in data.enumerated() {
            let x = horizontalInset + CGFloat(index) * stepX
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
        GasTrendCard(
            trendData: [0.30, 0.28, 0.32, 0.35, 0.33, 0.40, 0.45, 0.42, 0.50, 0.55, 0.62, 0.70],
            changePercent: "+45%",
            trendLabel: "SURGING",
            hourMarks: [
                HourMark(position: 0.111, label: "12:00"),
                HourMark(position: 0.444, label: "13:00"),
                HourMark(position: 0.778, label: "14:00")
            ],
            statusColor: StatusColor.color(for: "SEVERE")
        )
        .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
