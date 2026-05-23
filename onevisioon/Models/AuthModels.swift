import Foundation

enum AuthProvider: String, Codable, Hashable, CaseIterable, Identifiable {
    case apple
    case google

    var id: String { rawValue }

    var title: String {
        switch self {
        case .apple:
            return "Apple"
        case .google:
            return "Google"
        }
    }

    var subtitle: String {
        switch self {
        case .apple:
            return "Secure Apple sign-in"
        case .google:
            return "Secure Google sign-in"
        }
    }
}

struct AuthUserSession: Identifiable, Codable, Hashable {
    let provider: AuthProvider
    let providerUserID: String
    let supabaseUserID: String
    var displayName: String
    var email: String
    let createdAt: Date
    var lastSignInAt: Date
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiresAt: Date
    var tokenType: String

    var id: String {
        supabaseUserID
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

    var shouldRefreshSoon: Bool {
        accessTokenExpiresAt.timeIntervalSinceNow < 300
    }

    var isCloudBacked: Bool {
        !accessToken.trimmed.isEmpty
            && !refreshToken.trimmed.isEmpty
            && tokenType != "apple-local"
            && !supabaseUserID.hasPrefix("local.apple.")
    }
}

enum AuthBackendStatus: String, Codable, Hashable {
    case supabaseReady
    case configurationRequired

    var title: String {
        switch self {
        case .supabaseReady:
            return "Supabase Auth is live"
        case .configurationRequired:
            return "Cloud sync setup is required"
        }
    }

    var detail: String {
        switch self {
        case .supabaseReady:
            return "Apple and Google sign-in now connect to Supabase so One Visioon can secure accounts and sync progress."
        case .configurationRequired:
            return "Apple sign-in is available on this device. Add your Supabase project URL and anon key to enable Google sign-in and cloud sync."
        }
    }
}
