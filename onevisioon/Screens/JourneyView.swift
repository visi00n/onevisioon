import SwiftUI

struct ProfileView: View {
    @ObservedObject var store: SoulJourneyStore

    @State private var notesQuery = ""

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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    profileHeader
                    publicProfileCard
                    accountStatusCard
                    progressCard
                    identityBadgesCard
                    leaderboardCard
                    notesCard
                    learningProfileCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.onboardingProfile.fullName.isEmpty ? "Learner" : store.onboardingProfile.fullName)
                .font(OVTheme.display(40))
                .foregroundStyle(OVTheme.midnight)

            Text(personalStatement)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.ink)

            HStack(spacing: 8) {
                badge("Tier", store.currentGrowthTier)
                badge("Streak", "\(store.currentStreak) day\(store.currentStreak == 1 ? "" : "s")")
                badge("Days", "\(store.totalActiveDays)")
            }

            if !store.onboardingProfile.selectedVersion.isEmpty {
                Text("Path: \(store.onboardingProfile.selectedVersion == "premium" ? "Bible School" : "Studying the Bible")")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.62), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var accountStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Account & sync")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Sign in with Apple is live through About > Account. Your study progress is currently saved on this device while Apple handles your account identity.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            if !store.onboardingProfile.email.isEmpty {
                metricRow("Newsletter email", store.onboardingProfile.email)
            }

            metricRow("Sync status", "Apple on-device sign-in live")
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var learningProfileCard: some View {
        let profile = store.onboardingProfile

        return VStack(alignment: .leading, spacing: 10) {
            Text("Path settings")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            metricRow("Faith stage", profile.faithStage)
            metricRow("Main challenge", profile.biggestChallenge)
            metricRow("Scripture rhythm", profile.scriptureRhythm)
            metricRow("Prayer rhythm", profile.prayerRhythm)
            if !profile.email.isEmpty {
                metricRow("Email", profile.email)
            }
            if !profile.selectedVersion.isEmpty {
                metricRow("Path", profile.selectedVersion == "premium" ? "Bible School" : "Studying the Bible")
            }
            if profile.selectedVersion == "premium" && !profile.selectedPremiumPlan.isEmpty {
                metricRow("Plan", profile.selectedPremiumPlan == "yearly" ? "Yearly" : "Monthly")
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct LeaderboardView: View {
    @ObservedObject var store: SoulJourneyStore

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerCard
                rowsCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
        .padding(16)
        .background(
            LinearGradient(
                colors: [OVTheme.sky.opacity(0.52), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var rowsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(store.leaderboardEntries.enumerated()), id: \.element.id) { index, entry in
                leaderboardRow(entry, rank: index + 1)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
            VStack(alignment: .leading, spacing: 14) {
                settingsToggleCard
                testimonialCard
                socialsCard
                visibilityPreviewCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Public Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var settingsToggleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Make profile public", isOn: binding(\.isPublic))
                .font(OVTheme.heading(16))

            Toggle("Show wisdom level publicly", isOn: binding(\.showWisdomLevel))
                .font(OVTheme.body(15))
                .disabled(!store.publicProfileSettings.isPublic)
                .opacity(store.publicProfileSettings.isPublic ? 1 : 0.55)

            Text("Changes save automatically.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.6))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var testimonialCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bio / Testimonial")
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)

            TextEditor(text: binding(\.testimonial))
                .font(OVTheme.body(14))
                .frame(minHeight: 120)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

            if profile.isPublic && profile.showWisdomLevel {
                Text("Wisdom level shown: Level \(store.wisdomLevel)")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.8))
            }

            if !profile.testimonial.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Testimonial: \(profile.testimonial)")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.8))
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                VStack(spacing: 18) {
                    headerCard
                    suggestionsCard
                    itemsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
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
        .padding(20)
        .background(
            LinearGradient(
                colors: [OVTheme.orchid.opacity(0.5), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: SoulJourneyStore())
    }
}
