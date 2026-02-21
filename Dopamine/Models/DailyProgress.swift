//
//  DailyProgress.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


import Foundation

struct DailyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let points: Int
}