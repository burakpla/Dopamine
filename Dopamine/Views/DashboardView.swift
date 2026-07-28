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

// MARK: - Sheet Routing
enum DashboardSheet: Identifiable {
    case addHabit
    case target
    case datePicker
    case settings
    case achievements
    case dailyDetail(Date)

    var id: String {
        switch self {
        case .addHabit: return "addHabit"
        case .target: return "target"
        case .datePicker: return "datePicker"
        case .settings: return "settings"
        case .achievements: return "achievements"
        case .dailyDetail(let date): return "dailyDetail-\(date.timeIntervalSince1970)"
        }
    }
}

// MARK: - Chart Range
enum ChartRange: String, CaseIterable, Identifiable {
    case week = "Hafta"
    case month = "Ay"

    var id: String { rawValue }
    var dayCount: Int { self == .week ? 7 : 30 }
}

// MARK: - Dashboard View
struct DashboardView: View {
    // MARK: Storage & Environment
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("dailyTarget") private var dailyTarget: Int = 500
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = true

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @Query(sort: \HabitLog.date, order: .reverse) private var logs: [HabitLog]

    // MARK: State
    @State private var vm = DashboardViewModel()
    @State private var activeSheet: DashboardSheet?
    @State private var selectedDate: Date = Date()
    @State private var chartRange: ChartRange = .week
    @State private var confettiTrigger = 0
    @State private var tempTarget: Double = 500
    @State private var didCelebrateTarget = false

    // Animations
    @State private var bgRotation: Double = 0
    @State private var cardFloat: CGFloat = 0
    @State private var glowPulse: CGFloat = 0

    /// Hedef tamamlandığında altın vurgu, aksi halde seviye rengi.
    private var accentColor: Color {
        vm.isTargetAchieved ? DS.Colors.gold : vm.levelInfo.themeColor
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accent: vm.levelInfo.themeColor, rotation: bgRotation)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: DS.Spacing.md) {
                        greetingHeader
                        scoreCard
                        statsStrip
                        motivationCard
                        performanceChart
                        todayHabitsList
                    }
                    .padding(.horizontal, DS.Spacing.screenEdge)
                    .padding(.top, DS.Spacing.xs)
                    .padding(.bottom, DS.Spacing.xxl)
                }

                if confettiTrigger > 0 && !reduceMotion {
                    ConfettiView().id(confettiTrigger).allowsHitTesting(false)
                }
            }
            .toolbar { toolbarContent }
            .sheet(item: $activeSheet, content: sheet(for:))
            .onAppear {
                DataMigrator.migrateIfNeeded(context: modelContext)
                syncViewModel()
                startAmbientAnimations()
            }
            .onChange(of: habits) { _, _ in syncViewModel() }
            .onChange(of: logs) { _, _ in syncViewModel() }
            .onChange(of: dailyTarget) { _, _ in syncViewModel() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { syncViewModel() }
            }
        }
    }

    // MARK: Sheet Builder
    @ViewBuilder
    private func sheet(for sheet: DashboardSheet) -> some View {
        switch sheet {
        case .addHabit:
            AddHabitView().presentationDetents([.medium, .large])
        case .target:
            targetSettingSheet
        case .datePicker:
            datePickerSheet
        case .settings:
            SettingsView(
                themeColor: vm.levelInfo.themeColor,
                totalPoints: vm.totalPoints,
                totalCompletions: logs.count,
                bestStreak: vm.bestGlobalStreak
            )
        case .achievements:
            AchievementsView(achievements: vm.achievements, themeColor: vm.levelInfo.themeColor)
        case .dailyDetail(let date):
            DailyDetailView(date: date, logs: logs, themeColor: vm.levelInfo.themeColor)
        }
    }

    // MARK: Helpers
    private func syncViewModel() {
        vm.habits = habits
        vm.logs = logs
        vm.dailyTarget = dailyTarget
        celebrateTargetIfNeeded()
        refreshStreakGuard()
    }

    /// Hedefe ilk kez ulaşıldığında bir kez kutlama yapar.
    private func celebrateTargetIfNeeded() {
        if vm.isTargetAchieved, !didCelebrateTarget {
            didCelebrateTarget = true
            confettiTrigger += 1
            HapticManager.success()
        } else if !vm.isTargetAchieved {
            didCelebrateTarget = false
        }
    }

    private func refreshStreakGuard() {
        guard remindersEnabled else { return }
        NotificationManager.scheduleStreakGuard(
            streak: vm.globalStreak,
            remainingPoints: vm.remainingToTarget
        )
    }

    private func startAmbientAnimations() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: DS.Motion.ambientRotation).repeatForever(autoreverses: false)) {
            bgRotation = 360
        }
        withAnimation(.easeInOut(duration: DS.Motion.ambientFloat).repeatForever(autoreverses: true)) {
            cardFloat = -4
        }
        withAnimation(.easeInOut(duration: DS.Motion.ambientPulse).repeatForever(autoreverses: true)) {
            glowPulse = 1
        }
    }
}

