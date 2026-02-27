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
    var title: String
    var difficulty: Int
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var completedAt: Date?
    
    // MARK: Initializer
    init(title: String, difficulty: Int = 1) {
        self.title = title
        self.difficulty = difficulty
    }
    
    // MARK: Computed
    var points: Int {
        switch difficulty {
        case 1: return 5
        case 2: return 15
        default: return 40
        }
    }
}

