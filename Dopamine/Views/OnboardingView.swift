//
//  OnboardingView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import SwiftUI
import UIKit

import SwiftUI

struct OnboardingView: View {
    // MARK: - Persisted values
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // MARK: - UI State
    @State private var nameInput: String = ""
    @FocusState private var nameFieldFocused: Bool
    @State private var shimmerPhase: CGFloat = -1.0
    @State private var bgRotation: Double = 0.0
    @State private var isButtonAnimating = false
    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20

    // MARK: - Constants
    private enum Metrics {
        static let iconSize: CGFloat = 110
        static let fieldCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 64
        static let horizontalPadding: CGFloat = 36
    }

    private var isNameValid: Bool {
        nameInput.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    var body: some View {
        ZStack {
            // 1. Dinamik Arka Plan (Mesh Gradient Etkisi)
            backgroundGradient
                .ignoresSafeArea()

            // 2. Ana İçerik
            VStack(spacing: 32) {
                Spacer()

                // Logo Bölümü
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .blur(radius: 20)
                    
                    Image(systemName: "bolt.ring.closed") // "appLogo" yerine SF Symbol koydum, kendi logonla değiştirirsin
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                        .rotationEffect(.degrees(isButtonAnimating ? 5 : -5))
                }
                .scaleEffect(contentOpacity)

                // Başlıklar
                VStack(spacing: 12) {
                    Text("Dopamine")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Sana nasıl hitap edelim?")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .multilineTextAlignment(.center)

                // Giriş Alanı (Glassmorphic)
                textFieldSection

                Spacer()

                // Devam Et Butonu
                actionButton
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, Metrics.horizontalPadding)
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                bgRotation = 360
            }
            nameFieldFocused = true
        }
    }

    // MARK: - Background View
    private var backgroundGradient: some View {
        ZStack {
            Color(hex: "0F0F1E") // Koyu premium arka plan
            
            // Hareket eden renkli küreler
            Group {
                Circle()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -250)
                
                Circle()
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 300)
                    .blur(radius: 70)
                    .offset(x: 150, y: 200)
            }
            .rotationEffect(.degrees(bgRotation))
        }
    }

    // MARK: - TextField Section
    private var textFieldSection: some View {
        VStack(alignment: .center, spacing: 15) {
            TextField("", text: $nameInput, prompt: Text("Adın...").foregroundStyle(.white.opacity(0.4)))
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.fieldCornerRadius)
                        .fill(.white.opacity(0.1))
                        .background(VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark)))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Metrics.fieldCornerRadius)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .focused($nameFieldFocused)
                .submitLabel(.done)
                .onSubmit(saveAndProceed)
            
            if !nameInput.isEmpty && !isNameValid {
                Text("En az 2 karakter gir kanka :)")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Action Button
    // MARK: - Action Button (Yeni Renk Paleti ve Glow Efekti)
        private var actionButton: some View {
            Button(action: saveAndProceed) {
                ZStack {
                    // Ana Buton Gövdesi (Canlı Gradyan)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            isNameValid ?
                            LinearGradient(colors: [Color(hex: "8E2DE2"), Color(hex: "4A00E0")], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)], startPoint: .leading, endPoint: .trailing)
                        )
                        // Aktifken dışarıya hafif bir mor ışık yayar
                        .shadow(color: isNameValid ? Color(hex: "8E2DE2").opacity(0.5) : Color.clear, radius: 15, x: 0, y: 8)
                    
                    // Butonun içindeki parıltı (Glossy etki)
                    if isNameValid {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                    }

                    Text("Başlayalım")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(isNameValid ? .white : .white.opacity(0.3))
                    
                    // Geliştirilmiş Shimmer (Işık Süzmesi)
                    if isNameValid {
                        GeometryReader { geo in
                            Color.white.opacity(0.2)
                                .mask(
                                    Rectangle()
                                        .fill(
                                            LinearGradient(colors: [.clear, .white.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .rotationEffect(.degrees(25))
                                        .offset(x: shimmerPhase * geo.size.width * 2.5)
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
            }
            .frame(height: Metrics.buttonHeight)
            .disabled(!isNameValid)
            // Basıldığında küçülme efekti
            .scaleEffect(isButtonAnimating ? 0.96 : (isNameValid ? 1.02 : 1.0))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isNameValid)
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    shimmerPhase = 1.0
                }
            }
        }

    private func saveAndProceed() {
        guard isNameValid else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            hasSeenOnboarding = true
        }
    }
}

