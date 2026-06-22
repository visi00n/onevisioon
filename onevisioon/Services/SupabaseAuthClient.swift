import Foundation

@MainActor
final class SupabaseAuthClient {
    private let configuration: SupabaseProjectConfiguration
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(configuration: SupabaseProjectConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    func signInWithApple(idToken: String, rawNonce: String) async throws -> SupabaseAuthSessionPayload {
        try await performTokenRequest(
            grantType: "id_token",
            payload: AppleIDTokenGrantRequest(
                provider: "apple",
                idToken: idToken,
                nonce: rawNonce
            )
        )
    }

    func refreshSession(refreshToken: String) async throws -> SupabaseAuthSessionPayload {
        try await performTokenRequest(
            grantType: "refresh_token",
            payload: RefreshTokenGrantRequest(refreshToken: refreshToken)
        )
    }

    func fetchUser(accessToken: String) async throws -> SupabaseRemoteUser {
        let request = try makeAuthRequest(path: "user", method: "GET", bearerToken: accessToken)
        return try await perform(request, decode: SupabaseRemoteUser.self)
    }

    func updateUserMetadata(accessToken: String, metadata: [String: String]) async throws -> SupabaseRemoteUser {
        var request = try makeAuthRequest(path: "user", method: "PUT", bearerToken: accessToken)
        request.httpBody = try encoder.encode(UpdateUserRequest(data: metadata))
        return try await perform(request, decode: SupabaseRemoteUser.self)
    }

    func signOut(accessToken: String) async throws {
        let request = try makeAuthRequest(path: "logout", method: "POST", bearerToken: accessToken)
        _ = try await performWithoutResponseBody(request)
    }

    func fetchProfile(userID: String, accessToken: String) async throws -> SupabaseAppProfile? {
        let request = try makeDatabaseRequest(
            path: "profiles",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(userID)"),
                URLQueryItem(name: "select", value: "id,email,display_name,handle,bio,instagram,x_handle,youtube,country,usa_area_code,small_group_key,is_public,selected_version"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )

        return try await perform(request, decode: [SupabaseAppProfile].self).first
    }

    func upsertProfile(accessToken: String, payload: SupabaseProfileUpsertPayload) async throws -> SupabaseAppProfile {
        var request = try makeDatabaseRequest(
            path: "profiles",
            method: "POST",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "on_conflict", value: "id"),
                URLQueryItem(name: "select", value: "id,email,display_name,handle,bio,instagram,x_handle,youtube,country,usa_area_code,small_group_key,is_public,selected_version")
            ]
        )

        request.setValue("resolution=merge-duplicates,return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode([payload])

        guard let profile = try await perform(request, decode: [SupabaseAppProfile].self).first else {
            throw SupabaseAuthError.invalidResponse
        }

        return profile
    }

    func fetchUserSyncSnapshot(userID: String, accessToken: String) async throws -> SupabaseUserSyncSnapshotRecord? {
        let request = try makeDatabaseRequest(
            path: "user_sync_snapshots",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "user_id", value: "eq.\(userID)"),
                URLQueryItem(name: "select", value: "user_id,schema_version,snapshot"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )

        return try await perform(request, decode: [SupabaseUserSyncSnapshotRecord].self).first
    }

    func upsertUserSyncSnapshot(accessToken: String, payload: SupabaseUserSyncSnapshotUpsertPayload) async throws -> SupabaseUserSyncSnapshotRecord {
        var request = try makeDatabaseRequest(
            path: "user_sync_snapshots",
            method: "POST",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "on_conflict", value: "user_id"),
                URLQueryItem(name: "select", value: "user_id,schema_version,snapshot")
            ]
        )

        request.setValue("resolution=merge-duplicates,return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode([payload])

        guard let snapshotRecord = try await perform(request, decode: [SupabaseUserSyncSnapshotRecord].self).first else {
            throw SupabaseAuthError.invalidResponse
        }

        return snapshotRecord
    }

    func makeOAuthAuthorizeURL(
        provider: String,
        redirectTo: URL,
        queryParams: [String: String] = [:]
    ) throws -> URL {
        var components = URLComponents(
            url: configuration.projectURL.appendingPathComponent("auth/v1/authorize"),
            resolvingAgainstBaseURL: false
        )

        var items = [
            URLQueryItem(name: "provider", value: provider),
            URLQueryItem(name: "redirect_to", value: redirectTo.absoluteString)
        ]

        items.append(
            contentsOf: queryParams
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        )

        components?.queryItems = items

        guard let url = components?.url else {
            throw SupabaseAuthError.invalidURL
        }

        return url
    }

