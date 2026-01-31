//
//  NetworkActivityCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/31/26.
//

import SwiftUI

struct NetworkActivityCard: View {
    // MARK: - Properties
    let activityLevel: String
    let explanation: String
    let durationHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activityLevel)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange)

            Text(explanation)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.black)
                .lineSpacing(4)

            Text(durationHint)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.black.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .padding(.top, 2)
        .background(.white)
        .overlay(
            Rectangle()
                .stroke(.black, lineWidth: 2)
        )
        .overlay(alignment: .topLeading) {
            Text("NETWORK ACTIVITY")
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

#Preview {
    VStack {
        NetworkActivityCard(
            activityLevel: "HIGH VOLUME",
            explanation: "Major NFT mint driving\nelevated gas prices",
            durationHint: "Typical duration: 1-3 hours"
        )
        .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
