import AuthenticationServices
import SwiftUI
import UIKit

struct OneVisioonHubView: View {
    @ObservedObject var store: SoulJourneyStore
    @Environment(\.dismiss) private var dismiss
    @State private var showPrivacyPolicy = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: OVTheme.cardSpacing) {
                    hubHeaderCard
                    hubButtonsCard
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("One Visioon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            ProfilePrivacyPolicySheet()
        }
    }

    private var hubHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                LogoMark(size: 42, cornerRadius: 12)

                Text("One Visioon")
                    .font(OVTheme.display(34))
                    .foregroundStyle(OVTheme.midnight)
            }

            Text("Our mission is to help people understand Scripture, grow with Christ, and stay rooted in a real Christian community.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.78))

            Text("20% of our profits go to help people in need through future giving and support initiatives.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.gold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }

    private var hubButtonsCard: some View {
        VStack(spacing: 12) {
            NavigationLink {
                ProfileView(store: store, showsInfoButton: false, showsDismissButton: false)
            } label: {
                hubButtonRow(title: "Profile", subtitle: "Account, sign in, and your saved details.")
            }
            .buttonStyle(.plain)

            NavigationLink {
                CommunityLinksView()
            } label: {
                hubButtonRow(title: "Community", subtitle: "Open Discord and Instagram for the community.")
            }
            .buttonStyle(.plain)

            Button {
                showPrivacyPolicy = true
            } label: {
                hubButtonRow(title: "Privacy Policy", subtitle: "Read how your data is stored and used.")
            }
            .buttonStyle(.plain)

            NavigationLink {
                AboutOneVisioonView()
            } label: {
                hubButtonRow(title: "About", subtitle: "Mission, what is live, and what is coming next.")
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }

    private func hubButtonRow(title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.midnight)

                Text(subtitle)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(OVTheme.paper.opacity(0.96))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ProfileView: View {
    @ObservedObject var store: SoulJourneyStore
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthSessionManager

    let showsInfoButton: Bool
    let showsDismissButton: Bool

    @State private var notesQuery = ""
    @State private var showPrivacyPolicy = false

    init(store: SoulJourneyStore, showsInfoButton: Bool = true, showsDismissButton: Bool = false) {
        self.store = store
        self.showsInfoButton = showsInfoButton
        self.showsDismissButton = showsDismissButton
    }

    private var syncSnapshot: UserProgressSyncSnapshot {
        store.exportSyncSnapshot()
    }

    private let instagramURL = URL(string: "https://www.instagram.com/one.visioon/")!
    private let discordURL = URL(string: "https://discord.gg/W7M4zGPtqV")!

    private var personalStatement: String {
        let custom = store.publicProfileSettings.testimonial.trimmingCharacters(in: .whitespacesAndNewlines)
        return custom.isEmpty ? "I'm walking with God daily." : custom
    }

    private var achievementBadges: [(title: String, detail: String, unlocked: Bool)] {
        [
            ("7 Day Streak", "Stay in the Word for seven straight days.", store.currentStreak >= 7),
            ("First Lesson", "Finish your first lesson on the path.", store.completedLessonsCount >= 1),
            ("30 Day Discipline", "Show up for thirty active days.", store.totalActiveDays >= 30)
        ]
    }

    private var habitReflectionEntries: [GiftTrainingCheckIn] {
        store.giftTrainingCheckIns
            .filter { !$0.reflection.trimmed.isEmpty }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: OVTheme.cardSpacing) {
                    profileHeader
                    editableProfileCard
                    profileActionsCard
                    accountStatusCard
                    studySnapshotCard

                    if let giftProfile = store.giftDiscoveryProfile {
                        giftProfileCard(giftProfile)
                    }

                    if !habitReflectionEntries.isEmpty {
                        habitReflectionCard
                    }
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsDismissButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                        .font(OVTheme.body(15))
                    }
                }

                if showsInfoButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        AppInfoButton()
                    }
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.onboardingProfile.fullName.isEmpty ? "Profile" : store.onboardingProfile.fullName)
                .font(OVTheme.display(40))
                .foregroundStyle(OVTheme.midnight)

            Text("Your account and saved details.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            Text(personalStatement)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.62), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .premiumSurfaceCard(cornerRadius: 24)
    }

    private var editableProfileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit profile")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            TextField("Name", text: onboardingBinding(\.fullName))
                .textFieldStyle(.roundedBorder)

            TextField("Username", text: onboardingBinding(\.username))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("Bio / testimony")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                TextEditor(text: publicProfileBinding(\.testimonial))
                    .font(OVTheme.body(14))
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(OVTheme.paper.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Text("Friends and public profiles are coming later, so this stays ready without pretending the social layer is live.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.62))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var profileActionsCard: some View {
        VStack(spacing: 10) {
            NavigationLink {
                ProfileSettingsView(store: store)
            } label: {
                activeProfileRow(
                    title: "Profile Settings",
                    subtitle: "Manage your name, username, and profile details.",
                    systemImage: "slider.horizontal.3"
                )
            }
            .buttonStyle(.plain)

            comingSoonProfileRow(
                title: "Friends",
                subtitle: "Connect with people when community opens.",
                systemImage: "person.2.fill"
            )

            comingSoonProfileRow(
                title: "Achievements",
                subtitle: "Milestones for consistency and lesson progress.",
                systemImage: "trophy.fill"
            )

            comingSoonProfileRow(
                title: "Badges",
                subtitle: "Visual rewards for growth patterns.",
                systemImage: "checkmark.seal.fill"
            )

            comingSoonProfileRow(
                title: "Leaderboard",
                subtitle: "Community rankings will unlock later.",
                systemImage: "chart.bar.fill"
            )
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var aboutYouCard: some View {
        let profile = store.onboardingProfile

        return VStack(alignment: .leading, spacing: 10) {
            Text("About you")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            metricRow("Name", profile.fullName.trimmed.isEmpty ? "Not added yet" : profile.fullName)

            if !profile.age.isEmpty {
                metricRow("Age", profile.age)
            }

            if !profile.gender.isEmpty {
                metricRow("Gender", profile.gender)
            }

            if !profile.email.isEmpty {
                metricRow("Email", profile.email)
            }

            if !profile.heardAboutSource.isEmpty {
                metricRow("Found us on", profile.heardAboutSource)
            }

            metricRow("Saved progress", "Stored on this device")
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private func giftProfileCard(_ profile: GiftDiscoveryProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gift discovery")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            if let primary = profile.primaryGift {
                metricRow("Primary gift", primary.title)
                Text(primary.shortSummary)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))
            }

            if let secondary = profile.secondaryGift {
                metricRow("Support gift", secondary.title)
            }

            metricRow("Quiz completed", shortDate(profile.completedAt))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var habitReflectionCard: some View {
        let latest = habitReflectionEntries.first

        return VStack(alignment: .leading, spacing: 10) {
            Text("Habit reflection")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Your saved Glorify reflections live here with the date you submitted them.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            if let latest {
                metricRow("Latest", shortDate(latest.updatedAt))
            }

            NavigationLink {
                HabitReflectionHistoryView(entries: habitReflectionEntries)
            } label: {
                HStack {
                    Text("Open Habit Reflection")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(habitReflectionEntries.count)")
                        .font(OVTheme.heading(13))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var publicProfileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your witness")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Control what other people can see about your growth, testimony, and consistency.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            NavigationLink {
                PublicProfileSettingsView(store: store)
            } label: {
                HStack {
                    Text("Manage Public Profile")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Text(store.publicProfileSettings.isPublic ? "Status: Public" : "Status: Private")
                .font(OVTheme.body(12))
                .foregroundStyle(store.publicProfileSettings.isPublic ? .green : OVTheme.ink.opacity(0.6))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your path")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            metricRow("Lessons completed", "\(store.completedLessonsCount)/\(store.lessons.count)")
            metricRow("Quests passed", "\(store.passedQuestsCount)/\(store.lessons.count)")
            metricRow("Completion", "\(store.courseCompletionPercent)%")

            ProgressView(value: Double(store.courseCompletionPercent), total: 100)
                .tint(OVTheme.mint)

            Button(role: .destructive) {
                store.resetCourseProgress()
            } label: {
                Text("Reset Course Progress")
                    .font(OVTheme.body(13))
            }
            .padding(.top, 4)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var accountStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Account")
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.ink)

                Spacer()

                statusPill(
                    authManager.isSignedIn
                        ? (authManager.isAuthenticating ? "Connecting" : "Signed in")
                        : (authManager.isCloudConfigured ? "Cloud ready" : "Apple ready"),
                    tint: authManager.isSignedIn ? OVTheme.mint : (authManager.isCloudConfigured ? OVTheme.sky : OVTheme.gold.opacity(0.78))
                )
            }

            Text(authManager.backendStatus.detail)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            if let session = authManager.currentSession {
                metricRow("Provider", session.providerTitle)
                metricRow("Name", session.displayTitle)

                if !session.email.trimmed.isEmpty {
                    metricRow("Email", session.email)
                }

                metricRow("Cloud status", authManager.syncStatusLine)

                Button(role: .destructive) {
                    authManager.signOut()
                } label: {
                    Text("Sign out")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OVTheme.coral)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else if authManager.canStartAppleSignIn {
                Text(authManager.isCloudConfigured
                    ? "Sign in with Apple if you want to connect this profile and back up your progress."
                    : "Sign in with Apple if you want this profile connected to your Apple account. You can keep using the app without signing in.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))

                SignInWithAppleButton(.continue) { request in
                    authManager.configureAppleRequest(request)
                } onCompletion: { result in
                    Task {
                        await authManager.handleAppleSignIn(result: result, store: store)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(Capsule())
                .disabled(authManager.isAuthenticating)
                .opacity(authManager.isAuthenticating ? 0.7 : 1)

            } else {
                helperMessage(authManager.syncStatusLine, tint: OVTheme.gold)
            }

            if !authManager.errorMessage.isEmpty {
                helperMessage(authManager.errorMessage, tint: OVTheme.coral)
            }

            if !store.onboardingProfile.email.isEmpty {
                metricRow("Newsletter email", store.onboardingProfile.email)
            }

            metricRow("Progress storage", authManager.isSignedIn ? "Cloud + device" : "Saved on this device")
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var studySnapshotCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your stats")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("A live snapshot of how you are actually using the app, not just that you downloaded it.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            metricRow("Current streak", "\(store.currentStreak) day\(store.currentStreak == 1 ? "" : "s")")
            metricRow("Total active days", "\(store.totalActiveDays)")
            metricRow("Completed lessons", "\(store.completedLessonsCount)")
            metricRow("Passed quests", "\(store.passedQuestsCount)")
            metricRow("Chapter reflections", "\(syncSnapshot.chapterReflections.count)")
            metricRow("Bible notes", "\(syncSnapshot.bibleVerseNotes.count)")
            metricRow("Verse highlights", "\(syncSnapshot.bibleVerseHighlights.count)")
            metricRow("Wisdom points", "\(store.wisdomPoints)")
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var identityBadgesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Badges")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Milestones that show you are becoming disciplined, not just informed.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            ForEach(Array(achievementBadges.enumerated()), id: \.offset) { _, badge in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: badge.unlocked ? "checkmark.seal.fill" : "lock.fill")
                        .foregroundStyle(badge.unlocked ? OVTheme.gold : OVTheme.ink.opacity(0.35))
                        .font(.system(size: 18, weight: .semibold))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(badge.title)
                            .font(OVTheme.heading(15))
                            .foregroundStyle(OVTheme.ink)
                        Text(badge.detail)
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.ink.opacity(0.66))
                    }

                    Spacer()

                    Text(badge.unlocked ? "Earned" : "Locked")
                        .font(OVTheme.body(11))
                        .foregroundStyle(badge.unlocked ? OVTheme.gold : OVTheme.ink.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(OVTheme.smoke)
                        .clipShape(Capsule())
                }
                .padding(12)
                .background(OVTheme.smoke.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var leaderboardCard: some View {
        let rank = store.leaderboardEntries.firstIndex(where: { $0.isCurrentUser }).map { $0 + 1 } ?? 0

        return VStack(alignment: .leading, spacing: 10) {
            Text("Identity tier")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Climb from Seeker to Mentor through lessons, quests, and steady discipline.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            HStack(spacing: 10) {
                badge("Tier", store.currentGrowthTier)
                badge("Rank", rank > 0 ? "#\(rank)" : "-")
                badge("Points", "\(store.wisdomPoints)")
            }

            NavigationLink {
                LeaderboardView(store: store)
            } label: {
                HStack {
                    Text("Open Rankings")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private func badge(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
            Text(value)
                .font(OVTheme.heading(15))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(OVTheme.smoke)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var notesCard: some View {
        let notes = store.chapterReflections(matching: notesQuery)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Chapter reflections")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            TextField("Search by chapter, highlight, insight, or question", text: $notesQuery)
                .textFieldStyle(.roundedBorder)

            if notes.isEmpty {
                Text("No matching reflections yet. Save one inside a chapter study.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))
            } else {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Chapter \(note.lessonOrder): \(note.lessonTitle)")
                                .font(OVTheme.heading(14))
                                .foregroundStyle(OVTheme.ink)
                            Spacer()
                            Text(shortDate(note.updatedAt))
                                .font(OVTheme.body(11))
                                .foregroundStyle(OVTheme.ink.opacity(0.55))
                        }

                        if !note.highlightedVerses.isEmpty {
                            infoLine("Highlights", note.highlightedVerses.joined(separator: ", "))
                        }
                        infoLine("Stood out", note.stoodOut)
                        infoLine("God spoke", note.godMessage)
                        infoLine("Apply", note.application)
                        infoLine("Learned", note.learned)
                        infoLine("Questions", note.questions)
                    }
                    .padding(10)
                    .background(OVTheme.smoke)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var learningProfileCard: some View {
        let profile = store.onboardingProfile

        return VStack(alignment: .leading, spacing: 10) {
            Text("Path settings")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            if !profile.age.isEmpty {
                metricRow("Age", profile.age)
            }
            if !profile.gender.isEmpty {
                metricRow("Gender", profile.gender)
            }
            metricRow("Faith stage", profile.faithStage)
            metricRow("Main challenge", profile.biggestChallenge)
            if !profile.currentStruggles.isEmpty {
                metricRow("Recent pressure", profile.currentStruggles.joined(separator: ", "))
            }
            if !profile.lifeVision.isEmpty {
                metricRow("Life vision", profile.lifeVision)
            }
            if !profile.desiredGrowth.isEmpty {
                metricRow("Wants most", profile.desiredGrowth)
            }
            if !profile.behindArea.isEmpty {
                metricRow("Feels behind in", profile.behindArea)
            }
            if !profile.ifNothingChangesFeeling.isEmpty {
                metricRow("One-year fear", profile.ifNothingChangesFeeling)
            }
            if !profile.futureStrength.isEmpty {
                metricRow("Future strength", profile.futureStrength)
            }
            metricRow("Scripture rhythm", profile.scriptureRhythm)
            metricRow("Prayer rhythm", profile.prayerRhythm)
            if !profile.supportNeed.isEmpty {
                metricRow("Needs most", profile.supportNeed)
            }
            if !profile.spiritualStruggle.isEmpty {
                metricRow("Spiritual battle", profile.spiritualStruggle)
            }
            if !profile.readinessResponse.isEmpty {
                metricRow("Readiness", profile.readinessResponse)
            }
            if !profile.email.isEmpty {
                metricRow("Email", profile.email)
            }
            if !profile.heardAboutSource.isEmpty {
                metricRow("Discovered from", profile.heardAboutSource)
            }
            if !profile.referralCode.isEmpty {
                metricRow("Referral code", profile.referralCode)
            }
            if !profile.selectedVersion.isEmpty {
                metricRow("Path", profile.selectedVersion == "premium" ? "Bible School" : "Studying the Bible")
            }
            if profile.selectedVersion == "premium" && !profile.selectedPremiumPlan.isEmpty {
                metricRow("Plan", premiumPlanLabel(for: profile.selectedPremiumPlan))
            }
            if profile.onboardingPotentialScore > 0 {
                metricRow("Onboarding score", "\(profile.onboardingPotentialScore)%")
            }
            if !goalsSummary(from: profile).isEmpty {
                metricRow("Selected goals", goalsSummary(from: profile))
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private func premiumPlanLabel(for plan: String) -> String {
        switch plan {
        case SubscriptionAccessManager.yearlySpecialPlanSelection:
            return "Special Yearly"
        case "yearly":
            return "Yearly"
        default:
            return "Monthly"
        }
    }

    private var oneVisioonCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("One Visioon")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Understand Scripture. Grow with Christ.")
                .font(OVTheme.heading(16))
                .foregroundStyle(OVTheme.midnight)

            infoLine("Mission", "Help people understand God's Word one chapter at a time, reflect deeply, and grow with Christ in real community.")
            infoLine("Coming next", "Life-situation study guides, Bible in a Year depth, and stronger Bible School paths.")

            Button {
                showPrivacyPolicy = true
            } label: {
                HStack {
                    Text("Open Privacy Policy")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var communityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Community")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Stay connected to what One Visioon is building and to the people growing with you.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            Link(destination: instagramURL) {
                externalLinkLabel(title: "Instagram", subtitle: "@one.visioon")
            }
            .buttonStyle(.plain)

            Link(destination: discordURL) {
                externalLinkLabel(title: "Discord", subtitle: "Join the community")
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private func infoLine(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(label):")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.58))
            Text(value.isEmpty ? "-" : value)
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
            Spacer(minLength: 0)
        }
    }

    private func metricRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
            Spacer()
            Text(value)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
                .multilineTextAlignment(.trailing)
        }
    }

    private func statusPill(_ title: String, tint: Color) -> some View {
        Text(title)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint)
            .clipShape(Capsule())
    }

    private func helperMessage(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(OVTheme.body(12))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(tint.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func goalsSummary(from profile: OnboardingAnswerSet) -> String {
        [
            profile.selectedMindsetGoal,
            profile.selectedHealthGoal,
            profile.selectedPurposeGoal,
            profile.selectedCommunityGoal
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " • ")
    }

    private func externalLinkLabel(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(OVTheme.heading(15))
                    .foregroundStyle(OVTheme.midnight)
                Text(subtitle)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.muted)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(OVTheme.midnight)
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(OVTheme.elevatedCard)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func activeProfileRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(OVTheme.midnight)
                .frame(width: 40, height: 40)
                .background(OVTheme.lemon.opacity(0.48))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.midnight)

                Text(subtitle)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.66))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(14)
        .background(OVTheme.paper.opacity(0.96))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func comingSoonProfileRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(OVTheme.midnight.opacity(0.45))
                .frame(width: 40, height: 40)
                .background(OVTheme.smoke.opacity(0.85))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.ink.opacity(0.5))

                    Text("Coming soon")
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.midnight.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(OVTheme.smoke)
                        .clipShape(Capsule())
                }

                Text(subtitle)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.46))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 8)
        }
        .padding(14)
        .background(OVTheme.smoke.opacity(0.42))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line.opacity(0.7), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .opacity(0.72)
        .accessibilityLabel("\(title), coming soon")
    }

    private func onboardingBinding(_ keyPath: WritableKeyPath<OnboardingAnswerSet, String>) -> Binding<String> {
        Binding {
            store.onboardingProfile[keyPath: keyPath]
        } set: { value in
            var profile = store.onboardingProfile
            profile[keyPath: keyPath] = value
            store.onboardingProfile = profile
        }
    }

    private func publicProfileBinding(_ keyPath: WritableKeyPath<PublicProfileSettings, String>) -> Binding<String> {
        Binding {
            store.publicProfileSettings[keyPath: keyPath]
        } set: { value in
            store.publicProfileSettings[keyPath: keyPath] = value
        }
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct ProfileSettingsView: View {
    @ObservedObject var store: SoulJourneyStore

    private let faithStageOptions = [
        "I feel far from God",
        "I'm trying, but I'm not consistent",
        "I'm growing, but I need structure",
        "I'm doing well, but I want more"
    ]

    private let cadenceOptions = [
        "Every day",
        "Most days",
        "A few times a week",
        "Only when I really need it"
    ]

    private let supportOptions = [
        "A simple plan",
        "Daily Bible guidance",
        "Real accountability",
        "Encouragement when I slip",
        "Proof that I'm making progress"
    ]

    private let spiritualStruggleOptions = StruggleSupportCatalog.spiritualStruggleTitles

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                settingsHeader
                personalDetailsCard
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Profile Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile details")
                .font(OVTheme.display(32))
                .foregroundStyle(OVTheme.midnight)

            Text("Update the basic information shown with your profile and community activity.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }

    private var personalDetailsCard: some View {
        settingsCard(title: "Personal details") {
            settingsField("Name", text: onboardingBinding(\.fullName))
            settingsField("Username", text: onboardingBinding(\.username), autocapitalization: .never)
            settingsField("Email", text: onboardingBinding(\.email), keyboardType: .emailAddress, autocapitalization: .never)
            settingsField("Age", text: onboardingBinding(\.age), keyboardType: .numberPad, autocapitalization: .never)
            settingsField("Country", text: onboardingBinding(\.country))
            settingsField("Area code", text: onboardingBinding(\.usaAreaCode), keyboardType: .numberPad, autocapitalization: .never)
        }
    }

    private var pathAnswersCard: some View {
        settingsCard(title: "Path answers") {
            settingsMenu("Faith stage", selection: onboardingBinding(\.faithStage), options: faithStageOptions)
            settingsMenu("Weekly rhythm", selection: onboardingBinding(\.weeklyCommitment), options: cadenceOptions)
            settingsMenu("Support need", selection: onboardingBinding(\.supportNeed), options: supportOptions)
            settingsMenu("Spiritual battle", selection: onboardingBinding(\.spiritualStruggle), options: spiritualStruggleOptions)
            settingsEditor("Main challenge", text: onboardingBinding(\.biggestChallenge), minHeight: 80)
            settingsEditor("Life vision", text: onboardingBinding(\.lifeVision), minHeight: 96)
        }
    }

    private var goalsCard: some View {
        settingsCard(title: "Growth goals") {
            settingsField("Mindset goal", text: onboardingBinding(\.selectedMindsetGoal))
            settingsField("Health goal", text: onboardingBinding(\.selectedHealthGoal))
            settingsField("Purpose goal", text: onboardingBinding(\.selectedPurposeGoal))
            settingsField("Community goal", text: onboardingBinding(\.selectedCommunityGoal))
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            content()
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private func settingsField(
        _ title: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .words
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            TextField(title, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func settingsEditor(_ title: String, text: Binding<String>, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            TextEditor(text: text)
                .font(OVTheme.body(14))
                .frame(minHeight: minHeight)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(OVTheme.paper.opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func settingsMenu(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection.wrappedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue.isEmpty ? "Choose" : selection.wrappedValue)
                        .font(OVTheme.heading(14))
                        .foregroundStyle(selection.wrappedValue.isEmpty ? OVTheme.ink.opacity(0.48) : OVTheme.midnight)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OVTheme.midnight.opacity(0.72))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(OVTheme.paper.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func onboardingBinding(_ keyPath: WritableKeyPath<OnboardingAnswerSet, String>) -> Binding<String> {
        Binding {
            store.onboardingProfile[keyPath: keyPath]
        } set: { value in
            var profile = store.onboardingProfile
            profile[keyPath: keyPath] = value
            store.onboardingProfile = profile
        }
    }
}

private struct HabitReflectionHistoryView: View {
    let entries: [GiftTrainingCheckIn]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Habit reflection")
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Saved reflections from your Glorify habit training.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .premiumSurfaceCard(cornerRadius: 24)

                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(shortDate(entry.updatedAt))
                            .font(OVTheme.body(12))
                            .foregroundStyle(OVTheme.gold)

                        Text(entry.reflection)
                            .font(OVTheme.body(15))
                            .foregroundStyle(OVTheme.ink.opacity(0.82))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(18)
                    .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
                }
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Habit Reflection")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct CommunityLinksView: View {
    private let instagramURL = URL(string: "https://www.instagram.com/one.visioon/")!
    private let discordURL = URL(string: "https://discord.gg/W7M4zGPtqV")!

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Community")
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Stay connected to the people growing with One Visioon.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)

                Link(destination: instagramURL) {
                    communityLinkRow(title: "Instagram", subtitle: "@one.visioon")
                }
                .buttonStyle(.plain)

                Link(destination: discordURL) {
                    communityLinkRow(title: "Discord", subtitle: "Join the community")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Community")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func communityLinkRow(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(OVTheme.heading(15))
                    .foregroundStyle(OVTheme.midnight)
                Text(subtitle)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.muted)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(OVTheme.midnight)
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(OVTheme.elevatedCard)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct AboutOneVisioonView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                aboutCard(
                    title: "Mission",
                    body: "One Visioon exists to help people understand Scripture, grow with Christ, and stay rooted in a real Christian community."
                )

                aboutCard(
                    title: "What is live",
                    body: "Full Bible access in KJV 1769, ESV, ASV, CSB, NIV, and Greek Bible, daily verse, prayer help, life-situation guides, gift discovery, Bible notes, and clean study paths."
                )

                aboutCard(
                    title: "Coming next",
                    body: "Deeper Bible School lessons, online events, local events, and more structured community spaces."
                )

                aboutCard(
                    title: "Giving",
                    body: "20% of our profits go to help people in need through future giving and support initiatives."
                )
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func aboutCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            Text(body)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 18, fill: OVTheme.elevatedCard)
    }
}

private struct ProfilePrivacyPolicySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                    policySection(
                        title: "What One Visioon Stores",
                        body: "One Visioon stores your reading progress, streaks, highlights, notes, reflections, onboarding answers, and version choice on your device so the app can remember your place and your study history."
                    )

                    policySection(
                        title: "Account Sign-In",
                        body: "One Visioon can use Sign in with Apple on this device, and it connects Apple through Supabase Auth when cloud sync is configured. If Apple shares your name or email, the app uses that information to label your account and keep it consistent."
                    )

                    policySection(
                        title: "Progress Storage",
                        body: "One Visioon keeps a local copy of your progress on this device and can also sync your key study data with Supabase when you sign in."
                    )

                    policySection(
                        title: "Bible Translation Notices",
                        body: "This build includes KJV 1769, ESV, ASV, CSB, NIV, Greek Old Testament / Septuagint, SBL Greek New Testament, and Greek word-study data with required attribution notices. Full wording is published at unovisioon.com/privacy-policy."
                    )

                    policySection(
                        title: "External Links",
                        body: "If you tap Instagram or Discord, you leave the app and continue under those services and their privacy policies."
                    )
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
        }
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            Text(body)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 18, fill: OVTheme.elevatedCard)
    }
}

private struct LeaderboardView: View {
    @ObservedObject var store: SoulJourneyStore

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                headerCard
                rowsCard
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Rankings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        let myRank = store.leaderboardEntries.firstIndex(where: { $0.isCurrentUser }).map { $0 + 1 } ?? 0

        return VStack(alignment: .leading, spacing: 10) {
            Text("Community growth ranks")
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.ink)

            Text("Ranked by wisdom points first, then lessons completed. Tiers move from Seeker to Mentor.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.7))

            HStack(spacing: 10) {
                statChip("Your Rank", myRank > 0 ? "#\(myRank)" : "-")
                statChip("Tier", store.currentGrowthTier)
                statChip("Lessons", "\(store.completedLessonsCount)")
                statChip("Points", "\(store.wisdomPoints)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.sky.opacity(0.52), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .premiumSurfaceCard(cornerRadius: 18)
    }

    private var rowsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(store.leaderboardEntries.enumerated()), id: \.element.id) { index, entry in
                leaderboardRow(entry, rank: index + 1)
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 18)
    }

    private func leaderboardRow(_ entry: SoulJourneyStore.LeaderboardEntry, rank: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("#\(rank)")
                .font(OVTheme.heading(14))
                .foregroundStyle(rank <= 3 ? OVTheme.coral : OVTheme.ink.opacity(0.65))
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(entry.displayName)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.ink)
                    if entry.isCurrentUser {
                        Text("YOU")
                            .font(OVTheme.body(10))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(OVTheme.midnight)
                            .clipShape(Capsule())
                    }
                }

                Text("Tier: \(entry.growthTier) • Level \(entry.wisdomLevel)")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(entry.lessonsCompleted) lessons")
                    .font(OVTheme.heading(13))
                    .foregroundStyle(OVTheme.midnight)
                Text("\(entry.points) pts")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }
        }
        .padding(12)
        .background(entry.isCurrentUser ? OVTheme.lemon.opacity(0.38) : OVTheme.smoke.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func statChip(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.56))
            Text(value)
                .font(OVTheme.heading(13))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct PublicProfileSettingsView: View {
    @ObservedObject var store: SoulJourneyStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                settingsToggleCard
                bioCard
                socialsCard
                visibilityPreviewCard
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Public Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var settingsToggleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Make profile public", isOn: binding(\.isPublic))
                .font(OVTheme.heading(16))

            Text("People in chat will only see what you make public here.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.6))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 16)
    }

    private var bioCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bio")
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)

            Text("Share a short public intro people can see when they tap your profile in chat.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.66))

            TextEditor(text: binding(\.testimonial))
                .font(OVTheme.body(14))
                .frame(minHeight: 120)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 16)
    }

    private var socialsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Socials")
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)

            TextField("Instagram handle", text: binding(\.instagram))
                .textFieldStyle(.roundedBorder)
            TextField("X handle", text: binding(\.xHandle))
                .textFieldStyle(.roundedBorder)
            TextField("YouTube link or handle", text: binding(\.youtube))
                .textFieldStyle(.roundedBorder)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 16)
    }

    private var visibilityPreviewCard: some View {
        let profile = store.publicProfileSettings

        return VStack(alignment: .leading, spacing: 8) {
            Text("Public preview")
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)

            Text("Name: \(store.onboardingProfile.fullName.isEmpty ? "Learner" : store.onboardingProfile.fullName)")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.midnight)

            Text(profile.isPublic ? "Visible to others" : "Private profile")
                .font(OVTheme.body(14))
                .foregroundStyle(profile.isPublic ? .green : OVTheme.ink.opacity(0.6))

            if !profile.testimonial.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Bio: \(profile.testimonial)")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.8))
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 16)
    }

    private func binding<T>(_ keyPath: WritableKeyPath<PublicProfileSettings, T>) -> Binding<T> {
        Binding {
            store.publicProfileSettings[keyPath: keyPath]
        } set: { value in
            store.publicProfileSettings[keyPath: keyPath] = value
        }
    }
}

struct WisdomStoreView: View {
    @ObservedObject var store: SoulJourneyStore

    @State private var feedback = ""

    private var purchasedCount: Int {
        store.storeItems.filter { store.isStoreItemOwned($0) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: OVTheme.cardSpacing) {
                    headerCard
                    suggestionsCard
                    itemsSection
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Wisdom store")
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text("Unlock growth packs, profile items, and practical tools with wisdom points.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.7))

            HStack(spacing: 10) {
                statChip("Points", "\(store.wisdomPoints)")
                statChip("Owned", "\(purchasedCount)")
                statChip("Items", "\(store.storeItems.count)")
            }

            if !feedback.isEmpty {
                Text(feedback)
                    .font(OVTheme.body(12))
                    .foregroundStyle(feedback.contains("Unlocked") ? .green : OVTheme.ink.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.orchid.opacity(0.5), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private func statChip(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
            Text(value)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var suggestionsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Good items to add next")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            suggestionRow("Church attendance streak booster", "Reward consistent Sunday check-ins.")
            suggestionRow("Mentor Q&A credits", "Submit private biblical wisdom questions.")
            suggestionRow("Family devotion pack", "Guided plans for couples and parents.")
            suggestionRow("Scripture memory challenges", "Gamified verse memorization tracks.")
            suggestionRow("Seasonal prayer bundles", "Advent, Lent, and mission-focused tracks.")
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 18)
    }

    private func suggestionRow(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(OVTheme.coral)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.ink)
                Text(detail)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }
            Spacer()
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(WisdomStoreCategory.allCases, id: \.self) { category in
                let items = store.storeItems.filter { $0.category == category }
                if !items.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.title)
                            .font(OVTheme.heading(20))
                            .foregroundStyle(OVTheme.ink)

                        ForEach(items) { item in
                            itemCard(item)
                        }
                    }
                }
            }
        }
    }

    private func itemCard(_ item: WisdomStoreItem) -> some View {
        let owned = store.isStoreItemOwned(item)
        let affordable = store.wisdomPoints >= item.pointsCost

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)
                    .frame(width: 34, height: 34)
                    .background(OVTheme.sky.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.ink)
                    Text(item.detail)
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                Spacer()
            }

            HStack {
                Text("\(item.pointsCost) points")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.6))

                Spacer()

                if owned {
                    Text("Owned")
                        .font(OVTheme.heading(12))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(OVTheme.mint.opacity(0.45))
                        .clipShape(Capsule())
                } else {
                    Button {
                        if store.purchaseStoreItem(item) {
                            feedback = "Unlocked \(item.name)."
                        } else {
                            feedback = "Not enough points for \(item.name)."
                        }
                    } label: {
                        Text("Unlock")
                            .font(OVTheme.heading(13))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(affordable ? OVTheme.midnight : OVTheme.ink.opacity(0.35))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!affordable)
                }
            }
        }
        .padding(14)
        .premiumSurfaceCard(cornerRadius: 14, shadowOpacity: 0.03)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: SoulJourneyStore(), showsInfoButton: false)
            .environmentObject(AuthSessionManager())
    }
}