    func sessionTokens(fromOAuthCallback callbackURL: URL) throws -> SupabaseOAuthSessionTokens {
        let parameters = oauthParameters(from: callbackURL)

        if let errorDescription = parameters["error_description"]?.trimmed, !errorDescription.isEmpty {
            throw SupabaseAuthError.server(errorDescription)
        }

        if let error = parameters["error"]?.trimmed, !error.isEmpty {
            throw SupabaseAuthError.server(error)
        }

        guard let accessToken = parameters["access_token"]?.trimmed, !accessToken.isEmpty else {
            throw SupabaseAuthError.invalidResponse
        }

        guard let refreshToken = parameters["refresh_token"]?.trimmed, !refreshToken.isEmpty else {
            throw SupabaseAuthError.invalidResponse
        }

        let expiresIn = Int(parameters["expires_in"] ?? "") ?? 3600
        let expiresAtEpoch = TimeInterval(parameters["expires_at"] ?? "")
        let tokenType = parameters["token_type"]?.trimmed.isEmpty == false
            ? parameters["token_type"]!.trimmed
            : "bearer"

        return SupabaseOAuthSessionTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            expiresAtEpoch: expiresAtEpoch,
            tokenType: tokenType
        )
    }

    private func performTokenRequest<Payload: Encodable>(grantType: String, payload: Payload) async throws -> SupabaseAuthSessionPayload {
        var components = URLComponents(url: configuration.projectURL.appendingPathComponent("auth/v1/token"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "grant_type", value: grantType)]

        guard let url = components?.url else {
            throw SupabaseAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(configuration.anonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(payload)

        return try await perform(request, decode: SupabaseAuthSessionPayload.self)
    }

    private func makeAuthRequest(path: String, method: String, bearerToken: String) throws -> URLRequest {
        let url = configuration.projectURL.appendingPathComponent("auth/v1/\(path)")
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func makeDatabaseRequest(
        path: String,
        method: String,
        bearerToken: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        var components = URLComponents(
            url: configuration.projectURL.appendingPathComponent("rest/v1/\(path)"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw SupabaseAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func perform<Response: Decodable>(_ request: URLRequest, decode type: Response.Type) async throws -> Response {
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        return try decoder.decode(Response.self, from: data)
    }

    private func performWithoutResponseBody(_ request: URLRequest) async throws -> HTTPURLResponse {
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseAuthError.invalidResponse
        }

        return httpResponse
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseAuthError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let message = (try? decoder.decode(SupabaseAuthErrorEnvelope.self, from: data).bestMessage)
                ?? "Supabase Auth request failed with code \(httpResponse.statusCode)."

            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw SupabaseAuthError.unauthorized(message)
            }

            throw SupabaseAuthError.server(message)
        }
    }

    private func oauthParameters(from callbackURL: URL) -> [String: String] {
        var values: [String: String] = [:]

        if let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { item in
                values[item.name] = item.value ?? ""
            }

            if let fragment = components.fragment {
                fragment
                    .split(separator: "&")
                    .forEach { pair in
                        let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                        guard let key = parts.first?.removingPercentEncoding, !key.isEmpty else { return }
                        let value = parts.count > 1 ? (parts[1].removingPercentEncoding ?? parts[1]) : ""
                        values[key] = value
                    }
            }
        }

        return values
    }
}

struct SupabaseAuthSessionPayload: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let expiresAtEpoch: TimeInterval?
    let tokenType: String
    let user: SupabaseRemoteUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case expiresAtEpoch = "expires_at"
        case tokenType = "token_type"
        case user
    }

    var accessTokenExpiresAt: Date {
        if let expiresAtEpoch {
            return Date(timeIntervalSince1970: expiresAtEpoch)
        }

        return Date().addingTimeInterval(TimeInterval(expiresIn))
    }
}

struct SupabaseOAuthSessionTokens {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let expiresAtEpoch: TimeInterval?
    let tokenType: String

    var accessTokenExpiresAt: Date {
        if let expiresAtEpoch {
            return Date(timeIntervalSince1970: expiresAtEpoch)
        }

        return Date().addingTimeInterval(TimeInterval(expiresIn))
    }
}

