import SwiftUI

struct StruggleSupportView: View {
    @ObservedObject var store: SoulJourneyStore

    @AppStorage("ov_freedom_focus_quiz_completed") private var hasCompletedFocusQuiz = false

    private var topic: StruggleSupportTopic {
        StruggleSupportCatalog.selectedTopic(for: store.onboardingProfile)
    }

    private var guide: LifeSituationGuide {
        LifeSituationGuide.all.first(where: { $0.id == topic.guideID }) ?? LifeSituationGuide.all[0]
    }

    var body: some View {
        Group {
            if hasCompletedFocusQuiz {
                ScrollView {
                    VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                        heroCard
                        overviewCard
                        scriptureCard
                        coursePreviewCard
                        changeButton
                    }
                    .padding(.horizontal, OVTheme.screenHorizontalPadding)
                    .padding(.vertical, OVTheme.screenVerticalPadding)
                }
            } else {
                FreedomFocusQuizView { selection in
                    store.updateFocusedStruggle(selection)
                    hasCompletedFocusQuiz = true
                }
            }
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Freedom")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(topic.accent.opacity(0.28))
                        .frame(width: 56, height: 56)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Your daily helper")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(topic.title)
                        .font(OVTheme.display(32))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Scripture, prayer, and one faithful next step for the area you chose.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))
                }
            }

            HStack(spacing: 8) {
                supportChip("Scripture")
                supportChip("Prayer")
                supportChip("Daily guidance")
            }
        }
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [topic.accent.opacity(0.24), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .premiumSurfaceCard(cornerRadius: 24)
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How we will walk through this")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(topic.overview)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            Text(topic.planLine)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.midnight)
                .padding(14)
                .background(topic.accent.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                ForEach(topic.actionSteps, id: \.self) { step in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(OVTheme.gold)

                        Text(step)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.78))
                    }
                }
            }

            Text(topic.prayer)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.82))
                .padding(16)
                .background(OVTheme.paper)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var scriptureCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start with Scripture")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(topic.verseReferences, id: \.self) { reference in
                if let verse = StruggleSupportVerse(reference: reference) {
                    NavigationLink {
                        BibleChapterReaderView(store: store, target: verse.target)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(verse.reference)
                                    .font(OVTheme.heading(15))
                                    .foregroundStyle(OVTheme.midnight)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(OVTheme.midnight)
                            }

                            Text(verse.text)
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.78))
                                .lineLimit(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(topic.accent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(OVTheme.line, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            NavigationLink {
                LifeSituationGuideDetailView(store: store, guide: guide)
            } label: {
                HStack {
                    Text("Open full Scripture guide")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var coursePreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Full course")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.courseTitle)
                        .font(OVTheme.heading(18))
                        .foregroundStyle(OVTheme.midnight)

                    Text("A deeper chapter-by-chapter path is coming soon.")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.68))
                }

                Spacer()

                Text("Coming soon")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.gold)
            }
            .padding(16)
            .background(OVTheme.smoke.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .opacity(0.86)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22)
    }

    private var changeButton: some View {
        Button {
            hasCompletedFocusQuiz = false
        } label: {
            Text("Retake the Freedom focus quiz")
                .font(OVTheme.heading(15))
                .foregroundStyle(OVTheme.midnight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(OVTheme.paper)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func supportChip(_ title: String) -> some View {
        Text(title)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
    }
}

private struct FreedomFocusQuizView: View {
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Freedom focus quiz")
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("What do you most want God’s help with right now?")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text("Choose the most honest answer. Freedom will use it to open the right Scripture, prayer, and next step.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)

                focusSection(title: "Life and mind", options: StruggleSupportCatalog.currentStruggleTitles)
                focusSection(title: "Spiritual patterns", options: StruggleSupportCatalog.spiritualStruggleTitles)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
    }

    private func focusSection(title: String, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack(spacing: 12) {
                        Text(displayTitle(for: option))
                            .font(OVTheme.body(15))
                            .foregroundStyle(OVTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OVTheme.midnight)
                    }
                    .padding(15)
                    .background(OVTheme.paper)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
    }

    private func displayTitle(for title: String) -> String {
        StruggleSupportCatalog.topic(matching: title)?.title ?? title
    }
}

private struct ChangeStruggleSheet: View {
    @ObservedObject var store: SoulJourneyStore
    @Environment(\.dismiss) private var dismiss

    private var selectedTitle: String {
        StruggleSupportCatalog.selectedTopic(for: store.onboardingProfile).title
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose the area you want daily help with right now.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                        .padding(.bottom, 6)

                    ForEach(StruggleSupportCatalog.allSelectionTitles, id: \.self) { title in
                        Button {
                            store.updateFocusedStruggle(title)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(displayTitle(for: title))
                                        .font(OVTheme.heading(16))
                                        .foregroundStyle(OVTheme.ink)

                                    if let topic = StruggleSupportCatalog.topic(matching: title) {
                                        Text(topic.planLine)
                                            .font(OVTheme.body(12))
                                            .foregroundStyle(OVTheme.ink.opacity(0.62))
                                            .lineLimit(2)
                                    }
                                }

                                Spacer()

                                if isSelected(title) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(OVTheme.gold)
                                }
                            }
                            .padding(15)
                            .background(isSelected(title) ? OVTheme.lemon.opacity(0.3) : OVTheme.elevatedCard)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Change Struggle")
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

    private func displayTitle(for title: String) -> String {
        StruggleSupportCatalog.topic(matching: title)?.title ?? title
    }

    private func isSelected(_ title: String) -> Bool {
        guard let topic = StruggleSupportCatalog.topic(matching: title) else {
            return title == selectedTitle
        }

        return topic.title == selectedTitle
    }
}

private struct StruggleSupportVerse {
    let reference: String
    let text: String
    let target: BibleReferenceTarget

    init?(reference: String) {
        guard let target = BibleDataProvider.resolveReference(from: reference),
              let chapter = BibleDataProvider.chapter(at: target.location),
              let verseNumber = target.verse,
              let verse = chapter.verses.first(where: { $0.verse == verseNumber }) else {
            return nil
        }

        self.reference = reference
        self.text = verse.text
        self.target = target
    }
}

private extension StruggleSupportTopic {
    var accent: Color {
        Color(hex: accentHex)
    }
}
