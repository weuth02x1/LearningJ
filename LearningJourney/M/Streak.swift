//
//  Streak.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447

import Foundation

struct Streak: Codable, Equatable {
    var learnedDates: Set<Date> = []
    var freezedDates: Set<Date> = []
    var streakDays: Int = 0
    var freezesUsed: Int = 0
    
    var lastLoggedDate: Date? = nil
}
