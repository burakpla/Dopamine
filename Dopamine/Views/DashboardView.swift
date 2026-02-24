//
//  DashboardView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("dailyTarget") var dailyTarget: Int = 500
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .reverse) var habits: [Habit]
    
    // MARK: - State Variables
    @State private var isShowingAddSheet = false
    @State private var isShowingTargetSheet = false
    @State private var isShowingResetAlert = false
    @State private var isShowingDatePicker = false
    @State private var isShowingDetailSheet = false
    @State private var selectedDate: Date = Date() // Varsayılan bugün
    @State private var confettiTrigger = 0
    @State private var tempTarget: Double = 500
    
    // MARK: - Computed Properties
    var totalPoints: Int {
        habits.filter { $0.isCompleted }.reduce(0) { $0 + $1.points }
    }
    
    var levelInfo: LevelSystem {
        LevelSystem(totalPoints: totalPoints)
    }
    
    var todayPoints: Int {
        let calendar = Calendar.current
        return habits.filter { habit in
            guard let date = habit.completedAt else { return false }
            return calendar.isDateInToday(date)
        }.reduce(0) { $0 + $1.points }
    }
    
    var isTargetAchieved: Bool {
        todayPoints >= dailyTarget && dailyTarget > 0
    }
    
    var dailyProgress: Double {
        min(Double(todayPoints) / Double(dailyTarget), 1.0)
    }
    
    var weeklyData: [DailyProgress] {
        let calendar = Calendar.current
        return (0..<7).map { dayOffset in
            let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let dayPoints = habits.filter { habit in
                guard let completedDate = habit.completedAt else { return false }
                return calendar.isDate(completedDate, inSameDayAs: targetDate)
            }.reduce(0) { $0 + $1.points }
            return DailyProgress(date: targetDate, points: dayPoints)
        }.reversed()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        motivationCard
                        scoreCard
                        performanceChart // Artık sadece izlemelik
                        todayHabitsList
                    }
                    .padding()
                }
                
                if confettiTrigger > 0 {
                    ConfettiView().id(confettiTrigger).allowsHitTesting(false)
                }
            }
            .navigationTitle("Dopamine")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) { isShowingResetAlert = true } label: {
                        Image(systemName: "arrow.counterclockwise.circle").foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        // TAKVİM BUTONU
                        Button {
                            isShowingDatePicker = true
                        } label: {
                            Image(systemName: "calendar").font(.title3).foregroundStyle(levelInfo.themeColor)
                        }
                        
                        // EKLEME BUTONU
                        Button {
                            isShowingAddSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(levelInfo.themeColor)
                        }
                    }
                }
            }
            // MARK: - Sheets
            .sheet(isPresented: $isShowingDatePicker) {
                datePickerSheet
            }
            .sheet(isPresented: $isShowingDetailSheet) {
                DailyDetailView(date: selectedDate, habits: habits, themeColor: levelInfo.themeColor)
            }
            .sheet(isPresented: $isShowingTargetSheet) { targetSettingSheet }
            .sheet(isPresented: $isShowingAddSheet) { AddHabitView().presentationDetents([.medium]) }
            .alert("Sıfırlansın mı?", isPresented: $isShowingResetAlert) {
                Button("Vazgeç", role: .cancel) { }
                Button("Her Şeyi Sil", role: .destructive) { resetAllData() }
            } message: { Text("Tüm ilerlemen kalıcı olarak silinecek.") }
        }
    }
}

// MARK: - Subviews Extension
extension DashboardView {
    
