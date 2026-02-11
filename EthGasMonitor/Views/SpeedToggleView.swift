//
//  SpeedToggleView.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

// Enum for the three speed options
enum GasSpeed: String, CaseIterable {
    case slow = "SLOW"
    case standard = "STANDARD"
    case fast = "FAST"
}

struct SpeedToggleView: View {
    @Binding var selectedSpeed: GasSpeed
    @Namespace private var animation

    private let unselectedTextColor = Color(white: 0.4)

    var body: some View {
        HStack(spacing: 4) {
            ForEach(GasSpeed.allCases, id: \.self) { speed in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedSpeed = speed
                    }
                } label: {
                    Text(speed.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .tracking(0.5)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(selectedSpeed == speed ? .white : unselectedTextColor)
                        .background {
                            if selectedSpeed == speed {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(white: 0.15))
                                    .matchedGeometryEffect(id: "selector", in: animation)
                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        )
    }
}

#Preview {
    ZStack {
        // Colorful background to show glass effect
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3), .orange.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            SpeedToggleView(selectedSpeed: .constant(.fast))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
    }
}

#Preview("On White") {
    VStack {
        Spacer()
        SpeedToggleView(selectedSpeed: .constant(.standard))
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
    }
    .background(Color.white)
}
