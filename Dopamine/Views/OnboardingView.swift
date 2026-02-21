//
//  OnboardingView.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


import SwiftUI

struct OnboardingView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var nameInput: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2), .clear],
                           startPoint: .topLeading, 
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Image(systemName: "bolt.ring.closed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.linearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 12) {
                    Text("Dopamine'e Hoş Geldin")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Text("Sana nasıl hitap etmemizi istersin?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                TextField("Adın...", text: $nameInput)
                    .font(.title3)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button {
                    if !nameInput.isEmpty {
                        withAnimation(.spring()) {
                            userName = nameInput
                            hasSeenOnboarding = true
                        }
                    }
                } label: {
                    Text("Başlayalım")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(nameInput.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .disabled(nameInput.isEmpty)
            }
        }
    }
}
