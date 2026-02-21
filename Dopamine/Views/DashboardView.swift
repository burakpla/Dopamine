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
    // MARK: - Properties
    @AppStorage("userName") var userName: String = ""
    @AppStorage("dailyTarget") var dailyTarget: Int = 500
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .reverse) var habits: [Habit]
    
    @State private var isShowingAddSheet = false
    @State private var isShowingTargetSheet = false
    @State private var isShowingResetAlert = false
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

    // MARK: - Functions
    func resetAllData() {
        // Tüm veritabanını temizle
        for habit in habits {
            modelContext.delete(habit)
        }
        try? modelContext.save()
        
        // Tercihleri sıfırla (İsim silinince Onboarding açılır)
        userName = ""
        dailyTarget = 500
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // 1. MOTİVASYON KARTI
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "quote.opening").foregroundStyle(levelInfo.themeColor)
                                Text("GÜNÜN MOTİVASYONU").font(.caption2.bold()).tracking(1).foregroundStyle(.secondary)
                            }
                            Text(QuoteProvider.dailyQuote)
                                .font(.system(.body, design: .serif)).italic()
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding().frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial).cornerRadius(20)
                        
                        // 2. ANA KART (PARLAMA VE HEDEF HALKASI)
                        VStack(spacing: 20) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Selam, \(userName)!").font(.title2.bold())
                                    Text(isTargetAchieved ? "🏆 GÜNÜN ŞAMPİYONU" : levelInfo.rank)
                                        .font(.subheadline)
                                        .foregroundStyle(isTargetAchieved ? .orange : levelInfo.themeColor)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                
                                // HEDEF HALKASI (Ortasında hedef puanı yazar)
                                Button {
                                    tempTarget = Double(dailyTarget)
                                    isShowingTargetSheet = true
                                } label: {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            ProgressCircle(progress: dailyProgress, color: isTargetAchieved ? .orange : levelInfo.themeColor)
                                                .frame(width: 85, height: 85)
                                            
                                            VStack(spacing: -2) {
                                                Text("\(dailyTarget)")
                                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                                    .foregroundStyle(isTargetAchieved ? .orange : .primary)
                                                Text("HEDEF")
                                                    .font(.system(size: 8, weight: .black))
                                                    .foregroundStyle(.secondary)
                                            }
                                            
                                            // Düzenle İkonu
                                            Image(systemName: "pencil")
                                                .font(.system(size: 10, weight: .bold))
                                                .padding(4)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                                .offset(x: 32, y: -32)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .buttonStyle(ScalableButtonStyle())
                            }
                            
                            VStack(spacing: 5) {
                                Text("\(totalPoints)")
                                    .font(.system(size: 54, weight: .black, design: .rounded))
                                    .foregroundStyle(isTargetAchieved ? Color.orange.gradient : levelInfo.themeColor.gradient)
                                
                                Text("TOPLAM PUAN").font(.caption2.bold()).tracking(2).foregroundStyle(.secondary)
                                
                                Text("Bugün: \(todayPoints) / \(dailyTarget)")
                                    .font(.caption.bold())
                                    .foregroundStyle(isTargetAchieved ? .orange : .secondary)
                                    .padding(.vertical, 4).padding(.horizontal, 10)
                                    .background(isTargetAchieved ? Color.orange.opacity(0.1) : Color.clear).cornerRadius(10)
                            }
                            
                            levelProgressBar
                        }
                        .padding(24).background(.ultraThinMaterial).cornerRadius(32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(isTargetAchieved ? Color.orange.gradient : Color.clear.gradient, lineWidth: 3)
                        )
                        .animation(.spring(), value: isTargetAchieved)

                        // 3. GRAFİK KARTI
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
                        
                        // 4. GÖREV LİSTESİ
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
                    Button { isShowingAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(levelInfo.themeColor)
                    }
                }
            }
            .alert("Sıfırlansın mı?", isPresented: $isShowingResetAlert) {
                Button("Vazgeç", role: .cancel) { }
                Button("Her Şeyi Sil", role: .destructive) { resetAllData() }
            } message: { Text("Tüm ilerlemen kalıcı olarak silinecek.") }
            .sheet(isPresented: $isShowingTargetSheet) { targetSettingSheet }
            .sheet(isPresented: $isShowingAddSheet) { AddHabitView().presentationDetents([.medium]) }
        }
    }
    
    // MARK: - Subviews
    private var targetSettingSheet: some View {
        VStack(spacing: 25) {
            Text("Günlük Hedefini Belirle").font(.headline)
            Text("\(Int(tempTarget)) Puan").font(.system(size: 40, weight: .bold, design: .rounded)).foregroundStyle(levelInfo.themeColor)
            Slider(value: $tempTarget, in: 100...2000, step: 50).tint(levelInfo.themeColor)
            Button("Hedefi Güncelle") { dailyTarget = Int(tempTarget); isShowingTargetSheet = false }
            .buttonStyle(.borderedProminent).tint(levelInfo.themeColor).controlSize(.large)
        }.padding().presentationDetents([.height(250)])
    }
    
    private var levelProgressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Lvl \(levelInfo.level)").font(.caption.bold())
                Spacer()
                let nextLevelPoints = (levelInfo.level * 200)
                let remaining = nextLevelPoints - totalPoints
                Text("\(remaining) P kaldı").font(.caption2).foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.1)).frame(height: 8)
                    Capsule()
                        .fill(levelInfo.themeColor.gradient)
                        .frame(width: geo.size.width * CGFloat(Double(totalPoints % 200) / 200.0), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Destekleyici Tasarım
struct ScalableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Destekleyici Modeller ve Görünümler

struct HabitRow: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Binding var confettiTrigger: Int
    var themeColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    habit.isCompleted.toggle()
                    if habit.isCompleted {
                        habit.completedAt = Date()
                        confettiTrigger += 1
                        NotificationManager.cancelTaskReminder(for: habit)
                    } else {
                        habit.completedAt = nil
                    }
                }
            } label: {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(habit.isCompleted ? .green : themeColor)
                    .symbolEffect(.bounce, value: habit.isCompleted)
            }
            .sensoryFeedback(.success, trigger: habit.isCompleted) { _, newValue in
                return newValue == true
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.body.bold())
                    .strikethrough(habit.isCompleted)
                    .foregroundStyle(habit.isCompleted ? .secondary : .primary)
                
                Text("+\(habit.points) Puan")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(themeColor.opacity(0.1))
                    .foregroundStyle(themeColor).cornerRadius(5)
            }
            Spacer()
        }
        .padding()
        .background(Color.primary.opacity(0.03))
        .cornerRadius(20)
        .swipeActions {
            Button(role: .destructive) { modelContext.delete(habit) } label: { Label("Sil", systemImage: "trash") }
        }
    }
}

struct StatCard: View {
    var title: String; var value: String; var icon: String; var color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding().background(.ultraThinMaterial).cornerRadius(24)
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
