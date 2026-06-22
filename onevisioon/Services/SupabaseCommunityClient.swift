import Foundation

actor SupabaseCommunityClient {
    private let configuration: SupabaseProjectConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(configuration: SupabaseProjectConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            if let date = SupabaseCommunityDateCoder.iso8601WithFractionalSeconds.date(from: value)
                ?? SupabaseCommunityDateCoder.iso8601.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported Supabase date value: \(value)"
            )
        }
        self.encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(SupabaseCommunityDateCoder.iso8601WithFractionalSeconds.string(from: date))
        }
    }

    func fetchMessages(roomKey: String, accessToken: String, limit: Int = 120) async throws -> [CommunityChatMessage] {
        let request = try makeRequest(
            path: "community_messages",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "room_key", value: "eq.\(roomKey)"),
                URLQueryItem(name: "select", value: "id,room_key,room_title,user_id,author_name,handle,body,created_at"),
                URLQueryItem(name: "order", value: "created_at.asc"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )

        return try await perform(request, decode: [CommunityChatMessage].self)
    }

    func sendMessage(accessToken: String, payload: CommunityChatMessageCreatePayload) async throws -> CommunityChatMessage {
        var request = try makeRequest(
            path: "community_messages",
            method: "POST",
            bearerToken: accessToken,
            queryItems: [URLQueryItem(name: "select", value: "id,room_key,room_title,user_id,author_name,handle,body,created_at")]
        )
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode([payload])

        guard let message = try await perform(request, decode: [CommunityChatMessage].self).first else {
            throw SupabaseCommunityError.invalidResponse
        }

        return message
    }

    func upsertPresence(accessToken: String, payload: CommunityPresenceUpsertPayload) async throws {
        var request = try makeRequest(
            path: "community_presence",
            method: "POST",
            bearerToken: accessToken,
            queryItems: [URLQueryItem(name: "on_conflict", value: "user_id")]
        )
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode([payload])
        _ = try await performWithoutResponseBody(request)
    }

    func fetchPresence(localRoomKey: String, accessToken: String) async throws -> [CommunityPresenceMember] {
        let request = try makeRequest(
            path: "community_presence",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "local_room_key", value: "eq.\(localRoomKey)"),
                URLQueryItem(name: "select", value: "user_id,display_name,handle,current_room_key,local_room_key,small_group_key,country,usa_area_code,last_seen_at"),
                URLQueryItem(name: "order", value: "last_seen_at.desc"),
                URLQueryItem(name: "limit", value: "300")
            ]
        )

        return try await perform(request, decode: [CommunityPresenceMember].self)
    }

    func fetchPresence(smallGroupKey: String, accessToken: String) async throws -> [CommunityPresenceMember] {
        let request = try makeRequest(
            path: "community_presence",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "small_group_key", value: "eq.\(smallGroupKey)"),
                URLQueryItem(name: "select", value: "user_id,display_name,handle,current_room_key,local_room_key,small_group_key,country,usa_area_code,last_seen_at"),
                URLQueryItem(name: "order", value: "last_seen_at.desc"),
                URLQueryItem(name: "limit", value: "300")
            ]
        )

        return try await perform(request, decode: [CommunityPresenceMember].self)
    }

    func fetchPresenceMembers(accessToken: String) async throws -> [CommunityPresenceMember] {
        let request = try makeRequest(
            path: "community_presence",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "select", value: "user_id,display_name,handle,current_room_key,local_room_key,small_group_key,country,usa_area_code,last_seen_at"),
                URLQueryItem(name: "order", value: "last_seen_at.desc"),
                URLQueryItem(name: "limit", value: "300")
            ]
        )

        return try await perform(request, decode: [CommunityPresenceMember].self)
    }

    func fetchPublicProfile(userID: String, accessToken: String) async throws -> CommunityPublicProfile? {
        let request = try makeRequest(
            path: "profiles",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(userID)"),
                URLQueryItem(name: "select", value: "id,display_name,handle,bio,instagram,x_handle,youtube,country,usa_area_code,is_public"),
                URLQueryItem(name: "limit", value: "1")
            ]
        )

        return try await perform(request, decode: [CommunityPublicProfile].self).first
    }

    func fetchPrayerFeedPosts(accessToken: String) async throws -> [CommunityPrayerFeedPost] {
        let request = try makeRequest(
            path: "prayer_feed_posts",
            method: "GET",
            bearerToken: accessToken,
            queryItems: [
                URLQueryItem(name: "select", value: "id,user_id,author_name,handle,prayer_topic,message,amens,created_at"),
                URLQueryItem(name: "status", value: "eq.published"),
                URLQueryItem(name: "order", value: "created_at.desc"),
                URLQueryItem(name: "limit", value: "120")
            ]
        )

        return try await perform(request, decode: [CommunityPrayerFeedPost].self)
    }

    func createPrayerFeedPost(accessToken: String, payload: CommunityPrayerFeedPostCreatePayload) async throws -> CommunityPrayerFeedPost {
        var request = try makeRequest(
            path: "prayer_feed_posts",
            method: "POST",
            bearerToken: accessToken,
            queryItems: [URLQueryItem(name: "select", value: "id,user_id,author_name,handle,prayer_topic,message,amens,created_at")]
        )
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try encoder.encode([payload])

        guard let post = try await perform(request, decode: [CommunityPrayerFeedPost].self).first else {
            throw SupabaseCommunityError.invalidResponse
        }

        return post
    }

    private func makeRequest(
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
            throw SupabaseCommunityError.invalidURL
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
            throw SupabaseCommunityError.invalidResponse
        }

        return httpResponse
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseCommunityError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let message = SupabaseCommunityErrorEnvelope.bestMessage(from: data)
                ?? "Supabase community request failed with code \(httpResponse.statusCode)."
            throw SupabaseCommunityError.server(message)
        }
    }
}

private enum SupabaseCommunityDateCoder {
    static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

private enum SupabaseCommunityErrorEnvelope {
    nonisolated static func bestMessage(from data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        for key in ["message", "msg", "error_description", "error"] {
            if let value = root[key] as? String {
                let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty {
                    return cleaned
                }
            }
        }

        return nil
    }
}

enum SupabaseCommunityError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The Supabase community URL is invalid."
        case .invalidResponse:
            return "Supabase returned an unreadable community response."
        case .server(let message):
            return message
        }
    }
}
