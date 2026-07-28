//
//  DashboardViewModel.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//

// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Dashboard ViewModel
@Observable
class DashboardViewModel {
    // MARK: Properties
    var habits: [Habit] = []
    var logs: [HabitLog] = []
    var dailyTarget: Int = 500

    private let calendar = Calendar.current

    // MARK: Points
    /// Kalıcı toplam puan: tüm geçmiş kayıtların toplamı.
    var totalPoints: Int {
        logs.reduce(0) { $0 + $1.points }
    }

    var todayLogs: [HabitLog] {
        logs.filter { calendar.isDateInToday($0.date) }
    }

    var todayPoints: Int {
        todayLogs.reduce(0) { $0 + $1.points }
    }

    var dailyProgress: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(Double(todayPoints) / Double(dailyTarget), 1.0)
    }

    var isTargetAchieved: Bool { todayPoints >= dailyTarget }

    var remainingToTarget: Int { max(dailyTarget - todayPoints, 0) }

    var levelInfo: LevelSystem { LevelSystem(totalPoints: totalPoints) }

    // MARK: Habits
    var todayCompletedCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }

    var sortedHabits: [Habit] {
        habits.sorted {
            if $0.sortOrder != $1.sortOrder { return $0.sortOrder < $1.sortOrder }
            return $0.createdAt > $1.createdAt
        }
    }

    // MARK: Streak
    /// Üst üste en az bir alışkanlığın tamamlandığı gün sayısı.
    var globalStreak: Int {
        let days = Set(logs.map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: .now)
        if !days.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor),
                  days.contains(yesterday) else { return 0 }
            cursor = yesterday
        }

        var streak = 0
        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    /// Hedefin tutturulduğu toplam gün sayısı.
    var perfectDayCount: Int {
        pointsByDay.values.filter { $0 >= dailyTarget }.count
    }

    /// Tüm zamanların en uzun genel serisi.
    var bestGlobalStreak: Int {
        let days = Set(logs.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !days.isEmpty else { return 0 }

        var best = 1
        var current = 1
        for index in 1..<days.count {
            let diff = calendar.dateComponents([.day], from: days[index - 1], to: days[index]).day ?? 0
            current = (diff == 1) ? current + 1 : 1
            best = max(best, current)
        }
        return best
    }

    // MARK: Achievements
    var achievements: [Achievement] {
        AchievementEngine.evaluate(
            totalPoints: totalPoints,
            currentStreak: globalStreak,
            bestStreak: bestGlobalStreak,
            totalCompletions: logs.count,
            perfectDays: perfectDayCount,
            level: levelInfo.level
        )
    }

    var unlockedAchievements: [Achievement] { achievements.filter(\.isUnlocked) }

    // MARK: Aggregation
    /// Gün başına toplam puan sözlüğü (tek geçişte hesaplanır).
    private var pointsByDay: [Date: Int] {
        logs.reduce(into: [:]) { result, log in
            result[calendar.startOfDay(for: log.date), default: 0] += log.points
        }
    }

    // MARK: Actions
    func progress(forLastDays dayCount: Int) -> [DailyProgress] {
        let buckets = pointsByDay
        let today = calendar.startOfDay(for: .now)
        let items = (0..<dayCount).compactMap { offset -> DailyProgress? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DailyProgress(date: date, points: buckets[date] ?? 0)
        }
        return Array(items.reversed())
    }

    func getWeeklyData() -> [DailyProgress] { progress(forLastDays: 7) }

    func getMonthlyData() -> [DailyProgress] { progress(forLastDays: 30) }

    func points(on date: Date) -> Int {
        pointsByDay[calendar.startOfDay(for: date)] ?? 0
    }
}
