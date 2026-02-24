//
//  OnboardingView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    // Persisted values
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // UI State
    @State private var nameInput: String = ""
    @FocusState private var nameFieldFocused: Bool
    @State private var shimmerPhase: CGFloat = -1.0
    @State private var isPressingButton: Bool = false
    @State private var bgPulse: CGFloat = 0.0

    // Constants
    private enum Metrics {
        static let iconSize: CGFloat = 100
        static let titleFontSize: CGFloat = 32
        static let fieldCornerRadius: CGFloat = 15
        static let fieldHorizontalPadding: CGFloat = 40
        static let buttonHeight: CGFloat = 60
        static let buttonCornerRadius: CGFloat = 20
        static let outerSpacing: CGFloat = 40
        static let bottomPadding: CGFloat = 30
        static let shadowRadius: CGFloat = 10
        static let subtitleLineSpacing: CGFloat = 2
        static let buttonGradientCorner: CGFloat = 22
    }

    private var isNameValid: Bool {
        !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var buttonBackground: Color {
        isNameValid ? Color("AccentColor") : Color.gray.opacity(0.5)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AccentColor").opacity(0.45),
                    Color.purple.opacity(0.35),
                    Color.blue.opacity(0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    // Animated radial glow
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.22 + 0.08 * Double(bgPulse)),
                            Color.clear
                        ],
                        center: .top,
                        startRadius: 10 + 6 * bgPulse,
                        endRadius: 420 + 30 * bgPulse
                    )
                    .blendMode(.screen)

                    // Subtle moving linear tint
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.10 + 0.05 * Double(bgPulse)),
                            Color.blue.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(0.7)
                    .offset(x: bgPulse * 8, y: bgPulse * -6)
                    .blendMode(.plusLighter)
                }
                .ignoresSafeArea()
            )

            VStack(spacing: Metrics.outerSpacing) {
                Spacer()

                Image("appLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                    .shadow(color: .purple.opacity(0.2), radius: 20, x: 0, y: 10)
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("Dopamine'e Hoş Geldin")
                        .font(.system(size: Metrics.titleFontSize, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                    Text("Sana nasıl hitap etmemizi istersin?")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineSpacing(Metrics.subtitleLineSpacing)
                }
                .multilineTextAlignment(.center)

                TextField("Adın...", text: $nameInput)
                    .font(.title3)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(.ultraThinMaterial)
                    .cornerRadius(Metrics.fieldCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Metrics.fieldCornerRadius)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .overlay(alignment: .trailing) {
                        HStack(spacing: 8) {
                            if isNameValid {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            if !nameInput.isEmpty {
                                Button {
                                    nameInput = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, 12)
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .contentShape(RoundedRectangle(cornerRadius: Metrics.fieldCornerRadius))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, Metrics.fieldHorizontalPadding)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($nameFieldFocused)
                    .onSubmit(saveAndProceed)
                    .accessibilityLabel("Adın")

                Spacer()

                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    saveAndProceed()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Metrics.buttonGradientCorner, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: isNameValid
                                    ? [Color("AccentColor"), Color.purple.opacity(0.85)]
                                    : [Color("AccentColor").opacity(0.8), Color("AccentColor").opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Metrics.buttonGradientCorner, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: Color("AccentColor").opacity(0.35), radius: Metrics.shadowRadius, y: 6)
                            .overlay(
                                Group {
                                    if isNameValid {
                                        RoundedRectangle(cornerRadius: Metrics.buttonGradientCorner, style: .continuous)
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
                                            .blur(radius: 1.5)
                                            .blendMode(.screen)
                                            .opacity(0.9)
                                            .padding(-0.5)
                                    }
                                }
                            )
                            .shadow(color: isNameValid ? Color("AccentColor").opacity(0.55) : Color("AccentColor").opacity(0.25), radius: isNameValid ? 18 : 8, y: isNameValid ? 10 : 6)

                        Text("Başlayalım")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal)

                        // Shimmer overlay
                        RoundedRectangle(cornerRadius: Metrics.buttonGradientCorner, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.0), Color.white.opacity(0.35), Color.white.opacity(0.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(15))
                            .offset(x: shimmerPhase * 240, y: 0)
                            .blendMode(.screen)
                            .opacity(isNameValid ? 1.0 : 0.25)
                            .blur(radius: isNameValid ? 0 : 0.5)
                            .allowsHitTesting(false)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: Metrics.buttonHeight)
                    .opacity(isNameValid ? 1 : 0.6)
                    .scaleEffect(isNameValid ? 1.03 : 0.98)
                    .scaleEffect(isPressingButton ? 0.98 : 1.0)
                    .brightness(isNameValid ? 0.04 : 0.0)
                    .saturation(isNameValid ? 1.12 : 1.0)
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isNameValid)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if isNameValid { isPressingButton = true }
                        }
                        .onEnded { _ in
                            isPressingButton = false
                        }
                )
                .padding(.horizontal, Metrics.fieldHorizontalPadding)
                .padding(.bottom, Metrics.bottomPadding)
                .disabled(!isNameValid)
            }
        }
        .onAppear {
            nameFieldFocused = true
            withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.0
            }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                bgPulse = 1.0
            }
        }
    }
}
// MARK: - Actions
private extension OnboardingView {
    func saveAndProceed() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation(.spring()) {
            userName = trimmed
            hasSeenOnboarding = true
        }
    }
}

