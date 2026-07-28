//
//  Theme.swift
//  Dopamine
//
//  Uygulamanın tek doğruluk kaynağı olan tasarım sistemi.
//  Renk / boşluk / köşe yarıçapı / gölge / tipografi token'ları burada tanımlanır.
//  View'lar içinde "sihirli sayı" veya hex string kullanılmamalıdır.
//

// MARK: - Imports
import SwiftUI

// MARK: - Design System
enum DS {

    // MARK: - Colors
    /// Yeni palet: sert sistem renkleri (kırmızı/sarı) yerine, koyu zeminde
    /// yüksek okunabilirlik veren yumuşak "pastel-neon" tonlar.
    enum Colors {
        // Zemin katmanları
        static let canvas = Color(hex: "0B0B14")          // en arka plan
        static let background = Color(hex: "101020")      // ekran zemini
        static let surface = Color(hex: "17172C")         // kart zemini
        static let surfaceRaised = Color(hex: "1F1F38")   // yükseltilmiş kart

        // Cam (glass) efekti için yarı saydam katmanlar
        static let glass = Color.white.opacity(0.06)
        static let glassStrong = Color.white.opacity(0.10)
        static let hairline = Color.white.opacity(0.09)

        // Metin hiyerarşisi
        static let textPrimary = Color(hex: "F4F5FB")
        static let textSecondary = Color(hex: "F4F5FB").opacity(0.62)
        static let textTertiary = Color(hex: "F4F5FB").opacity(0.40)

        // Anlamsal renkler
        static let primary = Color(hex: "7C6BFF")   // ana mor-mavi
        static let secondary = Color(hex: "4CC9F0") // camgöbeği
        static let success = Color(hex: "3DDC97")   // tamamlandı
        static let streak = Color(hex: "FF9F45")    // seri / ateş
        static let gold = Color(hex: "FFC94A")      // rozet / hedef
        static let danger = Color(hex: "FF6B81")    // yıkıcı işlem

        /// Konfeti ve dekoratif parçacıklar için uyumlu palet.
        static let festive: [Color] = [
            Color(hex: "7C6BFF"), Color(hex: "4CC9F0"), Color(hex: "3DDC97"),
            Color(hex: "FFC94A"), Color(hex: "FF9F45"), Color(hex: "FF6B9E")
        ]
    }

    // MARK: - Spacing (4pt grid)
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32

        /// Ekran kenarları ile kartlar arasındaki standart yatay boşluk.
        static let screenEdge: CGFloat = 12
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 18
        static let lg: CGFloat = 22
        static let xl: CGFloat = 28
        static let pill: CGFloat = 999
    }

    // MARK: - Sizes
    enum Size {
        static let ringDiameter: CGFloat = 86
        static let ringGlowDiameter: CGFloat = 96
        static let ringLineWidth: CGFloat = 7
        static let progressBarHeight: CGFloat = 9
        static let checkbox: CGFloat = 28
        static let chartHeight: CGFloat = 160
        static let iconSm: CGFloat = 16
        static let iconMd: CGFloat = 22
    }

    // MARK: - Typography
    enum Typo {
        static let score = Font.system(size: 58, weight: .black, design: .rounded)
        static let statValue = Font.system(size: 19, weight: .bold, design: .rounded)
        static let ringValue = Font.system(size: 18, weight: .bold, design: .rounded)
        static let ringCaption = Font.system(size: 10, weight: .heavy, design: .rounded)
        static let overline = Font.system(size: 10, weight: .bold, design: .rounded)
        static let tileLabel = Font.system(size: 9.5, weight: .bold, design: .rounded)
        static let badge = Font.system(size: 10, weight: .bold, design: .rounded)
    }

    // MARK: - Motion
    enum Motion {
        static let spring = Animation.spring(response: 0.45, dampingFraction: 0.8)
        static let softSpring = Animation.spring(response: 0.6, dampingFraction: 0.85)
        static let press = Animation.spring(response: 0.28, dampingFraction: 0.7)

        static let ambientRotation: Double = 40
        static let ambientFloat: Double = 4.0
        static let ambientPulse: Double = 2.2
    }

    // MARK: - Elevation
    enum Shadow {
        static let cardRadius: CGFloat = 20
        static let cardY: CGFloat = 12
        static let glowRadius: CGFloat = 32
        static let glowY: CGFloat = 16
    }
}

// MARK: - Reusable Surfaces
/// Uygulama genelinde tutarlı "cam kart" görünümü.
struct GlassCard: ViewModifier {
    var radius: CGFloat = DS.Radius.lg
    var padding: CGFloat? = DS.Spacing.md
    var tint: Color = .clear

    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            .background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(DS.Colors.glass)
                    .overlay {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(tint.opacity(0.06))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(DS.Colors.hairline, lineWidth: 1)
            }
    }
}

extension View {
    /// Standart cam kart yüzeyi uygular.
    func glassCard(
        radius: CGFloat = DS.Radius.lg,
        padding: CGFloat? = DS.Spacing.md,
        tint: Color = .clear
    ) -> some View {
        modifier(GlassCard(radius: radius, padding: padding, tint: tint))
    }

    /// Bölüm başlığı gibi üst yazılar için ortak stil.
    func overlineStyle() -> some View {
        self.font(DS.Typo.overline)
            .tracking(1.4)
            .foregroundStyle(DS.Colors.textTertiary)
    }
}

// MARK: - App Background
/// Tüm ekranlarda kullanılan yumuşak, hareketli zemin.
///
/// Önemli: Dekoratif daireler `overlay` içinde çizilir. Böylece ekrandan geniş
/// olsalar bile üst katmanın ölçüsünü büyütmez ve içeriği kenarlardan taşırmazlar.
struct AppBackground: View {
    var accent: Color = DS.Colors.primary
    var rotation: Double = 0
    var showsOrbs: Bool = true

    var body: some View {
        DS.Colors.background
            .overlay {
                if showsOrbs { orbs }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var orbs: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.22))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: -140, y: -260)

            Circle()
                .fill(DS.Colors.secondary.opacity(0.14))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: 150, y: 240)
        }
        .rotationEffect(.degrees(rotation))
    }
}
