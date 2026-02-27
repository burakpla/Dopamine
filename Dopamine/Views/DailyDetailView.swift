//
//  DailyDetailView.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Daily Detail View
struct DailyDetailView: View {
    // MARK: State & Dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var vm: DailyDetailViewModel
    var themeColor: Color
    
    // MARK: Initializer
    init(date: Date, habits: [Habit], themeColor: Color) {
        _vm = State(initialValue: DailyDetailViewModel(date: date, habits: habits))
        self.themeColor = themeColor
    }
    
    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1E").ignoresSafeArea()
                
                // Sections
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Text("\(vm.dailyTotalPoints) PUAN")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(themeColor.gradient)
                        
                        Text(vm.dailySummary)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(30)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(24)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("TAMAMLANANLAR")
                            .font(.caption2.bold())
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        if vm.completedHabits.isEmpty {
                            ContentUnavailableView("Kayıt Bulunamadı", systemImage: "calendar.badge.exclamationmark")
                                .opacity(0.5)
                        } else {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(vm.completedHabits) { habit in
                                        HStack {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundStyle(themeColor)
                                            Text(habit.title)
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Text("+\(habit.points)P")
                                                .font(.caption.bold())
                                                .padding(6)
                                                .background(themeColor.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(vm.date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            // Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
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
