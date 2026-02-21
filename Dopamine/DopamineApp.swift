//
//  DopamineApp.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import SwiftUI
import SwiftData

@main
struct DopamineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Habit.self)
    }
}
