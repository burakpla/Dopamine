//
//  OnboardingViewModel.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//

// MARK: - Imports
import SwiftUI

// MARK: - Onboarding ViewModel
@Observable
class OnboardingViewModel {
    // MARK: Properties
    var name: String = ""
    
    // MARK: Actions
    func completeOnboarding(storageName: inout String, storageStatus: inout Bool) {
        guard !name.isEmpty else { return }
        
        storageName = name
        storageStatus = true
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

