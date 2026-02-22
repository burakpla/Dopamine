//
//  OnboardingView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    // Persisted values
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // UI State
    @State private var nameInput: String = ""
    @FocusState private var nameFieldFocused: Bool

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
    }

    private var isNameValid: Bool {
        !nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var buttonBackground: Color {
        isNameValid ? .blue : .gray
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2), .clear],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack(spacing: Metrics.outerSpacing) {
                Spacer()

                Image(systemName: "bolt.ring.closed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                    .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                    .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text("Dopamine'e Hoş Geldin")
                        .font(.system(size: Metrics.titleFontSize, weight: .bold, design: .rounded))

                    Text("Sana nasıl hitap etmemizi istersin?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                TextField("Adın...", text: $nameInput)
                    .font(.title3)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(Metrics.fieldCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Metrics.fieldCornerRadius)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, Metrics.fieldHorizontalPadding)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($nameFieldFocused)
                    .onSubmit(saveAndProceed)
                    .accessibilityLabel("Adın")

                Spacer()

                Button(action: saveAndProceed) {
                    Text("Başlayalım")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.buttonHeight)
                        .background(buttonBackground)
                        .cornerRadius(Metrics.buttonCornerRadius)
                        .shadow(color: .blue.opacity(0.3), radius: Metrics.shadowRadius, y: 5)
                }
                .padding(.horizontal, Metrics.fieldHorizontalPadding)
                .padding(.bottom, Metrics.bottomPadding)
                .disabled(!isNameValid)
            }
        }
        .onAppear { nameFieldFocused = true }
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

