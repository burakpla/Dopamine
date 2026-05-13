# 🧠 Dopamine — Alışkanlık Takip Uygulaması

<p align="center">
  <img src="Screenshots/dashboard.png" width="250" />
</p>

**Dopamine**, günlük alışkanlıklarını takip ederek motivasyonunu yüksek tutan, oyunlaştırma (gamification) mantığıyla çalışan bir iOS uygulamasıdır. Alışkanlık tamamladıkça puan kazan, seviye atla ve kendini ödüllendir!

---

## ✨ Özellikler

- 🎯 **Alışkanlık Oluşturma** — Kolay, Orta ve Zor zorluk seviyelerinde alışkanlıklar ekle
- 📊 **Günlük Performans Grafiği** — Haftalık ilerlemeyi Charts ile görselleştir
- 🏆 **Seviye & Rütbe Sistemi** — Puan topla, Çaylak'tan Efsane'ye yüksel
- 🎯 **Günlük Hedef** — Kendi hedefini belirle ve doluluk oranını takip et
- 📅 **Tarih Bazlı Detay** — Geçmiş günlere ait alışkanlıkları incele
- 💬 **Motivasyon Sözleri** — Her gün farklı bir ilham verici söz
- 🔔 **Bildirimler** — Hatırlatma bildirimleri ile alışkanlıklarını unutma
- 📳 **Haptic Feedback** — Tamamlama ve etkileşimlerde dokunsal geri bildirim
- 🎨 **Dinamik Tema** — Seviyene göre değişen renk teması
- 🧹 **Günlük Sıfırlama** — Yeni güne temiz bir başlangıç yap

---

## 📸 Ekran Görüntüleri

<p align="center">
  <img src="Screenshots/onboarding.png" width="200" />
  <img src="Screenshots/dashboard.png" width="200" />
  <img src="Screenshots/add_habit.png" width="200" />
</p>
<p align="center">
  <img src="Screenshots/daily_detail.png" width="200" />
  <img src="Screenshots/habit_list.png" width="200" />
  <img src="Screenshots/level_system.png" width="200" />
</p>

---

## 🎬 Demo Video

> 📹 Demo videosu yakında eklenecektir.

---

## 🏗️ Mimari & Teknolojiler

| Katman | Teknoloji |
|---|---|
| **UI** | SwiftUI |
| **Veri** | SwiftData |
| **Grafik** | Swift Charts |
| **Mimari** | MVVM (Model-View-ViewModel) |
| **Minimum iOS** | iOS 17+ |

### 📁 Proje Yapısı

```
Dopamine/
├── Models/
│   ├── Habit.swift              # Alışkanlık veri modeli
│   ├── DailyProgress.swift      # Günlük ilerleme modeli
│   └── LevelSystem.swift        # Seviye & rütbe sistemi
├── ViewModels/
│   ├── DashboardViewModel.swift # Ana ekran iş mantığı
│   ├── AddHabitViewModel.swift  # Alışkanlık ekleme mantığı
│   ├── DailyDetailViewModel.swift
│   ├── HabitRowViewModel.swift
│   └── OnboardingViewModel.swift
├── Views/
│   ├── DashboardView.swift      # Ana ekran
│   ├── AddHabitView.swift       # Alışkanlık ekleme
│   ├── DailyDetailView.swift    # Günlük detay
│   ├── HabitRow.swift           # Alışkanlık satırı
│   └── OnboardingView.swift     # Karşılama ekranı
└── Helpers/
    ├── HapticManager.swift      # Dokunsal geri bildirim
    ├── NotificationManager.swift # Bildirim yönetimi
    ├── QuoteProvider.swift      # Motivasyon sözleri
    └── SharedComponents.swift   # Ortak UI bileşenleri
```

---

## 🎮 Puan & Seviye Sistemi

| Zorluk | Puan |
|---|---|
| 🟢 Kolay | +5 |
| 🟡 Orta | +15 |
| 🔴 Zor | +40 |

| Seviye | Rütbe | Gerekli Puan |
|---|---|---|
| 1 | Çaylak | 0 |
| 2 | Gelişmekte Olan | 200 |
| 3 | Odak Ustası | 400 |
| 4 | Dopamin Mimarı | 600 |
| 5+ | Efsane | 800+ |

---

## 🚀 Kurulum

1. Bu repoyu klonlayın:
   ```bash
   git clone https://github.com/burakpla/Dopamine.git
   ```
2. Xcode 16+ ile `Dopamine.xcodeproj` dosyasını açın
3. iPhone 17 Pro veya üzeri simülatör seçin
4. ▶️ **Run** yapın

---

## 📄 Lisans

Bu proje MIT lisansı altında sunulmaktadır.

---

<p align="center">
  <b>Dopamine</b> ile her gün bir adım daha ileri! 🚀
</p>
