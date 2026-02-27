//
//  ContentView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

// MARK: - Imports
import SwiftUI

// MARK: - Content View
struct ContentView: View {
    // MARK: Storage
    @AppStorage("userName") var userName: String = ""
    
    // MARK: Body
    var body: some View {
        if userName.isEmpty {
            OnboardingView()
        } else {
            DashboardView()
        }
    }
}

