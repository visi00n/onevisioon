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
            TestamentFolderView(
                store: store,
                title: "New Testament",
                books: LessonBook.newTestamentBooks
            )
        case .bibleInAYear:
            BibleInAYearFolderView(store: store)
        case .resetWithGod:
            ResetWithGodView(store: store)
        case .freedom:
            StruggleSupportView(store: store)
        }
    }
}

private enum LessonHubDestination: Hashable {
    case oldTestament
    case newTestament
    case bibleInAYear
    case resetWithGod
    case freedom
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
            isEnabled: false
        ),
        LessonHubFolder(
            id: "reset-with-god",
            title: "7 Day Reset With God",
            destination: .resetWithGod,
            isEnabled: false
        ),
        LessonHubFolder(
            id: "freedom",
            title: "Freedom",
            destination: .freedom,
            isEnabled: true
        )
    ]
}

private struct LessonBook: Identifiable, Hashable {
    let id: String
    let title: String
    let isEnabled: Bool

    static let newTestamentBooks: [LessonBook] = [
        LessonBook(id: "matthew", title: "Matthew", isEnabled: true),
        LessonBook(id: "mark", title: "Mark", isEnabled: true),
        LessonBook(id: "luke", title: "Luke", isEnabled: true),
        LessonBook(id: "john", title: "John", isEnabled: true),
        LessonBook(id: "acts", title: "Acts", isEnabled: true),
        LessonBook(id: "romans", title: "Romans", isEnabled: true),
        LessonBook(id: "1-corinthians", title: "1 Corinthians", isEnabled: true),
        LessonBook(id: "2-corinthians", title: "2 Corinthians", isEnabled: false),
        LessonBook(id: "galatians", title: "Galatians", isEnabled: false),
        LessonBook(id: "ephesians", title: "Ephesians", isEnabled: false),
        LessonBook(id: "philippians", title: "Philippians", isEnabled: false),
        LessonBook(id: "colossians", title: "Colossians", isEnabled: false),
        LessonBook(id: "1-thessalonians", title: "1 Thessalonians", isEnabled: false),
        LessonBook(id: "2-thessalonians", title: "2 Thessalonians", isEnabled: false),
        LessonBook(id: "1-timothy", title: "1 Timothy", isEnabled: false),
        LessonBook(id: "2-timothy", title: "2 Timothy", isEnabled: false),
        LessonBook(id: "titus", title: "Titus", isEnabled: false),
        LessonBook(id: "philemon", title: "Philemon", isEnabled: false),
        LessonBook(id: "hebrews", title: "Hebrews", isEnabled: false),
        LessonBook(id: "james", title: "James", isEnabled: true),
        LessonBook(id: "1-peter", title: "1 Peter", isEnabled: false),
        LessonBook(id: "2-peter", title: "2 Peter", isEnabled: false),
        LessonBook(id: "1-john", title: "1 John", isEnabled: false),
        LessonBook(id: "2-john", title: "2 John", isEnabled: false),
        LessonBook(id: "3-john", title: "3 John", isEnabled: false),
        LessonBook(id: "jude", title: "Jude", isEnabled: false),
        LessonBook(id: "revelation", title: "Revelation", isEnabled: false)
    ]
}

private struct LessonChapter: Identifiable, Hashable {
    let id: String
    let title: String
    let reference: String
    let chapterNumber: Int
    let isEnabled: Bool

    static let matthewChapters: [LessonChapter] = (1...28).map { chapter in
        LessonChapter(
            id: "matthew-\(chapter)",
            title: "Chapter \(chapter)",
            reference: "Matthew \(chapter)",
            chapterNumber: chapter,
            isEnabled: true
        )
    }

