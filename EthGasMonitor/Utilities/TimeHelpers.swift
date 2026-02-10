//
//  TimeHelpers.swift
//  EthGasMonitor
//
//  Created by Damean Rittmann on 2/9/26.
//

import Foundation

enum TimeHelpers {

    /// Returns true if the given time is during peak trading hours (weekday 13:00-21:00 UTC)
    static func isPeakHours(_ time: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let hour = calendar.component(.hour, from: time)
        let weekday = calendar.component(.weekday, from: time)

        // Weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        // Monday-Friday = 2-6
        let isWeekday = weekday >= 2 && weekday <= 6
        let isDuringPeakHours = hour >= 13 && hour < 21

        return isWeekday && isDuringPeakHours
    }

    /// Returns true if the given time is during weekend morning (Saturday/Sunday 00:00-12:00 UTC)
    static func isWeekendMorning(_ time: Date, dayOfWeek: Int) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let hour = calendar.component(.hour, from: time)

        // dayOfWeek: 0 = Sunday, 6 = Saturday
        let isWeekend = dayOfWeek == 0 || dayOfWeek == 6
        let isMorning = hour >= 0 && hour < 12

        return isWeekend && isMorning
    }

    /// Returns true if the given time is during late night hours (00:00-06:00 UTC)
    static func isLateNight(_ time: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let hour = calendar.component(.hour, from: time)

        return hour >= 0 && hour < 6
    }
}