// MARK: - View Composition
private extension DashboardView {
    // MARK: Header - Greeting
    var greetingHeader: some View {
        HStack(alignment: .center, spacing: DS.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .overlineStyle()

                Text(userName.isEmpty ? "Şampiyon" : userName)
                    .font(.title2.bold())
                    .foregroundStyle(DS.Colors.textPrimary)
            }

            Spacer(minLength: 0)

            HStack(spacing: DS.Spacing.xxs) {
                Image(systemName: vm.levelInfo.badgeSymbol)
                    .font(.caption2)
                Text(vm.isTargetAchieved ? "GÜNÜN ŞAMPİYONU" : vm.levelInfo.rank.uppercased())
                    .font(DS.Typo.badge)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(accentColor)
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.vertical, DS.Spacing.xxs + 2)
            .background(accentColor.opacity(0.14), in: Capsule())
            .overlay(Capsule().strokeBorder(accentColor.opacity(0.28), lineWidth: 1))
        }
        .padding(.top, DS.Spacing.xxs)
        .accessibilityElement(children: .combine)
    }

    var greetingText: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "GÜNAYDIN"
        case 12..<18: return "İYİ GÜNLER"
        case 18..<23: return "İYİ AKŞAMLAR"
        default: return "İYİ GECELER"
        }
    }

    // MARK: Card - Motivation
    var motivationCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack(spacing: DS.Spacing.xxs + 2) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(vm.levelInfo.themeColor)

                Text("GÜNÜN MOTİVASYONU")
                    .overlineStyle()
            }

            Text(QuoteProvider.dailyQuote)
                .font(.system(.subheadline, design: .serif))
                .italic()
                .foregroundStyle(DS.Colors.textPrimary.opacity(0.88))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(radius: DS.Radius.lg, padding: DS.Spacing.md, tint: vm.levelInfo.themeColor)
        .accessibilityElement(children: .combine)
    }

    // MARK: Card - Score
    var scoreCard: some View {
        VStack(spacing: DS.Spacing.lg) {
            HStack(alignment: .center, spacing: DS.Spacing.md) {
                VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                    Text("TOPLAM PUAN")
                        .overlineStyle()

                    Text("\(vm.totalPoints)")
                        .font(DS.Typo.score)
                        .foregroundStyle(accentColor.gradient)
                        .contentTransition(.numericText())
                        .animation(DS.Motion.spring, value: vm.totalPoints)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)

                    Text(vm.isTargetAchieved
                         ? "Bugünkü hedefini tamamladın 🎉"
                         : "Hedefe \(vm.remainingToTarget) puan kaldı")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }

                Spacer(minLength: 0)

                targetRing
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Toplam puan \(vm.totalPoints)")

            levelProgressBar
        }
        .padding(DS.Spacing.lg)
        .background(scoreCardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.18), accentColor.opacity(0.22), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.35), radius: DS.Shadow.cardRadius, x: 0, y: DS.Shadow.cardY)
        .shadow(color: accentColor.opacity(0.16), radius: DS.Shadow.glowRadius, x: 0, y: DS.Shadow.glowY)
        .offset(y: cardFloat)
    }

    var scoreCardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DS.Colors.surfaceRaised, DS.Colors.surface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: DS.Radius.xl, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.20), .clear],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 240
                    )
                )
        }
    }

    var targetRing: some View {
        Button {
            tempTarget = Double(dailyTarget)
            activeSheet = .target
        } label: {
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.30), lineWidth: DS.Size.ringLineWidth + 3)
                    .blur(radius: 10)
                    .frame(width: DS.Size.ringGlowDiameter, height: DS.Size.ringGlowDiameter)
                    .scaleEffect(1.0 + glowPulse * 0.04)
                    .opacity(0.7)

                ProgressCircle(progress: vm.dailyProgress, color: accentColor)
                    .frame(width: DS.Size.ringDiameter, height: DS.Size.ringDiameter)

                VStack(spacing: 0) {
                    Text("\(vm.todayPoints)")
                        .font(DS.Typo.ringValue)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .contentTransition(.numericText())

                    Text("/ \(dailyTarget)")
                        .font(DS.Typo.ringCaption)
                        .foregroundStyle(DS.Colors.textTertiary)
                }
            }
        }
        .buttonStyle(ScalableButtonStyle())
        .accessibilityLabel("Günlük hedef")
        .accessibilityValue("\(vm.todayPoints) / \(dailyTarget) puan")
        .accessibilityHint("Hedefi değiştirmek için dokun")
    }

    // MARK: Component - Level Progress
    var levelProgressBar: some View {
        VStack(spacing: DS.Spacing.xs) {
            HStack {
                Text("Lvl \(vm.levelInfo.level)")
                    .font(.caption.bold())
                    .foregroundStyle(DS.Colors.textPrimary)

                Spacer()

                Text(vm.levelInfo.isMaxLevel ? "MAKS SEVİYE 👑" : "\(vm.levelInfo.pointsToNextLevel) P kaldı")
                    .font(.caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.10))
                    Capsule()
                        .fill(vm.levelInfo.themeColor.gradient)
                        .frame(width: max(geo.size.width * vm.levelInfo.levelProgress, DS.Size.progressBarHeight))
                        .animation(DS.Motion.softSpring, value: vm.levelInfo.levelProgress)
                }
            }
            .frame(height: DS.Size.progressBarHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Seviye \(vm.levelInfo.level), \(vm.levelInfo.rank)")
    }

    // MARK: Strip - Stats
    var statsStrip: some View {
        HStack(spacing: DS.Spacing.sm) {
            statTile(
                value: "\(vm.globalStreak)",
                label: "GÜN SERİ",
                symbol: "flame.fill",
                color: DS.Colors.streak
            )

            statTile(
                value: "\(vm.todayCompletedCount)/\(habits.count)",
                label: "BUGÜN",
                symbol: "checkmark.circle.fill",
                color: DS.Colors.success
            )

            Button { activeSheet = .achievements } label: {
                statTile(
                    value: "\(vm.unlockedAchievements.count)",
                    label: "ROZET",
                    symbol: "rosette",
                    color: DS.Colors.gold
                )
            }
            .buttonStyle(ScalableButtonStyle())
        }
    }

    func statTile(value: String, label: String, symbol: String, color: Color) -> some View {
        VStack(spacing: DS.Spacing.xxs + 1) {
            Image(systemName: symbol)
                .font(.system(size: DS.Size.iconSm))
                .foregroundStyle(color)

            Text(value)
                .font(DS.Typo.statValue)
                .foregroundStyle(DS.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(DS.Typo.tileLabel)
                .tracking(0.8)
                .foregroundStyle(DS.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.sm + 2)
        .glassCard(radius: DS.Radius.md, padding: 0, tint: color)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: Section - Performance Chart
    var performanceChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text("Performans")
                    .font(.headline)
                    .foregroundStyle(DS.Colors.textPrimary)

                Spacer()

                Picker("Aralık", selection: $chartRange) {
                    ForEach(ChartRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 132)
            }

            Chart {
                ForEach(vm.progress(forLastDays: chartRange.dayCount)) { data in
                    BarMark(
                        x: .value("Gün", data.date, unit: .day),
                        y: .value("Puan", data.points)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [vm.levelInfo.themeColor, vm.levelInfo.themeColor.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(chartRange == .week ? DS.Spacing.xxs + 2 : 2)
                }

                RuleMark(y: .value("Hedef", dailyTarget))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(DS.Colors.gold.opacity(0.65))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Hedef")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.Colors.gold.opacity(0.8))
                    }
            }
            .frame(height: DS.Size.chartHeight)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: chartRange == .week ? 1 : 7)) { _ in
                    AxisValueLabel(
                        format: chartRange == .week
                            ? Date.FormatStyle.dateTime.weekday(.abbreviated)
                            : Date.FormatStyle.dateTime.day().month(.abbreviated)
                    )
                    .foregroundStyle(DS.Colors.textTertiary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(DS.Colors.textTertiary)
                    AxisGridLine().foregroundStyle(.white.opacity(0.06))
                }
            }
        }
        .glassCard(radius: DS.Radius.lg, padding: DS.Spacing.md)
    }

    // MARK: Section - Today's Habits
    var todayHabitsList: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text("Bugünkü Hedeflerin")
                    .font(.headline)
                    .foregroundStyle(DS.Colors.textPrimary)

                Spacer()

                if !habits.isEmpty {
                    Text("\(vm.todayCompletedCount)/\(habits.count)")
                        .font(.caption.bold())
                        .foregroundStyle(vm.levelInfo.themeColor)
                        .padding(.horizontal, DS.Spacing.xs)
                        .padding(.vertical, 3)
                        .background(vm.levelInfo.themeColor.opacity(0.14), in: Capsule())
                }
            }

            if habits.isEmpty {
                ContentUnavailableView {
                    Label("Henüz hedef yok", systemImage: "sparkles")
                } description: {
                    Text("İlk alışkanlığını ekleyerek başla.")
                } actions: {
                    Button("Alışkanlık Ekle") { activeSheet = .addHabit }
                        .buttonStyle(.borderedProminent)
                        .tint(vm.levelInfo.themeColor)
                }
                .glassCard(radius: DS.Radius.lg, padding: DS.Spacing.xs)
            } else {
                VStack(spacing: DS.Spacing.sm) {
                    ForEach(vm.sortedHabits) { habit in
                        HabitRow(
                            habit: habit,
                            confettiTrigger: $confettiTrigger,
                            themeColor: vm.levelInfo.themeColor
                        )
                        .id(habit.id)
                    }
                }
            }
        }
    }

    // MARK: Toolbar
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button { activeSheet = .settings } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                .accessibilityLabel("Ayarlar")
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: DS.Spacing.md) {
                    Button { activeSheet = .datePicker } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(DS.Colors.textSecondary)
                    }
                    .accessibilityLabel("Geçmiş")

                    Button { activeSheet = .addHabit } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(vm.levelInfo.themeColor)
                    }
                    .accessibilityLabel("Alışkanlık ekle")
                }
            }
        }
    }

    // MARK: Sheet - Date Picker
    var datePickerSheet: some View {
        NavigationStack {
            ZStack {
                AppBackground(accent: vm.levelInfo.themeColor, showsOrbs: false)

                VStack(spacing: DS.Spacing.xl) {
                    DatePicker("Tarih", selection: $selectedDate, in: ...Date(), displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .tint(vm.levelInfo.themeColor)
                        .preferredColorScheme(.dark)
                        .glassCard(radius: DS.Radius.lg, padding: DS.Spacing.sm)

                    Button {
                        activeSheet = .dailyDetail(selectedDate)
                    } label: {
                        HStack {
                            Text("\(selectedDate.formatted(date: .abbreviated, time: .omitted)) Detayları")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.levelInfo.themeColor, in: RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(ScalableButtonStyle())

                    Spacer()
                }
                .padding(.horizontal, DS.Spacing.screenEdge)
                .padding(.top, DS.Spacing.md)
            }
            .navigationTitle("Tarih Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { activeSheet = nil }
                        .foregroundStyle(vm.levelInfo.themeColor)
                }
            }
        }
    }

    // MARK: Sheet - Target Setting
    var targetSettingSheet: some View {
        ZStack {
            AppBackground(accent: vm.levelInfo.themeColor, showsOrbs: false)

            VStack(spacing: DS.Spacing.xl) {
                VStack(spacing: DS.Spacing.xxs) {
                    Text("GÜNLÜK HEDEF")
                        .overlineStyle()

                    Text("\(Int(tempTarget)) Puan")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(vm.levelInfo.themeColor)
                        .contentTransition(.numericText())
                }

                Slider(value: $tempTarget, in: 50...2000, step: 50)
                    .tint(vm.levelInfo.themeColor)
                    .accessibilityValue("\(Int(tempTarget)) puan")

                Button("GÜNCELLE") {
                    dailyTarget = Int(tempTarget)
                    HapticManager.light()
                    activeSheet = nil
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.levelInfo.themeColor, in: RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
                .foregroundStyle(.white)
                .buttonStyle(ScalableButtonStyle())
            }
            .padding(.horizontal, DS.Spacing.screenEdge)
            .padding(.vertical, DS.Spacing.xl)
        }
        .presentationDetents([.height(340)])
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, HabitLog.self, configurations: config)

    UserDefaults.standard.set("Burak", forKey: "userName")

    let sampleHabit = Habit(title: "Sabah Koşusu 🏃‍♂️", difficulty: 2)
    container.mainContext.insert(sampleHabit)

    for offset in 0..<5 {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
        let log = HabitLog(date: date, points: 15, habitTitle: sampleHabit.title, habit: sampleHabit)
        container.mainContext.insert(log)
    }

    return DashboardView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
