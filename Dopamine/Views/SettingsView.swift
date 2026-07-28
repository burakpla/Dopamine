//
//  SettingsView.swift
//  Dopamine
//
//  Ayarlar: isim, hedef, bildirim, titreşim, veri sıfırlama.
//

// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Settings View
struct SettingsView: View {
    // MARK: Storage & Environment
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("dailyTarget") private var dailyTarget: Int = 500
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = true
    @AppStorage("reminderHour") private var reminderHour: Int = 20

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let themeColor: Color
    let totalPoints: Int
    let totalCompletions: Int
    let bestStreak: Int

    // MARK: State
    @State private var isShowingResetAlert = false
    @State private var draftName: String = ""

    // MARK: Body
    var body: some View {
        NavigationStack {
            Form {
                profileSection
                targetSection
                notificationSection
                statsSection
                dangerSection
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground(accent: themeColor, showsOrbs: false))
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Bitti") { commitName(); dismiss() }
                        .foregroundStyle(themeColor)
                }
            }
            .onAppear { draftName = userName }
            .alert("Tüm Verileri Sil", isPresented: $isShowingResetAlert) {
                Button("Vazgeç", role: .cancel) { }
                Button("Sil", role: .destructive) { resetAllData() }
            } message: {
                Text("Tüm alışkanlıklar, puanlar ve geçmiş kalıcı olarak silinecek. Bu işlem geri alınamaz.")
            }
        }
    }

    // MARK: Sections
    private var profileSection: some View {
        Section("Profil") {
            TextField("Adın", text: $draftName)
                .onSubmit(commitName)
        }
    }

    private var targetSection: some View {
        Section("Günlük Hedef") {
            Stepper(value: $dailyTarget, in: 50...3000, step: 50) {
                HStack {
                    Text("Hedef")
                    Spacer()
                    Text("\(dailyTarget) P")
                        .foregroundStyle(themeColor)
                        .bold()
                }
            }
        }
    }

    private var notificationSection: some View {
        Section("Bildirim & Geri Bildirim") {
            Toggle("Günlük hatırlatma", isOn: $remindersEnabled)
                .tint(themeColor)

            if remindersEnabled {
                Picker("Saat", selection: $reminderHour) {
                    ForEach(6..<24, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
            }

            Toggle("Titreşim", isOn: $hapticsEnabled)
                .tint(themeColor)
        }
        .onChange(of: remindersEnabled) { _, _ in refreshReminder() }
        .onChange(of: reminderHour) { _, _ in refreshReminder() }
    }

    private var statsSection: some View {
        Section("İstatistik") {
            LabeledContent("Toplam puan", value: "\(totalPoints)")
            LabeledContent("Toplam tamamlama", value: "\(totalCompletions)")
            LabeledContent("En uzun seri", value: "\(bestStreak) gün")
        }
    }

    private var dangerSection: some View {
        Section {
            Button("Tüm Verileri Sıfırla", role: .destructive) {
                isShowingResetAlert = true
            }
        } footer: {
            Text("Dopamine • Alışkanlıklarını oyunlaştır.")
                .font(.caption2)
                .foregroundStyle(DS.Colors.textTertiary)
        }
    }

    // MARK: Actions
    private func commitName() {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        userName = trimmed
    }

    private func refreshReminder() {
        if remindersEnabled {
            NotificationManager.scheduleDailyReminder(atHour: reminderHour)
        } else {
            NotificationManager.cancelDailyReminder()
        }
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: HabitLog.self)
            try modelContext.delete(model: Habit.self)
            try modelContext.save()
        } catch {
            print("Sıfırlama hatası: \(error)")
        }
        UserDefaults.standard.removeObject(forKey: "didMigrateToHabitLogV2")
        dailyTarget = 500
        userName = ""
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    SettingsView(themeColor: .purple, totalPoints: 1240, totalCompletions: 88, bestStreak: 12)
        .preferredColorScheme(.dark)
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
