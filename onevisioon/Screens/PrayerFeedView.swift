import SwiftUI

struct PrayerFeedView: View {
    @ObservedObject var store: SoulJourneyStore
    @EnvironmentObject private var authManager: AuthSessionManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    if !authManager.isSignedIn {
                        signInCard
                    }
                    folderButtons
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Community")
                .font(OVTheme.display(36))
                .foregroundStyle(OVTheme.midnight)
            Text("Talk, pray, and grow with other believers.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var signInCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sign in for live rooms")
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)

            Text("General chat, your small group, local chat, and live prayer posts all use your secure account session.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var folderButtons: some View {
        VStack(spacing: 14) {
            NavigationLink {
                LiveCommunityRoomView(
                    store: store,
                    room: CommunityRoomDescriptor(
                        kind: .smallGroup,
                        key: store.preferredSmallGroupKey,
                        title: "Small Group"
                    )
                )
            } label: {
                communityFolderButton("Small Group")
            }
            .buttonStyle(.plain)

            NavigationLink {
                LiveCommunityRoomView(
                    store: store,
                    room: CommunityRoomDescriptor(
                        kind: .general,
                        key: "general-chat",
                        title: "General"
                    )
                )
            } label: {
                communityFolderButton("General")
            }
            .buttonStyle(.plain)

            NavigationLink {
                PrayerFeedRoomView(store: store)
            } label: {
                communityFolderButton("Prayer Feed")
            }
            .buttonStyle(.plain)

            if store.usesUnitedStatesLocalGroup {
                NavigationLink {
                    LocalCommunityRoomView(store: store)
                } label: {
                    communityFolderButton("Local")
                }
                .buttonStyle(.plain)
            }

            communityComingSoonButton("Online Events")
        }
    }

    private func communityFolderButton(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.ink)

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func communityComingSoonButton(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.ink)

            Spacer()

            Text("Coming soon")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.gold)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .background(.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }
}

private struct LiveCommunityRoomView: View {
    @ObservedObject var store: SoulJourneyStore
    @EnvironmentObject private var authManager: AuthSessionManager

    let room: CommunityRoomDescriptor
    private let client: SupabaseCommunityClient?

    @State private var messages: [CommunityChatMessage] = []
    @State private var draft = ""
    @State private var members: [CommunityPresenceMember] = []
    @State private var errorMessage = ""
    @State private var isSending = false
    @State private var isRefreshing = false
    @State private var showMembersDrawer = false
    @State private var selectedMember: CommunityPresenceMember?
    @State private var selectedProfile: CommunityPublicProfile?
    @State private var isLoadingProfile = false
    @State private var realtimeConnection: SupabaseRealtimeClient?
    @State private var maintenanceTask: Task<Void, Never>?

