//
//  AddHabitViewModel.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Add Habit ViewModel
@Observable
class AddHabitViewModel {
    // MARK: Properties
    var title: String = ""
    var selectedDifficulty: Int = 1
    var errorMessage: String?

    // MARK: Constants
    let placeholders = [
        "Bugün neyi başaracaksın?",
        "Yeni bir alışkanlık, yeni bir sen.",
        "Kitap oku, su iç, spor yap...",
        "Küçük bir adım, büyük bir fark."
    ]

    /// Hızlı ekleme önerileri.
    let suggestions: [(title: String, difficulty: Int)] = [
        ("Su İç 💧", 1),
        ("10 Dk Yürüyüş 🚶", 1),
        ("Kitap Oku 📖", 2),
        ("Spor Yap 🏋️", 3),
        ("Meditasyon 🧘", 2),
        ("Erken Uyu 😴", 2)
    ]

    // MARK: Computed
    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool { !trimmedTitle.isEmpty && trimmedTitle.count <= 60 }

    // MARK: Actions
    func apply(suggestion: (title: String, difficulty: Int)) {
        title = suggestion.title
        selectedDifficulty = suggestion.difficulty
        HapticManager.light()
    }

    @discardableResult
    func saveHabit(modelContext: ModelContext) -> Bool {
        guard isValid else {
            errorMessage = trimmedTitle.isEmpty ? "Bir başlık gir." : "Başlık en fazla 60 karakter olabilir."
            HapticManager.error()
            return false
        }

        let nextOrder = (try? modelContext.fetchCount(FetchDescriptor<Habit>())) ?? 0
        let newHabit = Habit(title: trimmedTitle, difficulty: selectedDifficulty, sortOrder: nextOrder)
        modelContext.insert(newHabit)

        do {
            try modelContext.save()
            errorMessage = nil
            HapticManager.success()
            return true
        } catch {
            errorMessage = "Kaydedilemedi: \(error.localizedDescription)"
            HapticManager.error()
            return false
        }
    }
}
