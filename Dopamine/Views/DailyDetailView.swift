//
//  DailyDetailView.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


import SwiftUI
import SwiftData

struct DailyDetailView: View {
    let date: Date
    let habits: [Habit]
    let themeColor: Color
    @Environment(\.dismiss) var dismiss
    
    var filteredHabits: [Habit] {
        let calendar = Calendar.current
        return habits.filter { habit in
            guard let completedDate = habit.completedAt else { return false }
            return calendar.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1E").ignoresSafeArea()
                
                if filteredHabits.isEmpty {
                    emptyState
                } else {
                    habitList
                }
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }.bold().foregroundStyle(themeColor)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView {
            Label("Kayıt Bulunamadı", systemImage: "calendar.badge.exclamationmark")
        } description: {
            Text("Bu tarihte hiç görev tamamlamamışsın kanka.")
        }
    }
    
    private var habitList: some View {
        List {
            Section("Tamamlanan Görevler") {
                ForEach(filteredHabits) { habit in
                    HStack {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(themeColor)
                        VStack(alignment: .leading) {
                            Text(habit.title).font(.body.bold())
                            Text(habit.completedAt?.formatted(date: .omitted, time: .shortened) ?? "").font(.caption2).foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                        Text("+\(habit.points) P").font(.caption.bold()).padding(6).background(themeColor.opacity(0.2)).foregroundStyle(themeColor).cornerRadius(8)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    // Örnek tamamlanmış görevler
    let h1 = Habit(title: "Sabah Yogası", difficulty: 2)
    h1.isCompleted = true
    h1.completedAt = Date()
    
    let h2 = Habit(title: "Su İç", difficulty: 1)
    h2.isCompleted = true
    h2.completedAt = Date()
    
    container.mainContext.insert(h1)
    container.mainContext.insert(h2)
    
    return DailyDetailView(
        date: Date(),
        habits: [h1, h2],
        themeColor: .orange
    )
    .modelContainer(container)
}
