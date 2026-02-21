//
//  Habit.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID = UUID()
    var title: String
    var difficulty: Int
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var completedAt: Date?
    
    init(title: String, difficulty: Int = 1) {
        self.title = title
        self.difficulty = difficulty
    }
    
    var points: Int {
        switch difficulty {
        case 1: return 5
        case 2: return 15
        default: return 40
        }
    }
}
