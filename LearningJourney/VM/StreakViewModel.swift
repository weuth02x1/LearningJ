//
//  StreakViewModel.swift
//  LearningJourney
//
//  Created by شهد عبدالله القحطاني on 07/05/1447 AH.
//

import Foundation
import Combine

final class StreakViewModel: ObservableObject {
    @Published private(set) var streak: Streak
    @Published var learningTopic: String
    @Published var duration: Duration

    
    private let cal = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private var lastRefreshDay: Date = Calendar.current.startOfDay(for: Date())

    enum Duration { case week, month, year }

    // MARK: - Initializers
    init(streak: Streak = Streak(), learningTopic: String = "", duration: Duration = .week) {
        self.streak = streak
        self.learningTopic = learningTopic
        self.duration = duration
        loadData()
        observeTimer()
    }

//    init(mockLearned: Set<Date> = [], mockFreezed: Set<Date> = [], learningTopic: String = "", duration: Duration = .week) {
//        self.streak = Streak(learnedDates: mockLearned, freezedDates: mockFreezed)
//        self.learningTopic = learningTopic
//        self.duration = duration
//        self.streak.lastLoggedDate = lastLogged
//        recomputeStreak()
//    }
    init(mockLearned: Set<Date> = [], mockFreezed: Set<Date> = [], learningTopic: String = "", duration: Duration = .week, lastLogged: Date? = nil) {
        var mockStreak = Streak(learnedDates: mockLearned, freezedDates: mockFreezed)
        mockStreak.lastLoggedDate = lastLogged
        self.streak = mockStreak
        self.learningTopic = learningTopic
        self.duration = duration
        recomputeStreak()
    }


    // MARK: - Computed Properties
    var streakDays: Int { streak.streakDays }
    var freezesUsed: Int { streak.freezesUsed }
    var learnedDates: Set<Date> { streak.learnedDates }
    var freezedDates: Set<Date> { streak.freezedDates }
    var lastLoggedDate: Date? { streak.lastLoggedDate }

    var maxFreezes: Int {
        switch duration {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }

    var isFreezeDisabled: Bool {
        let today = cal.startOfDay(for: Date())
        return streak.freezesUsed >= maxFreezes || streak.freezedDates.contains(today) || streak.learnedDates.contains(today)
    }

    var isStreakExpired: Bool {
        guard let last = lastLoggedDate else { return false }
        return Date().timeIntervalSince(last) > 32 * 3600
    }
    func setLastLoggedDate(_ date: Date) {
        streak.lastLoggedDate = date
        recomputeStreak()
    }


    var isStreakCompleted: Bool {
        switch duration {
        case .week: return streakDays >= 7
        case .month: return streakDays >= 30
        case .year: return streakDays >= 365
        }
    }

    // MARK: - Actions
    func markAsLearned() {
        let today = cal.startOfDay(for: .now)
        guard !streak.learnedDates.contains(today) else { return }
        streak.learnedDates.insert(today)
        streak.freezedDates.remove(today)
        streak.lastLoggedDate = Date()
        recomputeStreak()
        saveData()
    }

    func toggleFreeze() {
        let today = cal.startOfDay(for: .now)
        guard !streak.freezedDates.contains(today) && !isFreezeDisabled else { return }

        if streak.learnedDates.contains(today) {
            streak.learnedDates.remove(today)
            recomputeStreak()
        }

        streak.freezedDates.insert(today)
        streak.freezesUsed += 1
        streak.lastLoggedDate = Date()
        saveData()
    }

    func unfreezeDay() {
        let today = cal.startOfDay(for: .now)
        if streak.freezedDates.contains(today) && streak.freezesUsed > 0 {
            streak.freezedDates.remove(today)
            streak.freezesUsed -= 1
            saveData()
        }
    }

    func resetStreak() {
        streak = Streak()
        saveData()
        objectWillChange.send()
    }

    // MARK: - Streak Logic
    func recomputeStreak() {
        let activeDays = streak.learnedDates.union(streak.freezedDates)
        let dates = activeDays.map { cal.startOfDay(for: $0) }.sorted()
        guard !dates.isEmpty else { streak.streakDays = 0; return }

        var count = 1
        for i in 1..<dates.count {
            let gap = cal.dateComponents([.day], from: dates[i - 1], to: dates[i]).day ?? 0
            count = (gap <= 1) ? (count + 1) : 1
        }
        streak.streakDays = count
    }

    // MARK: - Timer / Expiration
    private func observeTimer() {
        timer
            .sink { [weak self] _ in
                self?.checkStreakExpiration()
                self?.checkMidnightRefresh()
            }
            .store(in: &cancellables)
    }

    func checkStreakExpiration() {
        guard let last = streak.lastLoggedDate else { return }
        if Date().timeIntervalSince(last) > 32 * 3600 {
            resetStreak()
        }
    }

    private func checkMidnightRefresh() {
        let currentDay = cal.startOfDay(for: Date())
        if currentDay > lastRefreshDay {
            objectWillChange.send()
            lastRefreshDay = currentDay
        }
    }

    // MARK: - Persistence
    private enum Key {
        static let learned = "learnedDates"
        static let freezed = "freezedDates"
        static let streak = "streakDays"
        static let used = "freezesUsed"
        static let last = "lastLoggedDate"
    }

    private func saveData() {
        let encoder = JSONEncoder()
        let defaults = UserDefaults.standard
        defaults.set(try? encoder.encode(Array(streak.learnedDates)), forKey: Key.learned)
        defaults.set(try? encoder.encode(Array(streak.freezedDates)), forKey: Key.freezed)
        defaults.set(streak.streakDays, forKey: Key.streak)
        defaults.set(streak.freezesUsed, forKey: Key.used)
        if let last = streak.lastLoggedDate { defaults.set(last, forKey: Key.last) }
    }

    private func loadData() {
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: Key.learned),
           let decoded = try? decoder.decode([Date].self, from: data) {
            streak.learnedDates = Set(decoded)
        }

        if let data = defaults.data(forKey: Key.freezed),
           let decoded = try? decoder.decode([Date].self, from: data) {
            streak.freezedDates = Set(decoded)
        }

        streak.streakDays = defaults.integer(forKey: Key.streak)
        streak.freezesUsed = defaults.integer(forKey: Key.used)
        streak.lastLoggedDate = defaults.object(forKey: Key.last) as? Date
        recomputeStreak()
    }

    // MARK: - Helpers
    func stringFromDuration(_ duration: Duration) -> String {
        switch duration {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    static func durationFromString(_ period: String) -> Duration {
        switch period {
        case "Week": return .week
        case "Month": return .month
        case "Year": return .year
        default: return .week
        }
    }
}

