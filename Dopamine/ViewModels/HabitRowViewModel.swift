//
//  HabitRowViewModel.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Habit Row ViewModel
@Observable
class HabitRowViewModel {
    // MARK: Properties
    var habit: Habit
    /// Satırın temsil ettiği gün (varsayılan: bugün).
    var referenceDate: Date

    // MARK: Initializer
    init(habit: Habit, referenceDate: Date = .now) {
        self.habit = habit
        self.referenceDate = referenceDate
    }

    // MARK: Computed
    var isCompleted: Bool { habit.isCompleted(on: referenceDate) }
    var currentStreak: Int { habit.currentStreak }

    // MARK: Actions
    /// Tamamlama durumunu değiştirir; log ekler veya siler.
    /// - Returns: Yeni tamamlanma durumu.
    @discardableResult
    func toggleCompletion(modelContext: ModelContext, confettiTrigger: inout Int) -> Bool {
        let willComplete = !isCompleted

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if willComplete {
                let log = HabitLog(
                    date: referenceDate,
                    points: habit.points,
                    habitTitle: habit.title,
                    habit: habit
                )
                modelContext.insert(log)
                confettiTrigger += 1
                HapticManager.success()
            } else if let existing = habit.log(on: referenceDate) {
                modelContext.delete(existing)
                HapticManager.light()
            }
        }

        try? modelContext.save()
        return willComplete
    }
}

// MARK: Delete and Duplicate
extension HabitRowViewModel {
    func deleteHabit(modelContext: ModelContext) {
        HapticManager.warning()
        modelContext.delete(habit)
        try? modelContext.save()
    }

    func duplicateHabit(modelContext: ModelContext) {
        let newHabit = Habit(
            title: "\(habit.title) (Kopya)",
            difficulty: habit.difficulty,
            sortOrder: habit.sortOrder + 1
        )
        modelContext.insert(newHabit)
        try? modelContext.save()
    }
}
