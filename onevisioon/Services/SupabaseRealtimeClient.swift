import Foundation

actor SupabaseRealtimeClient {
    struct Subscription: Hashable, Sendable {
        let schema: String
        let table: String
        let event: String
        let filter: String?

        init(schema: String = "public", table: String, event: String = "*", filter: String? = nil) {
            self.schema = schema
            self.table = table
            self.event = event
            self.filter = filter
        }
    }

    struct PostgresChange: Sendable {
        let schema: String
        let table: String
        let eventType: String
    }

    enum Event: Sendable {
        case connected
        case postgresChange(PostgresChange)
        case system(message: String)
        case error(String)
    }

    typealias EventHandler = @Sendable (Event) -> Void

    private let configuration: SupabaseProjectConfiguration
    private let accessToken: String
    private let session: URLSession
    private let eventHandler: EventHandler

    private var socketTask: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var heartbeatTask: Task<Void, Never>?
    private var nextReference = 1
    private var channelTopic = ""
    private var joinReference = ""

    init(
        configuration: SupabaseProjectConfiguration,
        accessToken: String,
        session: URLSession = .shared,
        eventHandler: @escaping EventHandler
    ) {
        self.configuration = configuration
        self.accessToken = accessToken
        self.session = session
        self.eventHandler = eventHandler
    }

    func connect(channelName: String, subscriptions: [Subscription]) async {
        await tearDownConnection(sendLeaveEvent: true)

        do {
            let socketTask = session.webSocketTask(with: try makeWebSocketURL())
            self.socketTask = socketTask
            channelTopic = "realtime:\(channelName)"
            joinReference = nextRef()

            socketTask.resume()

            receiveTask = Task { [weak self] in
                await self?.receiveLoop()
            }
            heartbeatTask = Task { [weak self] in
                await self?.heartbeatLoop()
            }

            try await send(
                topic: channelTopic,
                event: "phx_join",
                payload: [
                    "config": [
                        "broadcast": [
                            "ack": false,
                            "self": false
                        ],
                        "presence": [
                            "enabled": false
                        ],
                        "postgres_changes": subscriptions.map {
                            var payload: [String: Any] = [
                                "event": $0.event,
                                "schema": $0.schema,
                                "table": $0.table
                            ]
                            if let filter = $0.filter {
                                payload["filter"] = filter
                            }
                            return payload
                        },
                        "private": true
                    ],
                    "access_token": accessToken
                ],
                ref: joinReference,
                joinRef: joinReference
            )
        } catch {
            await tearDownConnection(sendLeaveEvent: false)
            emit(.error(error.localizedDescription))
        }
    }

    func disconnect() async {
        await tearDownConnection(sendLeaveEvent: true)
    }

    private func receiveLoop() async {
        guard let socketTask else { return }

        while !Task.isCancelled {
            do {
                let message = try await socketTask.receive()
                switch message {
                case .string(let string):
                    handleIncoming(text: string)
                case .data(let data):
                    if let string = String(data: data, encoding: .utf8) {
                        handleIncoming(text: string)
                    }
                @unknown default:
                    break
                }
            } catch {
                if !Task.isCancelled {
                    emit(.error("Live chat disconnected. Pull to reopen the room if needed."))
                    await tearDownConnection(sendLeaveEvent: false)
                }
                break
            }
        }
    }

    private func heartbeatLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 20_000_000_000)
            guard !Task.isCancelled else { return }

            do {
                try await send(topic: "phoenix", event: "heartbeat", payload: [:], ref: nextRef(), joinRef: nil)
            } catch {
                emit(.error("Live chat lost its heartbeat."))
                await tearDownConnection(sendLeaveEvent: false)
                return
            }
        }
    }

    private func tearDownConnection(sendLeaveEvent: Bool) async {
        heartbeatTask?.cancel()
        receiveTask?.cancel()
        heartbeatTask = nil
        receiveTask = nil

        if sendLeaveEvent, socketTask != nil, !channelTopic.isEmpty, !joinReference.isEmpty {
            try? await send(topic: channelTopic, event: "phx_leave", payload: [:], ref: nextRef(), joinRef: joinReference)
        }

        socketTask?.cancel(with: .goingAway, reason: nil)
        socketTask = nil
        channelTopic = ""
        joinReference = ""
    }

    private func send(
        topic: String,
        event: String,
        payload: [String: Any],
        ref: String,
        joinRef: String?
    ) async throws {
        guard let socketTask else { return }

        var envelope: [String: Any] = [
            "topic": topic,
            "event": event,
            "payload": payload,
            "ref": ref
        ]
        if let joinRef {
            envelope["join_ref"] = joinRef
        }

        let data = try JSONSerialization.data(withJSONObject: envelope)
        guard let string = String(data: data, encoding: .utf8) else {
            throw SupabaseRealtimeError.invalidMessage
        }
        try await socketTask.send(.string(string))
    }

    private func handleIncoming(text: String) {
        guard let data = text.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let event = root["event"] as? String else {
            return
        }

        switch event {
        case "phx_reply":
            handleReply(root)
        case "postgres_changes":
            guard
                let payload = root["payload"] as? [String: Any],
                let data = payload["data"] as? [String: Any],
                let schema = data["schema"] as? String,
                let table = data["table"] as? String,
                let eventType = data["type"] as? String
            else { return }

            emit(.postgresChange(PostgresChange(schema: schema, table: table, eventType: eventType)))
        case "system":
            if let payload = root["payload"] as? [String: Any],
               let message = payload["message"] as? String,
               !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                emit(.system(message: message))
            }
        default:
            break
        }
    }

    private func handleReply(_ root: [String: Any]) {
        guard
            let ref = root["ref"] as? String,
            ref == joinReference,
            let payload = root["payload"] as? [String: Any],
            let status = payload["status"] as? String
        else {
            return
        }

        if status == "ok" {
            emit(.connected)
        } else {
            let message = ((payload["response"] as? [String: Any])?["message"] as? String)
                ?? "Realtime join failed."
            emit(.error(message))
        }
    }

    private func makeWebSocketURL() throws -> URL {
        var components = URLComponents(url: configuration.projectURL, resolvingAgainstBaseURL: false)
        components?.scheme = "wss"
        components?.path = "/realtime/v1/websocket"
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: configuration.anonKey),
            URLQueryItem(name: "vsn", value: "1.0.0")
        ]

        guard let url = components?.url else {
            throw SupabaseRealtimeError.invalidURL
        }

        return url
    }

    private func nextRef() -> String {
        defer { nextReference += 1 }
        return String(nextReference)
    }

    private func emit(_ event: Event) {
        eventHandler(event)
    }
}

enum SupabaseRealtimeError: LocalizedError {
    case invalidURL
    case invalidMessage

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The Supabase realtime URL is invalid."
        case .invalidMessage:
            return "The realtime message could not be encoded."
        }
    }
}
