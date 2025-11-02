//
//  WeakDaysHelper.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.
//
import Foundation

struct WeakDaysHelper {
    static let dayFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    
    static let dowFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    static let monthFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    static func weekDays(for date: Date, calendar cal: Calendar = Calendar.current) -> [Date] {
        guard let interval = cal.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) }
    }
}
