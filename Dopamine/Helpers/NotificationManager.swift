//
//  NotificationManager.swift
//  Dopamine
//
//  Created by PortalGrup on 22.02.2026.
//


// MARK: - Imports
import UserNotifications
import Foundation

// MARK: - Notification Manager
struct NotificationManager {
    // MARK: Identifiers
    private static let dailyReminderID = "dailyReminder"
    private static let streakReminderID = "streakReminder"

    // MARK: Permission
    static func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion?(granted) }
        }
    }

    // MARK: Scheduling - Daily Reminder
    static func scheduleDailyReminder(atHour hour: Int = 20) {
        let content = UNMutableNotificationContent()
        content.title = "DOPAMINE ⚡️"
        content.body = messages.randomElement() ?? "Bugün halkanı doldurmayı unutma! 🌈"
        content.sound = .default

        var components = DateComponents()
        components.hour = max(0, min(hour, 23))
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderID, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
    }

    // MARK: Scheduling - Streak Guard
    /// Seri bozulmasın diye gece geç saatte uyarı planlar.
    static func scheduleStreakGuard(streak: Int, remainingPoints: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [streakReminderID])
        guard streak > 1, remainingPoints > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "🔥 \(streak) günlük serin tehlikede!"
        content.body = "Hedefine sadece \(remainingPoints) puan kaldı. Gün bitmeden tamamla!"
        content.sound = .default

        var components = DateComponents()
        components.hour = 21
        components.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: streakReminderID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: Scheduling - Task Reminder
    static func scheduleTaskReminder(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Hala Bitmedi mi? ⏳"
        content.body = "'\(habit.title)' görevini ekleyeli 1 saat oldu. Harekete geç!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: Cancellation
    static func cancelTaskReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: Copy
    private static let messages = [
        "Bugün daireyi doldurmadın mı? Hadi biraz dopamin! 🌈",
        "Küçük bir adım, büyük bir fark. Bir görev tamamla! ⚡️",
        "Serini kaybetme! Bugünü boş geçme. 🔥",
        "Günü bitirmeden son bir kontrol yapalım mı? 👀"
    ]
}
