//
//  DashboardView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

// MARK: - Imports
import SwiftUI
import SwiftData
import Charts

// MARK: - Dashboard View
struct DashboardView: View {
    // MARK: Storage & Environment
    @AppStorage("userName") var userName: String = ""
    @AppStorage("dailyTarget") var dailyTarget: Int = 500
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .reverse) var habits: [Habit]
    
    // MARK: State
    @State private var vm = DashboardViewModel()
    @State private var isShowingAddSheet = false
    @State private var isShowingTargetSheet = false
    @State private var isShowingResetAlert = false
    @State private var isShowingDatePicker = false
    @State private var isShowingDetailSheet = false
    @State private var selectedDate: Date = Date()
    @State private var confettiTrigger = 0
    @State private var tempTarget: Double = 500
    @State private var bgRotation: Double = 0.0
    @State private var cardFloat: CGFloat = 0
    @State private var glowPulse: CGFloat = 0
    @State private var shineX: CGFloat = -1
    // MARK: Body
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
                
                if confettiTrigger > 0 {
                    ConfettiView().id(confettiTrigger).allowsHitTesting(false)
                }
            }
            .toolbar { toolbarContent }
            .sheet(isPresented: $isShowingDatePicker) { datePickerSheet }
            .sheet(isPresented: $isShowingDetailSheet) { DailyDetailView(date: selectedDate, habits: habits, themeColor: vm.levelInfo.themeColor) }
            .sheet(isPresented: $isShowingTargetSheet) { targetSettingSheet }
            .sheet(isPresented: $isShowingAddSheet) { AddHabitView().presentationDetents([.medium]) }
            .alert("Sıfırla", isPresented: $isShowingResetAlert) {
                Button("Vazgeç", role: .cancel) { }
                Button("Sil", role: .destructive) { resetAllData() }
            } message: { Text("Tüm veriler silinecek, emin misin?") }
                .onAppear {
                    updateVM()
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { bgRotation = 360 }
                }
                .onChange(of: habits) { updateVM() }
                .onChange(of: dailyTarget) { updateVM() }
        }
    }
    
    // MARK: Helpers
    private func updateVM() {
        vm.habits = habits
        vm.dailyTarget = dailyTarget
    }
}

