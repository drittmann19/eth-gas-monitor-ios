//
//  BestWindowCard.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 1/29/26.
//

import SwiftUI

struct BestWindowCard: View {
    // MARK: - Properties
    let predictedWindow: PredictedWindow
    let statusColor: Color

    private var timezoneAbbreviation: String {
        TimeZone.current.abbreviation() ?? "UTC"
    }

    private var startTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: predictedWindow.startDate)
    }

    private var endTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: predictedWindow.endDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Relative time label
            Text(predictedWindow.relativeLabel)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(predictedWindow.isNow ? statusColor : .black)

            // Time range on single line
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(startTimeFormatted)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                Text(" – ")
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .foregroundStyle(.gray)
                Text("\(endTimeFormatted)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
            }

            Text(timezoneAbbreviation)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.black.opacity(0.4))

            Spacer(minLength: 0)

            // Source label
            Text("Based on 7-day patterns")
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
        HStack(spacing: 12) {
            BestWindowCard(
                predictedWindow: PredictedWindow(
                    startDate: Date().addingTimeInterval(8 * 3600),
                    endDate: Date().addingTimeInterval(10 * 3600),
                    estimatedGwei: 12,
                    isNow: false,
                    relativeLabel: "IN 8 HOURS"
                ),
                statusColor: StatusColor.color(for: "OPTIMAL")
            )

            BestWindowCard(
                predictedWindow: PredictedWindow(
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(7200),
                    estimatedGwei: 6,
                    isNow: true,
                    relativeLabel: "NOW"
                ),
                statusColor: StatusColor.color(for: "OPTIMAL")
            )
        }
        .padding(.horizontal, 24)
        Spacer()
    }
    .background(.white)
}
