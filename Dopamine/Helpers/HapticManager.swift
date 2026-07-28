//
//  HapticManager.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

// MARK: - Imports
import SwiftUI

// MARK: - Haptic Manager
class HapticManager {
    // MARK: Singleton
    static let instance = HapticManager()

    /// Kullanıcı ayarlarından titreşim tercihi.
    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    // MARK: Actions
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard Self.isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard Self.isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: Convenience
    static func success() { instance.notification(type: .success) }
    static func warning() { instance.notification(type: .warning) }
    static func error() { instance.notification(type: .error) }
    static func light() { instance.impact(style: .light) }
    static func medium() { instance.impact(style: .medium) }
    static func heavy() { instance.impact(style: .heavy) }
}
