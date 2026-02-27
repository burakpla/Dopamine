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
    var dailyTarget: Int = 500
    
    // MARK: Computed
    var totalPoints: Int {
        habits.filter { $0.isCompleted }.reduce(0) { $0 + $1.points }
    }
    
    var todayPoints: Int {
        let calendar = Calendar.current
        return habits.filter { habit in
            guard let date = habit.completedAt, calendar.isDateInToday(date) else { return false }
            return true
        }.reduce(0) { $0 + $1.points }
    }
    
    var dailyProgress: Double {
        guard dailyTarget > 0 else { return 0 }
        return min(Double(todayPoints) / Double(dailyTarget), 1.0)
    }
    
    var isTargetAchieved: Bool { todayPoints >= dailyTarget }
    
    var levelInfo: LevelSystem { LevelSystem(totalPoints: totalPoints) }
    
    // MARK: Actions
    func getWeeklyData() -> [DailyProgress] {
        let calendar = Calendar.current
        return (0..<7).map { dayOffset in
            let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let dayPoints = habits.filter { habit in
                guard let completedDate = habit.completedAt else { return false }
                return calendar.isDate(completedDate, inSameDayAs: targetDate)
            }.reduce(0) { $0 + $1.points }
            return DailyProgress(date: targetDate, points: dayPoints)
        }.reversed()
    }
}

