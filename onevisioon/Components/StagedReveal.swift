import SwiftUI

private struct StagedRevealModifier: ViewModifier {
    let isVisible: Bool
    let delay: Double
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offset)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.86).delay(delay),
                value: isVisible
            )
    }
}

extension View {
    func stagedReveal(_ isVisible: Bool, delay: Double = 0, offset: CGFloat = 16) -> some View {
        modifier(StagedRevealModifier(isVisible: isVisible, delay: delay, offset: offset))
    }
}

