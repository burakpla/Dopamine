//
//  AddHabitView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Add Habit View
struct AddHabitView: View {
    // MARK: Environment & State
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm = AddHabitViewModel()

    // MARK: Computed
    /// Zorluk seviyesi renkleri — tasarım sistemi paletiyle uyumlu.
    static func difficultyColor(for level: Int) -> Color {
        HabitDifficulty.from(rawValue: level).color
    }

    private var activeDifficulty: HabitDifficulty { vm.resolvedDifficulty }

    private var currentDifficultyColor: Color { activeDifficulty.color }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundBase

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.lg) {
                        headerSection
                        levelPickerSection
                        catalogSection
                    }
                    .padding(.horizontal, DS.Spacing.screenEdge)
                    .padding(.top, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.xxl)
                }
                .safeAreaInset(edge: .bottom) { bottomBar }
            }
            .navigationTitle("Yeni Hedef")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }.foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - View Composition
private extension AddHabitView {
    // MARK: Background
    /// Daire `overlay` içinde çizilir; böylece ZStack'i genişletip içeriği taşırmaz.
    var backgroundBase: some View {
        DS.Colors.background
            .overlay {
                Circle()
                    .fill(currentDifficultyColor.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: 100, y: -200)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: activeDifficulty)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    // MARK: Section - Header
    /// Serbest metin girişi yoktur; kullanıcı yalnızca hazır listeden seçer.
    var headerSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("NE BAŞARACAKSIN?")
                .overlineStyle()

            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: vm.selectedTemplate?.symbol ?? "square.grid.2x2")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(vm.hasSelection ? currentDifficultyColor : DS.Colors.textTertiary)
                    .frame(width: DS.Size.iconMd)

