//
//  StatusColor.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/9/26.
//

import SwiftUI

enum StatusColor {
    static func color(for status: String) -> Color {
        switch status {
        case "OPTIMAL":
            return Color(red: 0x00/255, green: 0xC8/255, blue: 0x53/255)  // #00C853
        case "ACCEPTABLE":
            return Color(red: 0x00/255, green: 0xBC/255, blue: 0xD4/255)  // #00BCD4
        case "COSTLY":
            return Color(red: 0xFF/255, green: 0x6D/255, blue: 0x00/255)  // #FF6D00
        case "SEVERE":
            return Color(red: 0xD5/255, green: 0x00/255, blue: 0x00/255)  // #D50000
        default:
            return .orange
        }
    }
}
