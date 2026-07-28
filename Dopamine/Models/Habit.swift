//
//  Habit.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

// MARK: - Imports
import Foundation
import SwiftData

// MARK: - Habit Model
@Model
final class Habit {
    // MARK: Properties
    var id: UUID = UUID()
    var title: String = ""
    var difficulty: Int = 1
    var createdAt: Date = Date()
    /// Listedeki manuel sıralama.
    var sortOrder: Int = 0

    // MARK: Legacy (v1 verisinin migration'ı için tutuluyor - doğrudan kullanma)
    var isCompleted: Bool = false
    var completedAt: Date?
    /// Eski `completedAt` kaydının log'a taşınıp taşınmadığını belirtir.
    var isMigrated: Bool = false

    // MARK: Relationships
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]? = []

    // MARK: Initializer
    init(title: String, difficulty: Int = 1, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.difficulty = difficulty
        self.createdAt = Date()
        self.sortOrder = sortOrder
        self.isMigrated = true
    }

    // MARK: Computed
    var points: Int {
        switch difficulty {
        case 1: return 5
        case 2: return 15
        default: return 40
        }
    }

    var allLogs: [HabitLog] { logs ?? [] }

    // MARK: Completion
    func log(on date: Date = .now) -> HabitLog? {
        let calendar = Calendar.current
        return allLogs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func isCompleted(on date: Date = .now) -> Bool {
        log(on: date) != nil
    }

    var isCompletedToday: Bool { isCompleted(on: .now) }

    // MARK: Streak
    /// Bugünden (veya dünden) geriye doğru kesintisiz tamamlanan gün sayısı.
    var currentStreak: Int {
        let calendar = Calendar.current
        let days = Set(allLogs.map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: .now)
        // Bugün henüz yapılmadıysa seriyi dünden saymaya başla.
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

    /// Tüm zamanların en uzun serisi.
    var bestStreak: Int {
        let calendar = Calendar.current
        let days = Set(allLogs.map { calendar.startOfDay(for: $0.date) }).sorted()
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
}
