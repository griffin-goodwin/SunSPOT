import SwiftUI

struct Theme {
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.05, green: 0.04, blue: 0.08),  // deep void
            Color(red: 0.12, green: 0.08, blue: 0.14),  // nebula dark
            Color(red: 0.20, green: 0.10, blue: 0.15),  // cosmic dust
            Color(red: 0.30, green: 0.12, blue: 0.08)   // subtle warmth
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Modern UI Colors
    static let surface = Color(white: 0.1, opacity: 0.8)
    static let surfaceSecondary = Color(white: 0.15, opacity: 0.6)
    
    static let cardBackground = Color.black.opacity(0.4)
    static let glassMaterial = Material.ultraThin
    
    static let accentColor = Color(red: 1.0, green: 0.6, blue: 0.2) // bright orange
    static let accentSecondary = Color(red: 0.4, green: 0.6, blue: 1.0) // cool blue
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let danger = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    // Title Gradients
    static let solarTitleGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.9, blue: 0.4),   // bright yellow
            Color(red: 1.0, green: 0.6, blue: 0.2),   // orange
            Color(red: 1.0, green: 0.35, blue: 0.15)  // solar red
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let activityTitleGradient = LinearGradient(
        colors: [
            Color(red: 0.3, green: 0.8, blue: 1.0),   // cyan
            Color(red: 0.5, green: 0.6, blue: 1.0),   // light blue
            Color(red: 0.7, green: 0.4, blue: 1.0)    // purple
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let settingsTitleGradient = LinearGradient(
        colors: [
            Color(red: 0.6, green: 0.7, blue: 0.8),   // silver
            Color(red: 0.8, green: 0.85, blue: 0.9),  // light silver
            Color(red: 0.5, green: 0.6, blue: 0.7)    // steel
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Tab bar accent
    static let tabAccent = Color(red: 1.0, green: 0.65, blue: 0.3)
    
    // Text colors for better readability
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let tertiaryText = Color.white.opacity(0.4)

    // Prefer JetBrains Mono if installed, otherwise fall back gracefully
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Attempt to use system monospaced design which often looks better than raw courier
        return Font.system(size: size, weight: weight, design: .monospaced)
    }
    
    // Helper for glass effect
    struct GlassCard: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(glassMaterial)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(Theme.GlassCard())
    }
}
