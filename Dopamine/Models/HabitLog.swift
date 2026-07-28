//
//  HabitLog.swift
//  Dopamine
//
//  Tamamlanma kayıtlarını (geçmişi) tutan model.
//

// MARK: - Imports
import Foundation
import SwiftData

// MARK: - Habit Log Model
/// Bir alışkanlığın belirli bir gündeki tamamlanma kaydı.
/// Puan snapshot olarak saklanır; böylece alışkanlık silinse veya
/// zorluğu değişse bile geçmiş puanlar korunur.
@Model
final class HabitLog {
    // MARK: Properties
    var id: UUID = UUID()
    /// Günün başlangıcına normalize edilmiş tarih.
    var date: Date = Date()
    /// Kayıt anındaki puan değeri (snapshot).
    var points: Int = 0
    /// Kayıt anındaki alışkanlık başlığı (alışkanlık silinse de geçmiş okunabilsin).
    var habitTitle: String = ""

    var habit: Habit?

    // MARK: Initializer
    init(date: Date = .now, points: Int, habitTitle: String, habit: Habit? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.points = points
        self.habitTitle = habitTitle
        self.habit = habit
    }
}
