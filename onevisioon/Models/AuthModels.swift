import Foundation

enum AuthProvider: String, Codable, Hashable, CaseIterable, Identifiable {
    case apple

    var id: String { rawValue }

    var title: String {
        "Apple"
    }

    var subtitle: String {
        "Secure device sign-in"
    }
}

struct AuthUserSession: Identifiable, Codable, Hashable {
    let provider: AuthProvider
    let providerUserID: String
    var displayName: String
    var email: String
    let createdAt: Date
    var lastSignInAt: Date

    var id: String {
        "\(provider.rawValue):\(providerUserID)"
    }

    var providerTitle: String {
        provider.title
    }

    var displayTitle: String {
        if !displayName.trimmed.isEmpty {
            return displayName.trimmed
        }

        if !email.trimmed.isEmpty {
            return email.trimmed
        }

        return "One Visioon user"
    }
}

enum AuthBackendStatus: String, Codable, Hashable {
    case localAppleReady

    var title: String {
        "Apple sign-in is live on-device"
    }

    var detail: String {
        "You can sign in with Apple now, and the app will remember that account on this device."
    }
}
