//
//  AddHabitView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var difficulty: Int = 1
    
    var body: some View {
        NavigationStack {
            let placeholders = [
                "15 dakika kitap oku 📖",
                "Günde 2 litre su iç 💧",
                "Bugün 5.000 adım at 🏃‍♂️",
                "Yeni bir Swift özelliği öğren 💻",
                "Yatağını topla 🛌",
                "10 dakika meditasyon yap 🧘‍♂️",
                "Birine teşekkür et 🙏"
            ]
            Form {
                Section("Görev Detayları") {
                    TextField(placeholders.randomElement() ?? "Ne yapacaksın?", text: $title)
                }
                
                Section("Zorluk Seviyesi") {
                    Picker("Zorluk", selection: $difficulty) {
                        Text("Kolay (5p)").tag(1)
                        Text("Orta (15p)").tag(2)
                        Text("Zor (40p)").tag(3)
                    }
                    .pickerStyle(.segmented) // Apple tarzı yan yana butonlar
                }
            }
            .navigationTitle("Yeni Hedef")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        let newHabit = Habit(title: title, difficulty: difficulty)
                        modelContext.insert(newHabit) // SwiftData'ya kaydet
                        NotificationManager.scheduleTaskReminder(for: newHabit)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .bold()
                }
            }
        }
    }
}
