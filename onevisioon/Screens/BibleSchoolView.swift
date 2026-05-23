import SwiftUI
import UIKit

struct LessonLibraryView: View {
    @ObservedObject var store: SoulJourneyStore

    private let folders = LessonHubFolder.rootFolders

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: OVTheme.cardSpacing) {
                    ForEach(folders) { folder in
                        folderLink(for: folder)
                    }
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
        }
    }

    @ViewBuilder
    private func folderLink(for folder: LessonHubFolder) -> some View {
        if folder.isEnabled {
            NavigationLink {
                destinationView(for: folder.destination)
            } label: {
                LessonHubFolderButton(folder: folder)
            }
            .buttonStyle(.plain)
        } else {
            LessonHubFolderButton(folder: folder)
                .opacity(0.84)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: LessonHubDestination) -> some View {
        switch destination {
        case .oldTestament:
            LockedLessonFolderView(title: "Old Testament")
        case .newTestament:
            TestamentFolderView(title: "New Testament", books: LessonBook.newTestamentLaunchBooks)
        case .bibleInAYear:
            BibleInAYearFolderView(store: store)
        case .resetWithGod:
            ResetWithGodView(store: store)
        }
    }
}

private enum LessonHubDestination: Hashable {
    case oldTestament
    case newTestament
    case bibleInAYear
    case resetWithGod
}

private struct LessonHubFolder: Identifiable, Hashable {
    let id: String
    let title: String
    let destination: LessonHubDestination
    let isEnabled: Bool

    static let rootFolders: [LessonHubFolder] = [
        LessonHubFolder(
            id: "old-testament",
            title: "Old Testament",
            destination: .oldTestament,
            isEnabled: false
        ),
        LessonHubFolder(
            id: "new-testament",
            title: "New Testament",
            destination: .newTestament,
            isEnabled: true
        ),
        LessonHubFolder(
            id: "bible-in-a-year",
            title: "Bible in a Year",
            destination: .bibleInAYear,
            isEnabled: true
        ),
        LessonHubFolder(
            id: "reset-with-god",
            title: "7 Day Reset With God",
            destination: .resetWithGod,
            isEnabled: true
        )
    ]
}

private struct LessonBook: Identifiable, Hashable {
    let id: String
    let title: String

    static let newTestamentLaunchBooks: [LessonBook] = [
        LessonBook(id: "matthew-template", title: "Matthew"),
        LessonBook(id: "james-template", title: "James"),
        LessonBook(id: "romans-template", title: "Romans"),
        LessonBook(id: "john-template", title: "John"),
        LessonBook(id: "ephesians-template", title: "Ephesians")
    ]
}

private struct LessonTemplateSection: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
}

private struct LessonTemplateBlueprint: Hashable {
    let title: String
    let statusLine: String
    let sections: [LessonTemplateSection]

    static let chapterLesson = LessonTemplateBlueprint(
        title: "Chapter lesson template",
        statusLine: "This book is ready to be built chapter by chapter.",
        sections: [
            LessonTemplateSection(
                id: "overview",
                title: "Overview",
                detail: "Quick overview of what the chapter is about and what to watch for."
            ),
            LessonTemplateSection(
                id: "reading",
                title: "Chapter reading",
                detail: "Read the full chapter cleanly before anything else is explained."
            ),
            LessonTemplateSection(
                id: "guided-path",
                title: "Guided path",
                detail: "Simple teaching that walks through the key points in plain English."
            ),
            LessonTemplateSection(
                id: "reflection",
                title: "Reflection",
                detail: "Save what stood out, what God may be showing, and how to apply it."
            ),
            LessonTemplateSection(
                id: "sermon-depth",
                title: "Sermon depth",
                detail: "Trusted pastor insight or a clear in-house deep dive when needed."
            ),
            LessonTemplateSection(
                id: "scripture-links",
                title: "Scripture links",
                detail: "See how the same truth shows up across the rest of the Bible."
            ),
            LessonTemplateSection(
                id: "history",
                title: "History + word study",
                detail: "Important Hebrew or Greek words, the time period, and what the chapter meant then and now."
            ),
            LessonTemplateSection(
                id: "practice",
                title: "Practice",
                detail: "Finish with a quest that checks understanding and turns it into action."
            )
        ]
    )

