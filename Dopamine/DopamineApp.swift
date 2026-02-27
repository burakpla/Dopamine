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
        }
        .modelContainer(for: Habit.self)
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    // MARK: State
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.6
    @State private var contentOpacity: Double = 0.0
    @State private var logoRotation: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var blobs: [Blob] = []
    
    // MARK: Constants
    private enum Metrics {
        static let splashDuration: TimeInterval = 3.0
        static let logoSize: CGFloat = 160
        static let glowCircleSize: CGFloat = 200
        static let glowBlur: CGFloat = 50
        static let titleTracking: CGFloat = 10
        static let subtitleTracking: CGFloat = 3
        static let blobCount: Int = 15
        static let blobCornerRadius: CGFloat = 6
        static let blobMinSize: CGFloat = 20
        static let blobMaxSize: CGFloat = 45
        static let blobBlur: CGFloat = 10
        static let blobOpacity: Double = 0.6
        static let blobXRange: ClosedRange<CGFloat> = -180...180
        static let blobYRange: ClosedRange<CGFloat> = -250...250
        static let appearSpringResponse: Double = 0.9
        static let appearSpringDamping: Double = 0.5
        static let pulseDuration: Double = 1.5
        static let pulseMaxScale: CGFloat = 1.2
        static let transitionDuration: Double = 0.6
        static let titleFontSize: CGFloat = 32
    }
    
    // MARK: Appearance
    private let gradientColors: [Color] = [.orange, .pink, .purple]
    private let accentColors: [Color] = [.orange, .pink, .purple, .cyan, .yellow, .red]
    
    // MARK: View
    var body: some View {
        Group {
            if isActive {
                ContentView()
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    ForEach(blobs) { blob in
                        RoundedRectangle(cornerRadius: Metrics.blobCornerRadius)
                            .fill(blob.color)
                            .frame(width: blob.size.width, height: blob.size.height)
                            .blur(radius: Metrics.blobBlur)
                            .offset(x: contentOpacity == 1 ? blob.offset.x : 0,
                                    y: contentOpacity == 1 ? blob.offset.y : 0)
                            .opacity(contentOpacity == 1 ? Metrics.blobOpacity : 0)
                    }
                    
                    VStack(spacing: 35) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: Metrics.glowCircleSize, height: Metrics.glowCircleSize)
                                .blur(radius: Metrics.glowBlur)
                                .scaleEffect(pulseScale)
                                .opacity(0.4)
                            
                            Image("appLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: Metrics.logoSize, height: Metrics.logoSize)
                                .scaleEffect(logoScale)
                                .rotationEffect(.degrees(logoRotation))
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                                .accessibilityLabel("Dopamine Logo")
                        }
                        
                        VStack(spacing: 8) {
                            Text("DOPAMINE")
                                .font(.system(size: Metrics.titleFontSize, weight: .black, design: .rounded))
                                .tracking(Metrics.titleTracking)
                                .foregroundStyle(
                                    LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                                )
                            
                            Text("Harekete Geç")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .tracking(Metrics.subtitleTracking)
                        }
                        .opacity(contentOpacity)
                        .offset(y: contentOpacity == 1 ? 0 : 30)
                    }
                }
                .onAppear(perform: onAppear)
            }
        }
    }
}

// MARK: - Lifecycle & Helpers
private extension SplashScreenView {
    func onAppear() {
        if blobs.isEmpty {
            blobs = (0..<Metrics.blobCount).map { index in
                Blob(
                    id: index,
                    color: accentColors[index % accentColors.count],
                    size: .init(width: .random(in: Metrics.blobMinSize...Metrics.blobMaxSize),
                                height: .random(in: Metrics.blobMinSize...Metrics.blobMaxSize)),
                    offset: .init(
                        x: .random(in: Metrics.blobXRange),
                        y: .random(in: Metrics.blobYRange)
                    )
                )
            }
        }
        
        withAnimation(.spring(response: Metrics.appearSpringResponse, dampingFraction: Metrics.appearSpringDamping)) {
            logoScale = 1.0
            contentOpacity = 1.0
            logoRotation = 360
        }
        
        withAnimation(.easeInOut(duration: Metrics.pulseDuration).repeatForever(autoreverses: true)) {
            pulseScale = Metrics.pulseMaxScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.splashDuration) {
            NotificationHelper.requestNotificationPermissionAndScheduleDaily()
            withAnimation(.easeInOut(duration: Metrics.transitionDuration)) {
                isActive = true
            }
        }
    }
}

// MARK: - Models
private struct Blob: Identifiable {
    let id: Int
    let color: Color
    let size: CGSize
    let offset: CGPoint
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
