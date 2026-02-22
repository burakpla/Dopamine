//
//  ContentView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userName") var userName: String = ""
    
    var body: some View {
        if userName.isEmpty {
            OnboardingView()
        } else {
            DashboardView()
        }
    }
}