    private var motivationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "quote.opening").foregroundStyle(levelInfo.themeColor)
                Text("GÜNÜN MOTİVASYONU").font(.caption2.bold()).tracking(1).foregroundStyle(.secondary)
            }
            Text(QuoteProvider.dailyQuote).font(.system(.body, design: .serif)).italic()
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial).cornerRadius(20)
    }
    
    private var scoreCard: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selam, \(userName)!").font(.title2.bold())
                    Text(isTargetAchieved ? "🏆 GÜNÜN ŞAMPİYONU" : levelInfo.rank)
                        .font(.subheadline).foregroundStyle(isTargetAchieved ? .orange : levelInfo.themeColor).fontWeight(.bold)
                }
                Spacer()
                Button {
                    tempTarget = Double(dailyTarget)
                    isShowingTargetSheet = true
                } label: {
                    ZStack {
                        ProgressCircle(progress: dailyProgress, color: isTargetAchieved ? .orange : levelInfo.themeColor)
                            .frame(width: 85, height: 85)
                        VStack(spacing: -2) {
                            Text("\(dailyTarget)").font(.system(size: 18, weight: .bold, design: .rounded))
                            Text("HEDEF").font(.system(size: 8, weight: .black)).foregroundStyle(.secondary)
                        }
                    }
                }.buttonStyle(ScalableButtonStyle())
            }
            VStack(spacing: 5) {
                Text("\(totalPoints)").font(.system(size: 54, weight: .black, design: .rounded))
                    .foregroundStyle(isTargetAchieved ? Color.orange.gradient : levelInfo.themeColor.gradient)
                Text("TOPLAM PUAN").font(.caption2.bold()).tracking(2).foregroundStyle(.secondary)
            }
            levelProgressBar
        }
        .padding(24).background(.ultraThinMaterial).cornerRadius(32)
    }
    
    private var performanceChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Haftalık Performans").font(.headline)
            Chart {
                ForEach(weeklyData) { data in
                    BarMark(x: .value("Gün", data.date, unit: .day), y: .value("Puan", data.points))
                        .foregroundStyle(levelInfo.themeColor.gradient).cornerRadius(4)
                }
            }
            .frame(height: 120)
        }
        .padding().background(.ultraThinMaterial).cornerRadius(24)
    }
    
    private var todayHabitsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bugünkü Hedeflerin").font(.headline).padding(.leading, 4)
            if habits.isEmpty {
                ContentUnavailableView("Liste Boş", systemImage: "sparkles")
            } else {
                ForEach(habits) { habit in
                    HabitRow(habit: habit, confettiTrigger: $confettiTrigger, themeColor: levelInfo.themeColor)
                }
            }
        }
    }
    
    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Şık Takvim Görünümü
                DatePicker("Tarih", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .tint(levelInfo.themeColor)
                    .padding()
                
                // Seçilen Tarihe Git Butonu
                Button {
                    isShowingDatePicker = false
                    // İki sheet'in çakışmaması için yarım saniye bekleme
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isShowingDetailSheet = true
                    }
                } label: {
                    HStack {
                        Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted)) Detayları")
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(levelInfo.themeColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Tarih Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { isShowingDatePicker = false }
                }
            }
        }
    }

    private var targetSettingSheet: some View {
        VStack(spacing: 30) {
            Text("Günlük Hedef").font(.title2.bold())
            Slider(value: $tempTarget, in: 100...2000, step: 50).tint(levelInfo.themeColor)
            Text("\(Int(tempTarget)) Puan").font(.title.bold()).foregroundStyle(levelInfo.themeColor)
            Button("KAYDET") {
                dailyTarget = Int(tempTarget)
                isShowingTargetSheet = false
            }
            .font(.headline).frame(maxWidth: .infinity).padding().background(levelInfo.themeColor).foregroundColor(.white).cornerRadius(15)
        }
        .padding().presentationDetents([.height(300)])
    }

    private var levelProgressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Lvl \(levelInfo.level)").font(.caption.bold())
                Spacer()
                Text("\((levelInfo.level * 200) - totalPoints) P kaldı").font(.caption2).foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.1))
                    Capsule().fill(levelInfo.themeColor.gradient)
                        .frame(width: geo.size.width * CGFloat(Double(totalPoints % 200) / 200.0))
                }
            }.frame(height: 8)
        }
    }

    private func resetAllData() {
        for habit in habits { modelContext.delete(habit) }
        try? modelContext.save()
        userName = ""
        dailyTarget = 500
    }
}

// MARK: - DailyDetailView (Gelişmiş Detay Sayfası)
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
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                if filteredHabits.isEmpty {
                    ContentUnavailableView {
                        Label("Kayıt Bulunamadı", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text("\(date.formatted(date: .long, time: .omitted)) tarihinde hiç görev tamamlamamışsın.")
                    }
                } else {
                    List {
                        Section {
                            ForEach(filteredHabits) { habit in
                                HStack(spacing: 15) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(themeColor)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading) {
                                        Text(habit.title).font(.body.bold())
                                        Text(habit.completedAt?.formatted(date: .omitted, time: .shortened) ?? "")
                                            .font(.caption2).foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(habit.points) P")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(themeColor.opacity(0.1))
                                        .foregroundStyle(themeColor).cornerRadius(8)
                                }
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Text("Tamamlanan Görevler")
                        } footer: {
                            Text("Toplam \(filteredHabits.count) görev tamamlandı.")
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }.bold()
                }
            }
        }
    }
}

// MARK: - Destekleyici Yapılar (Row, ButtonStyle, Progress vb.)
struct HabitRow: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Binding var confettiTrigger: Int
    var themeColor: Color
    
    private func duplicate() {
        let newHabit = Habit(title: habit.title, difficulty: habit.difficulty)
        newHabit.isCompleted = false
        newHabit.createdAt = Date()
        withAnimation(.spring()) { modelContext.insert(newHabit) }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func deleteHabit() {
        withAnimation(.spring()) { modelContext.delete(habit) }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    habit.isCompleted.toggle()
                    if habit.isCompleted {
                        habit.completedAt = Date()
                        confettiTrigger += 1
                    } else {
                        habit.completedAt = nil
                    }
                }
            } label: {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isCompleted ? .green : themeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .strikethrough(habit.isCompleted)
                    .foregroundStyle(habit.isCompleted ? .secondary : .primary)
                
                Text("+\(habit.points) Puan")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(themeColor.opacity(0.1))
                    .foregroundStyle(themeColor).cornerRadius(5)
            }
            Spacer()
            HStack(spacing: 15) {
                Button(action: duplicate) {
                    Image(systemName: "plus.square.on.square").font(.system(size: 18)).foregroundStyle(themeColor.opacity(0.7))
                }.buttonStyle(ScalableButtonStyle())
                
                Button(action: deleteHabit) {
                    Image(systemName: "trash").font(.system(size: 18)).foregroundStyle(.red.opacity(0.7))
                }.buttonStyle(ScalableButtonStyle())
            }
        }
        .padding().background(Color.primary.opacity(0.04)).cornerRadius(20)
    }
}

struct ScalableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ProgressCircle: View {
    var progress: Double
    var color: Color
    var body: some View {
        ZStack {
            Circle().stroke(Color.primary.opacity(0.05), lineWidth: 5)
            Circle().trim(from: 0, to: progress).stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90)).animation(.spring, value: progress)
        }.frame(width: 44, height: 44)
    }
}

struct ConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<25) { i in
                Circle()
                    .fill([Color.orange, .blue, .purple, .green, .yellow, .pink, .cyan].randomElement()!)
                    .frame(width: 8, height: 8)
                    .offset(x: animate ? CGFloat.random(in: -200...200) : 0,
                            y: animate ? CGFloat.random(in: -400...400) : 0)
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.2 : 1.2)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animate = true
            }
        }
    }
}