    static let yearPath = LessonTemplateBlueprint(
        title: "Year path template",
        statusLine: "This path will be rebuilt to stay simple, steady, and easy to follow all year.",
        sections: [
            LessonTemplateSection(
                id: "reading-block",
                title: "Reading block",
                detail: "A clean daily plan that keeps the full Bible moving without rushing."
            ),
            LessonTemplateSection(
                id: "anchor-chapter",
                title: "Anchor chapter",
                detail: "One main chapter that becomes the teaching focus for that part of the year."
            ),
            LessonTemplateSection(
                id: "guided-path",
                title: "Guided path",
                detail: "Simple teaching that connects the main storyline and the big ideas."
            ),
            LessonTemplateSection(
                id: "reflection",
                title: "Reflection",
                detail: "Short guided questions that help the reading become personal and real."
            ),
            LessonTemplateSection(
                id: "scripture-links",
                title: "Scripture links",
                detail: "Cross-Bible links that help the full story stay connected."
            ),
            LessonTemplateSection(
                id: "practice",
                title: "Practice",
                detail: "A monthly check-in or quest that locks in what was learned."
            )
        ]
    )
}

private struct LessonHubFolderButton: View {
    let folder: LessonHubFolder

    var body: some View {
        HStack(spacing: 16) {
            Text(folder.title)
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 12)

            if folder.isEnabled {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)
            } else {
                Text("Coming soon")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.gold)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .premiumSurfaceCard(
            cornerRadius: 26,
            fill: folder.isEnabled ? OVTheme.elevatedCard : OVTheme.smoke.opacity(0.72),
            shadowOpacity: folder.isEnabled ? 0.06 : 0.03
        )
    }
}

