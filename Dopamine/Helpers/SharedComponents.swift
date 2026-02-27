//
//  SharedComponents.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//

import SwiftUI

struct ProgressCircle: View {
    var progress: Double
    var color: Color
    
    var body: some View {
        ZStack {
            // Arka plandaki sönük halka
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 6)
            
            // İlerlemeyi gösteren parlayan halka
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color.gradient,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Yukarıdan başlaması için
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    @State private var xOffsets: [CGFloat] = (0..<25).map { _ in CGFloat.random(in: -150...150) }
    @State private var yOffsets: [CGFloat] = (0..<25).map { _ in CGFloat.random(in: -300...300) }
    
    var body: some View {
        ZStack {
            ForEach(0..<25) { i in
                Circle()
                // Neon renkler temaya daha çok yakışır
                    .fill([Color.orange, .blue, .purple, .green, .yellow, .pink, .cyan].randomElement()!)
                    .frame(width: CGFloat.random(in: 6...10), height: CGFloat.random(in: 6...10))
                    .offset(x: animate ? xOffsets[i] : 0,
                            y: animate ? yOffsets[i] : 0)
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.2 : 1.2)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect? // UIEffect yerine UIVisualEffect yazınca SwiftUI bazen daha rahat tanıyor
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
#Preview("Progress Circle") {
    VStack(spacing: 20) {
        ProgressCircle(progress: 0.7, color: .green)
            .frame(width: 100, height: 100)
        
        ProgressCircle(progress: 0.3, color: .purple)
            .frame(width: 100, height: 100)
    }
    .padding()
    .background(Color(hex: "0F0F1E"))
    .preferredColorScheme(.dark)
}

struct ScalableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0) // Basınca %6 küçülür
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1.0) // Hafif saydamlık
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview("Confetti") {
    ConfettiView()
        .background(Color.black)
}
