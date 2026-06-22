import Foundation

struct SupabaseProjectConfiguration: Hashable {
    let projectURL: URL
    let anonKey: String

    private static let resourceName = "SupabaseConfig"
    private static let placeholderProjectURL = "https://YOUR_PROJECT_REF.supabase.co"
    private static let placeholderAnonKey = "YOUR_SUPABASE_ANON_KEY"

    static func load() throws -> SupabaseProjectConfiguration {
        if let environmentConfiguration = try loadFromEnvironment() {
            return environmentConfiguration
        }

        guard let resourceURL = Bundle.main.url(forResource: resourceName, withExtension: "plist") else {
            throw SupabaseProjectConfigurationError.missingResource
        }

        let data = try Data(contentsOf: resourceURL)
        let rawConfiguration = try PropertyListDecoder().decode(RawSupabaseProjectConfiguration.self, from: data)
        return try makeConfiguration(projectURLString: rawConfiguration.projectURL, anonKey: rawConfiguration.anonKey)
    }

    static var setupMessage: String {
        "Add your Supabase project URL and anon key to Resources/SupabaseConfig.plist to enable secure cloud sign-in."
    }

    private static func loadFromEnvironment() throws -> SupabaseProjectConfiguration? {
        let environment = ProcessInfo.processInfo.environment
        let projectURL = environment["SUPABASE_URL"]?.trimmed ?? ""
        let anonKey = environment["SUPABASE_ANON_KEY"]?.trimmed ?? ""

        guard !projectURL.isEmpty || !anonKey.isEmpty else {
            return nil
        }

        return try makeConfiguration(projectURLString: projectURL, anonKey: anonKey)
    }

    private static func makeConfiguration(projectURLString: String, anonKey: String) throws -> SupabaseProjectConfiguration {
        let trimmedProjectURL = projectURLString.trimmed
        let trimmedAnonKey = anonKey.trimmed

        guard !trimmedProjectURL.isEmpty, !trimmedAnonKey.isEmpty else {
            throw SupabaseProjectConfigurationError.placeholderValues
        }

        guard trimmedProjectURL != placeholderProjectURL, trimmedAnonKey != placeholderAnonKey else {
            throw SupabaseProjectConfigurationError.placeholderValues
        }

        guard let projectURL = URL(string: trimmedProjectURL) else {
            throw SupabaseProjectConfigurationError.invalidProjectURL
        }

        return SupabaseProjectConfiguration(projectURL: projectURL, anonKey: trimmedAnonKey)
    }
}

private struct RawSupabaseProjectConfiguration: Decodable {
    let projectURL: String
    let anonKey: String
}

enum SupabaseProjectConfigurationError: LocalizedError {
    case missingResource
    case placeholderValues
    case invalidProjectURL

    var errorDescription: String? {
        switch self {
        case .missingResource:
            return "SupabaseConfig.plist is missing from the app bundle."
        case .placeholderValues:
            return SupabaseProjectConfiguration.setupMessage
        case .invalidProjectURL:
            return "The Supabase project URL in SupabaseConfig.plist is invalid."
        }
    }
}
