//
//  HabitRow.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Habit Row View
struct HabitRow: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm: HabitRowViewModel
    @Binding var confettiTrigger: Int
    var themeColor: Color

    init(habit: Habit, confettiTrigger: Binding<Int>, themeColor: Color, referenceDate: Date = .now) {
        self._vm = State(initialValue: HabitRowViewModel(habit: habit, referenceDate: referenceDate))
        self._confettiTrigger = confettiTrigger
        self.themeColor = themeColor
    }

    private var isCompleted: Bool { vm.isCompleted }

    var body: some View {
        HStack(spacing: DS.Spacing.sm) {
            // MARK: Check Button
            Button {
                vm.toggleCompletion(modelContext: modelContext, confettiTrigger: &confettiTrigger)
            } label: {
                ZStack {
                    Circle()
                        .fill(isCompleted ? themeColor.opacity(0.16) : Color.clear)
                        .frame(width: DS.Size.checkbox, height: DS.Size.checkbox)

                    Circle()
                        .strokeBorder(isCompleted ? themeColor : .white.opacity(0.22), lineWidth: 2)
                        .frame(width: DS.Size.checkbox, height: DS.Size.checkbox)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(themeColor)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 44, height: 44) // dokunma hedefi min. 44pt
                .contentShape(Rectangle())
            }
            .buttonStyle(ScalableButtonStyle())
            .accessibilityLabel(vm.habit.title)
            .accessibilityValue(isCompleted ? "Tamamlandı" : "Tamamlanmadı")
            .accessibilityAddTraits(isCompleted ? [.isSelected, .isButton] : .isButton)
            .accessibilityHint("Tamamlama durumunu değiştirir")

            // MARK: Title & Points
            VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                Text(vm.habit.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isCompleted ? DS.Colors.textTertiary : DS.Colors.textPrimary)
                    .strikethrough(isCompleted, color: DS.Colors.textTertiary)
                    .lineLimit(2)

                HStack(spacing: DS.Spacing.xs) {
                    Text("+\(vm.habit.points) P")
                        .font(DS.Typo.badge)
                        .foregroundStyle(themeColor)
                        .padding(.horizontal, DS.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(themeColor.opacity(0.14), in: Capsule())

                    if vm.currentStreak > 1 {
                        Label("\(vm.currentStreak)", systemImage: "flame.fill")
                            .font(DS.Typo.badge)
                            .foregroundStyle(DS.Colors.streak)
                            .padding(.horizontal, DS.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(DS.Colors.streak.opacity(0.14), in: Capsule())
                            .accessibilityLabel("\(vm.currentStreak) günlük seri")
                    }
                }
            }

            Spacer(minLength: 0)

            // MARK: Actions Menu
            Menu {
                Button {
                    vm.duplicateHabit(modelContext: modelContext)
                } label: {
                    Label("Kopyala", systemImage: "plus.square.on.square")
                }

                Button(role: .destructive) {
                    vm.deleteHabit(modelContext: modelContext)
                } label: {
                    Label("Sil", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: DS.Size.iconMd, weight: .semibold))
                    .foregroundStyle(DS.Colors.textTertiary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Diğer işlemler")
        }
        .padding(.vertical, DS.Spacing.xs)
        .padding(.horizontal, DS.Spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .fill(isCompleted ? themeColor.opacity(0.07) : DS.Colors.glass)
        }
        .overlay {
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .strokeBorder(isCompleted ? themeColor.opacity(0.28) : DS.Colors.hairline, lineWidth: 1)
        }
        .animation(DS.Motion.press, value: isCompleted)
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitLog.self, configurations: config)

    let sampleHabit = Habit(title: "Kitap Oku 📖", difficulty: 1)
    container.mainContext.insert(sampleHabit)

    return HabitRow(
        habit: sampleHabit,
        confettiTrigger: .constant(0),
        themeColor: DS.Colors.primary
    )
    .padding()
    .background(DS.Colors.background)
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
