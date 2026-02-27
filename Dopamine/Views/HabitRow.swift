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
    // MARK: State & Bindings
    @State private var vm: HabitRowViewModel
    @Binding var confettiTrigger: Int
    var themeColor: Color
    
    // MARK: Initializer
    init(habit: Habit, confettiTrigger: Binding<Int>, themeColor: Color) {
        self._vm = State(initialValue: HabitRowViewModel(habit: habit))
        self._confettiTrigger = confettiTrigger
        self.themeColor = themeColor
    }
    
    // MARK: Body
    var body: some View {
        HStack(spacing: 15) {
            Button {
                vm.toggleCompletion(confettiTrigger: &confettiTrigger)
            } label: {
                ZStack {
                    Circle()
                        .stroke(vm.habit.isCompleted ? themeColor : .white.opacity(0.2), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if vm.habit.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(themeColor)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .buttonStyle(ScalableButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.habit.title)
                    .font(.headline)
                    .foregroundStyle(vm.habit.isCompleted ? .white.opacity(0.4) : .white)
                    .strikethrough(vm.habit.isCompleted)
                
                Text("+\(vm.habit.points) Puan")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(themeColor.opacity(0.8))
            }
            
            Spacer()
            
            Text(difficultyText)
                .font(.system(size: 8, weight: .black))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(vm.habit.isCompleted ? .white.opacity(0.05) : themeColor.opacity(0.1))
                .foregroundStyle(vm.habit.isCompleted ? .white.opacity(0.2) : themeColor)
                .cornerRadius(6)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(vm.habit.isCompleted ? themeColor.opacity(0.2) : .clear, lineWidth: 1)
        )
    }
    
    // MARK: Helpers
    private var difficultyText: String {
        switch vm.habit.difficulty {
        case 1: return "KOLAY"
        case 2: return "ORTA"
        case 3: return "ZOR"
        default: return ""
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    let sampleHabit = Habit(title: "Kitap Oku 📖", difficulty: 1)
    
    return HabitRow(
        habit: sampleHabit,
        confettiTrigger: .constant(0),
        themeColor: .blue
    )
    .padding()
    .background(Color(hex: "0F0F1E"))
    .modelContainer(container)
}

