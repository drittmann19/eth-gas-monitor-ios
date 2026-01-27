//
//  ContentView.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/26/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background color - white like the design
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 16, height: 16)
                    Text("ETH MAINNET")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .tracking(2)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Hero gas display
                GasStatusView()
                    .padding(.top, 24)

                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
