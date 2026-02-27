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
    
    // MARK: Constants
    let placeholders = [
        "Bugün neyi başaracaksın?",
        "Yeni bir alışkanlık, yeni bir sen.",
        "Kitap oku, su iç, spor yap...",
        "Küçük bir adım, büyük bir fark."
    ]
    
    // MARK: Actions
    func saveHabit(modelContext: ModelContext) -> Bool {
        guard !title.isEmpty else { return false }
        
        let newHabit = Habit(title: title, difficulty: selectedDifficulty)
        modelContext.insert(newHabit)
        
        do {
            try modelContext.save()
            return true
        } catch {
            print("Kaydetme hatası: \(error)")
            return false
        }
    }
}

