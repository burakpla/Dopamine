//
//  LevelSystem.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


import SwiftUI

struct LevelSystem {
    let totalPoints: Int
    
    var level: Int {
        return (totalPoints / 200) + 1
    }
    
    var rank: String {
        switch level {
        case 1: return "Çaylak"
        case 2: return "Gelişmekte Olan"
        case 3: return "Odak Ustası"
        case 4: return "Dopamin Mimarı"
        default: return "Efsane"
        }
    }
    
    var themeColor: Color {
        switch level {
        case 1: return .blue
        case 2: return .purple
        case 3: return .orange
        case 4: return .red
        default: return .indigo
        }
    }
}
