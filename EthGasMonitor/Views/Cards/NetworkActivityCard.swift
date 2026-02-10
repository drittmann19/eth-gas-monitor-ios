//
//  NetworkActivityCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/31/26.
//

import SwiftUI

struct NetworkActivityCard: View {
    // MARK: - Properties
    let networkData: NetworkData

    // MARK: - Computed Properties
    private var context: NetworkContext? {
        NetworkContexts.getContext(for: networkData)
    }

    var body: some View {
        if let context = context {
            VStack(alignment: .leading, spacing: 8) {
                Text(context.title)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)

                Text(context.reason)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(.black)
                    .lineSpacing(4)

                if let duration = context.duration {
                    Text(duration)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.black.opacity(0.4))
                }
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
                Text("NETWORK STATUS")
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
}

#Preview("Network Congestion") {
    VStack {
        NetworkActivityCard(networkData: .congestedNetwork)
            .padding(.horizontal, 24)
        Spacer()
    }
    .padding(.top, 20)
    .background(.white)
}

#Preview("Gas Surging") {
    VStack {
        NetworkActivityCard(networkData: .surgingGas)
            .padding(.horizontal, 24)
        Spacer()
    }
    .padding(.top, 20)
    .background(.white)
}

#Preview("Gas Dropping") {
    VStack {
        NetworkActivityCard(networkData: .droppingGas)
            .padding(.horizontal, 24)
        Spacer()
    }
    .padding(.top, 20)
    .background(.white)
}

#Preview("Optimal Weekend") {
    VStack {
        NetworkActivityCard(networkData: .optimalWeekend)
            .padding(.horizontal, 24)
        Spacer()
    }
    .padding(.top, 20)
    .background(.white)
}

#Preview("Normal Activity (Hidden)") {
    VStack {
        Text("Card should not appear below:")
            .font(.system(size: 12, design: .monospaced))
        NetworkActivityCard(networkData: .normalActivity)
            .padding(.horizontal, 24)
        Spacer()
    }
    .padding(.top, 20)
    .background(.white)
}