private struct LockedLessonFolderView: View {
    let title: String

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Coming soon")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TestamentFolderView: View {
    let title: String
    let books: [LessonBook]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: OVTheme.cardSpacing) {
                ForEach(books) { book in
                    NavigationLink {
                        BookLessonTemplateView(book: book, blueprint: .chapterLesson)
                    } label: {
                        LessonBookRow(title: book.title)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BibleInAYearFolderView: View {
    @ObservedObject var store: SoulJourneyStore

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                NavigationLink {
                    BookLessonTemplateView(
                        book: LessonBook(id: "bible-year-template", title: "Bible in a Year"),
                        blueprint: .yearPath,
                        showsNavigationTitle: false
                    )
                } label: {
                    LessonBookRow(title: "Bible in a Year")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Bible in a Year")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LessonBookRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.midnight)

            Spacer(minLength: 12)

            Image(systemName: "arrow.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(OVTheme.midnight)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard, shadowOpacity: 0.04)
    }
}

private struct BookLessonTemplateView: View {
    let book: LessonBook
    let blueprint: LessonTemplateBlueprint
    var showsNavigationTitle: Bool = true

    var body: some View {
        VStack(spacing: OVTheme.cardSpacing) {
            LessonTemplateHeroCard(title: book.title, statusLine: blueprint.statusLine)

            VStack(spacing: 12) {
                ForEach(Array(blueprint.sections.enumerated()), id: \.element.id) { index, section in
                    LessonTemplateSectionRow(
                        number: index + 1,
                        title: section.title,
                        detail: section.detail
                    )
                }
            }
            .padding(OVTheme.cardPadding)
            .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .navigationTitle(showsNavigationTitle ? book.title : "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LessonTemplateHeroCard: View {
    let title: String
    let statusLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text("No chapter content has been added yet.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.gold)

            Text(statusLine)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private struct LessonTemplateSectionRow: View {
    let number: Int
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(String(format: "%02d", number))
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.gold)
                .frame(width: 28, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.midnight)

                Text(detail)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))
            }

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.paper.opacity(0.96), shadowOpacity: 0.03)
    }
}

struct ChapterStudyView: View {
    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson
    let hasPremiumAccess: Bool

    @State private var step: Int
    @State private var reflectionDraft: ChapterReflectionDraft
    @State private var selectedVerses: Set<String>
    @State private var feedbackMessage = ""
    @State private var feedbackIsError = false
    @State private var showingPractice = false

    private let phases = ChapterLessonPhase.allCases

    init(store: SoulJourneyStore, lesson: WisdomLesson, hasPremiumAccess: Bool) {
        self.store = store
        self.lesson = lesson
        self.hasPremiumAccess = hasPremiumAccess

        let savedDraft = store.chapterReflectionDraft(for: lesson)
        let savedStep = store.lessonStudyStep(for: lesson)
        let initialStep = min(savedStep, max(0, ChapterLessonPhase.allCases.count - 1))

        _step = State(initialValue: initialStep)
        _reflectionDraft = State(initialValue: savedDraft)
        _selectedVerses = State(initialValue: Set(savedDraft.highlightedVerses))
    }

    private var currentPhase: ChapterLessonPhase {
        phases[step]
    }

    private var referenceTarget: BibleReferenceTarget? {
        BibleDataProvider.resolveReference(from: lesson.studyReference)
    }

    private var chapter: BibleChapter? {
        referenceTarget.flatMap { BibleDataProvider.chapter(at: $0.location) }
    }

    private var sortedSelectedVerses: [String] {
        selectedVerses.sorted { lhs, rhs in
            verseSortKey(for: lhs) < verseSortKey(for: rhs)
        }
    }

    private var selectedVerseCards: [(reference: String, text: String)] {
        sortedSelectedVerses.compactMap { reference in
            guard let text = verseText(for: reference) else { return nil }
            return (reference, text)
        }
    }

    private var progressState: LessonProgress {
        store.progress(for: lesson)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                ChapterStudyHeaderCard(
                    reference: lesson.studyReference,
                    title: lesson.title,
                    completed: progressState.lessonCompleted,
                    questPassed: progressState.quizPassed
                )

                LessonPhaseRail(phases: phases, currentPhase: currentPhase)

                phaseContent

                if !feedbackMessage.isEmpty {
                    LessonFeedbackCard(
                        message: feedbackMessage,
                        isError: feedbackIsError
                    )
                }

                LessonStepFooter(
                    showsBack: step > 0,
                    primaryTitle: primaryButtonTitle,
                    onBack: goBack,
                    onNext: goForward
                )
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(lesson.studyReference)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPractice) {
            LessonPracticeView(store: store, lesson: lesson)
        }
        .onChange(of: step) { _, newValue in
            store.saveLessonStudyStep(for: lesson, step: newValue)
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch currentPhase {
        case .overview:
            OverviewPhaseCard(
                summary: lesson.summary,
                keyIdeas: Array(lesson.keyIdeas.prefix(3))
            )
        case .reading:
            ChapterReadingPhaseCard(
                chapter: chapter,
                selectedVerses: selectedVerses,
                onToggleVerse: toggleVerseSelection
            )
        case .guidedPath:
            GuidedPathPhaseCard(
                title: guidedPathTitle,
                points: guidedPathPoints
            )
        case .reflection:
            ReflectionPhaseCard(
                draft: $reflectionDraft,
                selectedVerseCards: selectedVerseCards
            )
        case .sermonDepth:
            GuidedPathPhaseCard(
                title: "Sermon depth",
                points: sermonDepthPoints
            )
        case .scriptureLinks:
            ScriptureLinksPhaseCard(links: scriptureLinks)
        case .history:
            HistoryPhaseCard(items: historyNotes)
        case .practice:
            PracticePhaseCard(
                steps: practiceSteps,
                questPassed: progressState.quizPassed,
                onOpenPractice: {
                    showingPractice = true
                }
            )
        }
    }

    private var primaryButtonTitle: String {
        currentPhase == .practice ? "Open practice" : "Next"
    }

    private var guidedPathTitle: String {
        hasPremiumAccess ? "Guided path" : "Guided path"
    }

    private var guidedPathPoints: [String] {
        let seed = lesson.keyIdeas.isEmpty ? [lesson.summary] : lesson.keyIdeas
        return seed.prefix(4).enumerated().map { index, idea in
            "\(index + 1). \(idea)"
        }
    }

    private var sermonDepthPoints: [String] {
        [
            "This section will hold trusted sermon help for \(lesson.studyReference) as the book is built.",
            "For now, stay close to the chapter itself and trace the main truth through the guided path before you move on.",
            "When this chapter is fully built, this screen will carry deeper teaching in simple English instead of filler."
        ]
    }

    private var scriptureLinks: [ScriptureLinkItem] {
        let references = lesson.keyVerses.isEmpty ? [lesson.studyReference] : lesson.keyVerses
        return references.map { reference in
            ScriptureLinkItem(
                reference: reference,
                summary: verseText(for: reference) ?? "This verse will be linked here with its chapter context as the lesson is built."
            )
        }
    }

    private var historyNotes: [HistoryNote] {
        let isNewTestament = BibleDataProvider.newTestamentBooks.contains { $0.name == referenceTarget?.location.book }
        let language = isNewTestament ? "Greek" : "Hebrew"

        return [
            HistoryNote(
                title: "Original language",
                detail: "This section will highlight the most important \(language) words in \(lesson.studyReference) once the chapter is fully built."
            ),
            HistoryNote(
                title: "Setting",
                detail: "The final lesson will explain who first heard this chapter, what was happening around them, and why that changes how we read it."
            ),
            HistoryNote(
                title: "Then and now",
                detail: "This part will connect the original meaning to today so the chapter stays faithful to Scripture and useful in real life."
            )
        ]
    }

    private var practiceSteps: [String] {
        [
            "Name the main truth from this chapter in one line.",
            "Pick one real action you can obey today.",
            "Use the quest to check what actually stayed with you."
        ]
    }

    private func goBack() {
        guard step > 0 else { return }
        step -= 1
    }

    private func goForward() {
        switch currentPhase {
        case .reflection:
            saveReflectionIfPossible()
        case .practice:
            showingPractice = true
        default:
            advanceStep()
        }
    }

    private func advanceStep() {
        guard step < phases.count - 1 else { return }
        step += 1
        feedbackMessage = ""
    }

    private func saveReflectionIfPossible() {
        let draft = ChapterReflectionDraft(
            highlightedVerses: sortedSelectedVerses,
            stoodOut: reflectionDraft.stoodOut,
            godMessage: reflectionDraft.godMessage,
            application: reflectionDraft.application,
            learned: reflectionDraft.learned,
            questions: reflectionDraft.questions
        )

        let result = store.saveChapterReflection(for: lesson, draft: draft)
        guard result.saved else {
            feedbackIsError = true
            feedbackMessage = "Fill out what stood out, what God may be showing, and how you will apply it."
            return
        }

        store.markLessonCompleted(lesson)
        feedbackIsError = false
        feedbackMessage = result.pointsEarned > 0 ? "Reflection saved. +\(result.pointsEarned) points" : "Reflection updated."
        advanceStep()
    }

    private func toggleVerseSelection(_ reference: String) {
        if selectedVerses.contains(reference) {
            selectedVerses.remove(reference)
        } else {
            selectedVerses.insert(reference)
        }
    }

    private func verseText(for reference: String) -> String? {
        guard let target = BibleDataProvider.resolveReference(from: reference),
              let verseNumber = target.verse,
              let verse = BibleDataProvider.chapter(at: target.location)?.verses.first(where: { $0.verse == verseNumber }) else {
            return nil
        }
        return verse.text
    }

    private func verseSortKey(for reference: String) -> String {
        guard let target = BibleDataProvider.resolveReference(from: reference) else {
            return reference
        }

        let bookIndex = BibleDataProvider.canonicalBookOrder.firstIndex(of: target.location.book) ?? .max
        let verseNumber = target.verse ?? .max
        return "\(bookIndex)-\(target.location.chapter)-\(verseNumber)"
    }
}

private enum ChapterLessonPhase: String, CaseIterable, Identifiable {
    case overview
    case reading
    case guidedPath
    case reflection
    case sermonDepth
    case scriptureLinks
    case history
    case practice

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview:
            return "Overview"
        case .reading:
            return "Reading"
        case .guidedPath:
            return "Guided path"
        case .reflection:
            return "Reflection"
        case .sermonDepth:
            return "Sermon depth"
        case .scriptureLinks:
            return "Scripture links"
        case .history:
            return "History"
        case .practice:
            return "Practice"
        }
    }
}

private struct ChapterStudyHeaderCard: View {
    let reference: String
    let title: String
    let completed: Bool
    let questPassed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(reference.uppercased())
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(title)
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)
                }

                Spacer(minLength: 12)

                VStack(spacing: 8) {
                    StatusBadge(title: completed ? "Saved" : "In progress")
                    if questPassed {
                        StatusBadge(title: "Practice passed")
                    }
                }
            }

            Text("Overview, chapter reading, guided depth, reflection, Scripture links, history, and practice all stay in one clean path.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private struct StatusBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.96))
            .clipShape(Capsule())
    }
}

