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
    var logs: [HabitLog]

    // MARK: Initializer
    init(date: Date, logs: [HabitLog]) {
        self.date = date
        self.logs = logs
    }

    // MARK: Computed
    var dayLogs: [HabitLog] {
        let calendar = Calendar.current
        return logs
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.points > $1.points }
    }

    var dailyTotalPoints: Int {
        dayLogs.reduce(0) { $0 + $1.points }
    }

    var isToday: Bool { Calendar.current.isDateInToday(date) }

    var dailySummary: String {
        let count = dayLogs.count
        switch count {
        case 0: return isToday ? "Henüz başlamadın, hadi bakalım! 🚀" : "O gün biraz dinlenmişsin kanka. 😴"
        case 1...2: return "Güzel bir başlangıç yapmıştın! ⚡️"
        case 3...5: return "O gün tam bir canavardın! 🔥"
        default: return "Efsanevi bir gün! Bu tempoyu koru. 👑"
        }
    }
}
