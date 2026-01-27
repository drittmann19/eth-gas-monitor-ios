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
    // @Binding allows parent view to pass in and control this value
    @Binding var selectedSpeed: GasSpeed

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GasSpeed.allCases, id: \.self) { speed in
                Button {
                    selectedSpeed = speed
                } label: {
                    Text(speed.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedSpeed == speed ? .orange : .white)
                        .foregroundStyle(selectedSpeed == speed ? .white : .black)
                }
                .buttonStyle(.plain)

                // Add divider between segments (but not after last)
                if speed != GasSpeed.allCases.last {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 2)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
        SpeedToggleView(selectedSpeed: .constant(.fast))
            .padding(.horizontal, 16)
    }
}
