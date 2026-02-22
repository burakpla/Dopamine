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
    
    let placeholders = [
        "15 dakika kitap oku 📖",
        "Günde 2 litre su iç 💧",
        "Bugün 5.000 adım at 🏃‍♂️",
        "Yeni bir Swift özelliği öğren 💻",
        "Yatağını topla 🛌",
        "10 dakika meditasyon yap 🧘‍♂️",
        "Birine teşekkür et 🙏"
    ]
    
    // Zorluk seviyesine göre renk ve puan belirleyen yardımcı özellikler
    var difficultyColor: Color {
        switch difficulty {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .blue
        }
    }
    
    var difficultyIcon: String {
        switch difficulty {
        case 1: return "leaf.fill"
        case 2: return "bolt.fill"
        case 3: return "flame.fill"
        default: return "star.fill"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // MARK: - Görev Giriş Alanı
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NE BAŞARACAKSIN?")
                            .font(.caption2.bold())
                            .tracking(1)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 5)
                        
                        TextField(placeholders.randomElement() ?? "Hedefin nedir?", text: $title)
                            .font(.body)
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // MARK: - Zorluk Seçici Kartı
                    VStack(spacing: 20) {
                        HStack {
                            Text("ZORLUK VE ÖDÜL")
                                .font(.caption2.bold())
                                .tracking(1)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        Picker("Zorluk", selection: $difficulty) {
                            Text("Kolay").tag(1)
                            Text("Orta").tag(2)
                            Text("Zor").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .padding(4)
                        .background(difficultyColor.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Dinamik Ödül Göstergesi
                        HStack(spacing: 15) {
                            Image(systemName: difficultyIcon)
                                .font(.title)
                                .foregroundStyle(difficultyColor.gradient)
                                .symbolEffect(.bounce, value: difficulty)
                            
                            VStack(alignment: .leading) {
                                Text(difficulty == 1 ? "Basit Başlangıç" : (difficulty == 2 ? "Güçlü Adım" : "Efsane Modu"))
                                    .font(.headline)
                                
                                Text("Bu görev \(difficulty == 1 ? 5 : (difficulty == 2 ? 15 : 40)) puan")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                    
                    // MARK: - Ekle Butonu
                    Button {
                        let newHabit = Habit(title: title, difficulty: difficulty)
                        modelContext.insert(newHabit)
                        NotificationManager.scheduleTaskReminder(for: newHabit)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("GÖREVİ LİSTEYE EKLE")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: title.isEmpty ? [Color.gray] : [difficultyColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: difficultyColor.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(title.isEmpty)
                    .animation(.spring, value: difficulty)
                    .animation(.easeInOut, value: title.isEmpty)
                }
                .padding(25)
            }
            .navigationTitle("Yeni Hedef")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

