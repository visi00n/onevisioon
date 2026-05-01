import Foundation

struct ChapterReflectionDraft: Hashable, Codable {
    var highlightedVerses: [String]
    var stoodOut: String
    var godMessage: String
    var application: String
    var learned: String
    var questions: String

    static let empty = ChapterReflectionDraft(
        highlightedVerses: [],
        stoodOut: "",
        godMessage: "",
        application: "",
        learned: "",
        questions: ""
    )

    var hasRequiredFields: Bool {
        !stoodOut.trimmed.isEmpty && !godMessage.trimmed.isEmpty && !application.trimmed.isEmpty
    }
}

struct ChapterReflection: Identifiable, Hashable, Codable {
    let id: UUID
    let lessonID: String
    let lessonOrder: Int
    let lessonTitle: String
    var highlightedVerses: [String]
    var stoodOut: String
    var godMessage: String
    var application: String
    var learned: String
    var questions: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        lessonID: String,
        lessonOrder: Int,
        lessonTitle: String,
        highlightedVerses: [String],
        stoodOut: String,
        godMessage: String,
        application: String,
        learned: String,
        questions: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.lessonID = lessonID
        self.lessonOrder = lessonOrder
        self.lessonTitle = lessonTitle
        self.highlightedVerses = highlightedVerses
        self.stoodOut = stoodOut
        self.godMessage = godMessage
        self.application = application
        self.learned = learned
        self.questions = questions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var searchableText: String {
        (
            [
                lessonTitle,
                highlightedVerses.joined(separator: " "),
                stoodOut,
                godMessage,
                application,
                learned,
                questions
            ]
            .joined(separator: " ")
            .lowercased()
        )
    }

    func shareText(reference: String) -> String {
        let highlightsLine = highlightedVerses.isEmpty ? "None selected yet" : highlightedVerses.joined(separator: ", ")

        return """
        One Visioon Chapter Reflection

        Chapter: \(reference)
        Lesson: \(lessonTitle)
        Highlighted verses: \(highlightsLine)

        What stood out to you?
        \(stoodOut)

        What do you think God is speaking here?
        \(godMessage)

        How will you apply this chapter to your life?
        \(application)

        What did you learn?
        \(learned.isEmpty ? "-" : learned)

        What questions do you have?
        \(questions.isEmpty ? "-" : questions)
        """
    }
}

struct ReflectionSaveResult {
    let saved: Bool
    let pointsEarned: Int
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
    

