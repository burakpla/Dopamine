//
//  OnboardingView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

// MARK: - Imports
import SwiftUI
import UIKit

struct OnboardingView: View {
    // MARK: - Onboarding View

    // MARK: State
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    @State private var vm = OnboardingViewModel()

    @State private var nameInput: String = ""
    @FocusState private var nameFieldFocused: Bool

    @State private var shimmerPhase: CGFloat = -1.0
    @State private var bgRotation: Double = 0.0

    @State private var contentOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 20

    // Ring
    @State private var ringProgress: CGFloat = 0.0
    @State private var ringRotation: Double = 0.0

    // MARK: Metrics
    private enum Metrics {
        static let iconSize: CGFloat = 110
        static let fieldCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 64
        static let horizontalPadding: CGFloat = 36
        static let ringSize: CGFloat = 160
        static let ringLineWidth: CGFloat = 10
    }

    // MARK: Validation
    private var isNameValid: Bool {
        nameInput.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    // MARK: Body
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // MARK: Logo + Completed Ring
                ZStack {
                    // Soft glow behind
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: Metrics.ringSize, height: Metrics.ringSize)
                        .blur(radius: 18)

                    // Track ring
                    Circle()
                        .stroke(.white.opacity(0.12), lineWidth: Metrics.ringLineWidth)
                        .frame(width: Metrics.ringSize, height: Metrics.ringSize)

                    // Completed ring
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "8E2DE2"),
                                    Color(hex: "4A00E0"),
                                    Color(hex: "00D2FF"),
                                    Color(hex: "8E2DE2")
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: Metrics.ringLineWidth, lineCap: .round)
                        )
                        .frame(width: Metrics.ringSize, height: Metrics.ringSize)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color(hex: "8E2DE2").opacity(0.45), radius: 12, x: 0, y: 6)

                    // Optional sparkle arc (shows when completed)
                    Circle()
                        .trim(from: 0.0, to: 0.18)
                        .stroke(.white.opacity(0.25), style: StrokeStyle(lineWidth: Metrics.ringLineWidth, lineCap: .round))
                        .frame(width: Metrics.ringSize, height: Metrics.ringSize)
                        .rotationEffect(.degrees(ringRotation - 90))
                        .opacity(ringProgress > 0.95 ? 1 : 0)

                    // Icon
                    Image(systemName: "bolt.ring.closed")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                }
                .scaleEffect(contentOpacity)

                // MARK: Titles
                VStack(spacing: 12) {
                    Text("Dopamine")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Sana nasıl hitap edelim?")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .multilineTextAlignment(.center)

                textFieldSection

                Spacer()

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

            // Ring draw to "completed"
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                ringProgress = 1.0
            }

            // Sparkle rotation
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }

            nameFieldFocused = true
        }
    }

    // MARK: Subviews - Background
    private var backgroundGradient: some View {
        ZStack {
            Color(hex: "0F0F1E")

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

    // MARK: Subviews - Text Field
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

    // MARK: Subviews - Action Button
    private var actionButton: some View {
        Button(action: saveAndProceed) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        isNameValid ?
                        LinearGradient(
                            colors: [Color(hex: "8E2DE2"), Color(hex: "4A00E0")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(
                        color: isNameValid ? Color(hex: "8E2DE2").opacity(0.5) : Color.clear,
                        radius: 15,
                        x: 0,
                        y: 8
                    )

                if isNameValid {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }

                Text("Başlayalım")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(isNameValid ? .white : .white.opacity(0.3))

                if isNameValid {
                    GeometryReader { geo in
                        Color.white.opacity(0.2)
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white.opacity(0.8), .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
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
        .scaleEffect(isNameValid ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isNameValid)
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.0
            }
        }
    }

    // MARK: Actions
    private func saveAndProceed() {
        guard isNameValid else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        withAnimation(.easeInOut(duration: 0.5)) {
            userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            hasSeenOnboarding = true
        }
    }
}

