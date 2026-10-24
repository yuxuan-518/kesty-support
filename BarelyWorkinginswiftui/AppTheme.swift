import SwiftUI

// MARK: - App Theme
enum AppTheme {
    static let primary       = Color(red: 0.45, green: 0.35, blue: 0.70)
    static let bg            = Color(red: 0.94, green: 0.90, blue: 0.98)
    static let chip          = Color(red: 0.45, green: 0.35, blue: 0.70).opacity(0.10)
    static let textPrimary   = Color(red: 0.13, green: 0.11, blue: 0.20)
    static let textSecondary = Color(red: 0.50, green: 0.47, blue: 0.58)

    // Accent (button) color options
    static let themeColors: [ThemeColorOption] = [
        .init(name: "Purple", color: Color(red: 0.45, green: 0.35, blue: 0.70)),
        .init(name: "Blue",   color: Color(red: 0.20, green: 0.47, blue: 0.98)),
        .init(name: "Teal",   color: Color(red: 0.00, green: 0.60, blue: 0.62)),
        .init(name: "Green",  color: Color(red: 0.10, green: 0.70, blue: 0.35)),
        .init(name: "Orange", color: Color(red: 0.98, green: 0.62, blue: 0.20)),
        .init(name: "Red",    color: Color(red: 0.93, green: 0.30, blue: 0.36))
    ]

    // Background color options
    static let bgColors: [BgColorOption] = [
        .init(name: "Lavender", color: Color(red: 0.94, green: 0.90, blue: 0.98)),
        .init(name: "White",    color: Color(red: 0.98, green: 0.98, blue: 0.99)),
        .init(name: "Mint",     color: Color(red: 0.90, green: 0.97, blue: 0.95)),
        .init(name: "Peach",    color: Color(red: 0.99, green: 0.93, blue: 0.89)),
        .init(name: "Sky",      color: Color(red: 0.89, green: 0.94, blue: 0.99)),
        .init(name: "Lemon",    color: Color(red: 0.98, green: 0.97, blue: 0.88)),
        .init(name: "Rose",     color: Color(red: 0.99, green: 0.90, blue: 0.92)),
        .init(name: "Slate",    color: Color(red: 0.88, green: 0.90, blue: 0.94)),
    ]
}

struct ThemeColorOption: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct BgColorOption: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}