struct SupabaseRemoteUser: Decodable {
    let id: String
    let email: String?
    let userMetadata: [String: SupabaseJSONValue]?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case userMetadata = "user_metadata"
    }

    var bestDisplayName: String {
        if let fullName = metadataString(for: "full_name"), !fullName.isEmpty {
            return fullName
        }

        let givenName = metadataString(for: "given_name")
        let familyName = metadataString(for: "family_name")
        let combinedName = [givenName, familyName]
            .compactMap { $0?.trimmed }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if !combinedName.isEmpty {
            return combinedName
        }

        if let email, !email.trimmed.isEmpty {
            return email.trimmed
        }

        return ""
    }

    func metadataString(for key: String) -> String? {
        userMetadata?[key]?.stringValue?.trimmed
    }
}

struct SupabaseAppProfile: Decodable {
    let id: String
    let email: String?
    let displayName: String?
    let handle: String?
    let bio: String?
    let instagram: String?
    let xHandle: String?
    let youtube: String?
    let country: String?
    let usaAreaCode: String?
    let smallGroupKey: String?
    let isPublic: Bool
    let selectedVersion: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case handle
        case bio
        case instagram
        case xHandle = "x_handle"
        case youtube
        case country
        case usaAreaCode = "usa_area_code"
        case smallGroupKey = "small_group_key"
        case isPublic = "is_public"
        case selectedVersion = "selected_version"
    }
}

struct SupabaseProfileUpsertPayload: Encodable {
    let id: String
    let email: String?
    let displayName: String?
    let handle: String?
    let bio: String?
    let instagram: String?
    let xHandle: String?
    let youtube: String?
    let country: String?
    let usaAreaCode: String?
    let smallGroupKey: String?
    let avatarURL: String?
    let isPublic: Bool
    let selectedVersion: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case handle
        case bio
        case instagram
        case xHandle = "x_handle"
        case youtube
        case country
        case usaAreaCode = "usa_area_code"
        case smallGroupKey = "small_group_key"
        case avatarURL = "avatar_url"
        case isPublic = "is_public"
        case selectedVersion = "selected_version"
    }
}

struct SupabaseUserSyncSnapshotRecord: Decodable {
    let userID: String
    let schemaVersion: Int
    let snapshot: UserProgressSyncSnapshot

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case schemaVersion = "schema_version"
        case snapshot
    }
}

struct SupabaseUserSyncSnapshotUpsertPayload: Encodable {
    let userID: String
    let schemaVersion: Int
    let snapshot: UserProgressSyncSnapshot

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case schemaVersion = "schema_version"
        case snapshot
    }
}

enum SupabaseJSONValue: Decodable, Hashable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case object([String: SupabaseJSONValue])
    case array([SupabaseJSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .boolean(boolValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .number(doubleValue)
        } else if let objectValue = try? container.decode([String: SupabaseJSONValue].self) {
            self = .object(objectValue)
        } else if let arrayValue = try? container.decode([SupabaseJSONValue].self) {
            self = .array(arrayValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value.")
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return String(value)
        case .boolean(let value):
            return value ? "true" : "false"
        case .object, .array, .null:
            return nil
        }
    }
}

private struct AppleIDTokenGrantRequest: Encodable {
    let provider: String
    let idToken: String
    let nonce: String

    enum CodingKeys: String, CodingKey {
        case provider
        case idToken = "id_token"
        case nonce
    }
}

private struct RefreshTokenGrantRequest: Encodable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

private struct UpdateUserRequest: Encodable {
    let data: [String: String]
}

private struct SupabaseAuthErrorEnvelope: Decodable {
    let message: String?
    let msg: String?
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case message
        case msg
        case error
        case errorDescription = "error_description"
    }

    var bestMessage: String {
        if let message, !message.trimmed.isEmpty {
            return message.trimmed
        }

        if let msg, !msg.trimmed.isEmpty {
            return msg.trimmed
        }

        if let errorDescription, !errorDescription.trimmed.isEmpty {
            return errorDescription.trimmed
        }

        if let error, !error.trimmed.isEmpty {
            return error.trimmed
        }

        return "Supabase Auth request failed."
    }
}

enum SupabaseAuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case identityTokenMissing
    case requestStateMismatch
    case unauthorized(String)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Supabase project URL is invalid."
        case .invalidResponse:
            return "Supabase returned an unreadable response."
        case .identityTokenMissing:
            return "Apple sign-in did not return a usable identity token."
        case .requestStateMismatch:
            return "The Apple sign-in request expired. Please try again."
        case .unauthorized(let message):
            return message
        case .server(let message):
            return message
        }
    }

    var shouldForceSignOut: Bool {
        switch self {
        case .unauthorized:
            return true
        case .invalidURL, .invalidResponse, .identityTokenMissing, .requestStateMismatch, .server:
            return false
        }
    }
}