private struct LessonPhaseRail: View {
    let phases: [ChapterLessonPhase]
    let currentPhase: ChapterLessonPhase

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                    Text("\(index + 1). \(phase.title)")
                        .font(OVTheme.body(12))
                        .foregroundStyle(phase == currentPhase ? .white : OVTheme.midnight)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(phase == currentPhase ? OVTheme.midnight : .white.opacity(0.95))
                        .clipShape(Capsule())
                }
            }
            .padding(4)
        }
    }
}

private struct OverviewPhaseCard: View {
    let summary: String
    let keyIdeas: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(summary)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            VStack(spacing: 12) {
                ForEach(Array(keyIdeas.enumerated()), id: \.offset) { index, idea in
                    LessonPointRow(number: index + 1, text: idea)
                }
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private struct LessonPointRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(format: "%02d", number))
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.gold)
                .frame(width: 28, alignment: .leading)

            Text(text)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            Spacer(minLength: 0)
        }
        .padding(16)
        .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.paper.opacity(0.96), shadowOpacity: 0.03)
    }
}

private struct ChapterReadingPhaseCard: View {
    let chapter: BibleChapter?
    let selectedVerses: Set<String>
    let onToggleVerse: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let chapter {
                ForEach(chapter.verses) { verse in
                    let reference = "\(chapter.book) \(chapter.chapter):\(verse.verse)"
                    SelectableVerseCard(
                        number: verse.verse,
                        text: verse.text,
                        isSelected: selectedVerses.contains(reference),
                        onTap: {
                            onToggleVerse(reference)
                        }
                    )
                }
            } else {
                Text("Chapter text will appear here once this lesson is fully built.")
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
                    .padding(OVTheme.cardPadding)
                    .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
            }
        }
    }
}

