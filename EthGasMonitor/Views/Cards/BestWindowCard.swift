//
//  BestWindowCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/29/26.
//

import SwiftUI

struct BestWindowCard: View {
    // MARK: - Static Data (will be dynamic later)
    let startTime: String = "02:00"
    let endTime: String = "04:00"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text("BEST WINDOW")
                .font(.system(size: 11, weight: .bold, design: .monospaced))

            // Thick divider
            Rectangle()
                .fill(.black)
                .frame(width: 70, height: 3)

            // Start time
            Text(startTime)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(.black)

            // TO label
            Text("TO")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.gray)

            // End time
            Text(endTime)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(.orange)
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
        BestWindowCard()
            .padding(.horizontal, 16)
        Spacer()
    }
    .background(.white)
}
