//
//  DopamineApp.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import SwiftUI
import SwiftData

@main
struct DopamineApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .modelContainer(for: Habit.self) // Veritabanını buraya bağladık
    }
}

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale = 0.6
    @State private var opacity = 0.0
    @State private var rotateLogo = 0.0
    @State private var pulseScale = 1.0
    
    // Logondaki canlı renk paleti
    let colors: [Color] = [.orange, .pink, .purple, .cyan, .yellow, .red]
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color.white.ignoresSafeArea()
                
                // 1. ARKA PLAN RENK PATLAMALARI (Daha belirgin ve canlı)
                ForEach(0..<15) { i in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(colors[i % colors.count])
                        .frame(width: CGFloat.random(in: 20...45), height: CGFloat.random(in: 20...45))
                        .blur(radius: 10) // Blur azaldı, renkler netleşti
                        .offset(x: opacity == 1 ? CGFloat.random(in: -180...180) : 0,
                                y: opacity == 1 ? CGFloat.random(in: -250...250) : 0)
                        .opacity(opacity == 1 ? 0.6 : 0) // Opaklık arttı
                }
                
                VStack(spacing: 35) {
                    ZStack {
                        // 2. LOGO ARKASI GÜÇLÜ PARLAMA (Aura)
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 200, height: 200)
                            .blur(radius: 50)
                            .scaleEffect(pulseScale) // Hafif nefes alma efekti
                            .opacity(0.4)
                        
                        Image("appLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(rotateLogo))
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    }
                    
                    // 3. DAHA CANLI GRADIENT TEXT
                    VStack(spacing: 8) {
                        Text("DOPAMINE")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .tracking(10)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Harekete Geç")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .tracking(3)
                    }
                    .opacity(opacity)
                    .offset(y: opacity == 1 ? 0 : 30)
                }
            }
            .onAppear {
                // Giriş animasyonu
                withAnimation(.spring(response: 0.9, dampingFraction: 0.5)) {
                    self.scale = 1.0
                    self.opacity = 1.0
                    self.rotateLogo = 360
                }
                
                // Arka plandaki auranın yavaşça "nefes alması"
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    self.pulseScale = 1.2
                }
                
                // Geçiş süresi
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
