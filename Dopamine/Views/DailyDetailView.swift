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
    init(date: Date, logs: [HabitLog], themeColor: Color) {
        _vm = State(initialValue: DailyDetailViewModel(date: date, logs: logs))
        self.themeColor = themeColor
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                VStack(spacing: DS.Spacing.lg) {
                    summaryCard
                    completedSection
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DS.Spacing.screenEdge)
                .padding(.vertical, DS.Spacing.md)
            }
            .navigationTitle(vm.date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }.foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: Sections
    private var summaryCard: some View {
        VStack(spacing: 10) {
            Text("\(vm.dailyTotalPoints) PUAN")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(themeColor.gradient)
                .contentTransition(.numericText())

            Text(vm.dailySummary)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(24)
        .accessibilityElement(children: .combine)
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("TAMAMLANANLAR")
                    .font(.caption2.bold())
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Text("\(vm.dayLogs.count)")
                    .font(.caption2.bold())
                    .foregroundStyle(themeColor)
            }

            if vm.dayLogs.isEmpty {
                ContentUnavailableView("Kayıt Bulunamadı", systemImage: "calendar.badge.exclamationmark")
                    .opacity(0.5)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(vm.dayLogs) { log in
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(themeColor)

                                Text(log.habit?.title ?? log.habitTitle)
                                    .foregroundStyle(.white)

                                Spacer()

                                Text("+\(log.points)P")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(6)
                                    .background(themeColor.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitLog.self, configurations: config)

    let h1 = Habit(title: "Sabah Yogası", difficulty: 2)
    let h2 = Habit(title: "Su İç", difficulty: 1)
    container.mainContext.insert(h1)
    container.mainContext.insert(h2)

    let logs = [
        HabitLog(points: h1.points, habitTitle: h1.title, habit: h1),
        HabitLog(points: h2.points, habitTitle: h2.title, habit: h2)
    ]
    logs.forEach { container.mainContext.insert($0) }

    return DailyDetailView(date: Date(), logs: logs, themeColor: .orange)
        .modelContainer(container)
}
