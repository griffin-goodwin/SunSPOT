import SwiftUI

struct Theme {
    // MARK: - Spacing System
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Background Gradients
    
    /// Main app background - deep navy with subtle teal/purple depth
    static let backgroundGradient = RadialGradient(
        gradient: Gradient(stops: [
            .init(color: Color(red: 0.04, green: 0.06, blue: 0.12), location: 0.0),   // inner glow
            .init(color: Color(red: 0.07, green: 0.11, blue: 0.22), location: 0.35),  // mid tone
            .init(color: Color(red: 0.03, green: 0.06, blue: 0.14), location: 0.7),   // deep navy
            .init(color: Color(red: 0.01, green: 0.02, blue: 0.06), location: 1.0)    // near-black
        ]),
        center: .center,
        startRadius: 40,
        endRadius: 900
    )

    /// Alternative: Angular/conic sweep with cool professional palette
    static let backgroundAngular = AngularGradient(
        gradient: Gradient(stops: [
            .init(color: Color(red: 0.02, green: 0.03, blue: 0.08), location: 0.0),
            .init(color: Color(red: 0.06, green: 0.09, blue: 0.18), location: 0.25),
            .init(color: Color(red: 0.10, green: 0.15, blue: 0.28), location: 0.5),
            .init(color: Color(red: 0.06, green: 0.09, blue: 0.18), location: 0.75),
            .init(color: Color(red: 0.02, green: 0.03, blue: 0.08), location: 1.0)
        ]),
        center: .center,
        angle: .degrees(-35)
    )

    /// Elliptical glow - soft cyan accent for subtle emphasis
    static let solarGlow = EllipticalGradient(
        gradient: Gradient(stops: [
            .init(color: Color(red: 0.40, green: 0.78, blue: 1.0).opacity(0.18), location: 0.0),
            .init(color: Color(red: 0.30, green: 0.60, blue: 0.95).opacity(0.10), location: 0.45),
            .init(color: Color.clear, location: 1.0)
        ]),
        center: .top,
        startRadiusFraction: 0.0,
        endRadiusFraction: 0.85
    )
    
