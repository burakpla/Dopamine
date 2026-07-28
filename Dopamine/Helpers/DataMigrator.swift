//
//  DataMigrator.swift
//  Dopamine
//
//  v1 (isCompleted/completedAt) verisini v2 (HabitLog) yapısına taşır.
//

// MARK: - Imports
import Foundation
import SwiftData

// MARK: - Data Migrator
enum DataMigrator {
    // MARK: Keys
    private static let migrationKey = "didMigrateToHabitLogV2"

    // MARK: Entry Point
    /// Uygulama açılışında bir kez çalışır; eski tamamlanma kayıtlarını log'a çevirir.
    @MainActor
    static func migrateIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        do {
            let habits = try context.fetch(FetchDescriptor<Habit>())

            for habit in habits {
                defer { habit.isMigrated = true }

                guard !habit.isMigrated,
                      habit.isCompleted,
                      let completedAt = habit.completedAt,
                      !habit.isCompleted(on: completedAt) else { continue }

                let log = HabitLog(
                    date: completedAt,
                    points: habit.points,
                    habitTitle: habit.title,
                    habit: habit
                )
                context.insert(log)
            }

            // Sıralama alanını ilk kez doldur.
            let ordered = habits.sorted { $0.createdAt > $1.createdAt }
            for (index, habit) in ordered.enumerated() where habit.sortOrder == 0 {
                habit.sortOrder = index
            }

            try context.save()
            UserDefaults.standard.set(true, forKey: migrationKey)
        } catch {
            print("Migration hatası: \(error)")
        }
    }
}
