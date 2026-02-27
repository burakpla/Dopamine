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
    
    let placeholders = ["15 dk kitap oku 📖", "Su iç 💧", "Yürüyüş yap 🏃‍♂️", "Kod yaz 💻"]
    
    // Zorluk renkleri ve ikonlarını ayrı hesaplayalım (Derleyiciyi yormaz)
    private var currentDifficultyColor: Color {
        difficulty == 1 ? .green : (difficulty == 2 ? .orange : .red)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundBase
                
                VStack(spacing: 30) {
                    inputSection
                    difficultySelectionSection
                    rewardInfoCard
                    
                    Spacer()
                    
                    saveButton
                }
                .padding(25)
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Sub-Views (Parçalara Bölünmüş Alanlar)
extension AddHabitView {
    
    private var backgroundBase: some View {
        ZStack {
            Color(hex: "0F0F1E").ignoresSafeArea()
            Circle()
                .fill(currentDifficultyColor.opacity(0.15))
                .frame(width: 300)
                .blur(radius: 80)
                .offset(x: 100, y: -200)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // "NE BAŞARACAKSIN?" başlığını buraya geri ekleyelim,
            // hem şık durur hem de doğal bir boşluk yaratır.
            Text("NE BAŞARACAKSIN?")
                .font(.caption2.bold())
                .tracking(2)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 5)
            
            TextField("", text: $title, prompt: Text(placeholders.randomElement()!).foregroundStyle(.white.opacity(0.3)))
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white.opacity(0.1), lineWidth: 1))
                .foregroundStyle(.white)
        }
        .padding(.top, 30) // İşte burası! 30-40 arası bir değerle aşağı itebilirsin.
    }
    
    private var difficultySelectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("ZORLUK SEVİYESİ").font(.caption2.bold()).tracking(2).foregroundStyle(.white.opacity(0.5))
            HStack(spacing: 12) {
                ForEach(1...3, id: \.self) { index in
                    difficultyBtn(for: index)
                }
            }
        }
    }
    
    private func difficultyBtn(for index: Int) -> some View {
        Button { withAnimation { difficulty = index } } label: {
            VStack(spacing: 8) {
                Image(systemName: index == 1 ? "leaf.fill" : (index == 2 ? "bolt.fill" : "flame.fill"))
                Text(index == 1 ? "Kolay" : (index == 2 ? "Orta" : "Zor")).font(.caption.bold())
            }
            .frame(maxWidth: .infinity).padding(.vertical, 15)
            .background(difficulty == index ? currentDifficultyColor.opacity(0.2) : Color.white.opacity(0.05))
            .foregroundStyle(difficulty == index ? currentDifficultyColor : .white.opacity(0.4))
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(difficulty == index ? currentDifficultyColor.opacity(0.5) : .clear, lineWidth: 2))
        }.buttonStyle(ScalableButtonStyle())
    }
    
    private var rewardInfoCard: some View {
        HStack(spacing: 15) {
            Image(systemName: difficulty == 1 ? "leaf.fill" : (difficulty == 2 ? "bolt.fill" : "flame.fill"))
                .foregroundStyle(currentDifficultyColor).font(.title3)
            VStack(alignment: .leading) {
                Text("Tamamladığında").font(.caption).foregroundStyle(.white.opacity(0.6))
                Text("+\(difficulty == 1 ? 5 : (difficulty == 2 ? 15 : 40)) Puan").font(.subheadline.bold())
            }
            Spacer()
        }
        .padding().background(.ultraThinMaterial).cornerRadius(20)
    }
    
    private var saveButton: some View {
        Button {
            modelContext.insert(Habit(title: title, difficulty: difficulty))
            dismiss()
        } label: {
            Text("HEDEFİ EKLE")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
            // .gradient kullanarak tipi AnyGradient olarak eşitliyoruz
                .background(
                    title.isEmpty ?
                    Color.gray.opacity(0.3).gradient :
                        currentDifficultyColor.gradient
                )
                .foregroundStyle(title.isEmpty ? .white.opacity(0.3) : .white)
                .cornerRadius(18)
        }
        .disabled(title.isEmpty)
    }
}
#Preview {
    // Geçici bir veri konteyneri oluşturuyoruz ki Preview çalışabilsin
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Habit.self, configurations: config)
    
    return AddHabitView()
        .modelContainer(container) // SwiftData için gerekli
}