    // MARK: - Surface Colors
    static let surface = Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.92)
    static let surfaceSecondary = Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.75)
    static let surfaceElevated = Color(red: 0.12, green: 0.14, blue: 0.20).opacity(0.95)
    
    static let cardBackground = Color(red: 0.06, green: 0.08, blue: 0.12).opacity(0.65)
    static let cardBackgroundElevated = Color(red: 0.10, green: 0.12, blue: 0.16).opacity(0.85)
    static let glassMaterial = Material.ultraThinMaterial
    
    // MARK: - Accent Colors
    static let accentColor = Color(red: 0.98, green: 0.78, blue: 0.36) // warm gold
    static let accentSecondary = Color(red: 0.42, green: 0.74, blue: 0.94) // soft cyan
    static let success = Color(red: 0.32, green: 0.78, blue: 0.54)
    static let warning = Color(red: 0.96, green: 0.72, blue: 0.32)
    static let danger = Color(red: 0.92, green: 0.42, blue: 0.46)
    
    // MARK: - Aurora Colors
    static let auroraGreen = Color(red: 0.3, green: 0.9, blue: 0.5)
    static let auroraLow = Color(red: 0.3, green: 0.7, blue: 0.4)
    static let auroraModerate = Color(red: 0.4, green: 0.85, blue: 0.5)
    static let auroraHigh = Color(red: 0.5, green: 0.9, blue: 0.6)
    static let auroraExtreme = Color(red: 0.7, green: 0.5, blue: 0.9)
    
    // MARK: - Title Gradients
    
    /// Solar title - elegant gold to white
    static let solarTitleGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.92, blue: 0.70),   // cream
            Color(red: 0.98, green: 0.82, blue: 0.48),  // gold
            Color(red: 0.96, green: 0.72, blue: 0.38)   // amber
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Activity title - professional cyan/blue
    static let activityTitleGradient = LinearGradient(
        colors: [
            Color(red: 0.58, green: 0.84, blue: 0.98),  // light cyan
            Color(red: 0.42, green: 0.72, blue: 0.94),  // sky blue
            Color(red: 0.32, green: 0.58, blue: 0.88)   // azure
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Settings title - clean silver
    static let settingsTitleGradient = LinearGradient(
        colors: [
            Color(red: 0.88, green: 0.90, blue: 0.94),  // bright silver
            Color(red: 0.72, green: 0.76, blue: 0.82),  // mid silver
            Color(red: 0.58, green: 0.64, blue: 0.72)   // steel
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Aurora title - green to cyan
    static let auroraTitleGradient = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.95, blue: 0.6),   // bright green
            Color(red: 0.3, green: 0.85, blue: 0.5),   // aurora green
            Color(red: 0.3, green: 0.75, blue: 0.6)    // teal
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Tab bar accent
    static let tabAccent = Color(red: 0.98, green: 0.78, blue: 0.36)
    
    // MARK: - Text Colors
    static let primaryText = Color(red: 0.96, green: 0.97, blue: 0.98)
    static let secondaryText = Color(red: 0.78, green: 0.82, blue: 0.88)
    static let tertiaryText = Color(red: 0.52, green: 0.58, blue: 0.68)
    static let quaternaryText = Color(red: 0.36, green: 0.42, blue: 0.52)
    
    // MARK: - Shadows
    static func glow(_ color: Color, radius: CGFloat = 12) -> some View {
        color.opacity(0.4).blur(radius: radius)
    }
    
    // MARK: - Typography
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.system(size: size, weight: weight, design: .monospaced)
    }
    
    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bouncy = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.65)
    }
    
    // MARK: - View Modifiers
    struct GlassCard: ViewModifier {
        var cornerRadius: CGFloat = Radius.lg
        
        func body(content: Content) -> some View {
            content
                .background(glassMaterial)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
    
    struct ElevatedCard: ViewModifier {
        var color: Color = .clear
        
        func body(content: Content) -> some View {
            content
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }
    
    struct PressableButton: ViewModifier {
        @State private var isPressed = false
        
        func body(content: Content) -> some View {
            content
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .opacity(isPressed ? 0.9 : 1.0)
                .animation(Animation.quick, value: isPressed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
        }
    }
}

// MARK: - View Extensions
extension View {
    func glassCard(cornerRadius: CGFloat = Theme.Radius.lg) -> some View {
        modifier(Theme.GlassCard(cornerRadius: cornerRadius))
    }
    
    func elevatedCard(accent: Color = .clear) -> some View {
        modifier(Theme.ElevatedCard(color: accent))
    }
    
    func pressable() -> some View {
        modifier(Theme.PressableButton())
    }
    
    func shimmer(_ isActive: Bool = true) -> some View {
        self.modifier(ShimmerEffect(isActive: isActive))
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: phase)
                    .mask(content)
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            phase = 400
                        }
                    }
                }
            }
    }
}

// MARK: - Tab Background Style
enum TabBackgroundStyle {
    case solar      // Warm gold/amber
    case activity   // Cool cyan/blue
    case settings   // Neutral silver/gray
    
    var colors: [Color] {
        switch self {
        case .solar:
            return [
                Color(red: 0.45, green: 0.28, blue: 0.12),  // warm amber
                Color(red: 0.55, green: 0.35, blue: 0.15),  // golden
                Color(red: 0.35, green: 0.22, blue: 0.10),  // bronze
                Color(red: 0.48, green: 0.30, blue: 0.14),  // warm mid
                Color(red: 0.30, green: 0.18, blue: 0.08),  // dark warm
                Color(red: 0.40, green: 0.25, blue: 0.12)   // gold accent
            ]
        case .activity:
            return [
                Color(red: 0.12, green: 0.28, blue: 0.48),  // deep blue
                Color(red: 0.15, green: 0.38, blue: 0.58),  // cyan
                Color(red: 0.10, green: 0.22, blue: 0.38),  // navy
                Color(red: 0.12, green: 0.32, blue: 0.50),  // steel blue
                Color(red: 0.08, green: 0.18, blue: 0.32),  // dark blue
                Color(red: 0.10, green: 0.26, blue: 0.42)   // teal
            ]
        case .settings:
            return [
                Color(red: 0.22, green: 0.22, blue: 0.26),  // neutral
                Color(red: 0.28, green: 0.28, blue: 0.32),  // gray
                Color(red: 0.18, green: 0.18, blue: 0.22),  // deep gray
                Color(red: 0.24, green: 0.24, blue: 0.28),  // mid gray
                Color(red: 0.14, green: 0.14, blue: 0.18),  // dark
                Color(red: 0.20, green: 0.20, blue: 0.24)   // accent gray
            ]
        }
    }
}