                Text(vm.selectedTemplate?.title ?? "Aşağıdaki listeden bir hedef seç")
                    .font(.subheadline.weight(vm.hasSelection ? .semibold : .regular))
                    .foregroundStyle(vm.hasSelection ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                    .lineLimit(2)

                Spacer(minLength: DS.Spacing.xs)

                if vm.hasSelection {
                    difficultyBadge
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .frame(minHeight: 56)
            .background(DS.Colors.glass, in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                    .strokeBorder(
                        vm.errorMessage == nil
                            ? (vm.hasSelection ? currentDifficultyColor.opacity(0.45) : DS.Colors.hairline)
                            : DS.Colors.danger.opacity(0.6),
                        lineWidth: 1
                    )
            )
            .animation(DS.Motion.press, value: vm.selectedTemplate)

            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.danger)
                    .transition(.opacity)
            } else {
                Text("Zorluk ve puanı biz belirliyoruz — sen sadece hedefi seç.")
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.textTertiary)
            }
        }
    }

    /// Seçilen hedefin zorluğunu gösteren, salt okunur rozet.
    var difficultyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: activeDifficulty.symbol)
                .font(.system(size: 10, weight: .bold))
            Text(activeDifficulty.title.uppercased())
                .font(DS.Typo.badge)
        }
        .foregroundStyle(currentDifficultyColor)
        .padding(.horizontal, DS.Spacing.xs)
        .padding(.vertical, 5)
        .background(currentDifficultyColor.opacity(0.16), in: Capsule())
        .accessibilityLabel("Zorluk: \(activeDifficulty.title)")
    }

    // MARK: Section - Level Picker
    /// Kullanıcı zorluk *atamaz*, yalnızca hangi listeye bakacağını seçer.
    var levelPickerSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("HAZIR LİSTELER")
                .overlineStyle()

            HStack(spacing: DS.Spacing.xs) {
                ForEach(HabitDifficulty.allCases) { level in
                    levelTab(for: level)
                }
            }

            Text(vm.browsingLevel.caption)
                .font(.caption2)
                .foregroundStyle(DS.Colors.textTertiary)
                .transition(.opacity)
        }
    }

    func levelTab(for level: HabitDifficulty) -> some View {
        let isActive = vm.browsingLevel == level

        return Button {
            withAnimation(DS.Motion.press) { vm.changeLevel(to: level) }
        } label: {
            VStack(spacing: DS.Spacing.xxs) {
                HStack(spacing: 5) {
                    Image(systemName: level.symbol)
                        .font(.system(size: 12, weight: .bold))
                    Text(level.title)
                        .font(.caption.bold())
                }
                Text("+\(level.points) puan")
                    .font(DS.Typo.tileLabel)
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.sm)
            .background(
                isActive ? level.color.opacity(0.18) : DS.Colors.glass,
                in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
            )
            .foregroundStyle(isActive ? level.color : DS.Colors.textTertiary)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                    .strokeBorder(isActive ? level.color.opacity(0.55) : DS.Colors.hairline, lineWidth: isActive ? 1.5 : 1)
            )
        }
        .buttonStyle(ScalableButtonStyle())
        .accessibilityLabel("\(level.title) liste")
        .accessibilityAddTraits(isActive ? [.isSelected, .isButton] : .isButton)
    }

    // MARK: Section - Catalog
    var catalogSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            ForEach(vm.visibleGroups, id: \.category.id) { group in
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack(spacing: 6) {
                        Image(systemName: group.category.symbol)
                            .font(.system(size: 10, weight: .bold))
                        Text(group.category.rawValue.uppercased())
                    }
                    .overlineStyle()

                    ForEach(group.items) { template in
                        templateRow(template)
                    }
                }
            }
        }
        .animation(DS.Motion.press, value: vm.browsingLevel)
    }

    func templateRow(_ template: HabitTemplate) -> some View {
        let isSelected = vm.isSelected(template)
        let color = template.difficulty.color

        return Button {
            withAnimation(DS.Motion.press) { vm.select(template) }
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                Image(systemName: template.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: DS.Size.iconMd)

                Text(template.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DS.Colors.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: DS.Spacing.xs)

                Text("+\(template.points)")
                    .font(DS.Typo.badge)
                    .foregroundStyle(color)
                    .padding(.horizontal, DS.Spacing.xs)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.14), in: Capsule())

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(isSelected ? color : DS.Colors.textTertiary.opacity(0.6))
            }
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.sm)
            .background(
                isSelected ? color.opacity(0.14) : DS.Colors.glass,
                in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                    .strokeBorder(isSelected ? color.opacity(0.5) : DS.Colors.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(ScalableButtonStyle())
        .accessibilityLabel("\(template.title), \(template.difficulty.title), \(template.points) puan")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    // MARK: Bottom Bar
    /// Ödül bilgisi + kaydet butonu her zaman erişilebilir olsun diye alta sabitlenir.
    var bottomBar: some View {
        VStack(spacing: DS.Spacing.sm) {
            rewardInfoCard
            saveButton
        }
        .padding(.horizontal, DS.Spacing.screenEdge)
        .padding(.top, DS.Spacing.sm)
        .padding(.bottom, DS.Spacing.sm)
        .background(.ultraThinMaterial)
    }

    // MARK: Card - Reward
    var rewardInfoCard: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: activeDifficulty.symbol)
                .foregroundStyle(currentDifficultyColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.hasSelection ? "\(activeDifficulty.title) • Tamamladığında" : "Bir hedef seç")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)

                Text("+\(vm.rewardPoints) Puan")
                    .font(.subheadline.bold())
                    .foregroundStyle(DS.Colors.textPrimary)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 0)
        }
        .glassCard(radius: DS.Radius.md, padding: DS.Spacing.sm, tint: currentDifficultyColor)
        .accessibilityElement(children: .combine)
    }

    // MARK: Button - Save
    var saveButton: some View {
        Button(action: save) {
            Text("HEDEFİ EKLE")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    vm.isValid ? AnyShapeStyle(currentDifficultyColor.gradient) : AnyShapeStyle(DS.Colors.glassStrong),
                    in: RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                )
                .foregroundStyle(vm.isValid ? .white : DS.Colors.textTertiary)
        }
        .buttonStyle(ScalableButtonStyle())
        .disabled(!vm.isValid)
    }

    // MARK: Actions
    func save() {
        withAnimation {
            if vm.saveHabit(modelContext: modelContext) {
                dismiss()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitLog.self, configurations: config)

    return AddHabitView()
        .modelContainer(container)
}
