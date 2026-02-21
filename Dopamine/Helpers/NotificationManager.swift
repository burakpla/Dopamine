//
//  NotificationManager.swift
//  Dopamine
//
//  Created by PortalGrup on 22.02.2026.
//


import UserNotifications

struct NotificationManager {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    // Her akşam 20:00 bildirimi
    static func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "DOPAMINE ⚡️"
        content.body = "Bugün daireyi doldurmadın mı? Hadi biraz dopamin! 🌈"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // Dinamik 1 saat hatırlatıcısı
    static func scheduleTaskReminder(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Hala Bitmedi mi? ⏳"
        content.body = "'\(habit.title)' görevini ekleyeli 1 saat oldu. Harekete geç!"
        content.sound = .default
        
        // 1 saat (3600 saniye) sonra
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    // Görev bitince bildirimi siler
    static func cancelTaskReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
}