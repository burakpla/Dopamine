//
//  LevelSystem.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

// MARK: - Imports
import SwiftUI

// MARK: - Level System Model
/// Eğrisel (progressive) seviye sistemi.
/// Her seviye bir öncekinden daha fazla puan gerektirir: 100 * level^1.35
struct LevelSystem {
    // MARK: Properties
    let totalPoints: Int

    // MARK: Constants
    private static let maxLevel = 30

    // MARK: Curve
    /// Belirtilen seviyeyi tamamlamak için gereken puan.
    static func cost(forLevel level: Int) -> Int {
        Int((100.0 * pow(Double(level), 1.35)).rounded())
    }

    /// Belirtilen seviyeye ulaşmak için gereken toplam kümülatif puan.
    static func cumulativePoints(toReach level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (1..<level).reduce(0) { $0 + cost(forLevel: $1) }
    }

    // MARK: Computed
    var level: Int {
        var level = 1
        while level < Self.maxLevel, totalPoints >= Self.cumulativePoints(toReach: level + 1) {
            level += 1
        }
        return level
    }

    /// Mevcut seviyenin başlangıç puanı.
    var currentLevelFloor: Int { Self.cumulativePoints(toReach: level) }

    /// Bir sonraki seviyenin başlangıç puanı.
    var nextLevelThreshold: Int {
        guard level < Self.maxLevel else { return currentLevelFloor }
        return Self.cumulativePoints(toReach: level + 1)
    }

    var isMaxLevel: Bool { level >= Self.maxLevel }

    /// Seviye atlamak için kalan puan.
    var pointsToNextLevel: Int {
        guard !isMaxLevel else { return 0 }
        return max(nextLevelThreshold - totalPoints, 0)
    }

    /// Mevcut seviye içindeki ilerleme (0...1).
    var levelProgress: Double {
        guard !isMaxLevel else { return 1 }
        let span = nextLevelThreshold - currentLevelFloor
        guard span > 0 else { return 0 }
        return min(max(Double(totalPoints - currentLevelFloor) / Double(span), 0), 1)
    }

    // MARK: Presentation
    var rank: String {
        switch level {
        case 1: return "Çaylak"
        case 2: return "Isınıyor"
        case 3: return "Gelişmekte Olan"
        case 4: return "İstikrarlı"
        case 5: return "Odak Ustası"
        case 6...7: return "Disiplin Savaşçısı"
        case 8...9: return "Dopamin Mimarı"
        case 10...12: return "Zihin Simyacısı"
        case 13...16: return "Alışkanlık Lordu"
        case 17...21: return "Efsane"
        case 22...29: return "Mitolojik"
        default: return "Ölümsüz"
        }
    }

    /// Seviye teması: soğuk tonlardan sıcak tonlara doğru ilerleyen,
    /// koyu zeminde okunabilirliği yüksek yumuşak palet.
    /// (Ham sistem kırmızı/sarısı yerine düşük parlaklık yorgunluğu olan tonlar.)
    var themeColor: Color {
        switch level {
        case 1: return Color(hex: "6C8CFF")   // yumuşak mavi
        case 2: return Color(hex: "4CC9F0")   // camgöbeği
        case 3: return Color(hex: "7C6BFF")   // mor
        case 4: return Color(hex: "B07CFF")   // orkide
        case 5: return Color(hex: "3DD6C0")   // turkuaz
        case 6...7: return Color(hex: "3DDC97") // zümrüt
        case 8...9: return Color(hex: "FFB03A") // kehribar
        case 10...12: return Color(hex: "FF8A5B") // mercan
        case 13...16: return Color(hex: "FF6B9E") // pembe
        case 17...21: return Color(hex: "FFC94A") // altın
        default: return Color(hex: "FFD98A")  // parlak altın
        }
    }

    var badgeSymbol: String {
        switch level {
        case 1...2: return "leaf.fill"
        case 3...4: return "flame.fill"
        case 5...7: return "bolt.fill"
        case 8...12: return "crown.fill"
        case 13...21: return "star.circle.fill"
        default: return "trophy.fill"
        }
    }
}
