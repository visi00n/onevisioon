import SwiftUI

struct GoogleAuthButton: View {
    let title: String
    var isLoading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)

                    Text("G")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "4285F4"))
                }

                Text(isLoading ? "Connecting..." : title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)

                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(height: 54)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 27, style: .continuous)
                    .stroke(OVTheme.line, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