    init(store: SoulJourneyStore, room: CommunityRoomDescriptor) {
        self.store = store
        self.room = room
        self.client = try? SupabaseCommunityClient(configuration: SupabaseProjectConfiguration.load())
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                roomHeader

                if let session = authManager.currentSession, client != nil {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(messages) { message in
                                    messageBubble(message, currentUserID: session.supabaseUserID)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(OVTheme.mainBackground)
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    composer
                } else {
                    lockedRoomState
                }
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle(room.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                            showMembersDrawer.toggle()
                        }
                    } label: {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(OVTheme.midnight)
                    }
                }
            }
            .task(id: authManager.currentSession?.id) {
                await startLiveSession()
            }
            .onDisappear {
                Task { await stopLiveSession() }
            }
            .gesture(
                DragGesture(minimumDistance: 18)
                    .onEnded { value in
                        if value.startLocation.x > 300 && value.translation.width < -35 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                showMembersDrawer = true
                            }
                        } else if value.translation.width > 35 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                showMembersDrawer = false
                            }
                        }
                    }
            )

            if showMembersDrawer {
                CommunityMembersDrawer(
                    members: filteredMembersForRoom,
                    activeFilter: isMemberActive,
                    onClose: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                            showMembersDrawer = false
                        }
                    },
                    onSelectMember: { member in
                        Task { await openMember(member) }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .sheet(item: $selectedMember) { member in
            CommunityMemberProfileSheet(
                member: member,
                profile: selectedProfile,
                isLoading: isLoadingProfile
            )
        }
    }

    private var roomHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(room.kind == .smallGroup ? store.preferredSmallGroupName : room.title)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.ink)

            if room.kind == .smallGroup {
                Text("A live room for people carrying a similar struggle right now.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
            } else {
                Text("A live community room for everyday conversation.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.coral)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Write a message", text: $draft, axis: .vertical)
                .font(OVTheme.body(15))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(OVTheme.midnight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending ? 0.5 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(OVTheme.tabBarBackground)
    }

    private var lockedRoomState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Sign in to join live chat")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)
            Text("Use the Profile button in the top-right menu to sign in with Apple or Google first.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.68))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func refreshRoom() async {
        guard let session = authManager.currentSession, let client else { return }
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await client.upsertPresence(
                accessToken: session.accessToken,
                payload: CommunityPresenceUpsertPayload(
                    userID: session.supabaseUserID,
                    displayName: session.displayTitle,
                    handle: store.usernameHandle,
                    currentRoomKey: room.key,
                    localRoomKey: store.localCommunityKey,
                    smallGroupKey: store.preferredSmallGroupKey,
                    country: store.onboardingProfile.country.trimmed.isEmpty ? nil : store.onboardingProfile.country.trimmed,
                    usaAreaCode: store.onboardingProfile.usaAreaCode.trimmed.isEmpty ? nil : store.onboardingProfile.usaAreaCode.trimmed,
                    lastSeenAt: .now
                )
            )

            async let fetchedMessages = client.fetchMessages(roomKey: room.key, accessToken: session.accessToken)
            async let fetchedMembers: [CommunityPresenceMember] = {
                switch room.kind {
                case .smallGroup:
                    return try await client.fetchPresence(
                        smallGroupKey: store.preferredSmallGroupKey,
                        accessToken: session.accessToken
                    )
                case .general:
                    return try await client.fetchPresenceMembers(accessToken: session.accessToken)
                case .local:
                    return []
                }
            }()

            messages = try await fetchedMessages
            members = try await fetchedMembers
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshMessagesOnly() async {
        guard let session = authManager.currentSession, let client else { return }

        do {
            messages = try await client.fetchMessages(roomKey: room.key, accessToken: session.accessToken)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshMembersOnly() async {
        guard let session = authManager.currentSession, let client else { return }

        do {
            let fetchedMembers: [CommunityPresenceMember]
            switch room.kind {
            case .smallGroup:
                fetchedMembers = try await client.fetchPresence(
                    smallGroupKey: store.preferredSmallGroupKey,
                    accessToken: session.accessToken
                )
            case .general:
                fetchedMembers = try await client.fetchPresenceMembers(accessToken: session.accessToken)
            case .local:
                fetchedMembers = []
            }
            members = fetchedMembers
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sendMessage() async {
        guard let session = authManager.currentSession, let client else { return }
        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        isSending = true
        defer { isSending = false }

        do {
            let message = try await client.sendMessage(
                accessToken: session.accessToken,
                payload: CommunityChatMessageCreatePayload(
                    roomKey: room.key,
                    roomTitle: room.title,
                    userID: session.supabaseUserID,
                    authorName: session.displayTitle,
                    handle: store.usernameHandle,
                    body: cleaned
                )
            )
            if !messages.contains(where: { $0.id == message.id }) {
                messages.append(message)
            }
            draft = ""
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startLiveSession() async {
        await stopLiveSession()
        guard let session = authManager.currentSession, client != nil else { return }

        await refreshRoom()
        guard let configuration = try? SupabaseProjectConfiguration.load() else { return }
        maintenanceTask = Task {
            await maintenanceLoop()
        }

        let subscriptions = realtimeSubscriptions
        let connection = SupabaseRealtimeClient(
            configuration: configuration,
            accessToken: session.accessToken
        ) { event in
            Task { @MainActor in
                handleRealtimeEvent(event)
            }
        }
        realtimeConnection = connection
        await connection.connect(channelName: "community-\(room.key)", subscriptions: subscriptions)
    }

    private func stopLiveSession() async {
        maintenanceTask?.cancel()
        maintenanceTask = nil

        if let realtimeConnection {
            await realtimeConnection.disconnect()
        }
        realtimeConnection = nil
    }

    private func maintenanceLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 45_000_000_000)
            guard !Task.isCancelled else { return }
            await refreshRoom()
        }
    }

    private var realtimeSubscriptions: [SupabaseRealtimeClient.Subscription] {
        var subscriptions: [SupabaseRealtimeClient.Subscription] = [
            .init(table: "community_messages", event: "INSERT", filter: "room_key=eq.\(room.key)")
        ]

        switch room.kind {
        case .smallGroup:
            subscriptions.append(
                .init(
                    table: "community_presence",
                    event: "*",
                    filter: "small_group_key=eq.\(store.preferredSmallGroupKey)"
                )
            )
        case .general:
            subscriptions.append(.init(table: "community_presence", event: "*"))
        case .local:
            break
        }

        return subscriptions
    }

    @MainActor
    private func handleRealtimeEvent(_ event: SupabaseRealtimeClient.Event) {
        switch event {
        case .connected:
            errorMessage = ""
        case .postgresChange(let change):
            switch change.table {
            case "community_messages":
                Task { await refreshMessagesOnly() }
            case "community_presence":
                Task { await refreshMembersOnly() }
            default:
                break
            }
        case .system(let message):
            errorMessage = message
        case .error(let message):
            errorMessage = message
        }
    }

    private func messageBubble(_ message: CommunityChatMessage, currentUserID: String) -> some View {
        let isMine = message.userID == currentUserID

        return HStack {
            if isMine { Spacer() }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(message.authorName)
                        .font(OVTheme.heading(13))
                        .foregroundStyle(isMine ? .white : OVTheme.ink)
                    Text(message.handle)
                        .font(OVTheme.body(11))
                        .foregroundStyle(isMine ? Color.white.opacity(0.76) : OVTheme.ink.opacity(0.54))
                }

                Text(message.body)
                    .font(OVTheme.body(15))
                    .foregroundStyle(isMine ? .white : OVTheme.ink.opacity(0.84))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isMine ? OVTheme.midnight : .white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if !isMine { Spacer() }
        }
    }

    private var filteredMembersForRoom: [CommunityPresenceMember] {
        switch room.kind {
        case .smallGroup:
            return members.filter { $0.smallGroupKey == store.preferredSmallGroupKey }
        case .general:
            return members
        case .local:
            return members
        }
    }

    private func isMemberActive(_ member: CommunityPresenceMember) -> Bool {
        guard member.currentRoomKey == room.key else { return false }
        return member.lastSeenAt.timeIntervalSinceNow > -300
    }

    private func openMember(_ member: CommunityPresenceMember) async {
        selectedMember = member
        selectedProfile = nil
        guard let session = authManager.currentSession, let client else { return }

        isLoadingProfile = true
        defer { isLoadingProfile = false }
        selectedProfile = try? await client.fetchPublicProfile(userID: member.userID, accessToken: session.accessToken)
    }
}

private struct LocalCommunityRoomView: View {
    @ObservedObject var store: SoulJourneyStore
    @EnvironmentObject private var authManager: AuthSessionManager

    private let client: SupabaseCommunityClient?

    @State private var messages: [CommunityChatMessage] = []
    @State private var draft = ""
    @State private var members: [CommunityPresenceMember] = []
    @State private var errorMessage = ""
    @State private var isRefreshing = false
    @State private var isSending = false
    @State private var showMembersDrawer = false
    @State private var selectedMember: CommunityPresenceMember?
    @State private var selectedProfile: CommunityPublicProfile?
    @State private var isLoadingProfile = false
    @State private var realtimeConnection: SupabaseRealtimeClient?
    @State private var maintenanceTask: Task<Void, Never>?

    init(store: SoulJourneyStore) {
        self.store = store
        self.client = try? SupabaseCommunityClient(configuration: SupabaseProjectConfiguration.load())
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                roomHeader

                if authManager.currentSession != nil, client != nil {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(messages) { message in
                                    messageBubble(message)
                                        .id(message.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    composer
                } else {
                    lockedRoomState
                }
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle(store.localCommunityTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                            showMembersDrawer.toggle()
                        }
                    } label: {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(OVTheme.midnight)
                    }
                }
            }
            .task(id: authManager.currentSession?.id) {
                await startLiveSession()
            }
            .onDisappear {
                Task { await stopLiveSession() }
            }
            .gesture(
                DragGesture(minimumDistance: 18)
                    .onEnded { value in
                        if value.startLocation.x > 300 && value.translation.width < -35 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                showMembersDrawer = true
                            }
                        } else if value.translation.width > 35 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                showMembersDrawer = false
                            }
                        }
                    }
            )

            if showMembersDrawer {
                membersDrawer
                    .transition(.move(edge: .trailing))
            }
        }
        .sheet(item: $selectedMember) { member in
            CommunityMemberProfileSheet(
                member: member,
                profile: selectedProfile,
                isLoading: isLoadingProfile
            )
        }
    }

    private var roomHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.localCommunityTitle)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.ink)

            Text("Your local room for people near the same place and time zone.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.coral)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Write a message", text: $draft, axis: .vertical)
                .font(OVTheme.body(15))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(OVTheme.midnight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending ? 0.5 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(OVTheme.tabBarBackground)
    }

    private var lockedRoomState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Sign in to join your local room")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)
            Text("Use the Profile button in the top-right menu to sign in with Apple or Google first.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.68))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var membersDrawer: some View {
        let active = members.filter { isMemberActive($0) }
        let inactive = members.filter { !isMemberActive($0) }

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("People")
                    .font(OVTheme.heading(20))
                    .foregroundStyle(OVTheme.ink)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                        showMembersDrawer = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(OVTheme.ink.opacity(0.7))
                }
            }

            membersSection(title: "Active", members: active)
            membersSection(title: "Not active", members: inactive)

            Spacer()
        }
        .padding(18)
        .frame(width: 280)
        .frame(maxHeight: .infinity)
        .background(.white)
        .shadow(color: .black.opacity(0.08), radius: 22, x: -4, y: 0)
    }

    private func membersSection(title: String, members: [CommunityPresenceMember]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.ink.opacity(0.7))

            ForEach(members) { member in
                Button {
                    Task { await openMember(member) }
                } label: {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(OVTheme.gold.opacity(0.2))
                            .frame(width: 34, height: 34)
                            .overlay {
                                Text(String(member.displayName.prefix(1)).uppercased())
                                    .font(OVTheme.heading(14))
                                    .foregroundStyle(OVTheme.midnight)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.displayName)
                                .font(OVTheme.heading(13))
                                .foregroundStyle(OVTheme.ink)
                            Text(member.handle)
                                .font(OVTheme.body(11))
                                .foregroundStyle(OVTheme.ink.opacity(0.55))
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func refreshLocalRoom() async {
        guard let session = authManager.currentSession, let client else { return }
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await client.upsertPresence(
                accessToken: session.accessToken,
                payload: CommunityPresenceUpsertPayload(
                    userID: session.supabaseUserID,
                    displayName: session.displayTitle,
                    handle: store.usernameHandle,
                    currentRoomKey: store.localCommunityKey,
                    localRoomKey: store.localCommunityKey,
                    smallGroupKey: store.preferredSmallGroupKey,
                    country: store.onboardingProfile.country.trimmed.isEmpty ? nil : store.onboardingProfile.country.trimmed,
                    usaAreaCode: store.onboardingProfile.usaAreaCode.trimmed.isEmpty ? nil : store.onboardingProfile.usaAreaCode.trimmed,
                    lastSeenAt: .now
                )
            )

            async let fetchedMessages = client.fetchMessages(roomKey: store.localCommunityKey, accessToken: session.accessToken)
            async let fetchedMembers = client.fetchPresence(localRoomKey: store.localCommunityKey, accessToken: session.accessToken)
            messages = try await fetchedMessages
            members = try await fetchedMembers
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshMessagesOnly() async {
        guard let session = authManager.currentSession, let client else { return }

        do {
            messages = try await client.fetchMessages(roomKey: store.localCommunityKey, accessToken: session.accessToken)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshMembersOnly() async {
        guard let session = authManager.currentSession, let client else { return }

        do {
            members = try await client.fetchPresence(localRoomKey: store.localCommunityKey, accessToken: session.accessToken)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sendMessage() async {
        guard let session = authManager.currentSession, let client else { return }
        let cleaned = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        isSending = true
        defer { isSending = false }

        do {
            let message = try await client.sendMessage(
                accessToken: session.accessToken,
                payload: CommunityChatMessageCreatePayload(
                    roomKey: store.localCommunityKey,
                    roomTitle: store.localCommunityTitle,
                    userID: session.supabaseUserID,
                    authorName: session.displayTitle,
                    handle: store.usernameHandle,
                    body: cleaned
                )
            )
            if !messages.contains(where: { $0.id == message.id }) {
                messages.append(message)
            }
            draft = ""
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startLiveSession() async {
        await stopLiveSession()
        guard let session = authManager.currentSession, client != nil else { return }

        await refreshLocalRoom()
        guard let configuration = try? SupabaseProjectConfiguration.load() else { return }
        maintenanceTask = Task {
            await maintenanceLoop()
        }

        let connection = SupabaseRealtimeClient(
            configuration: configuration,
            accessToken: session.accessToken
        ) { event in
            Task { @MainActor in
                handleRealtimeEvent(event)
            }
        }
        realtimeConnection = connection
        await connection.connect(
            channelName: "community-\(store.localCommunityKey)",
            subscriptions: [
                .init(table: "community_messages", event: "INSERT", filter: "room_key=eq.\(store.localCommunityKey)"),
                .init(table: "community_presence", event: "*", filter: "local_room_key=eq.\(store.localCommunityKey)")
            ]
        )
    }

    private func stopLiveSession() async {
        maintenanceTask?.cancel()
        maintenanceTask = nil

        if let realtimeConnection {
            await realtimeConnection.disconnect()
        }
        realtimeConnection = nil
    }

    private func maintenanceLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 45_000_000_000)
            guard !Task.isCancelled else { return }
            await refreshLocalRoom()
        }
    }

    @MainActor
    private func handleRealtimeEvent(_ event: SupabaseRealtimeClient.Event) {
        switch event {
        case .connected:
            errorMessage = ""
        case .postgresChange(let change):
            switch change.table {
            case "community_messages":
                Task { await refreshMessagesOnly() }
            case "community_presence":
                Task { await refreshMembersOnly() }
            default:
                break
            }
        case .system(let message):
            errorMessage = message
        case .error(let message):
            errorMessage = message
        }
    }

    private func openMember(_ member: CommunityPresenceMember) async {
        selectedMember = member
        selectedProfile = nil
        guard let session = authManager.currentSession, let client else { return }

        isLoadingProfile = true
        defer { isLoadingProfile = false }
        selectedProfile = try? await client.fetchPublicProfile(userID: member.userID, accessToken: session.accessToken)
    }

    private func isMemberActive(_ member: CommunityPresenceMember) -> Bool {
        guard member.currentRoomKey == store.localCommunityKey else { return false }
        return member.lastSeenAt.timeIntervalSinceNow > -300
    }

    private func messageBubble(_ message: CommunityChatMessage) -> some View {
        let currentUserID = authManager.currentSession?.supabaseUserID ?? ""
        let isMine = message.userID == currentUserID

        return HStack {
            if isMine { Spacer() }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(message.authorName)
                        .font(OVTheme.heading(13))
                        .foregroundStyle(isMine ? .white : OVTheme.ink)
                    Text(message.handle)
                        .font(OVTheme.body(11))
                        .foregroundStyle(isMine ? Color.white.opacity(0.76) : OVTheme.ink.opacity(0.54))
                }

                Text(message.body)
                    .font(OVTheme.body(15))
                    .foregroundStyle(isMine ? .white : OVTheme.ink.opacity(0.84))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isMine ? OVTheme.midnight : .white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            if !isMine { Spacer() }
        }
    }
}

private struct PrayerFeedRoomView: View {
    @ObservedObject var store: SoulJourneyStore
    @EnvironmentObject private var authManager: AuthSessionManager

    private let client: SupabaseCommunityClient?
    private let roomKey = "prayer-feed"

    @State private var posts: [CommunityPrayerFeedPost] = []
    @State private var members: [CommunityPresenceMember] = []
    @State private var topic = ""
    @State private var message = ""
    @State private var errorMessage = ""
    @State private var isRefreshing = false
    @State private var isPosting = false
    @State private var showMembersDrawer = false
    @State private var selectedMember: CommunityPresenceMember?
    @State private var selectedProfile: CommunityPublicProfile?
    @State private var isLoadingProfile = false
    @State private var realtimeConnection: SupabaseRealtimeClient?
    @State private var maintenanceTask: Task<Void, Never>?

    init(store: SoulJourneyStore) {
        self.store = store
        self.client = try? SupabaseCommunityClient(configuration: SupabaseProjectConfiguration.load())
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            ScrollView {
                VStack(spacing: 16) {
                    if authManager.currentSession != nil, client != nil {
                        composeCard

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(OVTheme.body(12))
                                .foregroundStyle(OVTheme.coral)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        ForEach(posts) { post in
                            prayerPostCard(post)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("Sign in to post and read live prayer requests")
                                .font(OVTheme.heading(22))
                                .foregroundStyle(OVTheme.ink)
                            Text("Use the Profile button in the top-right menu to sign in with Apple or Google first.")
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.68))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 80)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Prayer Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                            showMembersDrawer.toggle()
                        }
                    } label: {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(OVTheme.midnight)
                    }
                }
            }
            .task(id: authManager.currentSession?.id) {
                await startLiveSession()
            }
            .onDisappear {
                Task { await stopLiveSession() }
            }
            .gesture(
                DragGesture(minimumDistance: 18)
                    .onEnded { value in
                        if value.startLocation.x > 300 && value.translation.width < -35 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                showMembersDrawer = true
                            }
                        } else if value.translation.width > 35 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                                showMembersDrawer = false
                            }
                        }
                    }
            )

            if showMembersDrawer {
                CommunityMembersDrawer(
                    members: members,
                    activeFilter: isMemberActive,
                    onClose: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                            showMembersDrawer = false
                        }
                    },
                    onSelectMember: { member in
                        Task { await openMember(member) }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .sheet(item: $selectedMember) { member in
            CommunityMemberProfileSheet(
                member: member,
                profile: selectedProfile,
                isLoading: isLoadingProfile
            )
        }
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Share a prayer request")
                .font(OVTheme.heading(21))
                .foregroundStyle(OVTheme.ink)

            TextField("Topic", text: $topic)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $message)
                .font(OVTheme.body(15))
                .frame(minHeight: 96)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button {
                Task { await postPrayer() }
            } label: {
                Text("Post to Prayer Feed")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
            .opacity(topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting ? 0.5 : 1)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func prayerPostCard(_ post: CommunityPrayerFeedPost) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.ink)
                    Text("\(post.handle) • \(relativeDate(post.createdAt))")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.56))
                }
                Spacer()
                Text(post.prayerTopic.uppercased())
                    .font(OVTheme.body(10))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(OVTheme.sky.opacity(0.45))
                    .clipShape(Capsule())
            }

            Text(post.message)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func refreshPrayerFeed() async {
        guard let session = authManager.currentSession, let client else { return }
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await client.upsertPresence(
                accessToken: session.accessToken,
                payload: CommunityPresenceUpsertPayload(
                    userID: session.supabaseUserID,
                    displayName: session.displayTitle,
                    handle: store.usernameHandle,
                    currentRoomKey: roomKey,
                    localRoomKey: store.localCommunityKey,
                    smallGroupKey: store.preferredSmallGroupKey,
                    country: store.onboardingProfile.country.trimmed.isEmpty ? nil : store.onboardingProfile.country.trimmed,
                    usaAreaCode: store.onboardingProfile.usaAreaCode.trimmed.isEmpty ? nil : store.onboardingProfile.usaAreaCode.trimmed,
                    lastSeenAt: .now
                )
            )

            async let fetchedPosts = client.fetchPrayerFeedPosts(accessToken: session.accessToken)
            async let fetchedMembers = client.fetchPresenceMembers(accessToken: session.accessToken)
            posts = try await fetchedPosts
            members = try await fetchedMembers
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshPostsOnly() async {
        guard let session = authManager.currentSession, let client else { return }

        do {
            posts = try await client.fetchPrayerFeedPosts(accessToken: session.accessToken)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshMembersOnly() async {
        guard let session = authManager.currentSession, let client else { return }

        do {
            members = try await client.fetchPresenceMembers(accessToken: session.accessToken)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func postPrayer() async {
        guard let session = authManager.currentSession, let client else { return }
        let cleanedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTopic.isEmpty && !cleanedMessage.isEmpty else { return }

        isPosting = true
        defer { isPosting = false }

        do {
            let post = try await client.createPrayerFeedPost(
                accessToken: session.accessToken,
                payload: CommunityPrayerFeedPostCreatePayload(
                    userID: session.supabaseUserID,
                    authorName: session.displayTitle,
                    handle: store.usernameHandle,
                    prayerTopic: cleanedTopic,
                    message: cleanedMessage
                )
            )
            if !posts.contains(where: { $0.id == post.id }) {
                posts.insert(post, at: 0)
            }
            topic = ""
            message = ""
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startLiveSession() async {
        await stopLiveSession()
        guard let session = authManager.currentSession, client != nil else { return }

        await refreshPrayerFeed()
        guard let configuration = try? SupabaseProjectConfiguration.load() else { return }
        maintenanceTask = Task {
            await maintenanceLoop()
        }

        let connection = SupabaseRealtimeClient(
            configuration: configuration,
            accessToken: session.accessToken
        ) { event in
            Task { @MainActor in
                handleRealtimeEvent(event)
            }
        }
        realtimeConnection = connection
        await connection.connect(
            channelName: "community-\(roomKey)",
            subscriptions: [
                .init(table: "prayer_feed_posts", event: "INSERT", filter: "status=eq.published"),
                .init(table: "community_presence", event: "*")
            ]
        )
    }

    private func stopLiveSession() async {
        maintenanceTask?.cancel()
        maintenanceTask = nil

        if let realtimeConnection {
            await realtimeConnection.disconnect()
        }
        realtimeConnection = nil
    }

    private func maintenanceLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 45_000_000_000)
            guard !Task.isCancelled else { return }
            await refreshPrayerFeed()
        }
    }

    @MainActor
    private func handleRealtimeEvent(_ event: SupabaseRealtimeClient.Event) {
        switch event {
        case .connected:
            errorMessage = ""
        case .postgresChange(let change):
            switch change.table {
            case "prayer_feed_posts":
                Task { await refreshPostsOnly() }
            case "community_presence":
                Task { await refreshMembersOnly() }
            default:
                break
            }
        case .system(let message):
            errorMessage = message
        case .error(let message):
            errorMessage = message
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }

    private func isMemberActive(_ member: CommunityPresenceMember) -> Bool {
        guard member.currentRoomKey == roomKey else { return false }
        return member.lastSeenAt.timeIntervalSinceNow > -300
    }

    private func openMember(_ member: CommunityPresenceMember) async {
        selectedMember = member
        selectedProfile = nil
        guard let session = authManager.currentSession, let client else { return }

        isLoadingProfile = true
        defer { isLoadingProfile = false }
        selectedProfile = try? await client.fetchPublicProfile(userID: member.userID, accessToken: session.accessToken)
    }
}

private struct CommunityMembersDrawer: View {
    let members: [CommunityPresenceMember]
    let activeFilter: (CommunityPresenceMember) -> Bool
    let onClose: () -> Void
    let onSelectMember: (CommunityPresenceMember) -> Void

    private var activeMembers: [CommunityPresenceMember] {
        members.filter(activeFilter)
    }

    private var inactiveMembers: [CommunityPresenceMember] {
        members.filter { !activeFilter($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("People")
                    .font(OVTheme.heading(20))
                    .foregroundStyle(OVTheme.ink)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(OVTheme.ink.opacity(0.7))
                }
            }

            communityMembersSection(title: "Active", members: activeMembers)
            communityMembersSection(title: "Not active", members: inactiveMembers)

            Spacer()
        }
        .padding(18)
        .frame(width: 280)
        .frame(maxHeight: .infinity)
        .background(.white)
        .shadow(color: .black.opacity(0.08), radius: 22, x: -4, y: 0)
    }

    private func communityMembersSection(title: String, members: [CommunityPresenceMember]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.ink.opacity(0.7))

            if members.isEmpty {
                Text(title == "Active" ? "No one is active here right now." : "No one else is listed right now.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.52))
            } else {
                ForEach(members) { member in
                    Button {
                        onSelectMember(member)
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(OVTheme.gold.opacity(0.2))
                                .frame(width: 34, height: 34)
                                .overlay {
                                    Text(String(member.displayName.prefix(1)).uppercased())
                                        .font(OVTheme.heading(14))
                                        .foregroundStyle(OVTheme.midnight)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.displayName)
                                    .font(OVTheme.heading(13))
                                    .foregroundStyle(OVTheme.ink)
                                Text(member.handle)
                                    .font(OVTheme.body(11))
                                    .foregroundStyle(OVTheme.ink.opacity(0.55))
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CommunityMemberProfileSheet: View {
    let member: CommunityPresenceMember
    let profile: CommunityPublicProfile?
    let isLoading: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(OVTheme.gold.opacity(0.2))
                            .frame(width: 58, height: 58)
                            .overlay {
                                Text(String(member.displayName.prefix(1)).uppercased())
                                    .font(OVTheme.heading(22))
                                    .foregroundStyle(OVTheme.midnight)
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(member.displayName)
                                .font(OVTheme.heading(24))
                                .foregroundStyle(OVTheme.ink)
                            Text(member.handle)
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.58))
                        }
                    }

                    if isLoading {
                        ProgressView()
                    } else if let profile, profile.isPublic {
                        if let bio = profile.bio, !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            infoCard(title: "Bio", value: bio)
                        }

                        if let country = profile.country, !country.isEmpty {
                            infoCard(title: "Country", value: country)
                        }

                        if let areaCode = profile.usaAreaCode, !areaCode.isEmpty {
                            infoCard(title: "Area code", value: areaCode)
                        }

                        if let instagram = profile.instagram, !instagram.isEmpty {
                            infoCard(title: "Instagram", value: instagram)
                        }

                        if let xHandle = profile.xHandle, !xHandle.isEmpty {
                            infoCard(title: "X", value: xHandle)
                        }

                        if let youtube = profile.youtube, !youtube.isEmpty {
                            infoCard(title: "YouTube", value: youtube)
                        }
                    } else {
                        infoCard(title: "Profile", value: "This member keeps their profile private right now.")
                    }
                }
                .padding(20)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.ink.opacity(0.65))
            Text(value)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct PrayerFeedView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerFeedView(store: SoulJourneyStore())
    }
}
