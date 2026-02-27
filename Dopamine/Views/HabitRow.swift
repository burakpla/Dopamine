//
//  HabitRow.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


import SwiftUI
import SwiftData

struct HabitRow: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Binding var confettiTrigger: Int
    var themeColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            completionButton
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .strikethrough(habit.isCompleted)
                    .foregroundStyle(habit.isCompleted ? .white.opacity(0.4) : .white)
                
                Text("+\(habit.points) Puan")
                    .font(.system(size: 10, weight: .black))
                    .padding(.horizontal, 8).padding(.vertical, 2)
                    .background(themeColor.opacity(0.2))
                    .foregroundStyle(themeColor)
                    .cornerRadius(6)
            }
            
            Spacer()
            
            actionButtons
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.05), lineWidth: 1))
    }
    
    // Alt parçalar
    private var completionButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                habit.isCompleted.toggle()
                if habit.isCompleted {
                    habit.completedAt = Date()
                    confettiTrigger += 1
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                } else {
                    habit.completedAt = nil
                }
            }
        } label: {
            Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(habit.isCompleted ? .green : themeColor)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 18) {
            Button(action: duplicate) {
                Image(systemName: "plus.square.on.square").foregroundStyle(.white.opacity(0.4))
            }
            Button(action: deleteHabit) {
                Image(systemName: "trash").foregroundStyle(.red.opacity(0.6))
            }
        }
    }
    
    private func duplicate() {
        let newHabit = Habit(title: habit.title, difficulty: habit.difficulty)
        modelContext.insert(newHabit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func deleteHabit() {
        modelContext.delete(habit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
#Preview {
    // Geçici konteyner
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    // Örnek veri
    let sampleHabit = Habit(title: "Kitap Oku 📖", difficulty: 1)
    
    return HabitRow(
        habit: sampleHabit,
        confettiTrigger: .constant(0), // Binding simülasyonu
        themeColor: .blue
    )
    .padding()
    .background(Color(hex: "0F0F1E"))
    .modelContainer(container)
}
