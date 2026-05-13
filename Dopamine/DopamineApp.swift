// MARK: - Imports
import SwiftUI
import SwiftData
import UserNotifications

// MARK: - App Entry
@main
struct DopamineApp: App {
    // MARK: Scene
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Habit.self)
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var isActive = false
    @State private var showContent = false
    
    // Background
    @State private var gradientAngle: Double = 0
    @State private var orbScale1: CGFloat = 0.5
    @State private var orbScale2: CGFloat = 0.5
    @State private var orbOffset1: CGSize = .zero
    @State private var orbOffset2: CGSize = .zero
    
    // Logo
    @State private var logoScale: CGFloat = 0.0
    @State private var logoOpacity: Double = 0
    @State private var logoY: CGFloat = 20
    @State private var glowIntensity: CGFloat = 0
    @State private var breatheScale: CGFloat = 1.0
    
    // Rings
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var ring2Scale: CGFloat = 0.3
    @State private var ring2Opacity: Double = 0
    @State private var ring3Scale: CGFloat = 0.2
    @State private var ring3Opacity: Double = 0
    @State private var ringRotation: Double = 0
    
    // Title
    @State private var titleReveal: CGFloat = 0
    @State private var titleOpacity: Double = 0
    @State private var shimmerX: CGFloat = -300
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleY: CGFloat = 15
    
    // Particles
    @State private var sparks: [Spark] = []
    
    // Exit
    @State private var exitScale: CGFloat = 1.0
    @State private var exitBlur: CGFloat = 0
    @State private var exitOpacity: Double = 1
    
    var body: some View {
        Group {
            if isActive {
                ContentView()
                    .transition(.opacity)
            } else {
                splashContent
                    .scaleEffect(exitScale)
                    .blur(radius: exitBlur)
                    .opacity(exitOpacity)
            }
        }
    }
    
    private var splashContent: some View {
        ZStack {
            // === BACKGROUND ===
            Color(hex: "0A0A16").ignoresSafeArea()
            
            // Rotating angular gradient
            AngularGradient(
                colors: [
                    Color(hex: "0F0F1E"),
                    Color(hex: "1A0A2E").opacity(0.8),
                    Color(hex: "0D1B2A"),
                    Color(hex: "0F0F1E"),
                    Color(hex: "1A0535").opacity(0.6),
                    Color(hex: "0F0F1E")
                ],
                center: .center,
                angle: .degrees(gradientAngle)
            )
            .ignoresSafeArea()
            .opacity(0.8)
            
            // Morphing orbs
            Ellipse()
                .fill(
                    RadialGradient(colors: [.purple.opacity(0.25), .clear], center: .center, startRadius: 10, endRadius: 180)
                )
                .frame(width: 360, height: 300)
                .scaleEffect(orbScale1)
                .offset(orbOffset1)
                .blur(radius: 60)
            
            Ellipse()
                .fill(
                    RadialGradient(colors: [.orange.opacity(0.2), .pink.opacity(0.1), .clear], center: .center, startRadius: 10, endRadius: 160)
                )
                .frame(width: 300, height: 350)
                .scaleEffect(orbScale2)
                .offset(orbOffset2)
                .blur(radius: 50)
            
            // === SPARKS ===
            ForEach(sparks) { spark in
                Circle()
                    .fill(spark.color)
                    .frame(width: spark.size, height: spark.size)
                    .blur(radius: spark.size > 3 ? 1.5 : 0)
                    .offset(x: spark.x, y: spark.y)
                    .opacity(spark.opacity)
            }
            
            // === CENTER CONTENT ===
            VStack(spacing: 35) {
                ZStack {
                    // Outer breathing ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.orange.opacity(0.5), .pink.opacity(0.3), .purple.opacity(0.5), .orange.opacity(0.5)],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .rotationEffect(.degrees(ringRotation))
                    
                    // Mid ring
                    Circle()
                        .stroke(
                            LinearGradient(colors: [.pink.opacity(0.4), .purple.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1.2
                        )
                        .frame(width: 170, height: 170)
                        .scaleEffect(ring2Scale)
                        .opacity(ring2Opacity)
                        .rotationEffect(.degrees(-ringRotation * 0.7))
                    
                    // Inner ring
                    Circle()
                        .stroke(
                            .white.opacity(0.15),
                            style: StrokeStyle(lineWidth: 0.8, dash: [4, 6])
                        )
                        .frame(width: 155, height: 155)
                        .scaleEffect(ring3Scale)
                        .opacity(ring3Opacity)
                        .rotationEffect(.degrees(ringRotation * 0.4))
                    
                    // Neon glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orange.opacity(0.35), .pink.opacity(0.15), .clear],
                                center: .center,
                                startRadius: 15,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(breatheScale)
                        .opacity(glowIntensity)
                    
                    // Logo
                    Image("appLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(y: logoY)
                        .shadow(color: .orange.opacity(0.4), radius: 25, x: 0, y: 8)
                        .shadow(color: .pink.opacity(0.2), radius: 40, x: 0, y: 15)
                }
                
                // Title area
                VStack(spacing: 12) {
                    ZStack {
                        // Base gradient text
                        Text("DOPAMINE")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .tracking(14)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Shimmer sweep
                        Text("DOPAMINE")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .tracking(14)
                            .foregroundStyle(.white.opacity(0.4))
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.clear, .white, .clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 60)
                                    .offset(x: shimmerX)
                            )
                    }
                    .opacity(titleOpacity)
                    .mask(
                        Rectangle()
                            .frame(width: titleReveal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )
                    
                    // Subtitle with line accents
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .orange.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 30, height: 1)
                        
                        Text("Harekete Geç")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.45))
                            .tracking(5)
                        
                        Rectangle()
                            .fill(LinearGradient(colors: [.orange.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 30, height: 1)
                    }
                    .opacity(subtitleOpacity)
                    .offset(y: subtitleY)
                }
            }
        }
        .onAppear(perform: runSequence)
    }
}

