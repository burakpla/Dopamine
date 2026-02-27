import SwiftUI

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