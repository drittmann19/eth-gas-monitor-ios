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
    let historicalData: [Double]       // 0-1 normalized, left half
    let forecastData: [Double]         // 0-1 normalized, right half
    let confidenceLow: [Double]        // 0-1 normalized lower band
    let confidenceHigh: [Double]       // 0-1 normalized upper band
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

                    // NOW vertical line at center
                    Rectangle()
                        .fill(.black.opacity(0.2))
                        .frame(width: 1, height: chartHeight)
                        .offset(x: chartInset + drawableWidth * 0.5)

                    // Horizontal grid lines
                    ForEach(1..<4) { i in
                        Rectangle()
                            .fill(.black.opacity(0.08))
                            .frame(height: 1)
                            .offset(y: chartHeight * CGFloat(i) / 4.0)
                    }

                    // Confidence band (forecast region only)
                    if confidenceLow.count > 1 && confidenceHigh.count > 1 {
                        ConfidenceBandShape(
                            upperData: confidenceHigh,
                            lowerData: confidenceLow,
                            horizontalInset: chartInset,
                            startProportion: 0.5
                        )
                        .fill(statusColor.opacity(0.12))
                    }

                    // Historical line (solid, left half)
                    TrendLineShape(
                        data: historicalData,
                        horizontalInset: chartInset,
                        startProportion: 0.0,
                        endProportion: 0.5
                    )
                    .stroke(statusColor, lineWidth: 2.5)

                    // Forecast line (dashed, right half)
                    TrendLineShape(
                        data: forecastData,
                        horizontalInset: chartInset,
                        startProportion: 0.5,
                        endProportion: 1.0
                    )
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 2.5, dash: [6, 4]))

                    // NOW dot at center
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                        .position(
                            x: chartInset + drawableWidth * 0.5,
                            y: chartHeight * (1.0 - (historicalData.last ?? 0.5))
                        )

                    // FORECAST label on right side
                    Text("FORECAST")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundStyle(statusColor.opacity(0.5))
                        .position(
                            x: chartInset + drawableWidth * 0.82,
                            y: 10
                        )
                }
            }
            .frame(height: 140)
            .clipped()
            .padding(.bottom, 4)

            // X-axis hour labels
            GeometryReader { geo in
                let drawableWidth = geo.size.width - chartInset * 2
                let nowX = chartInset + drawableWidth * 0.5

                ForEach(hourMarks) { mark in
                    let markX = chartInset + drawableWidth * mark.position
                    if abs(markX - nowX) > 30 {
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

            // Disclaimer
            Text("BASED ON 7-DAY PATTERNS \u{00B7} NOT FINANCIAL ADVICE")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundStyle(.black.opacity(0.25))
                .padding(.top, 6)
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

// MARK: - Trend Line Shape (supports sub-ranges of the chart)
struct TrendLineShape: Shape {
    let data: [Double]
    var horizontalInset: CGFloat = 0
    var startProportion: CGFloat = 0.0
    var endProportion: CGFloat = 1.0

    func path(in rect: CGRect) -> Path {
        guard data.count >= 2 else { return Path() }

        let drawableWidth = rect.width - horizontalInset * 2
        let segmentStart = horizontalInset + drawableWidth * startProportion
        let segmentWidth = drawableWidth * (endProportion - startProportion)
        let stepX = segmentWidth / CGFloat(data.count - 1)

        var path = Path()
        for (index, value) in data.enumerated() {
            let x = segmentStart + CGFloat(index) * stepX
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

// MARK: - Confidence Band Shape
struct ConfidenceBandShape: Shape {
    let upperData: [Double]
    let lowerData: [Double]
    var horizontalInset: CGFloat = 0
    var startProportion: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        guard upperData.count >= 2, lowerData.count >= 2,
              upperData.count == lowerData.count else { return Path() }

        let drawableWidth = rect.width - horizontalInset * 2
        let segmentStart = horizontalInset + drawableWidth * startProportion
        let segmentWidth = drawableWidth * (1.0 - startProportion)
        let stepX = segmentWidth / CGFloat(upperData.count - 1)

        var path = Path()

        // Forward along upper bound
        for (index, value) in upperData.enumerated() {
            let x = segmentStart + CGFloat(index) * stepX
            let y = rect.height * (1.0 - value)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        // Backward along lower bound
        for index in stride(from: lowerData.count - 1, through: 0, by: -1) {
            let x = segmentStart + CGFloat(index) * stepX
            let y = rect.height * (1.0 - lowerData[index])
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack {
        GasTrendCard(
            historicalData: [0.30, 0.28, 0.32, 0.35, 0.33, 0.40, 0.45, 0.42, 0.50, 0.55, 0.62, 0.70],
            forecastData: [0.70, 0.68, 0.65, 0.60, 0.55, 0.50, 0.48, 0.45, 0.42, 0.40, 0.38, 0.35, 0.33],
            confidenceLow: [0.70, 0.65, 0.60, 0.53, 0.46, 0.39, 0.35, 0.30, 0.25, 0.22, 0.18, 0.14, 0.10],
            confidenceHigh: [0.70, 0.71, 0.70, 0.67, 0.64, 0.61, 0.61, 0.60, 0.59, 0.58, 0.58, 0.56, 0.56],
            changePercent: "+45%",
            trendLabel: "SURGING",
            hourMarks: [
                HourMark(position: 0.0, label: "12:00"),
                HourMark(position: 0.25, label: "13:00"),
                HourMark(position: 0.75, label: "15:00"),
                HourMark(position: 1.0, label: "16:00")
            ],
            statusColor: StatusColor.color(for: "SEVERE")
        )
        .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
