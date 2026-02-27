//
//  DailyDetailViewModel.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Daily Detail ViewModel
@Observable
class DailyDetailViewModel {
    // MARK: Properties
    var date: Date
    var habits: [Habit]
    
    // MARK: Initializer
    init(date: Date, habits: [Habit]) {
        self.date = date
        self.habits = habits
    }
    
    // MARK: Computed
    var completedHabits: [Habit] {
        let calendar = Calendar.current
        return habits.filter { habit in
            guard let completedAt = habit.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: date)
        }
    }
    
    var dailyTotalPoints: Int {
        completedHabits.reduce(0) { $0 + $1.points }
    }
    
    var dailySummary: String {
        let count = completedHabits.count
        if count == 0 { return "O gün biraz dinlenmişsin kanka. 😴" }
        if count < 3 { return "Güzel bir başlangıç yapmıştın! ⚡️" }
        return "O gün tam bir canavardın! 🔥"
    }
}

