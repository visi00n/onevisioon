# Original Language Bible Study Prototype

This folder is intentionally outside the app target. It is a safe test area for the Greek/Hebrew study feature so the current Bible reader can stay stable until the UX feels right.

## Product Direction

- Keep the normal Bible reader clean and readable.
- Let users select one verse, multiple verses, or eventually a single word.
- Add a small original-language action near existing highlight/note actions.
- Open a study sheet that shows the selected passage in the original language.
- Let users tap Greek or Hebrew words to see pronunciation, lemma, glosses, morphology, and a short explanation.
- For Matthew and the New Testament, the original-language layer is Greek.
- For the Old Testament, the original-language layer should be Hebrew, with Aramaic support where the biblical text is Aramaic.

## Important Accuracy Note

NIV is an English translation. The app should not present a “Greek NIV.” The safer UX is:

1. Show the user’s selected translation at the top.
2. Under it, show the original-language text for that biblical passage.
3. Explain that word-level alignments are study helps, not always one-to-one translations.

## Source Strategy

Do not scrape GreekBible.com. It can inspire the interaction model, but the shipped product needs clean licensing and attribution.

Candidate source options to verify before production:

- SBL Greek New Testament: https://github.com/Faithlife/SBLGNT
- OpenGNT: https://github.com/eliranwong/OpenGNT
- Open Scriptures Hebrew Bible / morphology: https://github.com/openscriptures/morphhb

Before shipping, confirm:

- exact license terms,
- attribution text required inside the app,
- whether morphology, transliteration, and gloss data can be redistributed,
- whether share/export screens can include original-language text,
- whether any selected English translation license restricts alignment display.

## Prototype Files

- `OriginalLanguageStudyPrototype.swift` contains a standalone SwiftUI mock of the selection bar and original-language sheet.
- `original-language-sample-data.json` contains sample data for Matthew 1:21.
- `OriginalLanguageDataPipeline.md` outlines the production import and UX pipeline.
