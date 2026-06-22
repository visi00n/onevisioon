# Original Language Data Pipeline

## 1. Reader Interaction

Production Bible reader flow:

1. User taps a verse to select it.
2. User long-presses or drags to select a verse range.
3. Existing bottom bar shows copy, share, highlight, note, and an original-language action.
4. Original-language action opens a sheet.
5. Sheet shows the selected English translation first.
6. Sheet shows original Hebrew, Aramaic, or Greek beneath it.
7. User taps one word to see lemma, pronunciation, glosses, morphology, and explanation.

## 2. Data Shape

Recommended normalized model:

```swift
struct OriginalLanguagePassage {
    let reference: String
    let testamentLanguage: TestamentLanguage
    let selectedTranslationText: String
    let originalText: String
    let tokens: [OriginalLanguageToken]
}

struct OriginalLanguageToken {
    let surface: String
    let lemma: String
    let transliteration: String
    let pronunciation: String
    let morphology: String
    let strongs: String?
    let glosses: [String]
    let alignedEnglish: String?
    let explanation: String
}
```

## 3. Import Steps

1. Pick licensed source texts for Greek New Testament and Hebrew/Aramaic Old Testament.
2. Normalize book names, chapter numbers, and verse numbers to match `BibleDataProvider`.
3. Import original text by verse.
4. Import morphology and lemma data.
5. Generate or import transliteration.
6. Add pronunciation strings for app-friendly display.
7. Add concise gloss lists.
8. Create alignment hints from English phrase to original token where legally and technically safe.
9. Store data locally in compressed JSON or SQLite.
10. Add attribution screen and license text inside Settings.

## 4. Alignment Rules

Word study should be honest:

- Some English words map to multiple Greek or Hebrew words.
- Some Greek or Hebrew words are implied in English rather than directly translated.
- Word order often differs.
- A word's meaning is controlled by context, not by listing every possible dictionary gloss.
- NIV text should not be redistributed beyond whatever the app's existing Bible license permits.

## 5. UI Rules

- Keep the Bible reader uncluttered until the user selects text.
- Use a compact original-language chip, probably `Ἑ` for Greek and `ע` for Hebrew.
- Use a sheet instead of pushing the reader away from the chapter.
- Start with verse-level selection before trying native iOS text drag selection.
- Add word-level selection inside the original-language sheet first; it is easier and safer than selecting individual words in the rendered English Bible text.

## 6. Production Caution

This feature needs stronger review than normal UI work:

- theological accuracy,
- original-language accuracy,
- morphology accuracy,
- pronunciation consistency,
- source licensing,
- attribution requirements,
- offline storage size,
- performance in large chapters.

The first production milestone should support New Testament Greek for a small set of chapters, then expand after the model, UX, and license path are proven.
