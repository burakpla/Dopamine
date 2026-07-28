//
//  Achievement.swift
//  Dopamine
//
//  Rozet / başarım sistemi.
//

// MARK: - Imports
import SwiftUI

// MARK: - Achievement Model
struct Achievement: Identifiable, Hashable {
    // MARK: Properties
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let color: Color
    /// 0...1 aralığında ilerleme.
    let progress: Double

    var isUnlocked: Bool { progress >= 1 }
}

// MARK: - Achievement Engine
enum AchievementEngine {
    /// Mevcut istatistiklere göre tüm rozetleri üretir.
    static func evaluate(
        totalPoints: Int,
        currentStreak: Int,
        bestStreak: Int,
        totalCompletions: Int,
        perfectDays: Int,
        level: Int
    ) -> [Achievement] {
        func ratio(_ value: Int, _ goal: Int) -> Double {
            goal > 0 ? min(Double(value) / Double(goal), 1) : 0
        }

        return [
            Achievement(
                id: "first_step",
                title: "İlk Adım",
                detail: "İlk alışkanlığını tamamla",
                symbol: "figure.walk",
                color: DS.Colors.success,
                progress: ratio(totalCompletions, 1)
            ),
            Achievement(
                id: "points_100",
                title: "Yüzlük",
                detail: "Toplam 100 puan kazan",
                symbol: "100.circle.fill",
                color: DS.Colors.secondary,
                progress: ratio(totalPoints, 100)
            ),
            Achievement(
                id: "points_1000",
                title: "Binlik Kulüp",
                detail: "Toplam 1.000 puan kazan",
                symbol: "sparkles",
                color: DS.Colors.primary,
                progress: ratio(totalPoints, 1000)
            ),
            Achievement(
                id: "streak_3",
                title: "Isınma Turu",
                detail: "3 gün üst üste devam et",
                symbol: "flame",
                color: DS.Colors.streak,
                progress: ratio(bestStreak, 3)
            ),
            Achievement(
                id: "streak_7",
                title: "Haftalık Seri",
                detail: "7 gün üst üste devam et",
                symbol: "flame.fill",
                color: DS.Colors.streak,
                progress: ratio(bestStreak, 7)
            ),
            Achievement(
                id: "streak_30",
                title: "Ay Işığı",
                detail: "30 gün üst üste devam et",
                symbol: "moon.stars.fill",
                color: Color(hex: "B07CFF"),
                progress: ratio(bestStreak, 30)
            ),
            Achievement(
                id: "perfect_1",
                title: "Hedef Vuruşu",
                detail: "Günlük hedefini bir kez tuttur",
                symbol: "target",
                color: DS.Colors.danger,
                progress: ratio(perfectDays, 1)
            ),
            Achievement(
                id: "perfect_10",
                title: "Keskin Nişancı",
                detail: "10 gün hedefini tuttur",
                symbol: "scope",
                color: Color(hex: "FF6B9E"),
                progress: ratio(perfectDays, 10)
            ),
            Achievement(
                id: "completions_50",
                title: "Makine",
                detail: "50 alışkanlık tamamla",
                symbol: "gearshape.2.fill",
                color: Color(hex: "3DD6C0"),
                progress: ratio(totalCompletions, 50)
            ),
            Achievement(
                id: "level_5",
                title: "Odak Ustası",
                detail: "5. seviyeye ulaş",
                symbol: "bolt.fill",
                color: DS.Colors.gold,
                progress: ratio(level, 5)
            ),
            Achievement(
                id: "level_10",
                title: "Taç",
                detail: "10. seviyeye ulaş",
                symbol: "crown.fill",
                color: Color(hex: "FFD98A"),
                progress: ratio(level, 10)
            )
        ]
    }
}
