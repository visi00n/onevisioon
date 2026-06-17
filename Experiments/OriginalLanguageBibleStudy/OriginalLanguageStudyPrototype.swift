import SwiftUI

struct OriginalLanguageStudyPrototypeView: View {
    @State private var selectedVerseIDs: Set<String> = ["Matthew 1:21"]
    @State private var showingOriginalLanguage = false

    private let passage = OriginalLanguagePrototypeData.matthewOneTwentyOne

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Matthew 1")
                            .font(.largeTitle.bold())

                        prototypeVerseRow

                        Text("Prototype note: single tap selects this verse. In production, a long press could select the full verse range while a tap inside the original-language sheet selects individual words.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(20)
                    .padding(.bottom, selectedVerseIDs.isEmpty ? 20 : 110)
                }

                if !selectedVerseIDs.isEmpty {
                    selectionActionBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
            }
            .navigationTitle("Bible")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingOriginalLanguage) {
                OriginalLanguageStudySheet(passage: passage)
                    .presentationDetents([.fraction(0.58), .large])
            }
        }
    }

    private var prototypeVerseRow: some View {
        Button {
            toggleVerseSelection(passage.reference)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Text("21")
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .frame(width: 30, alignment: .leading)

                Text(passage.englishText)
                    .font(.body)
                    .lineSpacing(5)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(selectedVerseIDs.contains(passage.reference) ? Color.orange.opacity(0.13) : Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selectedVerseIDs.contains(passage.reference) ? Color.orange.opacity(0.5) : Color.gray.opacity(0.18), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.35) {
            selectedVerseIDs.insert(passage.reference)
        }
    }

    private var selectionActionBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(selectedVerseIDs.count) verse selected")
                    .font(.headline)

                Spacer()

                Button("Clear") {
                    selectedVerseIDs.removeAll()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                prototypeActionChip(title: "Highlight", systemImage: "highlighter")
                prototypeActionChip(title: "Note", systemImage: "note.text.badge.plus")

                Button {
                    showingOriginalLanguage = true
                } label: {
                    HStack(spacing: 8) {
                        Text("Ἑ")
                            .font(.title3.weight(.bold))

                        Text("Greek")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.indigo)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
    }

    private func prototypeActionChip(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }

    private func toggleVerseSelection(_ reference: String) {
        if selectedVerseIDs.contains(reference) {
            selectedVerseIDs.remove(reference)
        } else {
            selectedVerseIDs.insert(reference)
        }
    }
}

private struct OriginalLanguageStudySheet: View {
    let passage: OriginalLanguagePassage

    @State private var selectedToken: OriginalLanguageToken?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(passage.reference)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)

                        Text(passage.englishText)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Greek text")
                            .font(.headline)

                        FlexibleTokenGrid(tokens: passage.tokens, selectedToken: $selectedToken)
                    }

                    if let selectedToken {
                        OriginalLanguageTokenCard(token: selectedToken)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        Text("Tap any Greek word to see pronunciation, lemma, meanings, morphology, and a quick study note.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Original Language")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct FlexibleTokenGrid: View {
    let tokens: [OriginalLanguageToken]
    @Binding var selectedToken: OriginalLanguageToken?

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 82), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(tokens) { token in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedToken = token
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(token.surface)
                            .font(.title3.weight(.semibold))

                        Text(token.transliteration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedToken?.id == token.id ? Color.indigo.opacity(0.14) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedToken?.id == token.id ? Color.indigo.opacity(0.55) : Color.gray.opacity(0.16), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct OriginalLanguageTokenCard: View {
    let token: OriginalLanguageToken

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(token.surface)
                    .font(.largeTitle.bold())

                Text(token.transliteration)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            detailRow("Pronounce", token.pronunciation)
            detailRow("Lemma", token.lemma)
            detailRow("Morphology", token.morphology)
            detailRow("English range", token.glosses.joined(separator: ", "))
            detailRow("Aligned English", token.alignedEnglish)

            Text(token.quickExplanation)
                .font(.body)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.indigo.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
        }
    }
}

private struct OriginalLanguagePassage: Identifiable, Hashable {
    var id: String { reference }

    let reference: String
    let language: String
    let englishText: String
    let originalText: String
    let tokens: [OriginalLanguageToken]
}

private struct OriginalLanguageToken: Identifiable, Hashable {
    let id: String
    let surface: String
    let lemma: String
    let transliteration: String
    let pronunciation: String
    let morphology: String
    let glosses: [String]
    let alignedEnglish: String
    let quickExplanation: String
}

private enum OriginalLanguagePrototypeData {
    static let matthewOneTwentyOne = OriginalLanguagePassage(
        reference: "Matthew 1:21",
        language: "Greek",
        englishText: "She will bear a son, and you shall call his name Jesus, for he will save his people from their sins.",
        originalText: "τέξεται δὲ υἱὸν καὶ καλέσεις τὸ ὄνομα αὐτοῦ Ἰησοῦν· αὐτὸς γὰρ σώσει τὸν λαὸν αὐτοῦ ἀπὸ τῶν ἁμαρτιῶν αὐτῶν.",
        tokens: [
            OriginalLanguageToken(
                id: "mt1-21-texetai",
                surface: "τέξεται",
                lemma: "τίκτω",
                transliteration: "texetai",
                pronunciation: "TEK-seh-tie",
                morphology: "Verb, future middle indicative, third singular",
                glosses: ["will bear", "will give birth"],
                alignedEnglish: "She will bear",
                quickExplanation: "The future verb points to the promised birth announced by the angel, emphasizing that this child is coming by God's initiative."
            ),
            OriginalLanguageToken(
                id: "mt1-21-huion",
                surface: "υἱὸν",
                lemma: "υἱός",
                transliteration: "huion",
                pronunciation: "hwee-ON",
                morphology: "Noun, accusative masculine singular",
                glosses: ["son"],
                alignedEnglish: "a son",
                quickExplanation: "Matthew identifies the promised child as a son before explaining His saving name and mission."
            ),
            OriginalLanguageToken(
                id: "mt1-21-kaleseis",
                surface: "καλέσεις",
                lemma: "καλέω",
                transliteration: "kaleseis",
                pronunciation: "ka-LEH-says",
                morphology: "Verb, future active indicative, second singular",
                glosses: ["you will call", "you will name"],
                alignedEnglish: "you shall call",
                quickExplanation: "Joseph is commanded to name the child, publicly receiving Him into David's legal line."
            ),
            OriginalLanguageToken(
                id: "mt1-21-iesoun",
                surface: "Ἰησοῦν",
                lemma: "Ἰησοῦς",
                transliteration: "Iesoun",
                pronunciation: "yay-SOON",
                morphology: "Proper noun, accusative masculine singular",
                glosses: ["Jesus", "Yahweh saves"],
                alignedEnglish: "Jesus",
                quickExplanation: "The Greek name corresponds to Hebrew/Aramaic forms connected with the meaning Yahweh saves, matching the explanation that follows."
            ),
            OriginalLanguageToken(
                id: "mt1-21-sosei",
                surface: "σώσει",
                lemma: "σῴζω",
                transliteration: "sosei",
                pronunciation: "SOH-say",
                morphology: "Verb, future active indicative, third singular",
                glosses: ["he will save", "rescue", "deliver"],
                alignedEnglish: "he will save",
                quickExplanation: "Matthew defines Jesus' mission as rescue from sin, not merely moral advice or political victory."
            ),
            OriginalLanguageToken(
                id: "mt1-21-laon",
                surface: "λαὸν",
                lemma: "λαός",
                transliteration: "laon",
                pronunciation: "la-ON",
                morphology: "Noun, accusative masculine singular",
                glosses: ["people", "nation"],
                alignedEnglish: "his people",
                quickExplanation: "The saving mission gathers a people who belong to Him."
            ),
            OriginalLanguageToken(
                id: "mt1-21-hamartion",
                surface: "ἁμαρτιῶν",
                lemma: "ἁμαρτία",
                transliteration: "hamartion",
                pronunciation: "ha-mar-tee-OWN",
                morphology: "Noun, genitive feminine plural",
                glosses: ["sins", "offenses", "acts against God"],
                alignedEnglish: "their sins",
                quickExplanation: "The genitive plural names the problem Jesus comes to deal with: real sins against God, not only hardship or ignorance."
            )
        ]
    )
}

#Preview {
    OriginalLanguageStudyPrototypeView()
}
