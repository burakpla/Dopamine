//
//  HabitCatalog.swift
//  Dopamine
//
//  Hazır alışkanlık kataloğu.
//  Zorluk seviyesi kullanıcıya bırakılmaz; her aktivitenin zorluğu (ve dolayısıyla
//  puanı) burada, tek merkezden tanımlanır. Kullanıcı yalnızca aktiviteyi seçer.
//

// MARK: - Imports
import SwiftUI

// MARK: - Difficulty
/// Uygulama genelinde kullanılan zorluk seviyesi.
enum HabitDifficulty: Int, CaseIterable, Identifiable {
    case easy = 1
    case medium = 2
    case hard = 3

    var id: Int { rawValue }

    /// Model tarafındaki `Habit.points` ile birebir aynı olmalıdır.
    var points: Int {
        switch self {
        case .easy: return 5
        case .medium: return 15
        case .hard: return 40
        }
    }

    var title: String {
        switch self {
        case .easy: return "Kolay"
        case .medium: return "Orta"
        case .hard: return "Zor"
        }
    }

    var symbol: String {
        switch self {
        case .easy: return "leaf.fill"
        case .medium: return "bolt.fill"
        case .hard: return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .easy: return DS.Colors.success
        case .medium: return DS.Colors.streak
        case .hard: return DS.Colors.danger
        }
    }

    /// Seviyenin ne anlama geldiğini kısaca anlatır.
    var caption: String {
        switch self {
        case .easy: return "Birkaç dakikada biter, bahane bırakmaz."
        case .medium: return "Biraz plan ister, günün belirgin bir parçası."
        case .hard: return "Ciddi irade ve zaman ister, en çok puanı getirir."
        }
    }

    static func from(rawValue value: Int) -> HabitDifficulty {
        HabitDifficulty(rawValue: value) ?? .easy
    }
}

// MARK: - Category
/// Katalogdaki aktiviteleri anlamlı gruplara ayırır.
enum HabitCategory: String, CaseIterable, Identifiable {
    case health = "Sağlık"
    case mind = "Zihin"
    case productivity = "Üretkenlik"
    case home = "Yaşam"
    case social = "Bağlantı"
    case discipline = "Disiplin"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .health: return "heart.fill"
        case .mind: return "brain.head.profile"
        case .productivity: return "target"
        case .home: return "house.fill"
        case .social: return "person.2.fill"
        case .discipline: return "hand.raised.fill"
        }
    }
}

// MARK: - Catalog Item
struct HabitTemplate: Identifiable, Hashable {
    let title: String
    let symbol: String
    let difficulty: HabitDifficulty
    let category: HabitCategory

    var id: String { title }
    var points: Int { difficulty.points }
}

// MARK: - Habit Catalog
enum HabitCatalog {

    // MARK: All Templates
    static let all: [HabitTemplate] = easy + medium + hard

    // MARK: Easy
    static let easy: [HabitTemplate] = [
        .init(title: "1 Bardak Su İç", symbol: "drop.fill", difficulty: .easy, category: .health),
        .init(title: "5 Dakika Esne", symbol: "figure.cooldown", difficulty: .easy, category: .health),
        .init(title: "Vitaminini Al", symbol: "pills.fill", difficulty: .easy, category: .health),
        .init(title: "Diş İpi Kullan", symbol: "mouth.fill", difficulty: .easy, category: .health),
        .init(title: "10 Dakika Yürü", symbol: "figure.walk", difficulty: .easy, category: .health),

        .init(title: "Derin Nefes Egzersizi", symbol: "wind", difficulty: .easy, category: .mind),
        .init(title: "Şükran Notu Yaz", symbol: "hands.sparkles.fill", difficulty: .easy, category: .mind),
        .init(title: "5 Dakika Sessiz Kal", symbol: "moon.zzz.fill", difficulty: .easy, category: .mind),

        .init(title: "Yatağını Topla", symbol: "bed.double.fill", difficulty: .easy, category: .home),
        .init(title: "Masanı Topla", symbol: "tray.full.fill", difficulty: .easy, category: .home),
        .init(title: "Bulaşıkları Yıka", symbol: "sink.fill", difficulty: .easy, category: .home),
        .init(title: "Odayı Havalandır", symbol: "aqi.medium", difficulty: .easy, category: .home),
        .init(title: "Bitkileri Sula", symbol: "leaf.fill", difficulty: .easy, category: .home),

        .init(title: "Sevdiğine Mesaj At", symbol: "bubble.left.and.bubble.right.fill", difficulty: .easy, category: .social),
        .init(title: "Bir Kişiye İltifat Et", symbol: "heart.text.square.fill", difficulty: .easy, category: .social),

        .init(title: "Günün Planını Yaz", symbol: "checklist", difficulty: .easy, category: .productivity),
        .init(title: "Gelen Kutusunu Temizle", symbol: "envelope.open.fill", difficulty: .easy, category: .productivity)
    ]

