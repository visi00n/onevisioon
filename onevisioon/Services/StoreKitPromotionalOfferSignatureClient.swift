import Foundation

struct StoreKitPromotionalOfferSignatureClient {
    private let configuration: SupabaseProjectConfiguration
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(configuration: SupabaseProjectConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    func compactJWS(productID: String, offerID: String) async throws -> String {
        let url = configuration.projectURL
            .appendingPathComponent("functions")
            .appendingPathComponent("v1")
            .appendingPathComponent("storekit-promotional-offer-signature")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(configuration.anonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(
            StoreKitPromotionalOfferSignatureRequest(
                productID: productID,
                offerID: offerID
            )
        )

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StoreKitPromotionalOfferSignatureError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw StoreKitPromotionalOfferSignatureError.server(statusCode: httpResponse.statusCode)
        }

        let payload = try decoder.decode(StoreKitPromotionalOfferSignatureResponse.self, from: data)
        guard let compactJWS = payload.resolvedCompactJWS?.trimmed, !compactJWS.isEmpty else {
            throw StoreKitPromotionalOfferSignatureError.missingSignature
        }

        return compactJWS
    }
}

private struct StoreKitPromotionalOfferSignatureRequest: Encodable {
    let productID: String
    let offerID: String

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case offerID = "offer_id"
    }
}

private struct StoreKitPromotionalOfferSignatureResponse: Decodable {
    let compactJWS: String?
    let compactJWSLegacyKey: String?

    var resolvedCompactJWS: String? {
        compactJWS ?? compactJWSLegacyKey
    }

    enum CodingKeys: String, CodingKey {
        case compactJWS = "compact_jws"
        case compactJWSLegacyKey = "compactJWS"
    }
}

enum StoreKitPromotionalOfferSignatureError: LocalizedError {
    case invalidResponse
    case missingSignature
    case server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The promotional offer signing service returned an invalid response."
        case .missingSignature:
            return "The promotional offer signing service did not return a compact JWS."
        case .server(let statusCode):
            return "The promotional offer signing service failed with status \(statusCode)."
        }
    }
}