private struct SelectableVerseCard: View {
    let number: Int
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                Text("\(number)")
                    .font(OVTheme.heading(16))
                    .foregroundStyle(isSelected ? OVTheme.midnight : OVTheme.gold)
                    .frame(width: 26, alignment: .leading)

                Text(text)
                    .font(OVTheme.body(16))
                    .foregroundStyle(OVTheme.ink.opacity(0.82))
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .premiumSurfaceCard(
                cornerRadius: 22,
                fill: isSelected ? OVTheme.lemon.opacity(0.34) : OVTheme.elevatedCard,
                shadowOpacity: isSelected ? 0.05 : 0.03
            )
        }
        .buttonStyle(.plain)
    }
}

private struct GuidedPathPhaseCard: View {
    let title: String
    let points: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.midnight)

            VStack(spacing: 12) {
                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    LessonPointRow(number: index + 1, text: point)
                }
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private struct ReflectionPhaseCard: View {
    @Binding var draft: ChapterReflectionDraft
    let selectedVerseCards: [(reference: String, text: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !selectedVerseCards.isEmpty {
                VStack(spacing: 10) {
                    ForEach(selectedVerseCards, id: \.reference) { verse in
                        SelectedVersePreviewCard(reference: verse.reference, text: verse.text)
                    }
                }
            }

            ReflectionInputCard(
                title: "What stood out to you?",
                text: $draft.stoodOut,
                required: true
            )

            ReflectionInputCard(
                title: "What do you think God may be showing you here?",
                text: $draft.godMessage,
                required: true
            )

            ReflectionInputCard(
                title: "How will you apply this today?",
                text: $draft.application,
                required: true
            )

            ReflectionInputCard(
                title: "What did you learn?",
                text: $draft.learned,
                required: false
            )

            ReflectionInputCard(
                title: "What questions do you still have?",
                text: $draft.questions,
                required: false
            )
        }
    }
}

private struct SelectedVersePreviewCard: View {
    let reference: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reference)
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.gold)

            Text(text)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.paper.opacity(0.97), shadowOpacity: 0.03)
    }
}

private struct ReflectionInputCard: View {
    let title: String
    @Binding var text: String
    let required: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(title)
                    .font(OVTheme.heading(17))
                    .foregroundStyle(OVTheme.midnight)

                if required {
                    Text("Required")
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.gold)
                }
            }

            TextEditor(text: $text)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundStyle(OVTheme.ink)
                .frame(minHeight: 110)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(OVTheme.paper.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private struct ScriptureLinkItem: Identifiable, Hashable {
    let id = UUID()
    let reference: String
    let summary: String
}

private struct ScriptureLinksPhaseCard: View {
    let links: [ScriptureLinkItem]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(links) { link in
                VStack(alignment: .leading, spacing: 8) {
                    Text(link.reference)
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(link.summary)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.78))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
            }
        }
    }
}