    static func chapters(for book: LessonBook) -> [LessonChapter] {
        let chapterCount = BibleDataProvider.book(named: book.title, version: .esv)?.chapterCount ?? 0
        guard chapterCount > 0 else { return [] }

        return (1...chapterCount).map { chapter in
            LessonChapter(
                id: "\(book.id)-\(chapter)",
                title: "Chapter \(chapter)",
                reference: "\(book.title) \(chapter)",
                chapterNumber: chapter,
                isEnabled: true
            )
        }
    }
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
                id: "sermon",
                title: "Sermon",
                detail: "A longer chapter sermon that teaches, convicts, and connects the chapter with the rest of Scripture."
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
    @ObservedObject var store: SoulJourneyStore
    let title: String
    let books: [LessonBook]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: OVTheme.cardSpacing) {
                ForEach(books) { book in
                    if book.isEnabled {
                        NavigationLink {
                            destinationView(for: book)
                        } label: {
                            LessonBookRow(
                                title: book.title,
                                subtitle: "Open chapter lessons",
                                isEnabled: true
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        LessonBookRow(
                            title: book.title,
                            subtitle: "Coming chapter-by-chapter soon",
                            isEnabled: false
                        )
                    }
                }
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func destinationView(for book: LessonBook) -> some View {
        if LessonLibraryContent.supportsBook(id: book.id) {
            NewTestamentBookChapterFolderView(store: store, book: book)
        } else {
            LockedLessonFolderView(title: book.title)
        }
    }
}

private struct NewTestamentBookChapterFolderView: View {
    @ObservedObject var store: SoulJourneyStore
    let book: LessonBook

    private var chapters: [LessonChapter] {
        LessonChapter.chapters(for: book)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Every chapter lesson is visible. Pass each chapter quest with 75% or higher to unlock the next chapter in \(book.title).")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)

                ForEach(chapters) { chapter in
                    let lesson = LessonLibraryContent.lesson(for: book.id, chapterNumber: chapter.chapterNumber)
                    let isUnlocked = store.isLessonUnlocked(lesson)

                    if isUnlocked {
                        NavigationLink {
                            ChapterStudyView(
                                store: store,
                                lesson: lesson
                            )
                        } label: {
                            LessonBookRow(
                                title: chapter.title,
                                subtitle: chapterSubtitle(for: lesson),
                                isEnabled: true
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        LessonBookRow(
                            title: chapter.title,
                            subtitle: lockedSubtitle(for: chapter),
                            isEnabled: false,
                            lockedText: "Locked"
                        )
                    }
                }
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chapterSubtitle(for lesson: WisdomLesson) -> String {
        let progress = store.progress(for: lesson)
        if progress.quizPassed {
            return "\(lesson.studyReference) • Quest passed"
        }
        if progress.lessonCompleted {
            return "\(lesson.studyReference) • Quest ready"
        }
        return lesson.studyReference
    }

    private func lockedSubtitle(for chapter: LessonChapter) -> String {
        guard chapter.chapterNumber > 1 else { return chapter.reference }
        return "Pass Chapter \(chapter.chapterNumber - 1) quest with 75%+"
    }
}

private struct BibleInAYearFolderView: View {
    @ObservedObject var store: SoulJourneyStore

    private var lessons: [WisdomLesson] {
        store.lessons(for: store.yearCourse)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Bible in a Year")
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Twelve monthly checkpoints keep the full Bible storyline clear while you read. Pass each quest with 75% or higher to unlock the next month.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)

                ForEach(lessons) { lesson in
                    let isUnlocked = store.isLessonUnlocked(lesson)

                    if isUnlocked {
                        NavigationLink {
                            ChapterStudyView(
                                store: store,
                                lesson: lesson
                            )
                        } label: {
                            LessonBookRow(
                                title: "Month \(lesson.order)",
                                subtitle: chapterSubtitle(for: lesson),
                                isEnabled: true
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        LessonBookRow(
                            title: "Month \(lesson.order)",
                            subtitle: lockedSubtitle(for: lesson),
                            isEnabled: false,
                            lockedText: "Locked"
                        )
                    }
                }
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Bible in a Year")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chapterSubtitle(for lesson: WisdomLesson) -> String {
        let progress = store.progress(for: lesson)
        if progress.quizPassed {
            return "\(lesson.studyReference) • Quest passed"
        }
        if progress.lessonCompleted {
            return "\(lesson.studyReference) • Quest ready"
        }
        return lesson.title
    }

    private func lockedSubtitle(for lesson: WisdomLesson) -> String {
        guard lesson.order > 1 else { return lesson.title }
        return "Pass Month \(lesson.order - 1) quest with 75%+"
    }
}

private struct LessonBookRow: View {
    let title: String
    var subtitle: String? = nil
    var isEnabled: Bool = true
    var lockedText: String = "Coming soon"

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(OVTheme.heading(24))
                    .foregroundStyle(OVTheme.midnight)

                if let subtitle {
                    Text(subtitle)
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.64))
                }
            }

            Spacer(minLength: 12)

            if isEnabled {
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)
            } else {
                Text(lockedText)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.gold)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .premiumSurfaceCard(
            cornerRadius: 24,
            fill: isEnabled ? OVTheme.elevatedCard : OVTheme.smoke.opacity(0.7),
            shadowOpacity: isEnabled ? 0.04 : 0.02
        )
        .opacity(isEnabled ? 1 : 0.82)
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

private struct WordStudyInsight: Identifiable, Hashable {
    let reference: String
    let language: String
    let word: String
    let transliteration: String
    let meaning: String
    let deeperNote: String

    var id: String {
        "\(reference)-\(word.lowercased())-\(transliteration.lowercased())"
    }
}

private struct ScriptureLinkContent: Hashable {
    let reference: String
    let summary: String
}

private struct HistoryNoteContent: Hashable {
    let title: String
    let detail: String
}

private struct LessonChapterContent: Hashable {
    let guidedPathPoints: [String]
    let sermonPoints: [String]
    let scriptureLinks: [ScriptureLinkContent]
    let historyNotes: [HistoryNoteContent]
    let practiceSteps: [String]
    let wordInsightsByReference: [String: [WordStudyInsight]]
}

private struct MatthewLessonSeed: Hashable {
    let chapter: Int
    let title: String
    let movement: String
    let keyTruth: String
    let application: String
    let sermonFocus: String
    let keyVerses: [String]
    let scriptureLinks: [ScriptureLinkContent]
    let historyNotes: [HistoryNoteContent]
    let wordInsights: [WordStudyInsight]
}

private struct NTChapterLessonProfile: Hashable {
    let chapter: Int
    let title: String
    let movement: String
    let keyTruth: String
    let application: String
    let sermonFocus: String
}

private struct NTBookLessonPlan: Hashable {
    let id: String
    let name: String
    let authorNote: String
    let audienceNote: String
    let historyFrame: String
    let theologicalLens: String
    let convictionThread: String
    let discipleshipThread: String
    let scriptureLinks: [ScriptureLinkContent]
    let chapters: [NTChapterLessonProfile]

    var chapterCount: Int { chapters.count }
}

enum LessonLibraryContent {
    static func supportsBook(id: String) -> Bool {
        id == "matthew" || id == "james" || ntBookPlansByID[id] != nil
    }

    static func nextChapterLesson(after lesson: WisdomLesson) -> WisdomLesson? {
        guard let current = chapterLessonParts(from: lesson.id) else { return nil }
        let nextChapter = current.chapter + 1

        guard hasLesson(bookID: current.bookID, chapterNumber: nextChapter) else {
            return nil
        }

        return Self.lesson(for: current.bookID, chapterNumber: nextChapter)
    }

    static func lesson(for bookID: String, chapterNumber: Int) -> WisdomLesson {
        if bookID == "matthew" {
            return matthewLesson(for: chapterNumber)
        }

        if bookID == "james" {
            return WisdomCourse.jamesBibleSchool.lessons.first(where: { $0.order == chapterNumber })
                ?? WisdomCourse.jamesBibleSchool.lessons.first
                ?? matthewLesson(for: 1)
        }

        guard let plan = ntBookPlansByID[bookID],
              let profile = plan.chapters.first(where: { $0.chapter == chapterNumber }) else {
            return matthewLesson(for: 1)
        }

        return lesson(from: profile, plan: plan)
    }

    fileprivate static func content(for lessonID: String) -> LessonChapterContent? {
        if lessonID == matthewChapter1Lesson.id {
            return matthewChapter1Content
        }

        if let generated = generatedNTContent(for: lessonID) {
            return generated
        }

        guard
            let chapterNumber = matthewChapterNumber(from: lessonID),
            let seed = matthewSeedsByChapter[chapterNumber]
        else { return nil }

        return content(from: seed)
    }

    static func matthewLesson(for chapterNumber: Int) -> WisdomLesson {
        if chapterNumber == 1 {
            return matthewChapter1Lesson
        }

        guard let seed = matthewSeedsByChapter[chapterNumber] else {
            return matthewChapter1Lesson
        }

        return WisdomLesson(
            id: "matthew-chapter-\(seed.chapter)",
            order: seed.chapter,
            title: "Matthew \(seed.chapter): \(seed.title)",
            sourceName: "Bible: Matthew \(seed.chapter)",
            sourceURL: "https://www.biblegateway.com/passage/?search=Matthew+\(seed.chapter)&version=ESV",
            summary: "Matthew \(seed.chapter) moves through \(seed.movement). The chapter reveals that \(seed.keyTruth) and calls readers to \(seed.application)",
            keyIdeas: [
                "Follow the chapter's movement: \(seed.movement)",
                "See the main truth: \(seed.keyTruth)",
                "Watch how Matthew presents Jesus as the promised King who fulfills Scripture and confronts empty religion.",
                "Notice the discipleship pressure in the chapter: faith must become concrete obedience, not only admiration.",
                "Let the sermon aim land personally: \(seed.sermonFocus)",
                "Practice this chapter by choosing one visible act of obedience: \(seed.application)"
            ],
            keyVerses: seed.keyVerses,
            quest: quest(for: seed)
        )
    }

    private static func lesson(from profile: NTChapterLessonProfile, plan: NTBookLessonPlan) -> WisdomLesson {
        let keyVerses = generatedKeyVerses(book: plan.name, chapter: profile.chapter)

        return WisdomLesson(
            id: "\(plan.id)-chapter-\(profile.chapter)",
            order: profile.chapter,
            title: "\(plan.name) \(profile.chapter): \(profile.title)",
            sourceName: "Bible: \(plan.name) \(profile.chapter)",
            sourceURL: "https://www.biblegateway.com/passage/?search=\(plan.name.replacingOccurrences(of: " ", with: "+"))+\(profile.chapter)&version=ESV",
            summary: "\(plan.name) \(profile.chapter) moves through \(profile.movement). The chapter reveals that \(profile.keyTruth) and calls readers to \(profile.application).",
            keyIdeas: [
                "Read the chapter as one inspired movement: \(profile.movement)",
                "Hold the central truth in view: \(profile.keyTruth)",
                plan.theologicalLens,
                plan.convictionThread,
                "Let the sermon aim search you: \(profile.sermonFocus)",
                "Practice the chapter today: \(profile.application)"
            ],
            keyVerses: keyVerses,
            quest: quest(for: profile, plan: plan, keyVerses: keyVerses)
        )
    }

    private static func generatedNTContent(for lessonID: String) -> LessonChapterContent? {
        guard let parsed = generatedNTLessonID(from: lessonID),
              let plan = ntBookPlansByID[parsed.bookID],
              let profile = plan.chapters.first(where: { $0.chapter == parsed.chapter }) else {
            return nil
        }

        return content(from: profile, plan: plan)
    }

    private static func content(from profile: NTChapterLessonProfile, plan: NTBookLessonPlan) -> LessonChapterContent {
        LessonChapterContent(
            guidedPathPoints: [
                "Read \(plan.name) \(profile.chapter) without rushing. Follow the chapter movement: \(profile.movement)",
                "Ask what this chapter reveals about Jesus, the Spirit, the kingdom, the church, sin, faith, obedience, or witness.",
                "Name the main truth in plain language: \(profile.keyTruth)",
                "Let the chapter convict honestly. \(plan.convictionThread)",
                "Connect the chapter to the wider story of Scripture through the links below, not as loose quotes but as biblical context.",
                "Turn the lesson into obedience: \(profile.application)"
            ],
            sermonPoints: [
                "\(plan.name) \(profile.chapter) is not a detached devotional thought. It is a chapter inside \(plan.historyFrame). Read it as one movement: \(profile.movement).",
                "The chapter's central claim is this: \(profile.keyTruth). That truth is meant to do more than inform the mind. It exposes false trust, corrects shallow religion, and calls the reader into concrete faith.",
                plan.theologicalLens,
                "Here is where the Word presses the heart: \(profile.sermonFocus). Do not rush past that pressure. Conviction is mercy when it moves us toward repentance, humility, worship, and obedience.",
                "The history matters. \(plan.authorNote) \(plan.audienceNote) The first hearers were not reading abstract principles; they were being formed to know Christ, endure faithfully, and live under the authority of God's Word.",
                "This chapter also belongs to the whole Bible. The promises, warnings, covenant patterns, kingdom hopes, and mission of God are not background decoration. They help us see why this chapter matters and how it points us deeper into God's redemptive story.",
                "So do not finish \(plan.name) \(profile.chapter) with vague inspiration. Receive what God reveals, repent where the chapter exposes you, and take the faithful next step: \(profile.application)"
            ],
            scriptureLinks: generatedScriptureLinks(for: profile, plan: plan),
            historyNotes: generatedHistoryNotes(for: profile, plan: plan),
            practiceSteps: [
                "Write a one-sentence summary of \(plan.name) \(profile.chapter) using the chapter's own movement.",
                "Name one place where this chapter convicts, corrects, or reorders your heart.",
                "Pray through the chapter and choose one concrete act of obedience: \(profile.application)"
            ],
            wordInsightsByReference: [:]
        )
    }

    private static func generatedHistoryNotes(
        for profile: NTChapterLessonProfile,
        plan: NTBookLessonPlan
    ) -> [HistoryNoteContent] {
        [
            HistoryNoteContent(title: "Author and setting", detail: plan.authorNote),
            HistoryNoteContent(title: "First hearers", detail: plan.audienceNote),
            HistoryNoteContent(title: "Historical frame", detail: plan.historyFrame),
            HistoryNoteContent(title: "Chapter focus", detail: profile.movement),
            HistoryNoteContent(title: "Why it still matters", detail: plan.discipleshipThread)
        ] + nameOriginNotes(in: [
            plan.name,
            plan.authorNote,
            plan.audienceNote,
            plan.historyFrame,
            profile.title,
            profile.movement,
            profile.keyTruth,
            profile.sermonFocus
        ])
    }

    private static func generatedScriptureLinks(
        for profile: NTChapterLessonProfile,
        plan: NTBookLessonPlan
    ) -> [ScriptureLinkContent] {
        let chapterLinks = generatedKeyVerses(book: plan.name, chapter: profile.chapter).prefix(2).map { reference in
            ScriptureLinkContent(
                reference: reference,
                summary: "This verse anchors the \(plan.name) \(profile.chapter) lesson inside the chapter itself, so reflection stays governed by the actual text."
            )
        }

        return Array(chapterLinks) + plan.scriptureLinks
    }

    private static func generatedKeyVerses(book: String, chapter: Int) -> [String] {
        guard let bibleChapter = BibleDataProvider.chapter(
            at: BibleLocation(book: book, chapter: chapter),
            version: .esv
        ), !bibleChapter.verses.isEmpty else {
            return ["\(book) \(chapter):1"]
        }

        let numbers = bibleChapter.verses.map(\.verse)
        let first = numbers.first ?? 1
        let middle = numbers[numbers.count / 2]
        let last = numbers.last ?? first
        return Array(Set([first, middle, last]))
            .sorted()
            .map { "\(book) \(chapter):\($0)" }
    }

    private static func quest(
        for profile: NTChapterLessonProfile,
        plan: NTBookLessonPlan,
        keyVerses: [String]
    ) -> WisdomQuest {
        WisdomQuest(
            passingScore: 75,
            questions: [
                WisdomQuestion(
                    id: "\(plan.id)-\(profile.chapter)-q1",
                    prompt: "What is the main movement of \(plan.name) \(profile.chapter)?",
                    options: [
                        profile.movement,
                        "A random chapter with no connected argument or story",
                        "A chapter mainly about private success",
                        "A chapter that avoids conviction or obedience"
                    ],
                    correctIndex: 0,
                    explanation: "The lesson reads the chapter as one connected movement, not as detached quotes."
                ),
                WisdomQuestion(
                    id: "\(plan.id)-\(profile.chapter)-q2",
                    prompt: "What truth should shape how this chapter is read?",
                    options: [
                        "Human approval is the safest guide",
                        profile.keyTruth,
                        "The chapter is only useful if it feels encouraging",
                        "Obedience can wait until life is easier"
                    ],
                    correctIndex: 1,
                    explanation: "The chapter reveals a concrete truth about God, Christ, the Spirit, the church, mission, or obedience."
                ),
                WisdomQuestion(
                    id: "\(plan.id)-\(profile.chapter)-q3",
                    prompt: "Which reference belongs to this lesson?",
                    options: [
                        "Genesis 1:1",
                        "Psalms 23:1",
                        keyVerses.first ?? "\(plan.name) \(profile.chapter):1",
                        "Revelation 22:21"
                    ],
                    correctIndex: 2,
                    explanation: "The quest keeps the lesson anchored in the chapter's own Scripture."
                ),
                WisdomQuestion(
                    id: "\(plan.id)-\(profile.chapter)-q4",
                    prompt: "What is a faithful response to \(plan.name) \(profile.chapter)?",
                    options: [
                        "Collect information without changing",
                        "Use the chapter first to judge someone else",
                        "Skip the part that convicts",
                        profile.application
                    ],
                    correctIndex: 3,
                    explanation: "The Word of God calls for trust, repentance, worship, endurance, and concrete obedience."
                )
            ]
        )
    }

    private static func generatedNTLessonID(from lessonID: String) -> (bookID: String, chapter: Int)? {
        for bookID in ntBookPlansByID.keys {
            let prefix = "\(bookID)-chapter-"
            guard lessonID.hasPrefix(prefix),
                  let chapter = Int(lessonID.dropFirst(prefix.count)) else { continue }
            return (bookID, chapter)
        }

        return nil
    }

    private static func chapterLessonParts(from lessonID: String) -> (bookID: String, chapter: Int)? {
        if let chapter = matthewChapterNumber(from: lessonID) {
            return ("matthew", chapter)
        }

        if let parsed = generatedNTLessonID(from: lessonID) {
            return parsed
        }

        return nil
    }

    private static func hasLesson(bookID: String, chapterNumber: Int) -> Bool {
        if bookID == "matthew" {
            return chapterNumber == 1 || matthewSeedsByChapter[chapterNumber] != nil
        }

        if bookID == "james" {
            return WisdomCourse.jamesBibleSchool.lessons.contains(where: { $0.order == chapterNumber })
        }

        return ntBookPlansByID[bookID]?.chapters.contains(where: { $0.chapter == chapterNumber }) ?? false
    }

    private static func nameOriginNotes(in segments: [String]) -> [HistoryNoteContent] {
        let haystack = segments.joined(separator: " ").lowercased()
        return biblicalNameOrigins.compactMap { origin in
            guard haystack.localizedCaseInsensitiveContains(origin.name) else { return nil }
            return HistoryNoteContent(
                title: "Name origin: \(origin.displayName)",
                detail: origin.detail
            )
        }
        .prefix(4)
        .map { $0 }
    }

    private static let biblicalNameOrigins: [(name: String, displayName: String, detail: String)] = [
        ("jesus", "Jesus", "Jesus comes from the Hebrew name Yeshua/Joshua, meaning 'The Lord saves.' The name itself announces His mission to save His people from their sins."),
        ("christ", "Christ", "Christ comes from the Greek Christos, meaning 'Anointed One.' It points to the promised King, Priest, and deliverer God sends."),
        ("immanuel", "Immanuel", "Immanuel comes from Hebrew and means 'God with us.' Matthew uses it to show that God has come near in the Messiah."),
        ("abraham", "Abraham", "Abraham means 'father of a multitude.' His name carries the covenant promise that blessing would reach many nations through his seed."),
        ("david", "David", "David means 'beloved.' In the Gospels, David's name also signals the royal promise that the Messiah would come from his line."),
        ("joseph", "Joseph", "Joseph means 'may he add.' In Matthew 1, Joseph stands in David's line and receives Jesus as legal son through obedient faith."),
        ("mary", "Mary", "Mary is the Greek form of Miriam. Its exact root is debated, but the name ties Jesus' birth to real Jewish family history."),
        ("john", "John", "John comes from Hebrew Yohanan, meaning 'The Lord has been gracious.' That meaning fits John the Baptist's role as a mercy-filled witness preparing the way."),
        ("peter", "Peter", "Peter comes from Greek Petros, meaning 'rock.' Jesus uses the name to teach about confession, weakness, restoration, and leadership."),
        ("james", "James", "James is the English form of Jacob, a name connected with Israel's story of struggle, promise, and covenant mercy."),
        ("paul", "Paul", "Paul comes from Latin Paulus, meaning 'small' or 'humble.' The apostle's Roman name fits his Gentile mission in the wider empire."),
        ("saul", "Saul", "Saul means 'asked for.' Acts uses Saul/Paul's name shift inside the story of a persecutor transformed into a witness to the nations."),
        ("stephen", "Stephen", "Stephen comes from Greek Stephanos, meaning 'crown.' Acts presents him as a faithful witness crowned through suffering."),
        ("cornelius", "Cornelius", "Cornelius is a Roman family name. His story in Acts highlights the gospel crossing ethnic and cultural boundaries."),
        ("barnabas", "Barnabas", "Barnabas is explained in Acts as 'son of encouragement.' His name fits his ministry of strengthening others."),
        ("theophilus", "Theophilus", "Theophilus means 'lover of God' or 'friend of God.' Luke addresses him so believers may have certainty about Jesus."),
        ("herod", "Herod", "Herod is a Greek royal name tied to the Herodian dynasty. In the Gospels it often signals political power resisting God's King."),
        ("caesar", "Caesar", "Caesar became an imperial title in Rome. Gospel references to Caesar set earthly empire beside God's kingdom and Christ's lordship."),
        ("rome", "Rome", "Rome was the empire's capital and a symbol of Gentile power, public order, and imperial reach. New Testament references to Rome often place gospel witness before the wider world."),
        ("romans", "Romans", "Romans names believers living in the empire's capital. Paul's letter teaches that God's righteousness in Christ creates one people from Jews and Gentiles."),
        ("corinth", "Corinth", "Corinth was a wealthy Roman trade city marked by status competition, public rhetoric, temples, and moral confusion. First Corinthians applies the cross to a church under that pressure."),
        ("corinthians", "Corinthians", "Corinthians names the believers in Corinth whom Paul corrects and pastors toward holiness, unity, love, orderly worship, and resurrection hope."),
        ("apollos", "Apollos", "Apollos was an eloquent teacher connected with Corinth. Paul names him to correct leader-centered factions and redirect attention to God who gives the growth."),
        ("jerusalem", "Jerusalem", "Jerusalem is the covenant city of temple, kingship, worship, conflict, death, resurrection, and mission in Luke-Acts."),
        ("galilee", "Galilee", "Galilee means a district or region. The Gospels often show Jesus beginning and returning to ministry among ordinary and mixed communities."),
        ("samaria", "Samaria", "Samaria names a region marked by deep Jewish-Samaritan tension. In Acts, its inclusion shows the gospel healing old boundaries.")
    ]

    static let matthewChapter1Lesson = WisdomLesson(
        id: "matthew-chapter-1",
        order: 1,
        title: "Matthew 1: Promise, Lineage, and the Birth of Jesus",
        sourceName: "Bible: Matthew 1",
        sourceURL: "https://www.biblegateway.com/passage/?search=Matthew+1&version=ESV",
        summary: "Matthew 1 opens by declaring Jesus as the promised Son of David and Son of Abraham, then traces God's covenant faithfulness through real generations marked by sin, exile, and mercy. The chapter moves from genealogy to incarnation: the Messiah is conceived by the Holy Spirit, named Jesus because He will save His people from their sins, and called Immanuel because in Him God has come to dwell with us.",
        keyIdeas: [
            "Matthew presents Jesus as the legal royal heir in David's line and the covenant Seed promised to Abraham.",
            "The genealogy is not polished propaganda. It includes morally complex people and outsiders, showing grace running through real history.",
            "The exile is a major turning point in verse 17, reminding us that human kings failed and Israel needed a true King.",
            "Joseph models righteous mercy: he does not excuse sin, but he refuses public humiliation and listens for God before acting.",
            "The virgin conception guards the truth that salvation begins with God's initiative, not human ability.",
            "The names Jesus and Immanuel define the gospel: God with us to save us from our sins."
        ],
        keyVerses: [
            "Matthew 1:1",
            "Matthew 1:17",
            "Matthew 1:21",
            "Matthew 1:23"
        ],
        quest: WisdomQuest(
            passingScore: 75,
            questions: [
                WisdomQuestion(
                    id: "mt1-q1",
                    prompt: "Why does Matthew begin by calling Jesus both 'son of David' and 'son of Abraham'?",
                    options: [
                        "To connect Jesus to God's kingly and covenant promises",
                        "To prove Jesus was only a political reformer",
                        "To replace the Old Testament with a new story",
                        "To show that genealogy is more important than faith"
                    ],
                    correctIndex: 0,
                    explanation: "Matthew ties Jesus to the royal promise to David and the blessing promise to Abraham."
                ),
                WisdomQuestion(
                    id: "mt1-q2",
                    prompt: "What does the inclusion of women like Tamar, Rahab, Ruth, and 'the wife of Uriah' emphasize?",
                    options: [
                        "Only social status matters in God's plan",
                        "God's redemptive line moves through grace, not human perfection",
                        "Matthew wanted to avoid mentioning David",
                        "The genealogy is symbolic and not historical"
                    ],
                    correctIndex: 1,
                    explanation: "Matthew highlights that God works through broken histories and unexpected people."
                ),
                WisdomQuestion(
                    id: "mt1-q3",
                    prompt: "In Matthew 1:21, what is the central mission tied to the name Jesus?",
                    options: [
                        "To restore Israel's economy",
                        "To defeat Rome by force",
                        "To save His people from their sins",
                        "To remove all suffering immediately"
                    ],
                    correctIndex: 2,
                    explanation: "The angel explicitly explains the name: Jesus saves His people from their sins."
                ),
                WisdomQuestion(
                    id: "mt1-q4",
                    prompt: "How does Joseph respond when he receives God's word in a dream?",
                    options: [
                        "He delays until public opinion supports him",
                        "He obeys promptly and takes Mary as his wife",
                        "He asks for another sign and refuses to act",
                        "He ignores the command but keeps it private"
                    ],
                    correctIndex: 1,
                    explanation: "Joseph's faith is seen in immediate obedience, not emotional certainty."
                ),
                WisdomQuestion(
                    id: "mt1-q5",
                    prompt: "What truth does the title Immanuel communicate in Matthew 1:23?",
                    options: [
                        "God is near only in the temple",
                        "God is with us in the person of Jesus",
                        "God helps only Israel's kings",
                        "God speaks only through dreams now"
                    ],
                    correctIndex: 1,
                    explanation: "Matthew interprets Immanuel directly: God with us."
                ),
                WisdomQuestion(
                    id: "mt1-q6",
                    prompt: "What is the best way to apply Matthew 1 personally?",
                    options: [
                        "Hide your story until it looks clean",
                        "Trust that God's promises stand, then obey the next faithful step",
                        "Wait for perfect clarity before obeying",
                        "Assume your past disqualifies you from being used by God"
                    ],
                    correctIndex: 1,
                    explanation: "Matthew 1 calls us to confidence in God's promise and practical obedience like Joseph."
                )
            ]
        )
    )

    private static let matthewChapter1Content = LessonChapterContent(
        guidedPathPoints: [
            "Start with Matthew's first sentence. Jesus is introduced through covenant categories: Son of David and Son of Abraham.",
            "Read the genealogy as theology, not filler. It traces promise through kings, collapse, exile, and return.",
            "Pay attention to the names Matthew chooses to emphasize. Grace is not abstract here; it runs through complicated family history.",
            "Notice verse 17 and the exile marker. Matthew is telling us that human rule failed and a truer King is needed.",
            "In verses 18-25, the focus shifts from legal lineage to divine conception: this child is from the Holy Spirit.",
            "Hold verses 21 and 23 together. Jesus saves from sin, and Immanuel means God Himself has come near to do it."
        ],
        sermonPoints: [
            "Matthew does not begin with a motivational speech. He begins with a family line because the gospel is not myth or self-help; it is God's promise entering public history. Christianity stands in real names, real generations, real failures, and real fulfillment.",
            "The genealogy is full of grace. God did not wait for a flawless bloodline to send the Messiah. He wrote redemption through compromised people, wounded stories, and morally complex chapters. This confronts our pride and heals our shame: your past is not stronger than God's covenant mercy.",
            "Matthew structures the line through Abraham, David, and exile to show a movement: promise, kingdom, collapse, and hope. Human leadership could not produce the righteousness the world needed. The chapter prepares us to stop trusting human strength and receive God's King.",
            "Joseph's righteousness is not performative religion. He is just, but also merciful. He chooses restraint when he could have chosen exposure. Then when God speaks, he obeys without delay. Mature faith is both morally serious and deeply humble.",
            "The angel's command names the heart of the gospel: 'You shall call his name Jesus, for he will save his people from their sins.' The first Christian problem is not image, career, or circumstance. It is sin. The first Christian hope is not self-improvement. It is a Savior.",
            "Immanuel means God with us. Not distant advice, not abstract spirituality, but divine presence in flesh and blood. God does not save us by shouting instructions from far away. He comes near, bears our condition, and rescues from within our human story.",
            "Matthew 1 calls for a response. Bring your history to Christ without editing it. Repent where sin is active. Receive mercy where guilt is heavy. Then obey the next clear step God has given, even if your feelings are still catching up.",
            "Genesis 12:3 promised that all the families of the earth would be blessed through Abraham. Matthew is showing that this promise was never small. Jesus comes through Israel, but He does not belong only to one tribe, one personality type, one social class, or one clean-looking story. The blessing is moving outward because God keeps His word.",
            "Second Samuel 7 promised David a throne that would endure. Matthew 1 quietly asks us to compare every failed king with this coming King. David sinned. Solomon drifted. The kingdom divided. Exile came. But God's promise did not die in the wreckage of human leadership. Jesus is the King whose righteousness does not collapse under pressure.",
            "Isaiah 7:14 said the child would be called Immanuel. Matthew does not use that name as decoration. He wants us to feel the weight of it: the holy God comes near to an unholy people, not because we climbed high enough, but because mercy came down low enough.",
            "Galatians 4:4-5 says God sent His Son in the fullness of time to redeem those under the law. That is Matthew 1 in sermon form. The genealogy tells you time was not random. The birth tells you salvation was not human achievement. The name Jesus tells you redemption is personal, costly, and aimed at sin.",
            "Romans 5:8 says Christ came while we were still sinners. Matthew 1 preaches the same truth through names. Before Jesus ever teaches a sermon in Matthew, His family line is already preaching grace. This should humble religious pride and give courage to ashamed sinners.",
            "So do not read Matthew 1 like a hallway you rush through to get to the 'real story.' This is the doorway. God keeps covenant. God enters history. God confronts sin. God comes near. The right response is not vague inspiration; it is faith, repentance, and Joseph-like obedience when God makes the next step clear."
        ],
        scriptureLinks: [
            ScriptureLinkContent(
                reference: "Genesis 12:3",
                summary: "Matthew's 'son of Abraham' echoes the promise that all nations would be blessed through Abraham's seed. Jesus is that promised line reaching the nations."
            ),
            ScriptureLinkContent(
                reference: "2 Samuel 7:12-13",
                summary: "The 'son of David' title points to God's covenant with David about an enduring throne. Matthew presents Jesus as the true royal heir."
            ),
            ScriptureLinkContent(
                reference: "Ruth 4:17-22",
                summary: "Ruth's closing genealogy leads to David. Matthew resumes that line and shows the same redemptive thread now arriving at Christ."
            ),
            ScriptureLinkContent(
                reference: "2 Samuel 11:2-5",
                summary: "By naming 'the wife of Uriah,' Matthew refuses to hide David's sin. The Messiah comes through a line that needed grace, not self-righteousness."
            ),
            ScriptureLinkContent(
                reference: "Isaiah 7:14",
                summary: "Matthew explicitly cites Isaiah's sign of the virgin and Immanuel, showing Jesus as the fulfillment of God's long-announced promise."
            ),
            ScriptureLinkContent(
                reference: "Jeremiah 23:5-6",
                summary: "Jeremiah promised a righteous Branch from David who would bring salvation. Matthew's opening aligns Jesus with that expectation."
            ),
            ScriptureLinkContent(
                reference: "Luke 1:31-35",
                summary: "Luke's account parallels Matthew: Jesus is divinely conceived and identified as royal Son, confirming the same gospel claim."
            ),
            ScriptureLinkContent(
                reference: "Galatians 4:4-5",
                summary: "Paul summarizes Matthew 1's movement: in the fullness of time God sent His Son, born of a woman, to redeem those under the law."
            )
        ],
        historyNotes: [
            HistoryNoteContent(
                title: "Audience and purpose",
                detail: "Matthew writes with strong Old Testament awareness and introduces Jesus as Israel's promised Messiah and King. His opening is crafted to prove continuity, not replacement."
            ),
            HistoryNoteContent(
                title: "Genealogy structure",
                detail: "Verse 17 highlights three movements of fourteen generations: Abraham to David, David to exile, exile to Christ. Matthew is organizing history around covenant milestones and the exile crisis."
            ),
            HistoryNoteContent(
                title: "Why these names matter",
                detail: "Including Tamar, Rahab, Ruth, and 'the wife of Uriah' shows that God's redemptive line includes outsiders, scandal, and mercy. The Messiah enters the same broken human story He came to heal."
            ),
            HistoryNoteContent(
                title: "Joseph's legal fatherhood",
                detail: "Matthew emphasizes Joseph's role to establish Jesus' legal Davidic standing. Joseph's obedience publicly receives Jesus and anchors His place in the royal line."
            ),
            HistoryNoteContent(
                title: "From language to theology",
                detail: "The chapter's key vocabulary is theological: genealogy/origin, save, sin, and Immanuel. Matthew is defining Jesus' identity and mission before narrating His ministry."
            )
        ],
        practiceSteps: [
            "Summarize Matthew 1 in one sentence without skipping sin, promise, or incarnation.",
            "Write one place where shame or family history still shapes your identity more than God's promise.",
            "Pray from Matthew 1:21-23, asking Jesus to save you from present sin and teach you obedience like Joseph."
        ],
        wordInsightsByReference: [
            "Matthew 1:1": [
                WordStudyInsight(
                    reference: "Matthew 1:1",
                    language: "Greek",
                    word: "βίβλος",
                    transliteration: "biblos",
                    meaning: "book, record, written account",
                    deeperNote: "Matthew opens like a formal covenant document. Jesus is introduced as verifiable history, not legend."
                ),
                WordStudyInsight(
                    reference: "Matthew 1:1",
                    language: "Greek",
                    word: "γενέσεως",
                    transliteration: "geneseos",
                    meaning: "origin, genealogy, lineage",
                    deeperNote: "This word links Matthew's opening to creation and covenant themes. Jesus is presented as the promised culmination of God's story."
                ),
                WordStudyInsight(
                    reference: "Matthew 1:1",
                    language: "Greek",
                    word: "Χριστοῦ",
                    transliteration: "Christou",
                    meaning: "Anointed One, Messiah",
                    deeperNote: "Jesus is not only a personal name here; He is identified by office as God's appointed King and deliverer."
                )
            ],
            "Matthew 1:18": [
                WordStudyInsight(
                    reference: "Matthew 1:18",
                    language: "Greek",
                    word: "γένεσις",
                    transliteration: "genesis",
                    meaning: "birth, origin, coming into being",
                    deeperNote: "Matthew marks Jesus' birth as a decisive beginning event in salvation history."
                )
            ],
            "Matthew 1:19": [
                WordStudyInsight(
                    reference: "Matthew 1:19",
                    language: "Greek",
                    word: "δίκαιος",
                    transliteration: "dikaios",
                    meaning: "righteous, just, upright",
                    deeperNote: "Joseph's righteousness includes both moral conviction and merciful restraint."
                )
            ],
            "Matthew 1:20": [
                WordStudyInsight(
                    reference: "Matthew 1:20",
                    language: "Greek",
                    word: "γεννηθέν",
                    transliteration: "gennethen",
                    meaning: "conceived, brought forth",
                    deeperNote: "Matthew attributes Jesus' conception to divine action, emphasizing that salvation begins with God."
                ),
                WordStudyInsight(
                    reference: "Matthew 1:20",
                    language: "Greek",
                    word: "πνεύματος ἁγίου",
                    transliteration: "pneumatos hagiou",
                    meaning: "of the Holy Spirit",
                    deeperNote: "The Messiah's coming is supernatural and holy, not the product of human planning."
                )
            ],
            "Matthew 1:21": [
                WordStudyInsight(
                    reference: "Matthew 1:21",
                    language: "Greek",
                    word: "Ἰησοῦν",
                    transliteration: "Iesoun",
                    meaning: "Jesus (Yahweh saves)",
                    deeperNote: "The name itself carries mission: God acts to save."
                ),
                WordStudyInsight(
                    reference: "Matthew 1:21",
                    language: "Greek",
                    word: "σώσει",
                    transliteration: "sosei",
                    meaning: "he will save, rescue, deliver",
                    deeperNote: "Jesus' work is not symbolic rescue but real deliverance from sin's guilt and power."
                ),
                WordStudyInsight(
                    reference: "Matthew 1:21",
                    language: "Greek",
                    word: "ἁμαρτιῶν",
                    transliteration: "hamartion",
                    meaning: "sins, offenses against God",
                    deeperNote: "Matthew targets the deepest human problem directly: sin before God."
                )
            ],
            "Matthew 1:23": [
                WordStudyInsight(
                    reference: "Matthew 1:23",
                    language: "Greek",
                    word: "παρθένος",
                    transliteration: "parthenos",
                    meaning: "virgin",
                    deeperNote: "Matthew ties Jesus' birth to prophecy and divine initiative, not ordinary human origin."
                ),
                WordStudyInsight(
                    reference: "Matthew 1:23",
                    language: "Greek",
                    word: "Ἐμμανουήλ",
                    transliteration: "Emmanouel",
                    meaning: "God with us",
                    deeperNote: "This name interprets the whole chapter: in Jesus, God truly comes near to dwell and save."
                )
            ]
        ]
    )

    private static let ntBookPlansByID: [String: NTBookLessonPlan] = Dictionary(
        uniqueKeysWithValues: ntBookLessonPlans.map { ($0.id, $0) }
    )

    private static func ntChapter(
        _ chapter: Int,
        _ title: String,
        movement: String,
        keyTruth: String,
        application: String,
        sermonFocus: String
    ) -> NTChapterLessonProfile {
        NTChapterLessonProfile(
            chapter: chapter,
            title: title,
            movement: movement,
            keyTruth: keyTruth,
            application: application,
            sermonFocus: sermonFocus
        )
    }

    private static let ntBookLessonPlans: [NTBookLessonPlan] = [
        NTBookLessonPlan(
            id: "mark",
            name: "Mark",
            authorNote: "Mark is traditionally connected with John Mark and Peter's eyewitness preaching. The Gospel moves quickly, showing Jesus' authority in action and pressing readers to follow the suffering Son of God.",
            audienceNote: "Mark's first readers likely included believers who needed courage under pressure. The Gospel strengthens disciples who are tempted to want glory without the cross.",
            historyFrame: "the Roman world of Galilee and Jerusalem, where sickness, demonic oppression, religious authority, imperial power, and shame all meet the authority of Jesus",
            theologicalLens: "Mark keeps asking who Jesus is, then answers by showing His authority over demons, disease, nature, sin, tradition, and death, climaxing at the cross and empty tomb.",
            convictionThread: "Mark convicts shallow discipleship that wants miracles, safety, or status while resisting the way of the cross.",
            discipleshipThread: "Mark trains disciples to see, repent, believe the gospel, serve instead of grasping for greatness, and follow Jesus even when obedience costs.",
            scriptureLinks: [
                ScriptureLinkContent(reference: "Isaiah 40:3", summary: "Mark opens with the promised wilderness voice preparing the way of the Lord."),
                ScriptureLinkContent(reference: "Daniel 7:13-14", summary: "The Son of Man receives dominion, shaping Mark's portrait of Jesus' authority and suffering mission."),
                ScriptureLinkContent(reference: "Isaiah 53:10-12", summary: "The suffering Servant background helps explain why the Son of Man gives His life as a ransom.")
            ],
            chapters: [
                ntChapter(1, "The Kingdom Arrives with Authority", movement: "John preparing the way, Jesus announcing the kingdom, calling disciples, casting out demons, healing many, and cleansing a leper", keyTruth: "Jesus brings God's kingdom with authority that demands repentance, faith, and immediate following", application: "repent, believe the gospel, and obey Jesus' call without delay", sermonFocus: "The kingdom does not arrive as advice; it arrives as a King with authority over your whole life."),
                ntChapter(2, "Forgiveness, Mercy, and New Wine", movement: "Jesus forgiving a paralytic, eating with sinners, answering fasting questions, and challenging Sabbath controversy", keyTruth: "Jesus has authority to forgive sins and brings mercy that cannot be contained by old religious pride", application: "receive mercy honestly and stop using religion to avoid the Physician", sermonFocus: "The heart can stand near healing and still resent mercy when it comes to the wrong people."),
                ntChapter(3, "Conflict and a New Family", movement: "Jesus healing on the Sabbath, appointing the Twelve, being accused by leaders, and redefining family around obedience", keyTruth: "Jesus forms a new people around Himself while exposing hardened resistance to the Spirit's work", application: "belong to Jesus by doing the will of God rather than protecting image or status", sermonFocus: "Hardened religion can call the work of God dangerous when it threatens control."),
                ntChapter(4, "The Word, the Soils, and the Storm", movement: "Jesus teaching kingdom parables and then calming the sea before fearful disciples", keyTruth: "God's Word reveals the heart and Jesus' authority is stronger than chaos", application: "examine your soil and bring fear under Jesus' lordship", sermonFocus: "The same Word that bears fruit in one heart exposes hardness in another."),
                ntChapter(5, "Deliverance, Faith, and Life", movement: "Jesus delivering a tormented man, healing a bleeding woman, and raising Jairus's daughter", keyTruth: "Jesus is powerful enough to restore people no one else can rescue", application: "come to Jesus with honest desperation and trust His timing", sermonFocus: "No uncleanness, torment, delay, or death is beyond the mercy and authority of Christ."),
                ntChapter(6, "Rejected at Home, Shepherd to Crowds", movement: "Jesus being rejected in Nazareth, sending the Twelve, grieving John's death, feeding the crowd, and walking on the sea", keyTruth: "Jesus remains the compassionate Shepherd even when unbelief, fear, and violence surround His mission", application: "serve faithfully with what Jesus gives and bring unbelief into the light", sermonFocus: "Familiarity with holy things can become a shield against faith."),
                ntChapter(7, "Clean Hearts and Boundary-Crossing Mercy", movement: "Jesus confronting tradition, teaching heart defilement, and extending mercy to Gentile need", keyTruth: "Jesus exposes the heart as the source of uncleanness and opens mercy beyond expected boundaries", application: "confess heart-level sin and seek mercy with humble persistence", sermonFocus: "External religion cannot cleanse what the heart keeps producing."),
                ntChapter(8, "Seeing Slowly and Taking the Cross", movement: "Jesus feeding, warning about leaven, healing blind sight gradually, receiving Peter's confession, and teaching cross-bearing", keyTruth: "Jesus is the Christ who must suffer, and disciples must follow Him in self-denial", application: "reject self-protection and take the next cross-shaped step of obedience", sermonFocus: "You cannot confess Jesus as Christ while correcting His path to the cross."),
                ntChapter(9, "Glory, Weak Faith, and Servant Greatness", movement: "Jesus revealing glory, healing a tormented boy, predicting His death, and teaching humble service", keyTruth: "the glorious Son calls disciples away from self-importance into dependent faith and servant humility", application: "pray honestly from weak faith and choose lowly service over status", sermonFocus: "The Father says to listen to Jesus, not merely admire spiritual moments."),
                ntChapter(10, "Kingdom Reversals and Ransom", movement: "Jesus teaching on marriage, children, wealth, greatness, and healing blind Bartimaeus", keyTruth: "the kingdom overturns status, possessions, and ambition because the Son of Man gives Himself as ransom", application: "release what competes with Jesus and serve without demanding recognition", sermonFocus: "The disciples want thrones while Jesus walks toward a ransom cross."),
                ntChapter(11, "The King Inspects Worship", movement: "Jesus entering Jerusalem, judging fruitlessness, cleansing the temple, and teaching faith and forgiveness", keyTruth: "Jesus receives royal praise and judges worship that has leaves but no fruit", application: "let worship become prayer, fruit, forgiveness, and surrendered trust", sermonFocus: "Religious activity can look alive while producing nothing Jesus seeks."),
                ntChapter(12, "Rejected Son and Whole-Hearted Love", movement: "Jesus confronting leaders through parable, answering traps, naming the greatest commandments, and honoring a widow's gift", keyTruth: "God's rejected Son exposes false authority and calls for undivided love", application: "love God and neighbor with costly integrity instead of religious performance", sermonFocus: "The smallest gift can reveal more worship than the loudest religious display."),
                ntChapter(13, "Watchfulness under Pressure", movement: "Jesus predicting temple judgment, warning of deception and tribulation, and commanding watchfulness", keyTruth: "disciples must endure confusion and suffering with watchful trust in Jesus' words", application: "practice faithful readiness instead of fear-driven speculation", sermonFocus: "Jesus gives warnings to form endurance, not panic."),
                ntChapter(14, "Covenant, Agony, Betrayal", movement: "Jesus being anointed, sharing the covenant meal, praying in Gethsemane, being betrayed, tried, and denied", keyTruth: "Jesus walks willingly into covenant suffering while His disciples' weakness is exposed", application: "watch and pray, confess weakness, and receive the mercy of His covenant blood", sermonFocus: "The disciples collapse under pressure, but Jesus remains faithful for unfaithful people."),
                ntChapter(15, "The Crucified Son of God", movement: "Jesus being condemned, mocked, crucified, forsaken, declared Son of God, and buried", keyTruth: "Jesus is revealed as Son of God through the shame and saving power of the cross", application: "stand before the cross with repentance, worship, and courage", sermonFocus: "The world mocks the crucified King, but heaven reveals His identity there."),
                ntChapter(16, "The Empty Tomb and Witness", movement: "the women finding the stone rolled away, hearing resurrection news, and being sent to tell the disciples", keyTruth: "Jesus is risen, so fear must give way to faithful witness", application: "move from fear toward testimony that Jesus is alive", sermonFocus: "The resurrection does not flatter fear; it summons trembling witnesses into hope.")
            ]
        ),
        NTBookLessonPlan(
            id: "luke",
            name: "Luke",
            authorNote: "Luke writes as a careful historian and theologian, addressing Theophilus so believers may have certainty about the things taught concerning Jesus.",
            audienceNote: "Luke highlights outsiders, the poor, women, sinners, Gentiles, and the work of the Spirit, forming readers to see the wideness and holiness of God's salvation.",
            historyFrame: "the days of Herod, Caesar, temple worship, synagogue teaching, Roman rule, and Jewish expectation, where God's promises move toward worldwide salvation",
            theologicalLens: "Luke presents Jesus as the Spirit-anointed Savior who fulfills Israel's hope and brings salvation to the lost.",
            convictionThread: "Luke convicts respectable religion that avoids mercy, prayerless self-confidence, and hearts that hear Jesus without repentance.",
            discipleshipThread: "Luke forms disciples in repentance, prayer, mercy, reversal, endurance, Spirit-dependence, and witness to all nations.",
            scriptureLinks: [
                ScriptureLinkContent(reference: "Isaiah 61:1-2", summary: "Jesus announces His Spirit-anointed mission in language from Isaiah."),
                ScriptureLinkContent(reference: "Genesis 12:3", summary: "Luke's concern for all nations flows from God's promise to bless the nations through Abraham."),
                ScriptureLinkContent(reference: "Acts 1:8", summary: "Luke's Gospel flows directly into Acts and the Spirit-empowered witness of the church.")
            ],
            chapters: [
                ntChapter(1, "Promise, Praise, and the Coming Savior", movement: "angelic announcements, Mary's faith, Elizabeth's joy, and Zechariah's prophecy over John", keyTruth: "God keeps His covenant promises and prepares salvation through humble faith", application: "receive God's word with Mary's surrendered trust", sermonFocus: "Grace begins before human strength can take credit."),
                ntChapter(2, "The Savior Is Born", movement: "Jesus' birth, shepherd witnesses, temple praise, and the boy Jesus in His Father's house", keyTruth: "the promised Savior enters humble history and is recognized by waiting faith", application: "treasure Christ's arrival and let worship interrupt ordinary life", sermonFocus: "God's glory comes near in humility, not the places pride would expect."),
                ntChapter(3, "Repentance and the Beloved Son", movement: "John preaching repentance, Jesus being baptized, and the genealogy tracing Him to Adam", keyTruth: "the beloved Son enters human history to bring repentance and salvation", application: "bear fruit that fits repentance", sermonFocus: "Religious ancestry cannot replace repentant fruit."),
                ntChapter(4, "Temptation and Spirit-Anointed Mission", movement: "Jesus defeating temptation, announcing Isaiah's fulfillment, being rejected, and delivering many", keyTruth: "Jesus is the Spirit-anointed Son who resists evil and brings good news to the needy", application: "answer temptation with Scripture and receive Jesus' mission on His terms", sermonFocus: "People may want the benefits of Jesus while rejecting His claim over them."),
                ntChapter(5, "Calling Sinners into New Life", movement: "Jesus calling fishermen, cleansing a leper, forgiving a paralytic, and eating with tax collectors", keyTruth: "Jesus calls sinners, forgives sin, and creates new life that old categories cannot contain", application: "leave the nets of self-rule and follow Him", sermonFocus: "The Physician comes for people who admit they are sick."),
                ntChapter(6, "Lord of Mercy and Kingdom Ethics", movement: "Sabbath conflict, choosing the Twelve, blessings and woes, love for enemies, and obedience as foundation", keyTruth: "Jesus forms a kingdom people whose mercy and obedience reflect the Father", application: "practice enemy-love and build on Jesus' words", sermonFocus: "It is possible to call Him Lord while refusing to do what He says."),
                ntChapter(7, "Faith, Compassion, and Forgiven Love", movement: "Jesus honoring a centurion's faith, raising a widow's son, answering John, and forgiving a sinful woman", keyTruth: "Jesus brings compassionate authority and receives faith from unexpected people", application: "come to Jesus with humble faith and grateful love", sermonFocus: "Those who know they are forgiven much love much."),
                ntChapter(8, "The Word, Deliverance, and Faith", movement: "Jesus teaching the soils, calming the storm, delivering a man, healing a woman, and raising a daughter", keyTruth: "Jesus' word bears fruit and His authority reaches storm, demons, disease, and death", application: "hear the Word with persevering faith", sermonFocus: "Fear asks who Jesus is; faith learns to trust His authority."),
                ntChapter(9, "The Christ and the Cross-Shaped Way", movement: "mission, feeding, confession, transfiguration, and Jesus setting His face toward Jerusalem", keyTruth: "Jesus is the Christ who calls followers to deny themselves and follow His road", application: "take up your cross daily and stop bargaining with obedience", sermonFocus: "Discipleship is daily surrender, not occasional admiration."),
                ntChapter(10, "Mission, Mercy, and the Better Portion", movement: "the seventy-two sent, the Samaritan showing mercy, and Mary sitting at Jesus' feet", keyTruth: "kingdom mission joins mercy toward neighbor with listening devotion to Jesus", application: "show mercy concretely and choose attentive fellowship with Christ", sermonFocus: "Busyness for God can still miss the better portion of being with Him."),
                ntChapter(11, "Prayer and Exposed Hypocrisy", movement: "Jesus teaching prayer, confronting accusations, warning against empty religion, and pronouncing woes", keyTruth: "the Father gives good gifts while Jesus exposes hearts that resist light", application: "pray persistently and let God's light search hidden hypocrisy", sermonFocus: "The danger is not lack of religious language but refusal of light."),
                ntChapter(12, "Fear God, Seek the Kingdom", movement: "Jesus warning against hypocrisy, greed, anxiety, and unready servants", keyTruth: "the Father frees disciples from fear, greed, and anxiety as they seek His kingdom", application: "renounce one anxiety or possession that masters you", sermonFocus: "Your treasure quietly tells the truth about your heart."),
                ntChapter(13, "Repentance, Narrow Door, Kingdom Reversal", movement: "Jesus calling for repentance, healing on Sabbath, teaching the narrow door, and grieving Jerusalem", keyTruth: "God's kingdom calls for urgent repentance and reverses false security", application: "enter by repentance instead of assuming nearness is enough", sermonFocus: "Privilege near holy things is not the same as entering the kingdom."),
                ntChapter(14, "Humility at the Banquet", movement: "Jesus healing, teaching humility, warning about excuses, and naming the cost of discipleship", keyTruth: "God's banquet humbles pride and discipleship requires counting the cost", application: "take the low place and surrender what competes with Jesus", sermonFocus: "Many refuse the feast because lesser loves feel safer."),
                ntChapter(15, "Lost and Found", movement: "Jesus answering criticism with parables of lost sheep, coin, and sons", keyTruth: "God rejoices to seek and receive the lost while exposing resentful self-righteousness", application: "return to the Father's mercy and rejoice when others receive grace", sermonFocus: "The older brother can be near the house and far from the Father's heart."),
                ntChapter(16, "Stewardship and Eternal Reversal", movement: "Jesus teaching about money, faithfulness, law, and the rich man and Lazarus", keyTruth: "earthly stewardship reveals eternal allegiance", application: "use money faithfully before it uses you", sermonFocus: "Wealth can make eternity feel unreal until it is too late."),
                ntChapter(17, "Faith, Gratitude, and the Coming Kingdom", movement: "Jesus teaching forgiveness, faith, servant duty, grateful healing, and the kingdom's coming", keyTruth: "ordinary obedience, thankful faith, and readiness mark kingdom people", application: "forgive, give thanks, and live ready for the Son of Man", sermonFocus: "The grateful outsider may see mercy more clearly than the entitled insider."),
                ntChapter(18, "Persistent Prayer and Humble Entrance", movement: "Jesus teaching prayer, humility, childlike reception, wealth's danger, cross prediction, and blind faith", keyTruth: "God receives humble dependence and exposes self-trusting religion", application: "pray persistently and come to God like the tax collector", sermonFocus: "The prayer God receives is not self-congratulation but mercy-seeking humility."),
                ntChapter(19, "Salvation Comes Near", movement: "Zacchaeus receiving Jesus, a stewardship parable, and Jesus entering Jerusalem weeping", keyTruth: "the Son of Man seeks the lost and holds servants accountable until His return", application: "welcome Jesus with repentance that touches your possessions", sermonFocus: "Real salvation rearranges what the hands do with money and mercy."),
                ntChapter(20, "Rejected Authority and Resurrection Hope", movement: "leaders challenging Jesus, parables exposing rejection, traps about Caesar and resurrection, and warnings about scribes", keyTruth: "Jesus' authority exposes corrupt leadership and anchors hope beyond death", application: "submit to Jesus' authority over every competing claim", sermonFocus: "The stone rejected by builders becomes the stone that judges the builders."),
                ntChapter(21, "Watchful Endurance", movement: "the widow's offering, temple judgment, signs, persecution, and watchfulness", keyTruth: "disciples endure coming upheaval by trusting Jesus' words", application: "practice costly faithfulness and stay spiritually awake", sermonFocus: "Jesus values costly trust more than impressive abundance."),
                ntChapter(22, "The Table, the Cup, and the Trial", movement: "betrayal, Passover, kingdom greatness, Gethsemane, arrest, denial, and trial", keyTruth: "Jesus gives Himself in covenant faithfulness while disciples reveal weakness", application: "receive the cup of covenant mercy and watch against self-confidence", sermonFocus: "Peter's confidence collapses, but Jesus' intercession does not."),
                ntChapter(23, "The Innocent King Crucified", movement: "Jesus before rulers, crucified between criminals, forgiving enemies, saving a thief, dying, and being buried", keyTruth: "the innocent King saves sinners through the cross", application: "turn to the crucified Christ with the thief's desperate faith", sermonFocus: "The kingdom opens to the guilty who stop defending themselves and ask for mercy."),
                ntChapter(24, "Resurrection, Scripture, and Witness", movement: "the empty tomb, Emmaus, opened Scriptures, Jesus appearing, and mission promised", keyTruth: "the risen Christ opens Scripture and sends witnesses in the power promised from above", application: "read Scripture through Christ and bear witness with hope", sermonFocus: "Resurrection turns confusion into worship and witness.")
            ]
        ),
        NTBookLessonPlan(
            id: "john",
            name: "John",
            authorNote: "John writes as an eyewitness so readers may believe that Jesus is the Christ, the Son of God, and have life in His name.",
            audienceNote: "John addresses readers who need assurance, clear Christology, and living faith, presenting signs and discourses that reveal Jesus' divine identity.",
            historyFrame: "Jewish feasts, temple conflict, synagogue pressure, and intimate eyewitness testimony centered on Jesus' signs, words, death, and resurrection",
            theologicalLens: "John reveals Jesus as the eternal Word, Son, Lamb, I AM, Shepherd, Resurrection, Way, Truth, Life, and risen Lord.",
            convictionThread: "John convicts unbelief that sees signs without surrender, loves darkness, or wants life apart from the Son.",
            discipleshipThread: "John forms believers to abide, believe, love, bear witness, receive the Spirit, and confess Jesus as Lord and God.",
            scriptureLinks: [
                ScriptureLinkContent(reference: "Genesis 1:1", summary: "John opens in creation language to reveal the eternal Word."),
                ScriptureLinkContent(reference: "Exodus 3:14", summary: "Jesus' I AM sayings echo God's covenant self-revelation."),
                ScriptureLinkContent(reference: "1 John 5:13", summary: "John's purpose includes assurance of eternal life for believers in the Son.")
            ],
            chapters: [
                ntChapter(1, "The Word Became Flesh", movement: "John announcing the eternal Word, the witness of John the Baptist, and the first disciples meeting Jesus", keyTruth: "Jesus is the eternal Word made flesh, full of grace and truth", application: "behold Christ's glory and bear witness to Him", sermonFocus: "Christian faith begins not with self-improvement but with the eternal Son coming near."),
                ntChapter(2, "New Wine and True Temple", movement: "Jesus revealing glory at Cana and cleansing the temple while pointing to His body", keyTruth: "Jesus brings messianic joy and replaces corrupt temple confidence with Himself", application: "trust Jesus' timing and let Him cleanse false worship", sermonFocus: "The signs are not entertainment; they reveal glory and demand faith."),
                ntChapter(3, "New Birth and God's Love", movement: "Jesus teaching Nicodemus new birth and John exalting the Son above himself", keyTruth: "eternal life comes by Spirit-given new birth and faith in the lifted-up Son", application: "come into the light and believe in the Son", sermonFocus: "Religious knowledge cannot replace being born from above."),
                ntChapter(4, "Living Water for Outsiders", movement: "Jesus meeting the Samaritan woman, teaching true worship, and healing an official's son", keyTruth: "Jesus gives living water and seeks true worshipers beyond expected boundaries", application: "bring thirst and shame to Jesus instead of hiding", sermonFocus: "Jesus is not embarrassed to meet sinners at the well of their need."),
                ntChapter(5, "The Son's Authority", movement: "Jesus healing on the Sabbath and declaring His authority, witness, and life-giving power", keyTruth: "the Son does the Father's works and gives life to those who hear Him", application: "honor the Son and stop using Scripture to avoid Him", sermonFocus: "It is possible to search Scripture and still refuse the One Scripture reveals."),
                ntChapter(6, "Bread of Life", movement: "Jesus feeding the crowd, walking on water, teaching the bread of life, and exposing false discipleship", keyTruth: "Jesus Himself is the bread from heaven who gives eternal life", application: "seek Christ Himself above the gifts He provides", sermonFocus: "Many want bread from Jesus but not the life of Jesus."),
                ntChapter(7, "Living Water and Divided Crowds", movement: "Jesus teaching at the feast, promising living water, and dividing the crowd over His identity", keyTruth: "Jesus satisfies spiritual thirst and exposes divided responses to His word", application: "come to Jesus thirsty and submit to His teaching", sermonFocus: "Neutrality collapses when Jesus speaks with divine authority."),
                ntChapter(8, "Light, Truth, and Freedom", movement: "Jesus confronting sin, declaring Himself light, promising freedom, and revealing I AM identity", keyTruth: "the truth of the Son sets people free from sin and darkness", application: "abide in Jesus' word and let truth expose slavery", sermonFocus: "Freedom is not doing whatever you want; it is being freed by the Son."),
                ntChapter(9, "Blindness and True Sight", movement: "Jesus healing a man born blind and exposing the blindness of religious leaders", keyTruth: "Jesus gives sight while exposing proud spiritual blindness", application: "confess where pride has kept you from seeing", sermonFocus: "The healed blind man sees more clearly than experts who refuse the Light."),
                ntChapter(10, "The Good Shepherd", movement: "Jesus revealing Himself as the door, good shepherd, and one with the Father", keyTruth: "Jesus lays down His life for His sheep and holds them securely", application: "listen to the Shepherd's voice and follow Him", sermonFocus: "Security is not found in self-protection but in the Shepherd who gives His life."),
                ntChapter(11, "Resurrection and Life", movement: "Jesus raising Lazarus and intensifying the leaders' plot against Him", keyTruth: "Jesus is the resurrection and the life whose glory shines even at the grave", application: "bring grief and delayed hopes to Jesus in faith", sermonFocus: "Jesus does not merely comfort mourners; He confronts death itself."),
                ntChapter(12, "Glory through Death", movement: "Mary anointing Jesus, the King entering Jerusalem, Greeks seeking Him, and Jesus teaching that glory comes through death", keyTruth: "Jesus' hour reveals glory through sacrificial death", application: "follow Jesus by losing life rather than clinging to it", sermonFocus: "The grain of wheat bears fruit only by falling into the ground and dying."),
                ntChapter(13, "Love in the Upper Room", movement: "Jesus washing feet, exposing betrayal, and commanding love", keyTruth: "the Lord loves His own to the end and commands humble love", application: "serve someone lowly as an act of Christ-shaped love", sermonFocus: "Jesus washes feet while knowing betrayal is in the room."),
                ntChapter(14, "Way, Truth, Life, and Spirit", movement: "Jesus comforting troubled disciples, revealing the Father, and promising the Spirit", keyTruth: "Jesus is the only way to the Father and gives the Spirit to His people", application: "bring troubled hearts under Christ's promise and obey from love", sermonFocus: "Comfort is not vague optimism; it is the person and promise of Christ."),
                ntChapter(15, "Abide and Bear Fruit", movement: "Jesus teaching the vine, love, obedience, hatred from the world, and witness by the Spirit", keyTruth: "fruitful disciples abide in Christ and love under pressure", application: "abide in Christ through obedient love today", sermonFocus: "Branches do not produce life by trying harder apart from the vine."),
                ntChapter(16, "The Spirit and Sorrow Turned to Joy", movement: "Jesus preparing disciples for persecution, explaining the Spirit's work, and promising joy after sorrow", keyTruth: "the Spirit guides disciples as Jesus turns sorrow into joy", application: "trust Christ's victory when obedience brings grief", sermonFocus: "Jesus does not deny sorrow; He promises joy on the other side of His victory."),
                ntChapter(17, "The Son Prays for His People", movement: "Jesus praying for glory, protection, sanctification, unity, and future believers", keyTruth: "Jesus intercedes for His people to be kept, sanctified, unified, and brought to glory", application: "live as one kept by Jesus and set apart by truth", sermonFocus: "Before the cross, Jesus carries His people to the Father in prayer."),
                ntChapter(18, "The True King on Trial", movement: "Jesus being arrested, Peter denying, and Jesus testifying before Pilate", keyTruth: "Jesus is the true King whose kingdom is not from this world", application: "confess allegiance to Christ when pressure makes denial easier", sermonFocus: "Peter hides while Jesus bears witness openly."),
                ntChapter(19, "It Is Finished", movement: "Jesus being condemned, crucified, completing Scripture, dying, and being buried", keyTruth: "Jesus completes the saving work of God through the cross", application: "rest in His finished work and respond with worship", sermonFocus: "The cross is not defeat interrupting glory; it is glory accomplishing redemption."),
                ntChapter(20, "Seeing and Believing", movement: "the empty tomb, Mary meeting Jesus, the disciples receiving peace, and Thomas confessing", keyTruth: "the risen Jesus brings peace and calls for believing witness", application: "move from doubt toward confession: My Lord and my God", sermonFocus: "Jesus meets fearful and doubting disciples with wounds that speak peace."),
                ntChapter(21, "Restored Love and Shepherding", movement: "Jesus meeting disciples by the sea, restoring Peter, and calling him to shepherd and follow", keyTruth: "the risen Lord restores failed disciples into love, service, and costly following", application: "answer Jesus' call to love Him by feeding His people and following Him", sermonFocus: "Failure is not the final word when the risen Christ restores love and calling.")
            ]
        ),
        NTBookLessonPlan(
            id: "acts",
            name: "Acts",
            authorNote: "Acts is Luke's second volume, tracing the risen Jesus' work through the Holy Spirit, the apostles, and the expanding witness of the church.",
            audienceNote: "Acts strengthens believers to see that the gospel advances through prayer, Spirit power, suffering, preaching, holiness, and mission across ethnic boundaries.",
            historyFrame: "Jerusalem, Judea, Samaria, and the Roman world, where the church bears witness under temple authority, local opposition, imperial structures, and cross-cultural mission",
            theologicalLens: "Acts shows the risen Christ ruling and expanding His church by the Spirit through witness to the ends of the earth.",
            convictionThread: "Acts convicts prayerless ministry, fear of witness, ethnic pride, hypocrisy, and attempts to control the Spirit for human power.",
            discipleshipThread: "Acts forms believers to pray, witness, share life, endure opposition, guard holiness, cross boundaries, and trust God in mission.",
            scriptureLinks: [
                ScriptureLinkContent(reference: "Luke 24:46-49", summary: "Acts continues Jesus' promise of witness and power from Luke's Gospel."),
                ScriptureLinkContent(reference: "Joel 2:28-32", summary: "Peter interprets Pentecost through Joel's promise of the Spirit."),
                ScriptureLinkContent(reference: "Isaiah 49:6", summary: "The mission to the nations fulfills the servant-shaped hope of light to the ends of the earth.")
            ],
            chapters: [
                ntChapter(1, "Witnesses Waiting for Power", movement: "Jesus promising Spirit-empowered witness, ascending, and the apostles prayerfully replacing Judas", keyTruth: "the risen Jesus sends witnesses by the Spirit's power", application: "wait on God in prayer and receive mission as obedience", sermonFocus: "The church's mission begins not with strategy but with the risen Lord's promise."),
                ntChapter(2, "Pentecost and the New Community", movement: "the Spirit coming, Peter preaching Christ, many repenting, and the church sharing devoted life", keyTruth: "the Spirit empowers witness to the crucified and risen Lord", application: "repent, receive the gospel, and devote yourself to Word, fellowship, prayer, and generosity", sermonFocus: "The Spirit creates not spectacle only, but a repentant and devoted people."),
                ntChapter(3, "Healing and Witness at the Temple", movement: "a lame man healed and Peter preaching Jesus as the Author of life", keyTruth: "the risen Jesus restores and His name demands repentance", application: "point mercy back to Christ and call people to turn to Him", sermonFocus: "A miracle becomes witness when attention moves from servants to the Savior."),
                ntChapter(4, "Boldness under Threat", movement: "leaders opposing the apostles, Peter testifying, believers praying, and the church sharing boldly", keyTruth: "the name of Jesus is the only salvation and cannot be silenced", application: "pray for boldness instead of comfort when witness is opposed", sermonFocus: "Threatened believers ask not for safety first but for courage."),
                ntChapter(5, "Holiness, Fear, and Obedience", movement: "Ananias and Sapphira judged, signs continuing, apostles arrested, and obedience to God defended", keyTruth: "the Spirit-filled church must be holy and obey God over human pressure", application: "reject hidden hypocrisy and obey God when costly", sermonFocus: "The church cannot carry holy witness while making peace with holy pretense."),
                ntChapter(6, "Servants, Wisdom, and Opposition", movement: "the church appointing servants and Stephen's Spirit-filled ministry provoking opposition", keyTruth: "Spirit-filled wisdom protects unity and advances the Word", application: "serve practical needs as part of gospel faithfulness", sermonFocus: "Healthy mission refuses to choose between Word and care."),
                ntChapter(7, "Stephen's Witness and Martyrdom", movement: "Stephen retelling Israel's resistance and seeing the Son of Man before his death", keyTruth: "God's people have often resisted His messengers, but Jesus reigns as the exalted Son of Man", application: "bear witness with forgiveness even when opposed", sermonFocus: "Stephen dies seeing the glory his accusers refuse to behold."),
                ntChapter(8, "Gospel beyond Jerusalem", movement: "persecution scattering believers, Samaria receiving the word, Simon exposed, and the Ethiopian believing", keyTruth: "God uses scattering to spread the gospel across boundaries", application: "follow the Spirit into unexpected witness", sermonFocus: "What looks like setback may become mission in God's hands."),
                ntChapter(9, "Saul Converted and Called", movement: "Saul meeting the risen Jesus, being healed, preaching, and Peter ministering restoration", keyTruth: "Jesus can turn His enemy into His witness", application: "trust Christ's power to save and redirect even the hardest life", sermonFocus: "Grace does not merely forgive Saul; it gives him a new Lord and mission."),
                ntChapter(10, "Gentiles Receive the Spirit", movement: "Cornelius and Peter receiving visions, the gospel preached, and Gentiles receiving the Spirit", keyTruth: "God cleanses Gentiles by faith and welcomes them into His people", application: "renounce partiality and follow God across boundaries", sermonFocus: "The Spirit destroys categories we use to keep mercy contained."),
                ntChapter(11, "Grace Defended and the Church Grows", movement: "Peter explaining Gentile inclusion, Antioch growing, and believers sending famine relief", keyTruth: "the church must recognize and rejoice in God's grace to unexpected people", application: "defend grace where God gives repentance and practice generous fellowship", sermonFocus: "A church shaped by grace rejoices when outsiders become family."),
                ntChapter(12, "Prayer and Deliverance", movement: "James killed, Peter imprisoned and delivered, Herod judged, and the Word increasing", keyTruth: "God's Word advances despite violent rulers and impossible prisons", application: "pray earnestly and trust God when outcomes differ", sermonFocus: "The chapter holds martyrdom and deliverance together under God's sovereign mission."),
                ntChapter(13, "Mission to the Nations Begins", movement: "the Spirit sending Barnabas and Saul, Paul preaching in Pisidian Antioch, and Gentiles rejoicing", keyTruth: "the Spirit sends the church to proclaim forgiveness and justification in Christ", application: "receive the mission and speak Christ from Scripture", sermonFocus: "The gospel goes public: forgiveness and justification are announced in Jesus."),
                ntChapter(14, "Endurance in Mission", movement: "gospel advance, opposition, healing, mistaken worship, suffering, and strengthening churches", keyTruth: "mission advances through suffering and perseverance under God's grace", application: "continue in faith through hardship rather than reading opposition as failure", sermonFocus: "The kingdom path includes tribulation, but grace keeps planting churches."),
                ntChapter(15, "Grace and Gentile Belonging", movement: "the Jerusalem council affirming salvation by grace and sending guidance to Gentile believers", keyTruth: "Gentiles are saved by the grace of Jesus, not by becoming culturally Jewish", application: "guard gospel grace and practice love that protects fellowship", sermonFocus: "Adding cultural terms to grace threatens the heart of the gospel."),
                ntChapter(16, "Guided, Imprisoned, and Singing", movement: "Paul receiving Macedonian guidance, Lydia believing, a girl delivered, and a jailer saved", keyTruth: "the Spirit guides mission and turns suffering into witness", application: "worship faithfully in confinement and speak hope to those around you", sermonFocus: "Songs in prison may become the sound through which someone hears salvation."),
                ntChapter(17, "Reasoning in Synagogue and City", movement: "Paul preaching in Thessalonica, Berea, and Athens, reasoning from Scripture and creation", keyTruth: "the gospel confronts both synagogue expectation and pagan ignorance with the risen Christ", application: "search Scripture eagerly and speak Christ wisely in your culture", sermonFocus: "The unknown god becomes known only through the risen Jesus."),
                ntChapter(18, "Strengthened for Continued Witness", movement: "Paul ministering in Corinth, being encouraged by the Lord, and Apollos being instructed more accurately", keyTruth: "the Lord sustains gospel workers and refines teachers for accurate witness", application: "keep speaking and stay teachable", sermonFocus: "Courage grows when the Lord says He has people in the city."),
                ntChapter(19, "The Word Prevails in Ephesus", movement: "disciples receiving fuller instruction, extraordinary signs, repentance from magic, and idol economy threatened", keyTruth: "the Word of the Lord prevails over counterfeit power and idolatry", application: "renounce hidden practices that compete with Christ", sermonFocus: "When the gospel threatens idols, the economy of sin gets loud."),
                ntChapter(20, "Tears, Watchfulness, and the Word of Grace", movement: "Paul encouraging churches, raising Eutychus, and charging Ephesian elders with tearful warning", keyTruth: "church leaders must shepherd watchfully under the word of grace", application: "serve with humility and guard the flock from distortion", sermonFocus: "Faithful ministry is not performance; it is tears, truth, and costly care."),
                ntChapter(21, "Costly Obedience to Jerusalem", movement: "Paul traveling to Jerusalem, being warned, welcomed, accused, and arrested", keyTruth: "obedience to mission may lead directly into suffering", application: "follow Christ even when faithful friends fear the cost", sermonFocus: "Love may warn, but obedience must still answer the Lord's call."),
                ntChapter(22, "A Testimony before Hostility", movement: "Paul recounting conversion and calling before a hostile crowd", keyTruth: "personal testimony bears witness to Christ's grace and commission", application: "learn to tell how Christ met you and what He commands now", sermonFocus: "A testimony is not self-display; it is evidence of the Lord's mercy and authority."),
                ntChapter(23, "The Lord Stands by Paul", movement: "Paul before the council, receiving the Lord's promise, and being protected from a plot", keyTruth: "the Lord stands with His witness and governs threats against mission", application: "take courage from Christ's presence in conflict", sermonFocus: "The Lord's promise can stand stronger than a conspiracy."),
                ntChapter(24, "Righteousness before Felix", movement: "Paul defending himself and reasoning about righteousness, self-control, and judgment before Felix", keyTruth: "the gospel speaks to public accusation and private conscience", application: "do not postpone repentance when conviction comes", sermonFocus: "Felix trembles but delays, showing how fear can stop short of faith."),
                ntChapter(25, "Appeal to Caesar", movement: "Paul facing Festus, appealing to Caesar, and having his case explained before Agrippa", keyTruth: "God uses legal processes to carry witness toward Rome", application: "trust God's providence inside slow and imperfect systems", sermonFocus: "Mission can move through courtrooms as surely as through open doors."),
                ntChapter(26, "Almost Persuaded", movement: "Paul testifying before Agrippa about resurrection, repentance, and his calling to Gentiles", keyTruth: "the risen Christ sends witnesses to open eyes and turn people from darkness", application: "respond fully to Christ instead of stopping at almost persuaded", sermonFocus: "Almost is a tragic place to stand when resurrection truth is before you."),
                ntChapter(27, "Providence in the Storm", movement: "Paul sailing toward Rome, enduring a violent storm, and encouraging everyone with God's promise", keyTruth: "God preserves His servant and keeps His promise through terrifying circumstances", application: "speak courage from God's word while the storm is still raging", sermonFocus: "Faith does not deny the storm; it trusts the God who has spoken inside it."),
                ntChapter(28, "Unhindered Witness in Rome", movement: "Paul surviving Malta, healing, reaching Rome, preaching the kingdom, and teaching about Jesus unhindered", keyTruth: "the Word of God continues unhindered to the heart of empire", application: "keep proclaiming the kingdom wherever God places you", sermonFocus: "Acts ends with chains on Paul but no chains on the gospel.")
            ]
        ),
        NTBookLessonPlan(
            id: "romans",
            name: "Romans",
            authorNote: "Romans is Paul's carefully argued gospel letter to believers in Rome. He had not yet visited them, so he writes a wide, ordered presentation of sin, grace, justification, union with Christ, life in the Spirit, Israel, mercy, and transformed obedience.",
            audienceNote: "The first hearers were Jewish and Gentile believers learning to live as one church under the righteousness of God revealed in Christ, not under pride, ethnicity, law-keeping, or self-made status.",
            historyFrame: "the Roman capital and its mixed house churches, where Jewish-Gentile tensions, imperial power, moral confusion, and questions about the law all meet Paul's gospel of righteousness by faith",
            theologicalLens: "Romans reveals God's righteousness in the gospel: sinners are justified by faith, united to Christ, freed from condemnation, renewed by the Spirit, and made into a merciful people.",
            convictionThread: "Romans convicts self-righteousness, secret sin, boasting, despair, shallow grace, ethnic pride, and any attempt to live the Christian life by flesh instead of the Spirit.",
            discipleshipThread: "Romans forms believers to repent honestly, trust Christ's finished work, walk by the Spirit, worship through obedience, love the body, submit humbly, and overcome evil with good.",
            scriptureLinks: [
                ScriptureLinkContent(reference: "Genesis 15:6", summary: "Paul uses Abraham to show that righteousness is received by faith, not achieved by works."),
                ScriptureLinkContent(reference: "Habakkuk 2:4", summary: "Romans opens with the righteous living by faith, echoing Habakkuk's trust under pressure."),
                ScriptureLinkContent(reference: "Ezekiel 36:26-27", summary: "Life in the Spirit answers the prophetic hope of a renewed heart and Spirit-enabled obedience.")
            ],
            chapters: [
                ntChapter(1, "The Gospel Reveals God's Righteousness", movement: "Paul introducing his gospel, longing for Rome, announcing righteousness by faith, and exposing Gentile rebellion", keyTruth: "the gospel reveals God's righteousness while human sin suppresses the truth", application: "stop hiding from conviction and receive the gospel as God's power to save", sermonFocus: "The same chapter that announces saving power also exposes why every person needs it."),
                ntChapter(2, "Judgment, Hypocrisy, and True Obedience", movement: "Paul confronting judgmental hypocrisy, false security in law, and the need for inward covenant reality", keyTruth: "God's judgment is impartial and exposes religion that judges others while excusing itself", application: "repent of hidden hypocrisy before correcting someone else", sermonFocus: "Knowing the law cannot save a heart that refuses to obey God."),
                ntChapter(3, "All Under Sin, Justified by Grace", movement: "Paul proving universal guilt and then declaring justification through Christ's redemption", keyTruth: "all have sinned, but God justifies by grace through faith in Jesus Christ", application: "renounce boasting and rest in Christ's atoning work", sermonFocus: "The gospel does not lower God's justice; it satisfies it in Christ."),
                ntChapter(4, "Abraham and Righteousness by Faith", movement: "Paul showing from Abraham and David that righteousness is credited by faith apart from works", keyTruth: "God counts righteousness to those who trust His promise like Abraham did", application: "believe God's promise instead of building confidence on spiritual resume", sermonFocus: "Abraham's faith looked away from his weakness and toward the God who gives life."),
                ntChapter(5, "Peace, Hope, and the New Adam", movement: "Paul celebrating peace with God, hope through suffering, love poured out, and Christ's victory over Adam's ruin", keyTruth: "Christ brings justification, hope, and life stronger than Adam's sin and death", application: "stand in grace and let suffering produce hope rather than bitterness", sermonFocus: "Grace does not merely repair what Adam broke; it overflows through Christ."),
                ntChapter(6, "Dead to Sin, Alive to God", movement: "Paul rejecting shallow grace and teaching union with Christ in death and resurrection", keyTruth: "believers united to Christ must no longer present themselves as slaves to sin", application: "present your body to God in a specific act of obedience today", sermonFocus: "Grace is not permission to stay enslaved; it is power to live alive to God."),
                ntChapter(7, "Law, Sin, and the Divided Struggle", movement: "Paul explaining the law's goodness, sin's misuse of commandment, and the anguished struggle needing deliverance", keyTruth: "God's law exposes sin, but deliverance comes through Jesus Christ our Lord", application: "bring your real struggle to Christ instead of pretending the flesh can fix itself", sermonFocus: "The cry for rescue is not weakness to hide; it is honesty that points to Christ."),
                ntChapter(8, "No Condemnation and Spirit Life", movement: "Paul proclaiming no condemnation, Spirit-led adoption, suffering with hope, intercession, and inseparable love", keyTruth: "those in Christ are free from condemnation and kept by the Spirit in God's unbreakable love", application: "walk as an adopted child instead of obeying fear", sermonFocus: "Romans 8 lifts the believer from courtroom freedom into family security and future glory."),
                ntChapter(9, "God's Mercy and Israel's Question", movement: "Paul grieving Israel, defending God's promise, and emphasizing mercy over human claim", keyTruth: "God's saving promise rests on His mercy, not human entitlement", application: "let God's mercy humble your assumptions and deepen prayer for the lost", sermonFocus: "Paul's doctrine of mercy does not make him cold; it makes him grieve and pray."),
                ntChapter(10, "Christ, Faith, and Gospel Proclamation", movement: "Paul contrasting misguided zeal with righteousness by faith and the preached word of Christ", keyTruth: "Christ is the end of the law for righteousness to everyone who believes", application: "confess Christ openly and support faithful gospel proclamation", sermonFocus: "Zeal without submission to Christ can be religious and still wrong."),
                ntChapter(11, "Mercy, Mystery, and Worship", movement: "Paul explaining Israel's remnant, Gentile humility, future mercy, and ending in doxology", keyTruth: "God's mercy humbles both Jew and Gentile and leads the church into worship", application: "reject arrogance and worship the depth of God's wisdom", sermonFocus: "True theology should end with bowed hearts, not boastful arguments."),
                ntChapter(12, "Living Sacrifices and Sincere Love", movement: "Paul calling believers to bodily worship, renewed minds, humble gifts, sincere love, and overcoming evil with good", keyTruth: "the mercy of God creates a transformed life of humble worship and love", application: "offer one ordinary part of your body and schedule to God as worship", sermonFocus: "The gospel moves from doctrine into the body, the calendar, the church, and the enemy."),
                ntChapter(13, "Authority, Love, and Wakefulness", movement: "Paul teaching submission to authorities, love as law's fulfillment, and wakeful holiness", keyTruth: "believers live responsibly in the present because salvation's day is drawing near", application: "put off one work of darkness and practice neighbor-love", sermonFocus: "Christian freedom never becomes careless living; the day is near."),
                ntChapter(14, "Weak, Strong, and the Lord's Servants", movement: "Paul addressing disputed practices, conscience, judgment, and love inside the church", keyTruth: "Christians belong to the Lord and must not destroy one another over disputable matters", application: "choose love over winning a preference dispute", sermonFocus: "A correct opinion can become sin when it crushes a brother or sister Christ received."),
                ntChapter(15, "Christlike Welcome and Mission", movement: "Paul urging strong believers to bear with the weak, grounding unity in Scripture, and describing his Gentile mission", keyTruth: "Christ's welcome creates Scripture-shaped unity and outward mission", application: "welcome another believer with Christlike patience and pray for mission", sermonFocus: "The church's unity is not comfort with sameness; it is worship shaped by Christ's mercy."),
                ntChapter(16, "Names, Partnership, and Guarded Unity", movement: "Paul greeting many coworkers, warning against division, and praising God for the revealed mystery", keyTruth: "gospel doctrine creates real partnership and must be guarded from divisive distortion", application: "honor faithful servants and guard unity around apostolic truth", sermonFocus: "Romans ends with names because doctrine is meant to build a real family of mission.")
            ]
        ),
        NTBookLessonPlan(
            id: "1-corinthians",
            name: "1 Corinthians",
            authorNote: "First Corinthians is Paul's pastoral correction to a gifted but troubled church in Corinth. He writes as a founding apostle to call them back to the cross, holiness, love, order, resurrection hope, and unity under Christ.",
            audienceNote: "The first hearers were believers living in a wealthy, status-conscious, sexually confused, rhetorically proud city. Their church had real gifts, but also factions, lawsuits, immorality, worship disorder, and confusion about resurrection.",
            historyFrame: "the Roman city of Corinth, known for trade, status competition, temples, public rhetoric, sexual immorality, and house-church tensions that tested whether the gospel would reshape community life",
            theologicalLens: "First Corinthians applies the cross of Christ to church life: God's wisdom humbles pride, holiness protects the body, love governs gifts, and resurrection hope anchors endurance.",
            convictionThread: "First Corinthians convicts celebrity culture, spiritual pride, sexual compromise, selfish freedom, disorderly worship, loveless giftedness, and denial of bodily resurrection.",
            discipleshipThread: "First Corinthians forms believers to boast only in the Lord, flee immorality, honor the body, love the church, use gifts to build others, and stand firm in resurrection hope.",
            scriptureLinks: [
                ScriptureLinkContent(reference: "Isaiah 29:14", summary: "Paul's warning about worldly wisdom draws on God's promise to overturn proud human understanding."),
                ScriptureLinkContent(reference: "Genesis 2:24", summary: "Paul's sexual ethics and teaching on the body echo God's creation design for covenant union."),
                ScriptureLinkContent(reference: "Hosea 13:14", summary: "Paul's resurrection victory language draws from the prophetic hope that death will be defeated.")
            ],
            chapters: [
                ntChapter(1, "The Cross and a Divided Church", movement: "Paul thanking God for grace, confronting factions, and exalting the cross over worldly wisdom", keyTruth: "the message of the cross destroys boasting and unites believers under Christ", application: "stop building identity around favorite leaders and boast in the Lord", sermonFocus: "A church can be gifted and still be divided when the cross is not central."),
                ntChapter(2, "Wisdom from the Spirit", movement: "Paul rejecting showy eloquence, preaching Christ crucified, and explaining wisdom revealed by the Spirit", keyTruth: "God's wisdom is revealed by the Spirit and centered on the crucified Christ", application: "seek Spirit-given understanding instead of impressive religious performance", sermonFocus: "The church does not need a stage-managed gospel; it needs Christ crucified in Spirit power."),
                ntChapter(3, "God's Field and Building", movement: "Paul exposing jealousy, correcting leader-worship, and warning how builders work on God's temple", keyTruth: "the church belongs to God, so leaders are servants and believers must build carefully", application: "serve faithfully without turning ministers into trophies", sermonFocus: "When people say 'my leader' more loudly than 'God's church,' immaturity is showing."),
                ntChapter(4, "Servants, Stewards, and Apostolic Humility", movement: "Paul describing apostolic stewardship, confronting arrogance, and appealing as a father", keyTruth: "faithful ministry is stewardship before God, not status before people", application: "trade spiritual arrogance for humble faithfulness", sermonFocus: "The Corinthians wanted kingly status while Paul displayed cross-shaped weakness."),
                ntChapter(5, "Holiness and Church Discipline", movement: "Paul confronting tolerated sexual immorality and commanding serious church discipline", keyTruth: "Christ's church must not boast while tolerating open, destructive sin", application: "take holiness seriously and seek restoration through truth", sermonFocus: "False compassion lets sin destroy what discipline is meant to heal."),
                ntChapter(6, "Lawsuits, Bodies, and Belonging", movement: "Paul addressing lawsuits among believers and teaching that bodies belong to the Lord", keyTruth: "believers are washed, bought, and joined to Christ, so their bodies must glorify God", application: "flee sexual immorality and honor God with your body", sermonFocus: "The body is not disposable material; it is for the Lord and destined for resurrection."),
                ntChapter(7, "Marriage, Singleness, and Faithful Calling", movement: "Paul giving counsel on marriage, singleness, divorce, mixed marriages, and remaining faithful in one's calling", keyTruth: "every marital or single calling must be lived in devotion to the Lord", application: "serve Christ faithfully in your present season without envy or fear", sermonFocus: "Paul refuses to make marriage or singleness an idol; both must bow to undivided devotion."),
                ntChapter(8, "Knowledge, Love, and the Weak", movement: "Paul addressing food offered to idols and showing that love limits freedom for a weaker conscience", keyTruth: "knowledge without love can wound people Christ values", application: "limit a freedom when love for another believer requires it", sermonFocus: "Being technically right is not enough if your freedom trains another person's conscience toward harm."),
                ntChapter(9, "Rights Surrendered for the Gospel", movement: "Paul defending apostolic rights, surrendering them for mission, and disciplining himself for the prize", keyTruth: "gospel servants may surrender legitimate rights to remove obstacles to Christ", application: "give up one preference for the sake of another person's good", sermonFocus: "Christian freedom is strongest when it can lay itself down for mission."),
                ntChapter(10, "Warnings, Temptation, and God's Glory", movement: "Paul warning from Israel's failures, promising God's faithfulness in temptation, and calling all things toward God's glory", keyTruth: "God's people must flee idolatry and use freedom for His glory and others' good", application: "identify one escape God provides from a present temptation and take it", sermonFocus: "Temptation is common, but compromise is not inevitable because God is faithful."),
                ntChapter(11, "Order, Honor, and the Lord's Supper", movement: "Paul addressing worship honor and correcting selfish divisions at the Lord's Supper", keyTruth: "worship must honor God's order and Christ's body, not reinforce selfish status", application: "come to worship with humility, unity, and serious remembrance of Christ", sermonFocus: "The Lord's table rebukes a church that eats while humiliating its own members."),
                ntChapter(12, "One Body, Many Gifts", movement: "Paul teaching Spirit-given confession, diverse gifts, and one body with many members", keyTruth: "the Spirit gives different gifts so the one body of Christ is built together", application: "use your gift to serve the body and honor members that seem weaker", sermonFocus: "Diversity of gifts is not competition; it is God's design for mutual care."),
                ntChapter(13, "The More Excellent Way of Love", movement: "Paul showing that gifts without love are empty and that love endures beyond partial knowledge", keyTruth: "love is the necessary way that gives spiritual gifts their godly shape", application: "practice patient, humble love before trying to prove giftedness", sermonFocus: "Loveless giftedness can sound impressive and still be nothing."),
                ntChapter(14, "Gifts That Build the Church", movement: "Paul regulating prophecy, tongues, interpretation, and orderly worship for edification", keyTruth: "spiritual gifts must be used intelligibly and orderly to build up the church", application: "measure spiritual expression by whether it strengthens others", sermonFocus: "The Spirit is not honored by confusion that leaves the church unbuilt."),
                ntChapter(15, "Resurrection at the Center", movement: "Paul rehearsing the gospel, defending bodily resurrection, and proclaiming victory over death", keyTruth: "Christ's resurrection guarantees believers' resurrection and makes labor in the Lord meaningful", application: "stand firm because your labor in the risen Christ is not vain", sermonFocus: "If resurrection falls, Christian faith collapses; because Christ is risen, hope stands."),
                ntChapter(16, "Generosity, Watchfulness, and Love", movement: "Paul giving collection instructions, travel plans, exhortations, and final greetings", keyTruth: "resurrection-shaped believers practice generosity, courage, strength, and love", application: "do one concrete act of generous service with watchful love", sermonFocus: "Paul ends practically because resurrection hope should reshape ordinary schedules, money, and relationships.")
            ]
        )
    ]

    private static let matthewSeedsByChapter: [Int: MatthewLessonSeed] = Dictionary(
        uniqueKeysWithValues: matthewChapterSeeds.map { ($0.chapter, $0) }
    )

    private static func content(from seed: MatthewLessonSeed) -> LessonChapterContent {
        let wordInsightsByReference = Dictionary(grouping: seed.wordInsights, by: { $0.reference })

        return LessonChapterContent(
            guidedPathPoints: [
                "Read Matthew \(seed.chapter) slowly from beginning to end. Track the chapter movement: \(seed.movement)",
                "Underline the main truth about Jesus: \(seed.keyTruth)",
                "Notice what Matthew is doing with Old Testament promise, kingdom language, conflict, mercy, or discipleship pressure.",
                "Ask where the chapter exposes false security, shallow religion, fear, pride, or unbelief.",
                "Pray the chapter into one concrete response: \(seed.application)",
                "Review the key words and Scripture links, then reread the chapter with those connections in mind."
            ],
            sermonPoints: [
                "Matthew \(seed.chapter) is one whole message, not just a few famous lines. The chapter moves through \(seed.movement). Read it slowly and ask, \"What is Jesus showing me here?\"",
                "The main truth is simple: \(seed.keyTruth). If this is true, then we cannot just admire Jesus from a distance. We have to trust Him, listen to Him, repent where He corrects us, and obey what He says.",
                "This chapter speaks to the heart. It may expose pride, fear, shallow religion, hidden sin, or a faith that wants comfort without surrender. That is not meant to crush us. It is meant to wake us up and bring us back to the King.",
                "Matthew is also connecting this chapter to the rest of Scripture. The promises and warnings from earlier in the Bible are pointing us toward Jesus. When you tap the Scripture references below, read them like lights shining on the same truth.",
                "There is real mercy here. Jesus does not only confront sin; He also comes near to weak people. He teaches the confused, receives the humble, corrects the proud, and calls ordinary people into a better life with Him.",
                "The sermon focus is this: \(seed.sermonFocus). Let that sit with you. Where does your life line up with this chapter, and where are you resisting what God is saying?",
                "A real response is not just, \"That was a good lesson.\" A real response becomes prayer, confession, forgiveness, courage, purity, generosity, mission, and obedience in normal life.",
                "So take the chapter personally today. Receive what Jesus reveals, repent where He exposes you, and take this next step: \(seed.application)"
            ],
            scriptureLinks: seed.scriptureLinks,
            historyNotes: seed.historyNotes + nameOriginNotes(in: [
                "Matthew",
                seed.title,
                seed.movement,
                seed.keyTruth,
                seed.sermonFocus
            ]) + [
                HistoryNoteContent(
                    title: "Original language note",
                    detail: "Matthew is a Greek Gospel that constantly echoes the Hebrew Scriptures. The word study below focuses on Greek terms in Matthew and, where helpful, notes Hebrew or Aramaic background behind names, quotations, and worship language."
                )
            ],
            practiceSteps: [
                "Write a one-sentence summary of Matthew \(seed.chapter) using the words King, kingdom, and obedience.",
                "Choose one Greek word from the word study and explain how it changes the way you read the chapter.",
                "Name one specific action you will take today: \(seed.application)"
            ],
            wordInsightsByReference: wordInsightsByReference
        )
    }

    private static func quest(for seed: MatthewLessonSeed) -> WisdomQuest {
        WisdomQuest(
            passingScore: 75,
            questions: [
                WisdomQuestion(
                    id: "mt\(seed.chapter)-q1",
                    prompt: "What is the main movement of Matthew \(seed.chapter)?",
                    options: [
                        seed.movement,
                        "A random list of unrelated sayings",
                        "A break from Matthew's focus on Jesus as King",
                        "A chapter that avoids discipleship and obedience"
                    ],
                    correctIndex: 0,
                    explanation: "Matthew \(seed.chapter) should be read as one connected chapter movement, not as disconnected quotes."
                ),
                WisdomQuestion(
                    id: "mt\(seed.chapter)-q2",
                    prompt: "What main truth should shape how you read this chapter?",
                    options: [
                        "Human approval is the safest guide",
                        seed.keyTruth,
                        "The chapter is mainly about private success",
                        "Obedience is optional if the teaching is inspiring"
                    ],
                    correctIndex: 1,
                    explanation: "The chapter reveals a concrete truth about Jesus, the kingdom, and faithful response."
                ),
                WisdomQuestion(
                    id: "mt\(seed.chapter)-q3",
                    prompt: "Which reference belongs to this Matthew \(seed.chapter) lesson?",
                    options: [
                        "Genesis 1:1",
                        "Psalm 23:1",
                        seed.keyVerses.first ?? "Matthew \(seed.chapter):1",
                        "Revelation 22:21"
                    ],
                    correctIndex: 2,
                    explanation: "The key verses keep the lesson anchored in the chapter itself."
                ),
                WisdomQuestion(
                    id: "mt\(seed.chapter)-q4",
                    prompt: "What is a faithful response to this chapter?",
                    options: [
                        "Only collect information without changing",
                        "Use the chapter to judge others first",
                        "Skip the hard parts and keep the comforting parts",
                        seed.application
                    ],
                    correctIndex: 3,
                    explanation: "Matthew calls readers to concrete obedience, not passive inspiration."
                )
            ]
        )
    }

    private static func matthewChapterNumber(from lessonID: String) -> Int? {
        let prefix = "matthew-chapter-"
        guard lessonID.hasPrefix(prefix) else { return nil }
        return Int(lessonID.dropFirst(prefix.count))
    }

    private static func seed(
        _ chapter: Int,
        title: String,
        movement: String,
        keyTruth: String,
        application: String,
        sermonFocus: String,
        keyVerses: [String],
        links: [(String, String)],
        history: [(String, String)],
        words: [(String, String, String, String, String, String)]
    ) -> MatthewLessonSeed {
        MatthewLessonSeed(
            chapter: chapter,
            title: title,
            movement: movement,
            keyTruth: keyTruth,
            application: application,
            sermonFocus: sermonFocus,
            keyVerses: keyVerses,
            scriptureLinks: links.map { ScriptureLinkContent(reference: $0.0, summary: $0.1) },
            historyNotes: history.map { HistoryNoteContent(title: $0.0, detail: $0.1) },
            wordInsights: words.map {
                WordStudyInsight(
                    reference: $0.0,
                    language: $0.1,
                    word: $0.2,
                    transliteration: $0.3,
                    meaning: $0.4,
                    deeperNote: $0.5
                )
            }
        )
    }

    private static let matthewChapterSeeds: [MatthewLessonSeed] = [
        seed(
            2,
            title: "The Promised King and the Nations",
            movement: "the nations seeking the newborn King, Jerusalem resisting Him, and God preserving the child through danger and exile",
            keyTruth: "Jesus is the true King promised by Scripture, welcomed by outsiders and opposed by threatened powers",
            application: "worship Christ with costly obedience instead of protecting control like Herod",
            sermonFocus: "The heart either bows before Jesus or fights to keep its throne.",
            keyVerses: ["Matthew 2:2", "Matthew 2:6", "Matthew 2:11", "Matthew 2:15"],
            links: [
                ("Micah 5:2", "Bethlehem is promised as the birthplace of the ruler who shepherds Israel."),
                ("Hosea 11:1", "Matthew sees Jesus recapitulating Israel's story as God's faithful Son called out of Egypt."),
                ("Jeremiah 31:15", "Rachel's weeping gives biblical language to grief under violent oppression.")
            ],
            history: [
                ("Herod's kingdom", "Herod the Great was politically powerful and spiritually insecure. Matthew contrasts his fear with the magi's worship."),
                ("Magi from the east", "The magi are Gentile seekers. Their presence signals that the blessing promised to Abraham is already moving toward the nations.")
            ],
            words: [
                ("Matthew 2:2", "Greek", "προσκυνῆσαι", "proskynesai", "to worship, bow down", "The magi are not merely curious. Their posture is reverence before royal authority."),
                ("Matthew 2:6", "Greek", "ἡγούμενος", "hegoumenos", "ruler, leader", "The promised child is not sentimental decoration. He comes as ruler and shepherd."),
                ("Matthew 2:15", "Greek", "ἐπληρώθη", "eplerothe", "was fulfilled, filled up", "Fulfillment in Matthew often means the story of Israel reaches its intended fullness in Jesus.")
            ]
        ),
        seed(
            3,
            title: "Repentance and the Beloved Son",
            movement: "John preparing the wilderness road, calling for fruit-bearing repentance, and baptizing Jesus as the Father's beloved Son",
            keyTruth: "the kingdom arrives with repentance, Spirit renewal, and the public revelation of Jesus as God's beloved Son",
            application: "bring repentance into visible fruit and listen to the Father's verdict over Jesus",
            sermonFocus: "Grace does not excuse fruitless religion; it creates repentance that can be seen.",
            keyVerses: ["Matthew 3:2", "Matthew 3:8", "Matthew 3:11", "Matthew 3:17"],
            links: [
                ("Isaiah 40:3", "The wilderness voice prepares the way of the Lord, and Matthew identifies John's ministry with that promise."),
                ("Ezekiel 36:25-27", "Water and Spirit language echoes God's promise to cleanse His people and give them a new heart."),
                ("Psalm 2:7", "The Father's declaration over Jesus carries royal Sonship language from the Psalms.")
            ],
            history: [
                ("Wilderness preaching", "The wilderness recalls Israel's testing and hope. John calls Israel back to covenant seriousness outside the comfort of religious centers."),
                ("Baptism setting", "John's baptism publicly marked repentance and preparation. Jesus enters the water to identify with His people and fulfill righteousness.")
            ],
            words: [
                ("Matthew 3:2", "Greek", "μετανοεῖτε", "metanoeite", "repent, change the mind and direction", "Biblical repentance is not vague regret. It is a turning of heart, allegiance, and conduct."),
                ("Matthew 3:8", "Greek", "καρπὸν", "karpon", "fruit, visible produce", "John demands repentance that becomes visible in life."),
                ("Matthew 3:17", "Greek", "ἀγαπητός", "agapetos", "beloved", "The Father publicly delights in the Son before Jesus' public ministry begins.")
            ]
        ),
        seed(
            4,
            title: "Temptation, Light, and the First Disciples",
            movement: "Jesus defeating temptation by Scripture, announcing light in Galilee, and calling ordinary workers to follow Him",
            keyTruth: "Jesus succeeds where Israel failed and begins His kingdom mission by calling people into obedient discipleship",
            application: "answer temptation with God's Word and follow Jesus without treating obedience as optional",
            sermonFocus: "The devil offers shortcuts, but the Son walks the faithful road and calls us behind Him.",
            keyVerses: ["Matthew 4:4", "Matthew 4:10", "Matthew 4:17", "Matthew 4:19"],
            links: [
                ("Deuteronomy 8:3", "Jesus answers temptation with Israel's wilderness lesson that life depends on God's word."),
                ("Isaiah 9:1-2", "Galilee's light fulfills Isaiah's hope for people sitting in darkness."),
                ("Psalm 91:11-12", "The tempter misuses Scripture, showing why verses must be read with faithful submission to God.")
            ],
            history: [
                ("Forty days", "The forty days recall Israel's wilderness testing. Jesus stands as the faithful Son who trusts the Father."),
                ("Galilee of the nations", "Matthew highlights Galilee to show light reaching a mixed region and foreshadowing mission beyond Israel.")
            ],
            words: [
                ("Matthew 4:1", "Greek", "πειρασθῆναι", "peirasthenai", "to be tempted or tested", "The same word family can describe testing pressure and tempting assault. Jesus remains faithful under both."),
                ("Matthew 4:4", "Greek", "γέγραπται", "gegraptai", "it is written", "Jesus treats Scripture as living authority, not inspirational ornament."),
                ("Matthew 4:19", "Greek", "ἁλιεῖς ἀνθρώπων", "halieis anthropon", "fishers of people", "Jesus redirects ordinary labor into kingdom mission.")
            ]
        ),
        seed(
            5,
            title: "The Kingdom Life",
            movement: "Jesus opening the Sermon on the Mount with blessing, kingdom identity, fulfilled law, and heart-level righteousness",
            keyTruth: "kingdom righteousness reaches deeper than reputation and reshapes the heart before God",
            application: "practice hidden integrity in anger, purity, truthfulness, love, and mercy",
            sermonFocus: "Jesus does not lower holiness; He drives it from public behavior into the heart.",
            keyVerses: ["Matthew 5:3", "Matthew 5:16", "Matthew 5:17", "Matthew 5:48"],
            links: [
                ("Exodus 20:1-17", "Jesus teaches in continuity with God's moral law while exposing its heart-level demands."),
                ("Psalm 24:3-4", "Clean hands and a pure heart match the inner righteousness Jesus describes."),
                ("Leviticus 19:18", "The command to love neighbor stands behind Jesus' correction of narrowed love.")
            ],
            history: [
                ("Sermon setting", "Jesus teaches from a mountain, inviting readers to hear echoes of Moses while recognizing a greater authority."),
                ("Righteousness language", "Matthew's audience knew visible piety. Jesus presses beyond appearance into the whole person before God.")
            ],
            words: [
                ("Matthew 5:3", "Greek", "μακάριοι", "makarioi", "blessed, favored by God", "The Beatitudes name people whom God declares blessed, even when the world calls them weak."),
                ("Matthew 5:6", "Greek", "δικαιοσύνην", "dikaiosynen", "righteousness, justice, covenant uprightness", "The hunger Jesus blesses is not moral performance but a deep craving for God's right order."),
                ("Matthew 5:17", "Greek", "πληρῶσαι", "plerosai", "to fulfill, bring to fullness", "Jesus fulfills the Law and Prophets by bringing them to their intended goal.")
            ]
        ),
        seed(
            6,
            title: "Hidden Devotion and Undivided Trust",
            movement: "Jesus moving from secret giving, prayer, and fasting into treasure, loyalty, and freedom from anxiety",
            keyTruth: "the Father sees hidden devotion and frees His children from living for applause, money, or fear",
            application: "choose one secret act of prayer, generosity, or fasting and surrender today's anxiety to the Father",
            sermonFocus: "The question is not whether you are spiritual, but whose eyes you are living under.",
            keyVerses: ["Matthew 6:6", "Matthew 6:10", "Matthew 6:21", "Matthew 6:33"],
            links: [
                ("Psalm 139:1-4", "God sees what is hidden, which makes secret devotion meaningful and hypocrisy foolish."),
                ("Proverbs 30:8-9", "The prayer for daily provision connects with Jesus' teaching on daily bread and undivided trust."),
                ("1 Kings 3:11-14", "Solomon's request for wisdom illustrates seeking God's kingdom above lesser gain.")
            ],
            history: [
                ("Public piety", "Giving, prayer, and fasting were recognized practices. Jesus exposes the danger of using holy acts for human applause."),
                ("Mammon", "Wealth could function like a rival master. Jesus frames money as a loyalty issue, not merely a budgeting topic.")
            ],
            words: [
                ("Matthew 6:6", "Greek", "κρυπτῷ", "krypto", "hidden, secret", "Jesus honors unseen communion with the Father over staged spirituality."),
                ("Matthew 6:21", "Greek", "θησαυρός", "thesauros", "treasure, stored wealth", "Your treasure reveals what has captured your heart."),
                ("Matthew 6:25", "Greek", "μεριμνᾶτε", "merimnate", "be anxious, be divided by care", "Anxiety fractures attention; Jesus calls the heart back to the Father's care.")
            ]
        ),
        seed(
            7,
            title: "Discernment, Prayer, and the Narrow Way",
            movement: "Jesus warning against hypocritical judgment, urging persistent prayer, and ending with the narrow gate and two foundations",
            keyTruth: "true disciples hear Jesus' words and build their lives on obedient trust",
            application: "remove one plank of hypocrisy, ask the Father for help, and obey one command you already know",
            sermonFocus: "The house stands not because it admired the sermon, but because it obeyed the Lord.",
            keyVerses: ["Matthew 7:7", "Matthew 7:13", "Matthew 7:21", "Matthew 7:24"],
            links: [
                ("Proverbs 3:5-6", "Trusting the Lord and walking His path fits the narrow-way call."),
                ("Psalm 1:1-6", "Two ways and two destinies echo Jesus' contrast between life and destruction."),
                ("James 1:22", "James repeats the same warning: hearing without doing deceives the self.")
            ],
            history: [
                ("Judgment warning", "Jesus does not ban discernment; He condemns hypocritical judgment that refuses self-examination."),
                ("Building imagery", "Ancient builders knew foundations decided survival. Jesus turns that everyday truth into a final warning.")
            ],
            words: [
                ("Matthew 7:1", "Greek", "κρίνετε", "krinete", "judge, evaluate, condemn", "The warning targets condemning hypocrisy, not moral blindness."),
                ("Matthew 7:7", "Greek", "αἰτεῖτε", "aiteite", "ask, request", "The present form carries a persistent pattern of prayerful dependence."),
                ("Matthew 7:24", "Greek", "πέτραν", "petran", "rock", "The rock is hearing and doing Jesus' words, not merely respecting them.")
            ]
        ),
        seed(
            8,
            title: "Authority That Cleanses, Commands, and Saves",
            movement: "Jesus cleansing the unclean, honoring Gentile faith, healing many, calming the sea, and commanding demons",
            keyTruth: "Jesus has authority over sickness, nature, demons, and exclusion, and His authority is full of compassion",
            application: "bring one impossible place to Jesus in faith and follow Him beyond comfort",
            sermonFocus: "The King is not distant from uncleanness; He touches, commands, and restores.",
            keyVerses: ["Matthew 8:3", "Matthew 8:10", "Matthew 8:17", "Matthew 8:27"],
            links: [
                ("Isaiah 53:4", "Matthew connects Jesus' healings with the Servant who bears griefs and carries sorrows."),
                ("Psalm 107:23-30", "The Lord stills storms, illuminating the disciples' question about Jesus' identity."),
                ("2 Kings 5:1-14", "Naaman's cleansing provides an Old Testament backdrop for mercy that crosses boundaries.")
            ],
            history: [
                ("Leprosy and uncleanness", "Touching a leper risked ritual uncleanness, yet Jesus' holiness cleanses rather than becoming contaminated."),
                ("Centurion faith", "A Roman centurion becomes a model of faith, showing that kingdom belonging is not limited by ethnicity or status.")
            ],
            words: [
                ("Matthew 8:3", "Greek", "καθαρίσθητι", "katharistheti", "be cleansed", "Jesus does not merely comfort the leper; He restores him by authoritative command."),
                ("Matthew 8:10", "Greek", "πίστιν", "pistin", "faith, trust", "The centurion trusts Jesus' authority without needing visible control."),
                ("Matthew 8:27", "Greek", "ὑπακούουσιν", "hypakouousin", "they obey", "Wind and sea obey Jesus, revealing authority only God finally possesses.")
            ]
        ),
        seed(
            9,
            title: "Mercy for Sinners and Shepherdless People",
            movement: "Jesus forgiving sin, calling Matthew, healing desperate people, and seeing the crowds as sheep without a shepherd",
            keyTruth: "Jesus has authority to forgive and compassion to gather sinners into mercy and mission",
            application: "receive mercy honestly, extend mercy quickly, and pray for laborers in the harvest",
            sermonFocus: "The physician has not come for people pretending to be healthy.",
            keyVerses: ["Matthew 9:6", "Matthew 9:13", "Matthew 9:22", "Matthew 9:37"],
            links: [
                ("Hosea 6:6", "Jesus quotes God's desire for mercy over sacrifice to confront religious hardness."),
                ("Ezekiel 34:11-16", "God promises to shepherd His scattered sheep, echoed in Jesus' compassion for the crowds."),
                ("Isaiah 35:5-6", "Healings of blind and lame signal messianic restoration.")
            ],
            history: [
                ("Tax collectors", "Tax collectors were socially despised as collaborators. Jesus' call of Matthew displays scandalous mercy."),
                ("Synagogue ruler and woman", "Matthew pairs public status with private desperation to show all people need Jesus' restoring power.")
            ],
            words: [
                ("Matthew 9:6", "Greek", "ἀφιέναι", "aphienai", "to forgive, release", "Jesus claims authority to release sins, not simply announce moral advice."),
                ("Matthew 9:13", "Greek", "ἔλεος", "eleos", "mercy, covenant compassion", "Mercy is not softness toward sin; it is God's heart toward sinners who need healing."),
                ("Matthew 9:36", "Greek", "ἐσπλαγχνίσθη", "esplagchnisthe", "was moved with compassion", "The word points to deep, gut-level compassion, not detached pity.")
            ]
        ),
        seed(
            10,
            title: "Sent with Authority and Courage",
            movement: "Jesus appointing the Twelve, sending them to proclaim the kingdom, and preparing them for opposition and costly witness",
            keyTruth: "disciples are sent under Jesus' authority and must fear God more than rejection",
            application: "speak one faithful word this week and refuse to let fear silence obedience",
            sermonFocus: "Jesus never promised a painless mission, but He promised the Father's care inside it.",
            keyVerses: ["Matthew 10:1", "Matthew 10:16", "Matthew 10:28", "Matthew 10:39"],
            links: [
                ("Jeremiah 1:7-8", "God sends Jeremiah into hard speech with the promise of His presence."),
                ("Micah 7:6", "Jesus echoes family division language to prepare disciples for costly loyalty."),
                ("Acts 4:19-20", "The apostles later embody the courage Jesus teaches here.")
            ],
            history: [
                ("The Twelve", "The number twelve signals renewed Israel. Jesus forms a representative people around Himself."),
                ("Household conflict", "In an honor-shame culture, family rejection was severe. Jesus names the cost plainly.")
            ],
            words: [
                ("Matthew 10:2", "Greek", "ἀπόστολοι", "apostoloi", "sent ones, apostles", "The disciples act as authorized messengers, not self-appointed influencers."),
                ("Matthew 10:28", "Greek", "φοβεῖσθε", "phobeisthe", "fear, revere", "Jesus redirects fear away from human threats and toward God."),
                ("Matthew 10:32", "Greek", "ὁμολογήσει", "homologesei", "will confess, acknowledge", "Public allegiance to Jesus matters because discipleship is not secret admiration.")
            ]
        ),
        seed(
            11,
            title: "The Messiah Who Gives Rest",
            movement: "Jesus answering John's question, exposing unresponsive cities, and inviting the weary to His gentle yoke",
            keyTruth: "Jesus is the promised Messiah whose authority is gentle enough to give rest to burdened souls",
            application: "bring weariness to Jesus and exchange self-rule for His yoke",
            sermonFocus: "Rest is not found by escaping lordship but by coming under the gentle Lord.",
            keyVerses: ["Matthew 11:5", "Matthew 11:11", "Matthew 11:28", "Matthew 11:29"],
            links: [
                ("Isaiah 35:5-6", "Jesus answers John's question with messianic signs from Isaiah."),
                ("Malachi 3:1", "John's role as messenger prepares the way before the Lord."),
                ("Jeremiah 6:16", "The promise of rest for souls echoes the call to walk in God's good way.")
            ],
            history: [
                ("John's question", "John asks from prison, where faithful expectations and suffering collide. Jesus answers with Scripture-shaped evidence."),
                ("Yoke imagery", "A yoke often described teaching or allegiance. Jesus' yoke is real submission, but it is gentle and life-giving.")
            ],
            words: [
                ("Matthew 11:28", "Greek", "ἀναπαύσω", "anapauso", "I will give rest", "Jesus offers rest as a gift received by coming to Him."),
                ("Matthew 11:29", "Greek", "ζυγόν", "zygon", "yoke", "The image is discipleship under Jesus' teaching and rule."),
                ("Matthew 11:29", "Greek", "πραΰς", "praus", "gentle, meek", "Jesus' authority is not harsh or self-serving; it is humble strength.")
            ]
        ),
        seed(
            12,
            title: "Lord of the Sabbath and the Divided Heart",
            movement: "Jesus confronting Sabbath controversy, healing mercy, demonic accusation, and the need for a heart that bears good fruit",
            keyTruth: "Jesus is Lord of the Sabbath and exposes hearts that reject mercy while claiming religion",
            application: "choose mercy over religious image and let your speech reveal a surrendered heart",
            sermonFocus: "A religious heart can stand near Jesus and still call mercy a problem.",
            keyVerses: ["Matthew 12:7", "Matthew 12:8", "Matthew 12:34", "Matthew 12:40"],
            links: [
                ("1 Samuel 21:1-6", "Jesus uses David's bread episode to show mercy and need within Scripture's own story."),
                ("Isaiah 42:1-4", "Matthew quotes the Servant who brings justice gently and faithfully."),
                ("Jonah 1:17", "Jesus points to Jonah as a sign anticipating His death and resurrection.")
            ],
            history: [
                ("Sabbath disputes", "Sabbath was a covenant marker, but Jesus challenges interpretations that turned rest into burden and mercy into offense."),
                ("Beelzebul accusation", "Calling Jesus' Spirit-empowered mercy demonic reveals a terrifying hardness of heart.")
            ],
            words: [
                ("Matthew 12:8", "Greek", "κύριος", "kyrios", "Lord, master", "Jesus claims authority even over Sabbath interpretation and purpose."),
                ("Matthew 12:31", "Greek", "βλασφημία", "blasphemia", "blasphemy, slander against God", "The warning concerns hardened resistance to the Spirit's testimony about Jesus."),
                ("Matthew 12:34", "Greek", "καρδίας", "kardias", "heart, inner person", "Speech exposes the inner storehouse of the person.")
            ]
        ),
        seed(
            13,
            title: "Parables of the Kingdom",
            movement: "Jesus teaching parables about soils, weeds, mustard seed, leaven, treasure, pearl, and final sorting",
            keyTruth: "the kingdom grows in hidden, contested, priceless ways and demands a hearing heart",
            application: "examine your soil, treasure the kingdom above lesser things, and endure while God brings growth",
            sermonFocus: "The same Word that softens one heart can expose the hardness of another.",
            keyVerses: ["Matthew 13:9", "Matthew 13:23", "Matthew 13:44", "Matthew 13:52"],
            links: [
                ("Isaiah 6:9-10", "Jesus uses Isaiah to explain why parables reveal and conceal according to the heart's posture."),
                ("Daniel 2:44", "The kingdom that God establishes grows and outlasts worldly kingdoms."),
                ("Psalm 78:2", "Matthew sees Jesus' parable teaching as fulfilling Scripture.")
            ],
            history: [
                ("Parable function", "Parables are not cute illustrations only. They test whether hearers truly want the kingdom."),
                ("Agrarian imagery", "Seeds, weeds, and harvest were ordinary images that carried spiritual urgency for first-century hearers.")
            ],
            words: [
                ("Matthew 13:3", "Greek", "παραβολαῖς", "parabolais", "parables, comparisons", "A parable places truth beside everyday life and reveals the hearer's heart."),
                ("Matthew 13:11", "Greek", "μυστήρια", "mysteria", "mysteries, revealed secrets", "Kingdom truth is given by revelation, not mastered by pride."),
                ("Matthew 13:44", "Greek", "θησαυρῷ", "thesauro", "treasure", "The kingdom is worth joyful surrender of everything else.")
            ]
        ),
        seed(
            14,
            title: "Compassion, Provision, and Fear on the Water",
            movement: "Herod's violent feast contrasting with Jesus' compassionate feast, followed by Jesus walking on the sea and rescuing fearful disciples",
            keyTruth: "Jesus is the compassionate King whose presence is stronger than scarcity, grief, and fear",
            application: "bring limited resources and honest fear to Jesus instead of hiding behind self-sufficiency",
            sermonFocus: "The disciples learn that the King who feeds the crowd also meets them in the storm.",
            keyVerses: ["Matthew 14:14", "Matthew 14:19", "Matthew 14:27", "Matthew 14:31"],
            links: [
                ("2 Kings 4:42-44", "Elisha's multiplication miracle forms a backdrop for Jesus' greater provision."),
                ("Psalm 77:19", "God's way through the sea illuminates Jesus walking on the waters."),
                ("Exodus 16:4", "Bread in the wilderness echoes God's provision for Israel.")
            ],
            history: [
                ("Herod's banquet", "Herod's feast ends in death because power is ruled by pride and fear. Jesus' feast gives life through compassion."),
                ("Sea of Galilee", "Storms on the lake could rise quickly. Matthew uses the scene to reveal Jesus' divine authority and pastoral nearness.")
            ],
            words: [
                ("Matthew 14:14", "Greek", "ἐσπλαγχνίσθη", "esplagchnisthe", "was moved with compassion", "Jesus responds to needy crowds from deep mercy, not annoyance."),
                ("Matthew 14:27", "Greek", "θαρσεῖτε", "tharseite", "take courage", "The command rests on Jesus' presence, not the disciples' control."),
                ("Matthew 14:31", "Greek", "ὀλιγόπιστε", "oligopiste", "little-faith one", "Jesus corrects Peter's wavering faith while still rescuing him.")
            ]
        ),
        seed(
            15,
            title: "Clean Hearts and Persistent Faith",
            movement: "Jesus confronting tradition that avoids God's command, teaching heart defilement, honoring a Canaanite woman's faith, and feeding Gentile crowds",
            keyTruth: "Jesus exposes heart-level uncleanness and extends mercy beyond expected boundaries",
            application: "confess what comes from your heart and persistently seek Jesus' mercy",
            sermonFocus: "Tradition cannot cleanse the heart, but mercy from Jesus can reach the outsider.",
            keyVerses: ["Matthew 15:8", "Matthew 15:18", "Matthew 15:28", "Matthew 15:37"],
            links: [
                ("Isaiah 29:13", "Jesus quotes Isaiah against worship that honors God with lips while hearts remain far away."),
                ("Exodus 20:12", "The command to honor father and mother exposes tradition that evades God's Word."),
                ("Genesis 12:3", "Mercy reaching a Canaanite woman hints again at blessing moving to the nations.")
            ],
            history: [
                ("Tradition of elders", "Jesus challenges human traditions when they cancel God's command, not all tradition as such."),
                ("Canaanite woman", "Her identity evokes old hostility, making her faith and Jesus' mercy even more striking.")
            ],
            words: [
                ("Matthew 15:3", "Greek", "παράδοσιν", "paradosin", "tradition, something handed down", "Tradition becomes dangerous when it overrules God's command."),
                ("Matthew 15:18", "Greek", "καρδίας", "kardias", "heart, inner person", "Defilement is traced to the inner life, not merely external contact."),
                ("Matthew 15:28", "Greek", "πίστις", "pistis", "faith, trust", "Jesus praises persistent trust that clings to mercy.")
            ]
        ),
        seed(
            16,
            title: "Confession, Church, and the Cross",
            movement: "Peter confessing Jesus as Messiah, Jesus promising His church, and then redefining discipleship through cross-bearing",
            keyTruth: "the Christ builds His church through revelation, suffering, and cross-shaped discipleship",
            application: "confess Jesus clearly and deny one self-protective pattern that resists the cross",
            sermonFocus: "You cannot receive Jesus as Christ while rejecting His cross-shaped way.",
            keyVerses: ["Matthew 16:16", "Matthew 16:18", "Matthew 16:24", "Matthew 16:26"],
            links: [
                ("Daniel 7:13-14", "The Son of Man language points to royal authority and everlasting dominion."),
                ("Isaiah 53:3-6", "The suffering Servant prepares readers for a Messiah who suffers and saves."),
                ("Psalm 118:22", "Rejected stone imagery helps frame Jesus' rejected-yet-vindicated mission.")
            ],
            history: [
                ("Caesarea Philippi", "The confession happens in a region associated with pagan power, making Peter's confession stand out sharply."),
                ("Church language", "Ekklesia means assembly. Jesus promises to build His gathered people against the gates of death.")
            ],
            words: [
                ("Matthew 16:16", "Greek", "Χριστός", "Christos", "Messiah, Anointed One", "Peter identifies Jesus by royal and saving office, not only personal admiration."),
                ("Matthew 16:18", "Greek", "ἐκκλησίαν", "ekklesian", "assembly, church", "Jesus gathers a people around His identity and authority."),
                ("Matthew 16:24", "Greek", "σταυρὸν", "stauron", "cross", "Before it became a symbol, the cross meant shame, death, and total surrender.")
            ]
        ),
        seed(
            17,
            title: "Glory, Listening, and Little Faith",
            movement: "Jesus revealing glory at the transfiguration, commanding silence until resurrection, healing a demon-oppressed boy, and teaching humble provision",
            keyTruth: "the glorious Son must be listened to, trusted, and followed toward suffering and resurrection",
            application: "listen to Jesus above every competing voice and bring weak faith to Him honestly",
            sermonFocus: "The Father does not say admire Him only; He says listen to Him.",
            keyVerses: ["Matthew 17:5", "Matthew 17:12", "Matthew 17:20", "Matthew 17:27"],
            links: [
                ("Exodus 24:15-18", "Mountain, cloud, and glory echo Sinai while Jesus is revealed as greater than Moses."),
                ("Malachi 4:5-6", "Elijah expectation frames the discussion about John and fulfillment."),
                ("2 Peter 1:16-18", "Peter later remembers the transfiguration as eyewitness testimony to Jesus' majesty.")
            ],
            history: [
                ("Transfiguration", "Moses and Elijah represent the Law and Prophets, but the Father's command centers attention on the Son."),
                ("Temple tax", "The tax scene teaches sonship and humility: Jesus is free, yet avoids needless offense.")
            ],
            words: [
                ("Matthew 17:2", "Greek", "μετεμορφώθη", "metemorphothe", "was transfigured, transformed in appearance", "Jesus' hidden glory becomes visible to the disciples."),
                ("Matthew 17:5", "Greek", "ἀκούετε", "akouete", "listen, hear obediently", "The Father's command requires responsive obedience to Jesus."),
                ("Matthew 17:20", "Greek", "πίστιν", "pistin", "faith, trust", "Jesus exposes the disciples' little faith while calling them to dependence.")
            ]
        ),
        seed(
            18,
            title: "Humility, Care, and Forgiveness",
            movement: "Jesus teaching childlike humility, warning against causing little ones to stumble, pursuing the straying, and commanding lavish forgiveness",
            keyTruth: "kingdom greatness is humility that protects the vulnerable and forgives as one forgiven",
            application: "pursue one act of reconciliation or forgiveness without excusing sin",
            sermonFocus: "Forgiven people cannot keep treating mercy as something they own but do not owe.",
            keyVerses: ["Matthew 18:4", "Matthew 18:10", "Matthew 18:20", "Matthew 18:35"],
            links: [
                ("Ezekiel 34:11-16", "God's shepherding pursuit stands behind the search for the straying sheep."),
                ("Leviticus 19:17", "Private confrontation aims at love and restoration, not gossip or revenge."),
                ("Colossians 3:13", "Paul echoes Jesus' logic: forgive as the Lord has forgiven you.")
            ],
            history: [
                ("Little ones", "Children had low social status, so Jesus' use of a child confronts status-seeking disciples."),
                ("Church discipline", "The process aims to win a brother, guard the community, and honor heaven's authority.")
            ],
            words: [
                ("Matthew 18:4", "Greek", "ταπεινώσει", "tapeinosei", "will humble", "Kingdom greatness begins with lowering oneself, not climbing over others."),
                ("Matthew 18:6", "Greek", "σκανδαλίσῃ", "skandalise", "cause to stumble", "Jesus treats spiritual harm to vulnerable believers with severe seriousness."),
                ("Matthew 18:35", "Greek", "ἀφῆτε", "aphete", "forgive, release", "Forgiveness flows from receiving the King's mercy.")
            ]
        ),
        seed(
            19,
            title: "Marriage, Children, Wealth, and the Kingdom",
            movement: "Jesus teaching covenant marriage, welcoming children, challenging the rich young man, and promising reward for costly following",
            keyTruth: "the kingdom reorders relationships, possessions, status, and the meaning of eternal life",
            application: "release one possession, status marker, or self-justifying habit that competes with Jesus",
            sermonFocus: "The rich man had morality, but his treasure still mastered him.",
            keyVerses: ["Matthew 19:6", "Matthew 19:14", "Matthew 19:21", "Matthew 19:26"],
            links: [
                ("Genesis 2:24", "Jesus roots marriage in creation before addressing divorce debates."),
                ("Deuteronomy 24:1-4", "The divorce discussion engages a debated Mosaic text and exposes hard hearts."),
                ("Exodus 20:12-16", "The commandments quoted to the rich young man expose outward obedience and inward attachment.")
            ],
            history: [
                ("Divorce debate", "First-century Jewish teachers debated grounds for divorce. Jesus returns to creation purpose and heart hardness."),
                ("Wealth and blessing", "Many assumed wealth signaled divine favor. Jesus shocks the disciples by showing riches can hinder entrance into the kingdom.")
            ],
            words: [
                ("Matthew 19:6", "Greek", "σάρκα μίαν", "sarka mian", "one flesh", "Marriage is covenant union, not a disposable contract."),
                ("Matthew 19:21", "Greek", "τέλειος", "teleios", "complete, whole, mature", "Jesus exposes what keeps the man from wholehearted devotion."),
                ("Matthew 19:24", "Greek", "πλούσιον", "plousion", "rich person", "Wealth is spiritually dangerous when it becomes security and identity.")
            ]
        ),
        seed(
            20,
            title: "Grace, Service, and the Ransom King",
            movement: "Jesus teaching generous grace, predicting His suffering, correcting ambition, and healing blind men crying for mercy",
            keyTruth: "the kingdom is governed by grace and greatness is measured by servant-shaped love",
            application: "serve without demanding recognition and ask Jesus for mercy with honest need",
            sermonFocus: "The Son of Man did not come to be served, so His followers cannot make greatness about being noticed.",
            keyVerses: ["Matthew 20:15", "Matthew 20:26", "Matthew 20:28", "Matthew 20:34"],
            links: [
                ("Isaiah 53:10-12", "The suffering Servant bears sin, matching Jesus' ransom language."),
                ("Jonah 4:2", "The parable's offense at generosity echoes resentment toward God's mercy."),
                ("Mark 10:45", "Mark preserves the same ransom saying, underlining its centrality to Jesus' mission.")
            ],
            history: [
                ("Day laborers", "Workers depended on daily wages. The parable turns economic expectation into a lesson on grace."),
                ("Ransom language", "A ransom price released captives or slaves. Jesus applies that costly rescue to His own death.")
            ],
            words: [
                ("Matthew 20:15", "Greek", "ἀγαθός", "agathos", "good, generous", "The landowner's goodness exposes envy toward grace."),
                ("Matthew 20:26", "Greek", "διάκονος", "diakonos", "servant, minister", "Kingdom greatness takes the posture of service."),
                ("Matthew 20:28", "Greek", "λύτρον", "lytron", "ransom price", "Jesus interprets His death as costly deliverance for many.")
            ]
        ),
        seed(
            21,
            title: "The King Enters and Inspects His House",
            movement: "Jesus entering Jerusalem, cleansing the temple, cursing fruitlessness, and confronting leaders through parables of rejected authority",
            keyTruth: "the humble King comes to receive worship, purify His house, and judge fruitless religion",
            application: "welcome Jesus as King by bearing fruit, not only singing religious words",
            sermonFocus: "Hosanna on the lips must become surrender in the life.",
            keyVerses: ["Matthew 21:5", "Matthew 21:9", "Matthew 21:13", "Matthew 21:43"],
            links: [
                ("Zechariah 9:9", "Matthew presents Jesus as the humble King riding into Zion."),
                ("Isaiah 56:7", "Jesus' temple cleansing appeals to God's house as a house of prayer for all nations."),
                ("Psalm 118:22-26", "Hosanna and rejected stone language shape the chapter's worship and warning.")
            ],
            history: [
                ("Triumphal entry", "Pilgrims gathered for Passover, making public royal claims especially charged."),
                ("Temple commerce", "Jesus attacks corruption and misuse of sacred space, especially where prayer and Gentile access should have been honored.")
            ],
            words: [
                ("Matthew 21:5", "Greek", "πραΰς", "praus", "gentle, humble", "The King comes with humble authority, not worldly swagger."),
                ("Matthew 21:9", "Hebrew background", "ὡσαννά", "hosanna", "save now, please save", "The Greek form preserves a Hebrew plea that becomes praise for the arriving King."),
                ("Matthew 21:43", "Greek", "καρπούς", "karpous", "fruits", "Kingdom privilege is judged by fruit, not possession of religious status.")
            ]
        ),
        seed(
            22,
            title: "The Wedding Feast and the Greatest Commandment",
            movement: "Jesus warning through a wedding feast, answering traps about Caesar and resurrection, and centering the law on love for God and neighbor",
            keyTruth: "God's invitation is gracious and serious, and the whole law calls for undivided love",
            application: "receive God's invitation with repentance and practice love for God and neighbor in one visible way",
            sermonFocus: "The kingdom invitation is free, but no one enters on their own terms.",
            keyVerses: ["Matthew 22:14", "Matthew 22:21", "Matthew 22:32", "Matthew 22:37"],
            links: [
                ("Isaiah 25:6-9", "A feast of salvation stands behind kingdom banquet imagery."),
                ("Deuteronomy 6:5", "Jesus names love for God as the great commandment from Israel's daily confession."),
                ("Leviticus 19:18", "Love for neighbor is joined to love for God as the law's living center.")
            ],
            history: [
                ("Wedding garment", "The garment image warns against presuming on invitation while rejecting the King's terms."),
                ("Sadducees and resurrection", "Sadducees rejected resurrection. Jesus argues from Scripture that God is God of the living.")
            ],
            words: [
                ("Matthew 22:14", "Greek", "κλητοί", "kletoi", "called, invited", "Many hear the invitation, but response reveals the heart."),
                ("Matthew 22:21", "Greek", "ἀπόδοτε", "apodote", "give back, render", "Jesus distinguishes civic responsibility from ultimate allegiance to God."),
                ("Matthew 22:37", "Greek", "ἀγαπήσεις", "agapeseis", "you shall love", "Love is commanded as whole-person allegiance, not only emotion.")
            ]
        ),
        seed(
            23,
            title: "Woe to Hypocrisy",
            movement: "Jesus warning crowds about religious hypocrisy and pronouncing woes on leaders who polish appearances while neglecting justice, mercy, and faithfulness",
            keyTruth: "Jesus sees through religious performance and calls leaders and learners to humble integrity",
            application: "repent of one image-management habit and practice unseen justice, mercy, or faithfulness",
            sermonFocus: "The outside can look clean while the inside is full of death.",
            keyVerses: ["Matthew 23:11", "Matthew 23:23", "Matthew 23:27", "Matthew 23:37"],
            links: [
                ("Micah 6:8", "Justice, mercy, and humble walking with God match the weightier matters Jesus names."),
                ("Isaiah 1:11-17", "God rejects empty worship while calling for justice and repentance."),
                ("2 Chronicles 24:20-22", "Zechariah's death stands behind Jesus' indictment of violent religious history.")
            ],
            history: [
                ("Scribes and Pharisees", "Jesus critiques hypocrisy and abusive leadership, not careful Scripture study itself."),
                ("Phylacteries and tassels", "Visible devotion markers could be used for status. Jesus exposes the hunger to be seen and honored.")
            ],
            words: [
                ("Matthew 23:13", "Greek", "ὑποκριταί", "hypokritai", "hypocrites, actors", "The word exposes religious performance that hides a divided heart."),
                ("Matthew 23:23", "Greek", "ἔλεος", "eleos", "mercy", "Mercy belongs among the weightier matters of God's law."),
                ("Matthew 23:27", "Greek", "τάφοις", "taphois", "tombs", "Whitewashed tomb imagery reveals clean appearance covering inward death.")
            ]
        ),
        seed(
            24,
            title: "Watchfulness in the Last Days",
            movement: "Jesus predicting temple judgment, warning about deception and suffering, and calling disciples to watchful endurance until the Son of Man comes",
            keyTruth: "disciples must endure deception, distress, and delay with watchful faith in Jesus' final coming",
            application: "strengthen watchfulness by rejecting fear-driven speculation and practicing faithful obedience today",
            sermonFocus: "Jesus gives prophecy not to feed panic, but to form endurance.",
            keyVerses: ["Matthew 24:13", "Matthew 24:14", "Matthew 24:30", "Matthew 24:42"],
            links: [
                ("Daniel 7:13-14", "The Son of Man coming with dominion shapes Jesus' return language."),
                ("Daniel 9:27", "Abomination language lies behind Jesus' warning about desolating sacrilege."),
                ("Zechariah 14:5", "Old Testament day-of-the-Lord imagery contributes to the chapter's final-coming horizon.")
            ],
            history: [
                ("Temple prediction", "The temple's destruction would be unimaginable to many hearers. Jesus prepares disciples for coming upheaval."),
                ("Already and not yet", "The chapter moves between near judgment and final coming, requiring humility and readiness.")
            ],
            words: [
                ("Matthew 24:3", "Greek", "παρουσίας", "parousias", "coming, royal arrival", "The word can signal the arrival or presence of a ruler, fitting Jesus' royal return."),
                ("Matthew 24:13", "Greek", "ὑπομείνας", "hypomeinas", "having endured", "Endurance is active faithfulness under pressure."),
                ("Matthew 24:42", "Greek", "γρηγορεῖτε", "gregoreite", "keep watch, stay awake", "Watchfulness means faithful readiness, not anxious date-setting.")
            ]
        ),
        seed(
            25,
            title: "Ready, Faithful, and Merciful",
            movement: "Jesus teaching readiness through virgins, stewardship through talents, and final judgment through mercy shown to the least",
            keyTruth: "the returning King evaluates readiness, faithful stewardship, and mercy toward those who belong to Him",
            application: "use one entrusted gift faithfully and show concrete mercy to someone overlooked",
            sermonFocus: "Waiting for Jesus is not passive; it is faithful, merciful readiness.",
            keyVerses: ["Matthew 25:13", "Matthew 25:21", "Matthew 25:29", "Matthew 25:40"],
            links: [
                ("Proverbs 31:18", "The wise keeping of a lamp helps frame readiness imagery."),
                ("Daniel 7:10", "Judgment before the throne echoes the final evaluation in Jesus' teaching."),
                ("Isaiah 58:6-10", "True devotion expresses itself in mercy toward the hungry, oppressed, and needy.")
            ],
            history: [
                ("Wedding customs", "Wedding processions required readiness. Jesus uses familiar delay and arrival imagery for His return."),
                ("Talents", "A talent was a large sum. The parable is about faithful stewardship of what belongs to the master.")
            ],
            words: [
                ("Matthew 25:2", "Greek", "φρόνιμοι", "phronimoi", "wise, prudent", "Wisdom is readiness that prepares before the crisis arrives."),
                ("Matthew 25:21", "Greek", "πιστέ", "piste", "faithful, trustworthy", "The master praises reliability with entrusted resources."),
                ("Matthew 25:40", "Greek", "ἐλαχίστων", "elachiston", "least, smallest", "Jesus identifies care for His least brothers with service rendered to Him.")
            ]
        ),
        seed(
            26,
            title: "Covenant Blood and the Betrayed King",
            movement: "Jesus being anointed for burial, sharing Passover, instituting the covenant meal, praying in Gethsemane, and being betrayed and denied",
            keyTruth: "Jesus willingly gives Himself as covenant sacrifice while His disciples' weakness is exposed",
            application: "watch and pray against weakness, and receive the covenant mercy purchased by Jesus' blood",
            sermonFocus: "The disciples sleep, flee, and deny, yet Jesus walks forward to give His blood for sinners.",
            keyVerses: ["Matthew 26:28", "Matthew 26:39", "Matthew 26:41", "Matthew 26:64"],
            links: [
                ("Exodus 12:1-14", "Passover frames Jesus' final meal and sacrificial mission."),
                ("Jeremiah 31:31-34", "New covenant promise illuminates Jesus' covenant blood language."),
                ("Zechariah 13:7", "Jesus cites the struck shepherd prophecy as the disciples scatter.")
            ],
            history: [
                ("Passover context", "The meal remembers deliverance from Egypt. Jesus reveals a deeper exodus through His own death."),
                ("Gethsemane", "The garden scene shows real anguish and perfect submission, not theatrical courage.")
            ],
            words: [
                ("Matthew 26:28", "Greek", "διαθήκης", "diathekes", "covenant", "Jesus interprets His death as covenant-making blood for forgiveness."),
                ("Matthew 26:28", "Greek", "αἷμά", "haima", "blood", "Blood language points to sacrificial life given for many."),
                ("Matthew 26:41", "Greek", "γρηγορεῖτε", "gregoreite", "watch, stay awake", "Prayerful watchfulness is necessary because willing intentions do not erase weak flesh.")
            ]
        ),
        seed(
            27,
            title: "The Crucified King",
            movement: "Jesus being condemned, mocked, crucified, forsaken, dying, and buried while signs reveal the meaning of His death",
            keyTruth: "the true King saves not by escaping the cross but by giving His life under judgment for sinners",
            application: "stand before the cross with repentance, worship, and courage instead of mockery or distance",
            sermonFocus: "They mock Him as King, but the cross is where His kingship saves.",
            keyVerses: ["Matthew 27:37", "Matthew 27:46", "Matthew 27:51", "Matthew 27:54"],
            links: [
                ("Psalm 22:1", "Jesus' cry of forsakenness comes from the lament Psalm that moves toward vindication."),
                ("Isaiah 53:7-12", "The suffering Servant bears sin and is counted with transgressors."),
                ("Amos 8:9", "Darkness at noon provides prophetic language for judgment and grief.")
            ],
            history: [
                ("Roman crucifixion", "Crucifixion was public shame and torture. Matthew presents Jesus enduring disgrace as King."),
                ("Temple curtain", "The torn curtain signals access and judgment: Jesus' death changes approach to God.")
            ],
            words: [
                ("Matthew 27:22", "Greek", "σταυρωθήτω", "staurotheto", "let him be crucified", "The crowd's demand names the horrific death Jesus willingly endures."),
                ("Matthew 27:46", "Aramaic and Greek", "Ἠλί", "Eli", "my God", "Matthew preserves Jesus' cry from Psalm 22, holding anguish and Scripture together."),
                ("Matthew 27:51", "Greek", "καταπέτασμα", "katapetasma", "curtain, veil", "The torn veil announces that Jesus' death opens access to God.")
            ]
        ),
        seed(
            28,
            title: "Resurrection and the Great Commission",
            movement: "the women finding the empty tomb, meeting the risen Jesus, false reports spreading, and Jesus commissioning disciples to make disciples of all nations",
            keyTruth: "the risen Jesus has all authority and sends His people to make disciples with His abiding presence",
            application: "obey the Great Commission by naming one person to pray for, serve, and invite toward Jesus",
            sermonFocus: "Resurrection turns fearful followers into commissioned witnesses.",
            keyVerses: ["Matthew 28:6", "Matthew 28:10", "Matthew 28:18", "Matthew 28:19"],
            links: [
                ("Daniel 7:14", "All authority and all nations echo the Son of Man's dominion."),
                ("Genesis 12:3", "The nations promised to be blessed through Abraham now become the mission field of the risen Christ."),
                ("Acts 1:8", "The church's witness flows outward in the pattern Jesus commands.")
            ],
            history: [
                ("Women witnesses", "Matthew highlights women as first witnesses to the resurrection, a striking feature in the ancient world."),
                ("All nations", "Matthew ends where his opening genealogy pointed: Israel's Messiah sends blessing to the nations.")
            ],
            words: [
                ("Matthew 28:6", "Greek", "ἠγέρθη", "egerthe", "he has been raised", "The passive form points to God's action in raising Jesus."),
                ("Matthew 28:19", "Greek", "μαθητεύσατε", "matheteusate", "make disciples", "The commission is not merely decisions or information, but forming learners under Jesus."),
                ("Matthew 28:20", "Greek", "ἐντειλάμην", "enteilamen", "I commanded", "Discipleship includes teaching obedience to Jesus' commands.")
            ]
        )
    ]
}

struct ChapterStudyView: View {
    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson

    @State private var step: Int
    @State private var reflectionDraft: ChapterReflectionDraft
    @State private var selectedVerses: Set<String>
    @State private var feedbackMessage = ""
    @State private var feedbackIsError = false
    @State private var showingPractice = false
    @State private var selectedScripturePreview: ScriptureLinkItem?
    @State private var bibleNavigationTarget: BibleReferenceTarget?
    @State private var nextLessonTarget: WisdomLesson?

    private let phases = ChapterLessonPhase.allCases

    init(store: SoulJourneyStore, lesson: WisdomLesson) {
        self.store = store
        self.lesson = lesson

        let savedDraft = store.chapterReflectionDraft(for: lesson)
        let savedStep = store.lessonStudyStep(for: lesson)
        var initialStep = min(savedStep, max(0, ChapterLessonPhase.allCases.count - 1))
        if let reflectionIndex = ChapterLessonPhase.allCases.firstIndex(of: .reflection),
           initialStep > reflectionIndex,
           !savedDraft.hasRequiredFields {
            initialStep = reflectionIndex
        }

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
        referenceTarget.flatMap {
            BibleDataProvider.chapter(at: $0.location, version: .esv)
        }
    }

    private var lessonContent: LessonChapterContent? {
        LessonLibraryContent.content(for: lesson.id)
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
            LazyVStack(spacing: OVTheme.cardSpacing) {
                if currentPhase == .overview {
                    ChapterStudyHeaderCard(
                        reference: lesson.studyReference,
                        title: lesson.title,
                        completed: progressState.lessonCompleted,
                        questPassed: progressState.quizPassed
                    )
                }

                LessonPhaseRail(phases: phases, currentPhase: currentPhase, onSelect: jump)

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
        .scrollDismissesKeyboard(.interactively)
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(lesson.studyReference)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPractice) {
            LessonPracticeView(store: store, lesson: lesson)
        }
        .sheet(item: $selectedScripturePreview) { item in
            ScripturePreviewSheet(item: item) { target in
                selectedScripturePreview = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    bibleNavigationTarget = target
                }
            }
        }
        .navigationDestination(item: $bibleNavigationTarget) { target in
            BibleChapterReaderView(store: store, target: target)
        }
        .navigationDestination(item: $nextLessonTarget) { nextLesson in
            ChapterStudyView(store: store, lesson: nextLesson)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
            }
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
            SermonPhaseCard(
                title: "Sermon",
                points: sermonDepthPoints,
                links: sermonScriptureLinks,
                onSelectLink: { selectedScripturePreview = $0 }
            )
        case .scriptureLinks:
            ScriptureLinksPhaseCard(
                links: scriptureLinks,
                onSelect: { selectedScripturePreview = $0 }
            )
        case .history:
            HistoryPhaseCard(items: historyNotes)
        case .practice:
            PracticePhaseCard(
                topics: questTopics,
                passingScore: lesson.assessmentQuest.passingScore,
                questPassed: progressState.quizPassed,
                hasNextLesson: store.nextLesson(after: lesson) != nil
            )
        }
    }

    private var primaryButtonTitle: String {
        guard currentPhase == .practice else { return "Next" }
        return progressState.quizPassed ? (store.nextLesson(after: lesson) == nil ? "Finish" : "Next lesson") : "Start quest"
    }

    private var guidedPathTitle: String {
        "Guided path"
    }

    private var guidedPathPoints: [String] {
        let seed = lessonContent?.guidedPathPoints ?? (lesson.keyIdeas.isEmpty ? [lesson.summary] : lesson.keyIdeas)
        return seed.prefix(6).enumerated().map { index, idea in
            "\(index + 1). \(idea)"
        }
    }

    private var sermonDepthPoints: [String] {
        lessonContent?.sermonPoints ?? [
            "This sermon will teach \(lesson.studyReference) as one whole chapter, then connect its truth to the rest of Scripture.",
            "For now, stay close to the chapter itself: observe what God says, what sin is confronted, and what obedience is being called for.",
            "As this book is built out, this section will become a longer pastoral teaching that convicts, encourages, and moves people toward real obedience."
        ]
    }

    private var scriptureLinks: [ScriptureLinkItem] {
        if let links = lessonContent?.scriptureLinks {
            return links.map { link in
                ScriptureLinkItem(
                    reference: link.reference,
                    summary: link.summary
                )
            }
        }

        let references = lesson.keyVerses.isEmpty ? [lesson.studyReference] : lesson.keyVerses
        return references.map { reference in
            ScriptureLinkItem(
                reference: reference,
                summary: verseText(for: reference) ?? "This verse will be linked here with its chapter context as the lesson is built."
            )
        }
    }

    private var sermonScriptureLinks: [ScriptureLinkItem] {
        uniqueScriptureLinks(
            [
                ScriptureLinkItem(
                    reference: lesson.studyReference,
                    summary: "Open the full chapter so the sermon stays rooted in the whole passage."
                )
            ] + scriptureLinks
        )
    }

    private var historyNotes: [HistoryNote] {
        if let historyItems = lessonContent?.historyNotes {
            return historyItems.map { item in
                HistoryNote(
                    title: item.title,
                    detail: item.detail
                )
            }
        }

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

    private var questTopics: [String] {
        let prompts = lesson.assessmentQuest.questions.prefix(3).map(\.prompt)
        if !prompts.isEmpty {
            return prompts
        }

        return [
            "The main truth of \(lesson.studyReference).",
            "The chapter's key people, movement, and message.",
            "The obedience or heart response this chapter calls for."
        ]
    }

    private func goBack() {
        guard step > 0 else { return }
        step -= 1
    }

    private func jump(to phase: ChapterLessonPhase) {
        guard let index = phases.firstIndex(of: phase) else { return }
        guard canMove(to: index) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            step = index
            feedbackMessage = ""
        }
    }

    private func goForward() {
        switch currentPhase {
        case .reflection:
            saveReflectionIfPossible()
        case .practice:
            if progressState.quizPassed {
                goToNextLesson()
            } else {
                showingPractice = true
            }
        default:
            advanceStep()
        }
    }

    private func goToNextLesson() {
        guard let nextLesson = store.nextLesson(after: lesson) else {
            feedbackIsError = false
            feedbackMessage = "You finished the available lessons in this book."
            return
        }

        nextLessonTarget = nextLesson
    }

    private func advanceStep() {
        guard step < phases.count - 1 else { return }
        guard canMove(to: step + 1) else { return }
        step += 1
        feedbackMessage = ""
    }

    private func canMove(to index: Int) -> Bool {
        guard let reflectionIndex = phases.firstIndex(of: .reflection),
              index > reflectionIndex,
              !reflectionDraft.hasRequiredFields else {
            return true
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            step = reflectionIndex
        }
        feedbackIsError = true
        feedbackMessage = "Fill out the required reflection fields before moving on."
        return false
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
              let verse = BibleDataProvider.chapter(
                at: target.location,
                version: .esv
              )?.verses.first(where: { $0.verse == verseNumber }) else {
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

    private func uniqueScriptureLinks(_ links: [ScriptureLinkItem]) -> [ScriptureLinkItem] {
        var seenReferences: Set<String> = []
        return links.filter { link in
            seenReferences.insert(link.reference.lowercased()).inserted
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
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
            return "Sermon"
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
                        StatusBadge(title: "Quest passed")
                    }
                }
            }

            Text("Overview, chapter reading, guided teaching, reflection, sermon, Scripture links, history, and practice all stay in one clean path.")
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
    let onSelect: (ChapterLessonPhase) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                    Button {
                        onSelect(phase)
                    } label: {
                        Text("\(index + 1). \(phase.title)")
                            .font(OVTheme.body(12))
                            .foregroundStyle(phase == currentPhase ? .white : OVTheme.midnight)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(phase == currentPhase ? OVTheme.midnight : .white.opacity(0.95))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
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
                FullChapterReadingCard(
                    chapter: chapter,
                    selectedVerses: selectedVerses,
                    onToggleVerse: onToggleVerse
                )
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

private struct FullChapterReadingCard: View {
    let chapter: BibleChapter
    let selectedVerses: Set<String>
    let onToggleVerse: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(chapter.title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.midnight)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(chapter.verses) { verse in
                    let reference = "\(chapter.book) \(chapter.chapter):\(verse.verse)"
                    Button {
                        onToggleVerse(reference)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(verse.verse)")
                                .font(OVTheme.heading(12))
                                .foregroundStyle(selectedVerses.contains(reference) ? OVTheme.midnight : OVTheme.gold)
                                .frame(width: 24, alignment: .leading)

                            Text(verse.text)
                                .font(OVTheme.body(16))
                                .foregroundStyle(OVTheme.ink.opacity(0.82))
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 9)
                        .padding(.horizontal, 10)
                        .background(selectedVerses.contains(reference) ? OVTheme.lemon.opacity(0.34) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if !selectedVerses.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "highlighter")
                        .foregroundStyle(OVTheme.gold)
                    Text("\(selectedVerses.count) verse\(selectedVerses.count == 1 ? "" : "s") selected for reflection")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
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

private struct SermonPhaseCard: View {
    let title: String
    let points: [String]
    let links: [ScriptureLinkItem]
    let onSelectLink: (ScriptureLinkItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.midnight)

            Text(points.joined(separator: "\n\n"))
                .font(OVTheme.body(16))
                .foregroundStyle(OVTheme.ink.opacity(0.82))
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(OVTheme.paper.opacity(0.97))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            if !links.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Referenced Scripture")
                        .font(OVTheme.heading(17))
                        .foregroundStyle(OVTheme.midnight)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 122), spacing: 10)], alignment: .leading, spacing: 10) {
                        ForEach(links) { link in
                            Button {
                                onSelectLink(link)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(link.reference)
                                        .font(OVTheme.heading(12))
                                        .underline()
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(OVTheme.midnight)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .frame(maxWidth: .infinity)
                                .background(.white.opacity(0.96))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
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
    let reference: String
    let summary: String

    var id: String { reference }
}

private struct ScriptureLinksPhaseCard: View {
    let links: [ScriptureLinkItem]
    let onSelect: (ScriptureLinkItem) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(links) { link in
                Button {
                    onSelect(link)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(link.reference)
                            .font(OVTheme.body(11))
                            .foregroundStyle(OVTheme.gold)
                            .underline()

                        Text(link.summary)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.78))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ScripturePreviewSheet: View {
    let item: ScriptureLinkItem
    let onGoToBible: (BibleReferenceTarget) -> Void

    @Environment(\.dismiss) private var dismiss

    private var target: BibleReferenceTarget? {
        BibleDataProvider.resolveReference(from: item.reference)
    }

    private var previewVerses: [(reference: String, text: String)] {
        guard let target,
              let chapter = BibleDataProvider.chapter(at: target.location, version: .esv) else {
            return []
        }

        if let verseNumber = target.verse,
           let verse = chapter.verses.first(where: { $0.verse == verseNumber }) {
            return [("\(chapter.book) \(chapter.chapter):\(verse.verse)", verse.text)]
        }

        return chapter.verses.prefix(6).map { verse in
            ("\(chapter.book) \(chapter.chapter):\(verse.verse)", verse.text)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.reference)
                            .font(OVTheme.display(30))
                            .foregroundStyle(OVTheme.midnight)

                        Text(item.summary)
                            .font(OVTheme.body(15))
                            .foregroundStyle(OVTheme.ink.opacity(0.76))
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(OVTheme.cardPadding)
                    .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)

                    if previewVerses.isEmpty {
                        Text("This reference will open in the Bible reader when available.")
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.72))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(OVTheme.cardPadding)
                            .premiumSurfaceCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(previewVerses, id: \.reference) { verse in
                                SelectedVersePreviewCard(reference: verse.reference, text: verse.text)
                            }
                        }
                    }

                    if let target {
                        Button {
                            dismiss()
                            onGoToBible(target)
                        } label: {
                            HStack {
                                Text("GO TO BIBLE")
                                    .font(OVTheme.heading(14))
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(OVTheme.midnight)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Scripture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)
                }
            }
        }
        .presentationDetents([.medium, .large])
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
    let topics: [String]
    let passingScore: Int
    let questPassed: Bool
    let hasNextLesson: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Quest will test you on")
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.midnight)

                Text("Pass with \(passingScore)% or higher to unlock what comes next.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(Array(topics.enumerated()), id: \.offset) { index, topic in
                    LessonPointRow(number: index + 1, text: topic)
                }
            }

            Text(statusText)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }

    private var statusText: String {
        if questPassed {
            return hasNextLesson
                ? "Quest passed. Continue to the next lesson from the button below."
                : "Quest passed. You finished the available lessons in this book."
        }

        return "Start the quest from the button below when you are ready."
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
                        Text("Quest")
                            .font(OVTheme.display(30))
                            .foregroundStyle(OVTheme.midnight)

                        Text("Answer the questions from this chapter. Passing unlocks the next lesson.")
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
            Text(result.passed ? "Quest passed" : "Quest complete")
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
