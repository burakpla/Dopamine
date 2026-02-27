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
    
    // MARK: Initializer
    init(habit: Habit) {
        self.habit = habit
    }
    
    // MARK: Actions
    func toggleCompletion(confettiTrigger: inout Int) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            habit.isCompleted.toggle()
            
            if habit.isCompleted {
                habit.completedAt = Date()
                confettiTrigger += 1 // Konfeti patlat!
                generator.impactOccurred()
            } else {
                habit.completedAt = nil
            }
        }
        
        
    }
}

