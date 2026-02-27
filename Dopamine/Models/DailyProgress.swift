//
//  DailyProgress.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


// MARK: - Imports
import Foundation

// MARK: - Daily Progress Model
struct DailyProgress: Identifiable {
    // MARK: Properties
    let id = UUID()
    let date: Date
    let points: Int
}