    // MARK: Medium
    static let medium: [HabitTemplate] = [
        .init(title: "8.000 Adım At", symbol: "figure.walk.motion", difficulty: .medium, category: .health),
        .init(title: "30 Dakika Spor Yap", symbol: "figure.strengthtraining.traditional", difficulty: .medium, category: .health),
        .init(title: "Ev Yemeği Pişir", symbol: "fork.knife", difficulty: .medium, category: .health),
        .init(title: "2 Litre Su İç", symbol: "drop.circle.fill", difficulty: .medium, category: .health),
        .init(title: "23:00'te Yat", symbol: "moon.stars.fill", difficulty: .medium, category: .health),

        .init(title: "20 Sayfa Kitap Oku", symbol: "book.fill", difficulty: .medium, category: .mind),
        .init(title: "10 Dakika Meditasyon", symbol: "figure.mind.and.body", difficulty: .medium, category: .mind),
        .init(title: "Günlük Yaz", symbol: "square.and.pencil", difficulty: .medium, category: .mind),
        .init(title: "Yabancı Dil Pratiği", symbol: "character.bubble.fill", difficulty: .medium, category: .mind),

        .init(title: "45 Dakika Ders Çalış", symbol: "graduationcap.fill", difficulty: .medium, category: .productivity),
        .init(title: "Bütçeni Güncelle", symbol: "banknote.fill", difficulty: .medium, category: .productivity),
        .init(title: "Ertelediğin İşi Bitir", symbol: "checkmark.seal.fill", difficulty: .medium, category: .productivity),

        .init(title: "Evi Derli Toplu Bırak", symbol: "house.and.flag.fill", difficulty: .medium, category: .home),
        .init(title: "Çamaşırları Katla", symbol: "tshirt.fill", difficulty: .medium, category: .home),

        .init(title: "Aileni Ara", symbol: "phone.fill", difficulty: .medium, category: .social),
        .init(title: "Bir Arkadaşınla Buluş", symbol: "person.2.wave.2.fill", difficulty: .medium, category: .social),

        .init(title: "Sosyal Medyayı 30 Dk'ya İndir", symbol: "hourglass", difficulty: .medium, category: .discipline),
        .init(title: "Bugün Şeker Yeme", symbol: "nosign", difficulty: .medium, category: .discipline),
        .init(title: "Soğuk Duş Al", symbol: "shower.fill", difficulty: .medium, category: .discipline)
    ]

    // MARK: Hard
    static let hard: [HabitTemplate] = [
        .init(title: "1 Saat Antrenman", symbol: "dumbbell.fill", difficulty: .hard, category: .health),
        .init(title: "5 km Koş", symbol: "figure.run", difficulty: .hard, category: .health),
        .init(title: "10.000 Adım At", symbol: "flame.fill", difficulty: .hard, category: .health),
        .init(title: "100 Şınav Çek", symbol: "figure.strengthtraining.functional", difficulty: .hard, category: .health),
        .init(title: "Aralıklı Oruç (16:8)", symbol: "timer", difficulty: .hard, category: .health),

        .init(title: "Sabah 06:00'da Kalk", symbol: "sunrise.fill", difficulty: .hard, category: .discipline),
        .init(title: "Sigara İçme", symbol: "nosign", difficulty: .hard, category: .discipline),
        .init(title: "Alkol Alma", symbol: "xmark.seal.fill", difficulty: .hard, category: .discipline),
        .init(title: "Dijital Detoks Günü", symbol: "iphone.slash", difficulty: .hard, category: .discipline),
        .init(title: "Fast Food Yeme", symbol: "takeoutbag.and.cup.and.straw.fill", difficulty: .hard, category: .discipline),

        .init(title: "2 Saat Derin Çalışma", symbol: "brain.head.profile", difficulty: .hard, category: .productivity),
        .init(title: "Yan Projene 1 Saat Ver", symbol: "hammer.fill", difficulty: .hard, category: .productivity),
        .init(title: "Yeni Bir Beceri Öğren", symbol: "sparkles", difficulty: .hard, category: .mind),
        .init(title: "1 Bölüm Kitap Bitir", symbol: "books.vertical.fill", difficulty: .hard, category: .mind),

        .init(title: "Genel Ev Temizliği", symbol: "sparkle.magnifyingglass", difficulty: .hard, category: .home)
    ]

    // MARK: Query
    static func templates(for difficulty: HabitDifficulty) -> [HabitTemplate] {
        switch difficulty {
        case .easy: return easy
        case .medium: return medium
        case .hard: return hard
        }
    }

    /// Seçilen seviyedeki aktiviteleri kategori sırasına göre gruplar.
    static func grouped(for difficulty: HabitDifficulty) -> [(category: HabitCategory, items: [HabitTemplate])] {
        let items = templates(for: difficulty)
        return HabitCategory.allCases.compactMap { category in
            let matches = items.filter { $0.category == category }
            return matches.isEmpty ? nil : (category, matches)
        }
    }

    /// Başlığa karşılık gelen katalog kaydını döndürür.
    static func template(named title: String) -> HabitTemplate? {
        all.first { $0.title == title }
    }
}