// MARK: - Mesh Gradient Background
/// A matted, grainy mesh-style gradient background
struct MeshGradientBackground: View {
    let style: TabBackgroundStyle
    
    var body: some View {
        ZStack {
            // Base color - slightly lighter for visibility
            Color(red: 0.06, green: 0.06, blue: 0.08)
            
            // Simulated mesh with overlapping radial gradients at grid points
            GeometryReader { geometry in
                let colors = style.colors
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    // Top-left point
                    RadialGradient(
                        colors: [colors[0], colors[0].opacity(0.5), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.8
                    )
                    
                    // Top-right point
                    RadialGradient(
                        colors: [colors[1], colors[1].opacity(0.4), Color.clear],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.75
                    )
                    
                    // Center point
                    RadialGradient(
                        colors: [colors[2], colors[2].opacity(0.35), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.6
                    )
                    
                    // Bottom-left point
                    RadialGradient(
                        colors: [colors[3], colors[3].opacity(0.45), Color.clear],
                        center: .bottomLeading,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.8
                    )
                    
                    // Bottom-right point
                    RadialGradient(
                        colors: [colors[4], colors[4].opacity(0.4), Color.clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.7
                    )
                    
                    // Mid-center accent
                    RadialGradient(
                        colors: [colors[5], colors[5].opacity(0.3), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.6),
                        startRadius: 0,
                        endRadius: max(width, height) * 0.5
                    )
                }
            }
            
            // Film grain overlay for texture
            GrainOverlay()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Grain Texture Overlay
struct GrainOverlay: View {
    var body: some View {
        Canvas { context, size in
            // Draw noise pattern
            for _ in 0..<Int(size.width * size.height * 0.015) {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.08)
                let radius = CGFloat.random(in: 0.5...1.5)
                
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                    with: .color(.white.opacity(opacity))
                )
            }
        }
        .blendMode(.overlay)
        .allowsHitTesting(false)
    }
}

// MARK: - Dynamic Color Background
/// A mesh-style gradient background that adapts to any accent color
struct DynamicColorBackground: View {
    let accentColor: Color
    
    // Derive color variations from the accent color
    private var colors: [Color] {
        [
            accentColor.opacity(0.45),           // Primary
            accentColor.opacity(0.35),           // Secondary
            accentColor.opacity(0.25),           // Tertiary
            accentColor.opacity(0.30),           // Mid
            accentColor.opacity(0.20),           // Dark
            accentColor.opacity(0.28)            // Accent
        ]
    }
    
    var body: some View {
        ZStack {
            // Base color
            Color(red: 0.04, green: 0.04, blue: 0.06)
            
            // Simulated mesh with overlapping radial gradients
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    // Top-left point
                    RadialGradient(
                        colors: [colors[0], colors[0].opacity(0.5), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.8
                    )
                    
                    // Top-right point
                    RadialGradient(
                        colors: [colors[1], colors[1].opacity(0.4), Color.clear],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.75
                    )
                    
                    // Center point - stronger presence
                    RadialGradient(
                        colors: [colors[2], colors[2].opacity(0.35), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.6
                    )
                    
                    // Bottom-left point
                    RadialGradient(
                        colors: [colors[3], colors[3].opacity(0.45), Color.clear],
                        center: .bottomLeading,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.8
                    )
                    
                    // Bottom-right point
                    RadialGradient(
                        colors: [colors[4], colors[4].opacity(0.4), Color.clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: max(width, height) * 0.7
                    )
                    
                    // Mid-center accent
                    RadialGradient(
                        colors: [colors[5], colors[5].opacity(0.3), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.6),
                        startRadius: 0,
                        endRadius: max(width, height) * 0.5
                    )
                }
            }
            
            // Film grain overlay for texture
            GrainOverlay()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Animated Tab Background (for smooth transitions)
struct AnimatedTabBackground: View {
    let selectedTab: Int
    
    private var currentStyle: TabBackgroundStyle {
        switch selectedTab {
        case 0: return .solar
        case 1: return .activity
        case 2: return .settings
        default: return .solar
        }
    }
    
    var body: some View {
        MeshGradientBackground(style: currentStyle)
            .animation(.easeInOut(duration: 0.5), value: selectedTab)
    }
}
