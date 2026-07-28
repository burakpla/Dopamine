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
    @FocusState private var isTitleFocused: Bool

    /// Görünüm ömrü boyunca sabit kalan placeholder.
    @State private var placeholder: String = ""

    // MARK: Computed
    /// Zorluk seviyesi renkleri — tasarım sistemi paletiyle uyumlu.
    static func difficultyColor(for level: Int) -> Color {
        switch level {
        case 1: return DS.Colors.success
        case 2: return DS.Colors.streak
        default: return DS.Colors.danger
        }
    }

    private var currentDifficultyColor: Color {
        Self.difficultyColor(for: vm.selectedDifficulty)
    }

    private var difficultySymbol: String {
        switch vm.selectedDifficulty {
        case 1: return "leaf.fill"
        case 2: return "bolt.fill"
        default: return "flame.fill"
        }
    }

    private var rewardPoints: Int {
        switch vm.selectedDifficulty {
        case 1: return 5
        case 2: return 15
        default: return 40
        }
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundBase

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.lg) {
                        inputSection
                        suggestionsSection
                        difficultySelectionSection
                        rewardInfoCard
                        saveButton
                    }
                    .padding(.horizontal, DS.Spacing.screenEdge)
                    .padding(.vertical, DS.Spacing.lg)
                }
            }
            .navigationTitle("Yeni Hedef")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }.foregroundStyle(.white.opacity(0.7))
                }
            }
            .onAppear {
                placeholder = vm.placeholders.randomElement() ?? "Bugün neyi başaracaksın?"
                isTitleFocused = true
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
            .animation(.easeInOut(duration: 0.35), value: vm.selectedDifficulty)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    // MARK: Section - Input
    var inputSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("NE BAŞARACAKSIN?")
                .overlineStyle()

            TextField(
                "",
                text: $vm.title,
                prompt: Text(placeholder).foregroundStyle(DS.Colors.textTertiary)
            )
            .focused($isTitleFocused)
            .submitLabel(.done)
            .onSubmit(save)
            .padding()
            .background(DS.Colors.glass, in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                    .strokeBorder(vm.errorMessage == nil ? DS.Colors.hairline : DS.Colors.danger.opacity(0.6), lineWidth: 1)
            )
            .foregroundStyle(DS.Colors.textPrimary)

            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.danger)
                    .transition(.opacity)
            }
        }
    }

    // MARK: Section - Suggestions
    var suggestionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.xs) {
                ForEach(vm.suggestions, id: \.title) { suggestion in
                    Button {
                        withAnimation(DS.Motion.press) {
                            vm.apply(suggestion: suggestion)
                        }
                    } label: {
                        Text(suggestion.title)
                            .font(.caption.bold())
                            .foregroundStyle(DS.Colors.textPrimary.opacity(0.85))
                            .padding(.horizontal, DS.Spacing.sm)
                            .padding(.vertical, DS.Spacing.xs)
                            .background(DS.Colors.glassStrong, in: Capsule())
                    }
                    .buttonStyle(ScalableButtonStyle())
                }
            }
        }
        .scrollClipDisabled()
        .accessibilityLabel("Hazır öneriler")
    }

    // MARK: Section - Difficulty
    var difficultySelectionSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("ZORLUK SEVİYESİ")
                .overlineStyle()

            HStack(spacing: DS.Spacing.sm) {
                ForEach(1...3, id: \.self) { index in
                    difficultyButton(for: index)
                }
            }
        }
    }

    func difficultyButton(for index: Int) -> some View {
        let isSelected = vm.selectedDifficulty == index
        let color = Self.difficultyColor(for: index)
        let label = index == 1 ? "Kolay" : (index == 2 ? "Orta" : "Zor")
        let symbol = index == 1 ? "leaf.fill" : (index == 2 ? "bolt.fill" : "flame.fill")

        return Button {
            withAnimation(DS.Motion.press) {
                vm.selectedDifficulty = index
                HapticManager.light()
            }
        } label: {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: symbol)
                Text(label).font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.md)
            .background(
                isSelected ? color.opacity(0.18) : DS.Colors.glass,
                in: RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
            )
            .foregroundStyle(isSelected ? color : DS.Colors.textTertiary)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous)
                    .strokeBorder(isSelected ? color.opacity(0.55) : DS.Colors.hairline, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(ScalableButtonStyle())
        .accessibilityLabel("\(label) zorluk")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    // MARK: Card - Reward
    var rewardInfoCard: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: difficultySymbol)
                .foregroundStyle(currentDifficultyColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Tamamladığında")
                    .font(.caption)
                    .foregroundStyle(DS.Colors.textSecondary)

                Text("+\(rewardPoints) Puan")
                    .font(.subheadline.bold())
                    .foregroundStyle(DS.Colors.textPrimary)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 0)
        }
        .glassCard(radius: DS.Radius.md, padding: DS.Spacing.md, tint: currentDifficultyColor)
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
