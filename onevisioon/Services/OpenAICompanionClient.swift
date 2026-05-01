import Foundation

actor OpenAICompanionClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func ask(apiKey: String, model: String, systemPrompt: String, userPrompt: String) async throws -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AICompanionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let payload = ChatRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: systemPrompt),
                ChatMessage(role: "user", content: userPrompt)
            ],
            temperature: 0.4,
            max_tokens: 220
        )

        let encodedBody = try await MainActor.run {
            try JSONEncoder().encode(payload)
        }
        request.httpBody = encodedBody

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AICompanionError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 401 {
                throw AICompanionError.unauthorized
            }
            let message = await MainActor.run {
                (try? JSONDecoder().decode(APIErrorEnvelope.self, from: data).error.message)
                    ?? "API request failed with code \(http.statusCode)."
            }
            throw AICompanionError.server(message)
        }

        let decoded = try await MainActor.run {
            try JSONDecoder().decode(ChatResponse.self, from: data)
        }
        guard let text = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            throw AICompanionError.emptyResponse
        }

        return text
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let max_tokens: Int
}

private struct ChatMessage: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: ChatMessage
    }
}

private struct APIErrorEnvelope: Decodable {
    let error: APIErrorDetail

    struct APIErrorDetail: Decodable {
        let message: String
    }
}

enum AICompanionError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case emptyResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL."
        case .invalidResponse:
            return "Invalid response from AI backend."
        case .unauthorized:
            return "API key was rejected. Check your OpenAI key."
        case .emptyResponse:
            return "AI returned an empty response."
        case .server(let message):
            return message
        }
    }
}
