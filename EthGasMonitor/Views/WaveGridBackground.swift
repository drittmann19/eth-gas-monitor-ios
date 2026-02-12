//
//  WaveGridBackground.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/9/26.
//

import SwiftUI

struct WaveGridBackground: View {
    let statusMessage: String

    // MARK: - Wave Parameters Based on Status
    private var waveParams: WaveParameters {
        switch statusMessage {
        case "OPTIMAL":
            // Was Acceptable - gentle movement
            return WaveParameters(
                amplitude: 0.1,
                speed: 0.35,
                turbulence: 0.15,
                lineOpacity: 0.35
            )
        case "ACCEPTABLE":
            // Was Costly - moderate waves
            return WaveParameters(
                amplitude: 0.18,
                speed: 0.5,
                turbulence: 0.35,
                lineOpacity: 0.4
            )
        case "COSTLY":
            // New middle ground between old Costly and Severe
            return WaveParameters(
                amplitude: 0.24,
                speed: 0.65,
                turbulence: 0.48,
                lineOpacity: 0.45
            )
        case "SEVERE":
            // Most chaotic
            return WaveParameters(
                amplitude: 0.3,
                speed: 0.8,
                turbulence: 0.6,
                lineOpacity: 0.25
            )
        default:
            return WaveParameters(
                amplitude: 0.1,
                speed: 0.35,
                turbulence: 0.15,
                lineOpacity: 0.4
            )
        }
    }

    private var statusColor: Color {
        StatusColor.color(for: statusMessage)
    }

    // Grid configuration - tighter, more lines
    private let gridLinesX = 60
    private let gridLinesZ = 50

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                drawWaveGrid(context: context, size: size, time: time)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Noise Function (multi-octave for organic feel)

    private func noise(x: Double, z: Double, time: Double, turbulence: CGFloat) -> Double {
        let t = turbulence

        // Base wave - slow, large
        let base = sin(x * 0.8 + time * 0.5) * cos(z * 0.6 + time * 0.3)

        // Medium detail
        let medium = sin(x * 1.7 + z * 1.3 + time * 0.7) * 0.5

        // Fine detail (adds choppiness)
        let fine = sin(x * 3.2 + time * 1.1) * sin(z * 2.8 + time * 0.9) * Double(t)

        // Extra turbulence layer
        let turb = sin(x * 5.1 + z * 4.7 + time * 1.5) * Double(t) * 0.5

        return base + medium * Double(t * 0.5 + 0.5) + fine + turb
    }

    // MARK: - Drawing

    private func drawWaveGrid(context: GraphicsContext, size: CGSize, time: Double) {
        let params = waveParams
        let width = size.width
        let height = size.height

        // Full screen grid - no perspective, uniform coverage
        let gridTop: CGFloat = -height * 0.1
        let gridBottom: CGFloat = height * 1.1
        let gridHeight = gridBottom - gridTop

        // Calculate grid points with wave displacement
        var points: [[CGPoint]] = []

        for z in 0..<gridLinesZ {
            var row: [CGPoint] = []
            let zProgress = CGFloat(z) / CGFloat(gridLinesZ - 1)

            // Uniform Y distribution (no perspective convergence)
            let baseY = gridTop + gridHeight * zProgress

            // Full width for all rows
            let rowWidth = width * 1.2
            let rowStartX = (width - rowWidth) / 2

            for x in 0..<gridLinesX {
                let xProgress = CGFloat(x) / CGFloat(gridLinesX - 1)
                let pointX = rowStartX + rowWidth * xProgress

                // Multi-layered noise for organic terrain
                let noiseValue = noise(
                    x: Double(xProgress) * 8.0,
                    z: Double(zProgress) * 6.0,
                    time: time * params.speed,
                    turbulence: params.turbulence
                )

                // Wave height scales with amplitude
                let waveHeight = noiseValue * Double(params.amplitude * height * 0.3)

                let pointY = baseY - waveHeight

                row.append(CGPoint(x: pointX, y: pointY))
            }
            points.append(row)
        }

        // Draw horizontal lines (across X) with smooth curves
        for z in 0..<gridLinesZ {
            let path = smoothPath(through: points[z])

            context.stroke(
                path,
                with: .color(statusColor.opacity(params.lineOpacity)),
                lineWidth: 0.8
            )
        }

        // Draw vertical lines (across Z) with smooth curves
        for x in stride(from: 0, to: gridLinesX, by: 2) {
            let xProgress = CGFloat(x) / CGFloat(gridLinesX - 1)
            let edgeFade = 1.0 - pow(abs(xProgress - 0.5) * 2, 4) * 0.6

            var columnPoints: [CGPoint] = []
            for z in 0..<gridLinesZ {
                columnPoints.append(points[z][x])
            }

            let path = smoothPath(through: columnPoints)
            let lineOpacity = params.lineOpacity * edgeFade * 0.5

            context.stroke(
                path,
                with: .color(statusColor.opacity(lineOpacity)),
                lineWidth: 0.5
            )
        }
    }

    // MARK: - Smooth Path Using Catmull-Rom Spline

    private func smoothPath(through points: [CGPoint]) -> Path {
        guard points.count >= 2 else { return Path() }

        var path = Path()
        path.move(to: points[0])

        if points.count == 2 {
            path.addLine(to: points[1])
            return path
        }

        for i in 0..<points.count - 1 {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = i < points.count - 2 ? points[i + 2] : points[i + 1]

            let tension: CGFloat = 0.5

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6 * tension,
                y: p1.y + (p2.y - p0.y) / 6 * tension
            )

            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6 * tension,
                y: p2.y - (p3.y - p1.y) / 6 * tension
            )

            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }

        return path
    }
}

// MARK: - Wave Parameters

private struct WaveParameters {
    let amplitude: CGFloat
    let speed: Double
    let turbulence: CGFloat
    let lineOpacity: Double
}

// MARK: - Previews

#Preview("Optimal") {
    ZStack {
        Color.white
        WaveGridBackground(statusMessage: "OPTIMAL")

        VStack {
            Text("OPTIMAL")
                .font(.system(size: 56, weight: .heavy, design: .monospaced))
                .foregroundStyle(StatusColor.color(for: "OPTIMAL"))
            Spacer()
        }
        .padding(.top, 100)
    }
}

#Preview("Acceptable") {
    ZStack {
        Color.white
        WaveGridBackground(statusMessage: "ACCEPTABLE")

        VStack {
            Text("ACCEPTABLE")
                .font(.system(size: 48, weight: .heavy, design: .monospaced))
                .foregroundStyle(StatusColor.color(for: "ACCEPTABLE"))
            Spacer()
        }
        .padding(.top, 100)
    }
}

#Preview("Costly") {
    ZStack {
        Color.white
        WaveGridBackground(statusMessage: "COSTLY")

        VStack {
            Text("COSTLY")
                .font(.system(size: 56, weight: .heavy, design: .monospaced))
                .foregroundStyle(StatusColor.color(for: "COSTLY"))
            Spacer()
        }
        .padding(.top, 100)
    }
}

#Preview("Severe") {
    ZStack {
        Color.white
        WaveGridBackground(statusMessage: "SEVERE")

        VStack {
            Text("SEVERE")
                .font(.system(size: 56, weight: .heavy, design: .monospaced))
                .foregroundStyle(StatusColor.color(for: "SEVERE"))
            Spacer()
        }
        .padding(.top, 100)
    }
}