// MARK: - View Composition
extension DashboardView {
    // MARK: Background Layer
    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "0F0F1E").ignoresSafeArea()
            Group {
                Circle().fill(vm.levelInfo.themeColor.opacity(0.3)).frame(width: 450).blur(radius: 80).offset(x: -150, y: -250)
                Circle().fill(Color.blue.opacity(0.2)).frame(width: 350).blur(radius: 70).offset(x: 150, y: 250)
            }
            .rotationEffect(.degrees(bgRotation))
        }
    }
    
    // MARK: Sheet - Date Picker
    private var datePickerSheet: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F0F1E").ignoresSafeArea()
                
                VStack(spacing: 25) {
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(vm.levelInfo.themeColor)
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
                        .background(vm.levelInfo.themeColor)
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
    
    // MARK: Card - Score
    private var scoreCard: some View {
        VStack(spacing: 25) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selam, \(userName)!")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text(vm.isTargetAchieved ? "🏆 GÜNÜN ŞAMPİYONU" : vm.levelInfo.rank)
                        .font(.subheadline).bold()
                        .foregroundStyle(vm.isTargetAchieved ? .orange : vm.levelInfo.themeColor)
                }

                Spacer()

                Button {
                    tempTarget = Double(dailyTarget)
                    isShowingTargetSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                (vm.isTargetAchieved ? Color.orange : vm.levelInfo.themeColor).opacity(0.35),
                                lineWidth: 10
                            )
                            .blur(radius: 10)
                            .frame(width: 92, height: 92)
                            .scaleEffect(1.0 + glowPulse * 0.05)
                            .opacity(0.7)

                        ProgressCircle(
                            progress: vm.dailyProgress,
                            color: vm.isTargetAchieved ? .orange : vm.levelInfo.themeColor
                        )
                        .frame(width: 85, height: 85)

                        VStack(spacing: -2) {
                            Text("\(dailyTarget)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("HEDEF")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
                .buttonStyle(ScalableButtonStyle())
            }

            VStack(spacing: 8) {
                Text("\(vm.totalPoints)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(vm.isTargetAchieved ? Color.orange.gradient : vm.levelInfo.themeColor.gradient)

                Text("TOPLAM PUAN")
                    .font(.caption2.bold())
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.5))
            }

            levelProgressBar
        }
        .padding(24)
        .background(
            ZStack {
                // ✅ Theme background (no glass)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "141429"),
                                Color(hex: "0F0F1E")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // ✅ Soft color bloom (themeColor / orange)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                (vm.isTargetAchieved ? Color.orange : vm.levelInfo.themeColor).opacity(0.22),
                                .clear
                            ],
                            center: .topTrailing,
                            startRadius: 10,
                            endRadius: 240
                        )
                    )

                // ✅ Subtle noise / texture feel (fake grain using tiny opacity)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.06),
                                .clear,
                                .white.opacity(0.03)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.overlay)
                    .opacity(0.35)

                // ✅ Moving shine (kalsın, premium duruyor)
                GeometryReader { geo in
                    Color.white.opacity(0.10)
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.8), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .rotationEffect(.degrees(25))
                                .offset(x: shineX * geo.size.width * 2.2)
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .opacity(0.28)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.20),
                            (vm.isTargetAchieved ? Color.orange : vm.levelInfo.themeColor).opacity(0.20),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
        .shadow(color: (vm.isTargetAchieved ? Color.orange : vm.levelInfo.themeColor).opacity(0.15), radius: 30, x: 0, y: 18)
        .offset(y: cardFloat)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                cardFloat = -6
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                glowPulse = 1
            }
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                shineX = 1
            }
        }
    }
    
    // MARK: Card - Motivation
    private var motivationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundStyle(vm.levelInfo.themeColor)
                
                Text("GÜNÜN MOTİVASYONU")
                    .font(.caption2.bold())
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            Text(QuoteProvider.dailyQuote)
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true) 
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: Section - Performance Chart
    private var performanceChart: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Haftalık Performans").font(.headline).foregroundStyle(.white)
            Chart {
                ForEach(vm.getWeeklyData()) { data in
                    BarMark(x: .value("Gün", data.date, unit: .day), y: .value("Puan", data.points))
                        .foregroundStyle(vm.levelInfo.themeColor.gradient).cornerRadius(6)
                }
            }
            .frame(height: 140)
            .chartXAxis { AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.abbreviated)).foregroundStyle(.white.opacity(0.5)) } }
            .chartYAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(.white.opacity(0.5)); AxisGridLine().foregroundStyle(.white.opacity(0.05)) } }
        }
        .padding(20).background(Color.white.opacity(0.06)).cornerRadius(24)
    }
    
    // MARK: Section - Today's Habits
    private var todayHabitsList: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Bugünkü Hedeflerin").font(.headline).foregroundStyle(.white).padding(.leading, 4)
            if habits.isEmpty {
                ContentUnavailableView("Henüz hedef yok", systemImage: "sparkles").opacity(0.4)
            } else {
                VStack(spacing: 12) {
                    ForEach(habits) { habit in
                        HabitRow(habit: habit, confettiTrigger: $confettiTrigger, themeColor: vm.levelInfo.themeColor)
                    }
                }
            }
        }
    }
    
    // MARK: Component - Level Progress
    private var levelProgressBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Lvl \(vm.levelInfo.level)").font(.caption.bold()).foregroundStyle(.white)
                Spacer()
                Text("\((vm.levelInfo.level * 200) - vm.totalPoints) P kaldı").font(.caption2).foregroundStyle(.white.opacity(0.5))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1))
                    Capsule().fill(vm.levelInfo.themeColor.gradient)
                        .frame(width: geo.size.width * CGFloat(Double(vm.totalPoints % 200) / 200.0))
                }
            }.frame(height: 8)
        }
    }
    
    // MARK: Toolbar
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) { isShowingResetAlert = true } label: {
                    Image(systemName: "arrow.counterclockwise.circle").foregroundStyle(.red)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 15) {
                    Button { isShowingDatePicker = true } label: { Image(systemName: "calendar").foregroundStyle(.white) }
                    Button { isShowingAddSheet = true } label: { Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(vm.levelInfo.themeColor) }
                }
            }
        }
    }
    
    // MARK: Sheet - Target Setting
    private var targetSettingSheet: some View {
        ZStack {
            Color(hex: "0F0F1E").ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Günlük Hedef").font(.title2.bold()).foregroundStyle(.white)
                Slider(value: $tempTarget, in: 100...2000, step: 50).tint(vm.levelInfo.themeColor)
                Text("\(Int(tempTarget)) Puan").font(.system(size: 40, weight: .black, design: .rounded)).foregroundStyle(vm.levelInfo.themeColor)
                Button("GÜNCELLE") { dailyTarget = Int(tempTarget); isShowingTargetSheet = false }
                    .font(.headline).frame(maxWidth: .infinity).padding().background(vm.levelInfo.themeColor).foregroundColor(.white).cornerRadius(18)
            }.padding()
        }.presentationDetents([.height(350)])
    }
    
    // MARK: Actions
    private func resetAllData() {
        habits.forEach { modelContext.delete($0) }
        userName = ""; dailyTarget = 500
    }
}

// MARK: - Preview
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