// MARK: - Animation Sequence
private extension SplashScreenView {
    func runSequence() {
        // BG rotation - slow ambient
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            gradientAngle = 360
        }
        
        // Orbs morph in
        withAnimation(.easeOut(duration: 2.0)) {
            orbScale1 = 1.0
            orbScale2 = 1.0
        }
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            orbOffset1 = CGSize(width: 40, height: -30)
            orbOffset2 = CGSize(width: -30, height: 40)
        }
        
        // Rings expand with stagger
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2)) {
            ringScale = 1.0
            ringOpacity = 0.7
        }
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.35)) {
            ring2Scale = 1.0
            ring2Opacity = 0.5
        }
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5)) {
            ring3Scale = 1.0
            ring3Opacity = 0.4
        }
        
        // Ring rotation
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Logo entrance - bounce in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.4)) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoY = 0
        }
        
        // Glow pulse
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            glowIntensity = 0.8
        }
        withAnimation(.easeInOut(duration: 2.0).delay(1.0).repeatForever(autoreverses: true)) {
            breatheScale = 1.12
            glowIntensity = 0.5
        }
        
        // Title wipe reveal
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            titleOpacity = 1.0
            titleReveal = 500
        }
        
        // Shimmer sweep loop
        withAnimation(.easeInOut(duration: 2.0).delay(1.5).repeatForever(autoreverses: false)) {
            shimmerX = 300
        }
        
        // Subtitle
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.3)) {
            subtitleOpacity = 1.0
            subtitleY = 0
        }
        
        // Sparks
        spawnSparks()
        
        // Fade rings to subtle
        withAnimation(.easeOut(duration: 1.5).delay(1.8)) {
            ringOpacity = 0.3
            ring2Opacity = 0.2
            ring3Opacity = 0.15
        }
        
        // Exit transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            NotificationHelper.requestNotificationPermissionAndScheduleDaily()
            withAnimation(.easeIn(duration: 0.4)) {
                exitScale = 1.08
                exitBlur = 12
                exitOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                isActive = true
            }
        }
    }
    
    func spawnSparks() {
        let colors: [Color] = [.orange, .pink, .purple, .cyan, .yellow, .white]
        let w = UIScreen.main.bounds.width / 2
        let h = UIScreen.main.bounds.height / 2
        
        for i in 0..<30 {
            let angle = Double.random(in: 0...(2 * .pi))
            let radius = CGFloat.random(in: 80...max(w, h))
            let spark = Spark(
                id: i,
                x: cos(angle) * radius,
                y: sin(angle) * radius,
                size: CGFloat.random(in: 1.5...5),
                color: colors.randomElement()!.opacity(Double.random(in: 0.3...0.8)),
                opacity: 0
            )
            sparks.append(spark)
            
            let delay = Double.random(in: 0.3...1.8)
            withAnimation(.easeOut(duration: Double.random(in: 0.8...1.5)).delay(delay)) {
                sparks[i].opacity = Double.random(in: 0.3...0.9)
            }
            // Twinkle
            withAnimation(.easeInOut(duration: Double.random(in: 1.0...2.5)).delay(delay + 1.0).repeatForever(autoreverses: true)) {
                sparks[i].opacity = Double.random(in: 0.1...0.4)
            }
        }
    }
}

// MARK: - Spark Model
private struct Spark: Identifiable {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
}

// MARK: - Notifications
private enum NotificationHelper {
    static func requestNotificationPermissionAndScheduleDaily() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            guard success else { return }
            scheduleDailyReminder()
        }
    }
    
    private static func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "DOPAMINE ⚡️"
        content.body = "Günü bitirmeden son bir kontrol yapalım mı? Halkan ne durumda? 🌈"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
