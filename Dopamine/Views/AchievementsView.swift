//
//  AchievementsView.swift
//  Dopamine
//
//  Rozet vitrini.
//

// MARK: - Imports
import SwiftUI

// MARK: - Achievements View
struct AchievementsView: View {
    // MARK: Dependencies
    @Environment(\.dismiss) private var dismiss
    let achievements: [Achievement]
    let themeColor: Color

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    private var unlockedCount: Int { achievements.filter(\.isUnlocked).count }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.md) {
                        header

                        LazyVGrid(columns: columns, spacing: DS.Spacing.sm) {
                            ForEach(achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.screenEdge)
                    .padding(.vertical, DS.Spacing.md)
                }
            }
            .navigationTitle("Rozetler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("\(unlockedCount) / \(achievements.count)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(themeColor.gradient)

            Text("ROZET KAZANILDI")
                .font(.caption2.bold())
                .tracking(2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(24)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Achievement Card
private struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: achievement.symbol)
                .font(.system(size: 26))
                .foregroundStyle(achievement.isUnlocked ? achievement.color : .white.opacity(0.25))
                .frame(height: 30)

            Text(achievement.title)
                .font(.subheadline.bold())
                .foregroundStyle(achievement.isUnlocked ? .white : .white.opacity(0.5))

            Text(achievement.detail)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
                .fixedSize(horizontal: false, vertical: true)

            if !achievement.isUnlocked {
                ProgressView(value: achievement.progress)
                    .tint(achievement.color)
                    .scaleEffect(x: 1, y: 0.6, anchor: .center)
            } else {
                Label("Kazanıldı", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(achievement.color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(achievement.isUnlocked ? 0.08 : 0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(achievement.isUnlocked ? achievement.color.opacity(0.35) : .white.opacity(0.06), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityValue(achievement.isUnlocked ? "Kazanıldı" : "İlerleme yüzde \(Int(achievement.progress * 100))")
    }
}

// MARK: - Preview
#Preview {
    AchievementsView(
        achievements: AchievementEngine.evaluate(
            totalPoints: 320,
            currentStreak: 4,
            bestStreak: 6,
            totalCompletions: 22,
            perfectDays: 2,
            level: 3
        ),
        themeColor: .purple
    )
    .preferredColorScheme(.dark)
}
