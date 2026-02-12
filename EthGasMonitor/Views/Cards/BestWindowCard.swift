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

    private var timezoneAbbreviation: String {
        TimeZone.current.abbreviation() ?? "UTC"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Start time
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(startTime)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                Text(timezoneAbbreviation)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }

            // TO label
            Text("TO")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.gray)

            // End time
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(endTime)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
                Text(timezoneAbbreviation)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }

            Spacer(minLength: 0)

            // Source label
            Text("Based on past 7 days")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
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
            Text("BEST WINDOW")
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
        BestWindowCard()
            .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
