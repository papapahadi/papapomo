import SwiftUI

enum LuxuryTheme {
    static let background = LinearGradient(
        colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let card = Color.white.opacity(0.08)
    static let border = Color.white.opacity(0.16)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
}

struct LuxuryCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LuxuryTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LuxuryTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func luxuryCard() -> some View {
        modifier(LuxuryCardModifier())
    }
}
