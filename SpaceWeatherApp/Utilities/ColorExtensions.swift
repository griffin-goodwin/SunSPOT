import SwiftUI

// MARK: - Cross-Platform Color Support

extension Color {
    /// Background color for grouped content (works on both iOS and macOS)
    static var groupedBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemGroupedBackground)
        #else
        return Color(nsColor: .windowBackgroundColor)
        #endif
    }
    
    /// Secondary background color for grouped content
    static var secondaryGroupedBackground: Color {
        #if os(iOS)
        return Color(uiColor: .secondarySystemGroupedBackground)
        #else
        return Color(nsColor: .controlBackgroundColor)
        #endif
    }
}