private struct HistoryNote: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct HistoryPhaseCard: View {
    let items: [HistoryNote]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(OVTheme.heading(18))
                        .foregroundStyle(OVTheme.midnight)

                    Text(item.detail)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
            }
        }
    }
}

private struct PracticePhaseCard: View {
    let steps: [String]
    let questPassed: Bool
    let onOpenPractice: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    LessonPointRow(number: index + 1, text: step)
                }
            }

            Button(action: onOpenPractice) {
                HStack {
                    Text(questPassed ? "Review practice" : "Open practice")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(OVTheme.midnight)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private struct LessonFeedbackCard: View {
    let message: String
    let isError: Bool

    var body: some View {
        Text(message)
            .font(OVTheme.body(13))
            .foregroundStyle(isError ? Color.red : OVTheme.midnight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .premiumSurfaceCard(
                cornerRadius: 18,
                fill: isError ? Color.red.opacity(0.08) : OVTheme.paper.opacity(0.96),
                shadowOpacity: 0.01
            )
    }
}

private struct LessonStepFooter: View {
    let showsBack: Bool
    let primaryTitle: String
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if showsBack {
                Button(action: onBack) {
                    Text("Back")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.midnight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.white.opacity(0.95))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button(action: onNext) {
                Text(primaryTitle)
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct LessonPracticeView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson

    @State private var answers: [String: Int] = [:]
    @State private var result: QuestSubmissionResult?

    private var quest: WisdomQuest {
        lesson.assessmentQuest
    }

    private var allAnswered: Bool {
        answers.count == quest.questions.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: OVTheme.cardSpacing) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Practice")
                            .font(OVTheme.display(30))
                            .foregroundStyle(OVTheme.midnight)

                        Text("Keep the chapter honest. Answer the questions, see what stayed with you, and then keep building from there.")
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.74))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(OVTheme.cardPadding)
                    .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)

                    ForEach(quest.questions) { question in
                        QuestQuestionCard(
                            question: question,
                            selectedIndex: answers[question.id],
                            revealAnswer: result != nil,
                            onSelect: { index in
                                answers[question.id] = index
                            }
                        )
                    }

                    if let result {
                        QuestResultCard(result: result)
                    }

                    Button(action: submitOrClose) {
                        Text(result == nil ? "Submit" : "Done")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background((allAnswered || result != nil) ? OVTheme.midnight : OVTheme.ink.opacity(0.35))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!allAnswered && result == nil)
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle(lesson.studyReference)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submitOrClose() {
        if result != nil {
            dismiss()
            return
        }

        result = store.submitQuest(for: lesson, answers: answers)
    }
}

private struct QuestQuestionCard: View {
    let question: WisdomQuestion
    let selectedIndex: Int?
    let revealAnswer: Bool
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(question.prompt)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            VStack(spacing: 10) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        guard !revealAnswer else { return }
                        onSelect(index)
                    }) {
                        HStack(spacing: 12) {
                            Text(option)
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.82))
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if selectedIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(OVTheme.gold)
                            } else if revealAnswer && question.correctIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .premiumSurfaceCard(
                            cornerRadius: 18,
                            fill: fillColor(for: index),
                            shadowOpacity: 0.02
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if revealAnswer {
                Text(question.explanation)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }

    private func fillColor(for index: Int) -> Color {
        if revealAnswer && question.correctIndex == index {
            return Color.green.opacity(0.14)
        }

        if selectedIndex == index {
            return OVTheme.lemon.opacity(0.28)
        }

        return OVTheme.paper.opacity(0.96)
    }
}

private struct QuestResultCard: View {
    let result: QuestSubmissionResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(result.passed ? "Practice passed" : "Practice complete")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.midnight)

            Text("Score: \(result.score)% • \(result.correctAnswers) of \(result.totalQuestions) right")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            if result.pointsEarned > 0 {
                Text("+\(result.pointsEarned) points")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.gold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }
}

private extension WisdomLesson {
    var studyReference: String {
        sourceName.replacingOccurrences(of: "Bible: ", with: "")
    }
}

struct LessonLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LessonLibraryView(
            store: SoulJourneyStore()
        )
    }
}
