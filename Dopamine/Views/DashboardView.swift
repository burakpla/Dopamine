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
    // MARK: - Persistence & Data
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
    @State private var selectedDate: Date = Date()
    @State private var confettiTrigger = 0
    @State private var tempTarget: Double = 500
    @State private var bgRotation: Double = 0.0 // Arka plan animasyonu için
    
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
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        motivationCard
                        scoreCard
                        performanceChart
                        todayHabitsList
                    }
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .padding(.vertical, 10)
                }
                
                // Konfeti Efekti
                if confettiTrigger > 0 {
                    ConfettiView().id(confettiTrigger).allowsHitTesting(false)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) { isShowingResetAlert = true } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.red)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 15) {
                        Button { isShowingDatePicker = true } label: {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundStyle(.white)
                        }
                        
                        Button { isShowingAddSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(levelInfo.themeColor)
                        }
                    }
                }
            }
            // MARK: - Sheets & Alerts
            .sheet(isPresented: $isShowingDatePicker) { datePickerSheet }
            .sheet(isPresented: $isShowingDetailSheet) {
                DailyDetailView(date: selectedDate, habits: habits, themeColor: levelInfo.themeColor)
            }
            .sheet(isPresented: $isShowingTargetSheet) { targetSettingSheet }
            .sheet(isPresented: $isShowingAddSheet) {
                AddHabitView().presentationDetents([.medium])
            }
            .alert("Verileri Sıfırla", isPresented: $isShowingResetAlert) {
                Button("Vazgeç", role: .cancel) { }
                Button("Her Şeyi Sil", role: .destructive) { resetAllData() }
            } message: {
                Text("Tüm ilerlemen ve görevlerin kalıcı olarak silinecek. Emin misin?")
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                bgRotation = 360
            }
        }
    }
}

// MARK: - UI Components Extension
extension DashboardView {
    
    // Onboarding'den gelen Mesh Arka Plan
    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "0F0F1E").ignoresSafeArea()
            
            Group {
                Circle()
                    .fill(levelInfo.themeColor.opacity(0.3))
                    .frame(width: 450)
                    .blur(radius: 80)
                    .offset(x: -150, y: -250)
                
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 350)
                    .blur(radius: 70)
                    .offset(x: 150, y: 250)
            }
            .rotationEffect(.degrees(bgRotation))
        }
    }
    
    private var motivationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "quote.opening").foregroundStyle(levelInfo.themeColor)
                Text("GÜNÜN MOTİVASYONU").font(.caption2.bold()).tracking(1).foregroundStyle(.white.opacity(0.5))
            }
            Text(QuoteProvider.dailyQuote)
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.1), lineWidth: 1))
    }
    
    private var scoreCard: some View {
        VStack(spacing: 25) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selam, \(userName)!").font(.title2.bold()).foregroundStyle(.white)
                    Text(isTargetAchieved ? "🏆 GÜNÜN ŞAMPİYONU" : levelInfo.rank)
                        .font(.subheadline)
                        .foregroundStyle(isTargetAchieved ? .orange : levelInfo.themeColor)
                        .fontWeight(.bold)
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
                            Text("\(dailyTarget)").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(.white)
                            Text("HEDEF").font(.system(size: 8, weight: .black)).foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
                .buttonStyle(ScalableButtonStyle())
            }
            
            VStack(spacing: 8) {
                Text("\(totalPoints)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(isTargetAchieved ? Color.orange.gradient : levelInfo.themeColor.gradient)
                    .shadow(color: (isTargetAchieved ? Color.orange : levelInfo.themeColor).opacity(0.3), radius: 15, y: 10)
                
                Text("TOPLAM PUAN").font(.caption2.bold()).tracking(2).foregroundStyle(.white.opacity(0.5))
            }
            
            levelProgressBar
        }
        .padding(24)
        .background(Color.white.opacity(0.06))
        .background(.ultraThinMaterial)
        .cornerRadius(32)
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(.white.opacity(0.12), lineWidth: 1.5))
    }
    
    private var performanceChart: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Haftalık Performans").font(.headline).foregroundStyle(.white)
            
            Chart {
                ForEach(weeklyData) { data in
                    BarMark(
                        x: .value("Gün", data.date, unit: .day),
                        y: .value("Puan", data.points)
                    )
                    .foregroundStyle(levelInfo.themeColor.gradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 140)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated)).foregroundStyle(.white.opacity(0.5))
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel().foregroundStyle(.white.opacity(0.5))
                    AxisGridLine().foregroundStyle(.white.opacity(0.05))
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.06))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.1), lineWidth: 1))
    }
    
    private var todayHabitsList: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Bugünkü Hedeflerin")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.leading, 4)
            
            if habits.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(levelInfo.themeColor.opacity(0.6))
                    Text("Henüz bir hedef eklemedin kanka.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(habits) { habit in
                        HabitRow(habit: habit, confettiTrigger: $confettiTrigger, themeColor: levelInfo.themeColor)
                    }
                }
            }
        }
    }
    
    private var levelProgressBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Lvl \(levelInfo.level)").font(.caption.bold()).foregroundStyle(.white)
                Spacer()
                Text("\((levelInfo.level * 200) - totalPoints) P kaldı").font(.caption2).foregroundStyle(.white.opacity(0.5))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(levelInfo.themeColor.gradient)
                        .frame(width: geo.size.width * CGFloat(Double(totalPoints % 200) / 200.0))
                        .shadow(color: levelInfo.themeColor.opacity(0.5), radius: 4)
                }
            }
            .frame(height: 8)
        }
    }
    
    // Tarih Seçici Sayfası
    private var datePickerSheet: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1E").ignoresSafeArea()
                VStack(spacing: 25) {
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(levelInfo.themeColor)
                        .preferredColorScheme(.dark)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(24)
                    
                    Button {
                        isShowingDatePicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            isShowingDetailSheet = true
                        }
                    } label: {
                        HStack {
                            Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted)) Detayları")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(levelInfo.themeColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
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
    
    // Hedef Ayarlama Sayfası
    private var targetSettingSheet: some View {
        ZStack {
            Color(hex: "0F0F1E").ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Günlük Hedef").font(.title2.bold()).foregroundStyle(.white)
                
                VStack {
                    Slider(value: $tempTarget, in: 100...2000, step: 50)
                        .tint(levelInfo.themeColor)
                    
                    Text("\(Int(tempTarget)) Puan")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(levelInfo.themeColor)
                }
                .padding(30)
                .background(Color.white.opacity(0.05))
                .cornerRadius(24)
                
                Button("GÜNCELLE") {
                    dailyTarget = Int(tempTarget)
                    isShowingTargetSheet = false
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(levelInfo.themeColor)
                .foregroundColor(.white)
                .cornerRadius(18)
            }
            .padding()
        }
        .presentationDetents([.height(380)])
    }
    
    private func resetAllData() {
        for habit in habits { modelContext.delete(habit) }
        try? modelContext.save()
        userName = ""
        dailyTarget = 500
    }
}

#Preview {
    let _ = UserDefaults.standard.set("Burak", forKey: "username")
    let _ = UserDefaults.standard.set(true, forKey: "isLoggedIn")
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    let sampleHabit = Habit(title: "Sabah Koşusu 🏃‍♂️", difficulty: 2)
    container.mainContext.insert(sampleHabit)
    
    return DashboardView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
