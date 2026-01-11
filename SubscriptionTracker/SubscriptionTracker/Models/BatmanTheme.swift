import SwiftUI

// Batman-inspired dark tech theme
extension Color {
    // Background colors
    static let batBlack = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let batDarkGray = Color(red: 0.12, green: 0.12, blue: 0.15)
    static let batMidGray = Color(red: 0.18, green: 0.18, blue: 0.22)

    // Accent colors
    static let batCyan = Color(red: 0.0, green: 0.8, blue: 0.9)
    static let batBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let batGreen = Color(red: 0.0, green: 0.9, blue: 0.6)
    static let batRed = Color(red: 0.9, green: 0.2, blue: 0.3)
    static let batYellow = Color(red: 1.0, green: 0.8, blue: 0.0)

    // Text colors
    static let batTextPrimary = Color(red: 0.95, green: 0.95, blue: 0.98)
    static let batTextSecondary = Color(red: 0.6, green: 0.6, blue: 0.65)
    static let batTextTertiary = Color(red: 0.4, green: 0.4, blue: 0.45)
}

// Custom view modifiers
struct BatCardModifier: ViewModifier {
    let glowing: Bool

    func body(content: Content) -> some View {
        content
            .background(Color.batDarkGray)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(
                        glowing ? Color.batCyan.opacity(0.5) : Color.batMidGray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .cornerRadius(2)
            .shadow(color: glowing ? Color.batCyan.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 0)
    }
}

struct BatGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

struct BatButtonModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .background(isSelected ? Color.batCyan.opacity(0.15) : Color.batMidGray)
            .foregroundColor(isSelected ? Color.batCyan : Color.batTextSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(isSelected ? Color.batCyan : Color.clear, lineWidth: 1)
            )
            .cornerRadius(2)
    }
}

struct BatTooltipModifier: ViewModifier {
    let text: String
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                isHovering = hovering
            }
            .overlay(
                Group {
                    if isHovering {
                        Text(text.uppercased())
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.batCyan)
                            .tracking(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.batBlack)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(Color.batCyan.opacity(0.5), lineWidth: 1)
                            )
                            .cornerRadius(2)
                            .shadow(color: Color.batCyan.opacity(0.4), radius: 4, x: 0, y: 0)
                            .offset(y: -28)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.15), value: isHovering)
                    }
                }
            )
    }
}

extension View {
    func batCard(glowing: Bool = false) -> some View {
        modifier(BatCardModifier(glowing: glowing))
    }

    func batGlow(color: Color = .batCyan, radius: CGFloat = 4) -> some View {
        modifier(BatGlowModifier(color: color, radius: radius))
    }

    func batButton(isSelected: Bool = false) -> some View {
        modifier(BatButtonModifier(isSelected: isSelected))
    }

    func batTooltip(_ text: String) -> some View {
        modifier(BatTooltipModifier(text: text))
    }
}

// Monospaced number formatter for that tech feel
extension Double {
    var batFormatted: String {
        String(format: "%.2f", self)
    }
}

extension Int {
    var batFormatted: String {
        String(format: "%02d", self)
    }
}
