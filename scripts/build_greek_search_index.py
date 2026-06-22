#!/usr/bin/env python3
import json
import re
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RESOURCES_DIR = REPO_ROOT / "onevisioon" / "Resources"

CANONICAL_BOOK_ORDER = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
    "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
    "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
    "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
    "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
    "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
    "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
    "Zephaniah", "Haggai", "Zechariah", "Malachi",
    "Matthew", "Mark", "Luke", "John", "Acts",
    "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
    "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy",
    "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
    "1 Peter", "2 Peter", "1 John", "2 John", "3 John",
    "Jude", "Revelation",
]

REFERENCE_RE = re.compile(r"^(?P<book>.+?) (?P<chapter>\d+):(?P<verse>\d+)$")
LOW_SIGNAL_GLOSSES = {
    "a",
    "an",
    "and",
    "also",
    "among",
    "as",
    "at",
    "be",
    "but",
    "by",
    "even",
    "for",
    "from",
    "he",
    "her",
    "herself",
    "him",
    "himself",
    "his",
    "i",
    "in",
    "into",
    "it",
    "itself",
    "me",
    "my",
    "of",
    "on",
    "or",
    "our",
    "she",
    "that",
    "the",
    "their",
    "them",
    "themselves",
    "they",
    "this",
    "to",
    "we",
    "what",
    "which",
    "who",
    "whom",
    "with",
    "you",
    "your",
    "namely",
    "one",
    "same",
    "not",
    "all",
}


def normalize_key(value: str) -> str:
    cleaned = (value or "").strip().lower()
    decomposed = unicodedata.normalize("NFD", cleaned)
    without_marks = "".join(
        character for character in decomposed
        if unicodedata.category(character) != "Mn"
    )
    return re.sub(r"\s+", " ", without_marks)


def normalize_search_term(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", (value or "").lower()).strip()


def search_terms_from(value: str) -> list[str]:
    normalized = normalize_search_term(value)
    if not normalized:
        return []

    terms = set(normalized.split())
    if len(normalized) > 2:
        terms.add(normalized)
    return sorted(terms)


def compact_values(values: list[str]) -> list[str]:
    seen = set()
    compacted = []
    for value in values:
        cleaned = re.sub(r"\s+", " ", (value or "").strip())
        if not cleaned or cleaned == "-" or cleaned.lower() in seen:
            continue
        seen.add(cleaned.lower())
        compacted.append(cleaned)
    return compacted


def comma_join(values: list[str], limit: int | None = None) -> str:
    selected = values if limit is None else values[:limit]
    if not selected:
        return ""

    if len(selected) == 1:
        return selected[0]

    if len(selected) == 2:
        return f"{selected[0]} and {selected[1]}"

    return f"{', '.join(selected[:-1])}, and {selected[-1]}"


def is_low_signal_gloss(value: str) -> bool:
    normalized = normalize_search_term(value)
    if normalized in LOW_SIGNAL_GLOSSES:
        return True

    words = normalized.split()
    return bool(words) and all(word in LOW_SIGNAL_GLOSSES for word in words)


def definition_glosses(glosses: list[str]) -> list[str]:
    substantive = [gloss for gloss in glosses if not is_low_signal_gloss(gloss)]
    return substantive or glosses


def definition_glosses_from_counter(glosses: Counter) -> list[str]:
    all_ranked = glosses.most_common()
    if all_ranked and is_low_signal_gloss(all_ranked[0][0]):
        return [all_ranked[0][0]]

    ranked = [(gloss, count) for gloss, count in all_ranked if not is_low_signal_gloss(gloss)]
    if not ranked:
        ranked = glosses.most_common()
    if not ranked:
        return []

    top_count = ranked[0][1]
    if top_count <= 2:
        return [gloss for gloss, _ in ranked[:2]]

    threshold = max(2, int(top_count * 0.12))

    filtered = [gloss for gloss, count in ranked if count >= threshold]
    return filtered or [ranked[0][0]]


def related_glosses_from_counter(glosses: Counter, primary_glosses: list[str]) -> list[str]:
    if primary_glosses and is_low_signal_gloss(primary_glosses[0]):
        return []

    ranked = [(gloss, count) for gloss, count in glosses.most_common() if not is_low_signal_gloss(gloss)]
    if not ranked:
        return []

    primary_keys = {normalize_search_term(gloss) for gloss in primary_glosses}
    top_count = ranked[0][1]
    if top_count < 10:
        return []

    threshold = max(5, int(top_count * 0.25))

    related: list[str] = []
    for gloss, count in ranked:
        if count < threshold:
            continue
        if normalize_search_term(gloss) in primary_keys:
            continue
        related.append(gloss)
        if len(related) >= 12:
            break

    return related


def searchable_terms_from_glosses(glosses: list[str]) -> list[str]:
    seen: set[str] = set()
    terms: list[str] = []

    for gloss in glosses:
        for term in search_terms_from(gloss):
            if len(term) < 2 or is_low_signal_gloss(term) or term in seen:
                continue
            seen.add(term)
            terms.append(term)

    return terms


def parse_reference(reference: str) -> tuple[str, int, int] | None:
    match = REFERENCE_RE.match(reference)
    if not match:
        return None
    return (
        match.group("book"),
        int(match.group("chapter")),
        int(match.group("verse")),
    )


def resource_files() -> list[Path]:
    return [RESOURCES_DIR / "original-language-greek-nt.json"] + sorted(
        RESOURCES_DIR.glob("original-language-greek-ot-*.json")
    )


def contextual_definition(preferred: list[str]) -> str:
    if not preferred:
        return "This word's meaning is shown by its verse context."

    if len(preferred) == 1:
        return f"In context, this word is commonly used with the sense of {preferred[0]}."

    return f"In context, this word can carry the sense of {comma_join(preferred, limit=3)}."


def expanded_definition(
    display_greek: str,
    lemma: str,
    preferred: list[str],
    occurrence_count: int,
) -> str:
    if not preferred:
        return (
            f"{display_greek} is indexed with {occurrence_count} verse occurrence"
            f"{'' if occurrence_count == 1 else 's'}. Its local meaning is best read from each verse alignment."
        )

    headline = preferred[0]
    range_text = comma_join(preferred[1:], limit=5)
    lemma_text = f" The dictionary form is {lemma}." if lemma and lemma != display_greek else ""

    if range_text:
        return (
            f"{display_greek} most often points to {headline} in the indexed verse data, "
            f"with related contextual senses such as {range_text}.{lemma_text} "
            "Use the occurrence list to confirm the exact sense in each verse."
        )

    return (
        f"{display_greek} most often points to {headline} in the indexed verse data."
        f"{lemma_text} Use the occurrence list to confirm the exact sense in each verse."
    )


def usage_summary(
    preferred: list[str],
    surfaces: Counter,
    books: Counter,
    occurrence_count: int,
) -> str:
    book_count = len(books)
    form_text = comma_join([value for value, _ in surfaces.most_common(4)])
    gloss_text = comma_join(preferred, limit=4)

    pieces = [
        f"Appears {occurrence_count} time{'' if occurrence_count == 1 else 's'}",
        f"across {book_count} book{'' if book_count == 1 else 's'}",
    ]

    if form_text:
        pieces.append(f"with common forms including {form_text}")

    if gloss_text:
        pieces.append(f"and common local glosses including {gloss_text}")

    return " ".join(pieces) + "."


def build_search_index() -> list[dict[str, object]]:
    grouped: dict[str, dict[str, object]] = defaultdict(
        lambda: {
            "surfaces": Counter(),
            "lemmas": Counter(),
            "strongs": Counter(),
            "transliterations": Counter(),
            "glosses": Counter(),
            "localGlosses": Counter(),
            "searchTerms": Counter(),
            "books": Counter(),
            "occurrences": [],
        }
    )

    for path in resource_files():
        with path.open(encoding="utf-8") as handle:
            references = json.load(handle)

        for reference, tokens in references.items():
            parsed = parse_reference(reference)
            if not parsed:
                continue

            book, chapter, verse = parsed
            for token in tokens:
                key_source = token.get("lemma") or token.get("strongs") or token.get("surface")
                key = normalize_key(key_source)
                if not key:
                    continue

                entry = grouped[key]
                surface = (token.get("surface") or "").strip()
                lemma = (token.get("lemma") or "").strip()
                strongs = (token.get("strongs") or "").strip()
                transliteration = (token.get("transliteration") or "").strip()
                aligned = re.sub(r"[\t\n\r]+", " ", (token.get("alignedEnglish") or "").strip())
                glosses = compact_values(token.get("glosses") or [])
                local_gloss = aligned or (glosses[0] if glosses else "")

                if surface:
                    entry["surfaces"][surface] += 1
                entry["books"][book] += 1
                if local_gloss:
                    entry["localGlosses"][local_gloss] += 1
                if lemma:
                    entry["lemmas"][lemma] += 1
                if strongs:
                    entry["strongs"][strongs] += 1
                if transliteration:
                    entry["transliterations"][transliteration] += 1

                for gloss in glosses:
                    entry["glosses"][gloss] += 1
                    for term in search_terms_from(gloss):
                        entry["searchTerms"][term] += 1

                for term in search_terms_from(aligned):
                    entry["searchTerms"][term] += 1

                # tab-separated keeps the occurrence list much smaller than objects.
                entry["occurrences"].append(
                    "\t".join([book, str(chapter), str(verse), surface, aligned])
                )

    book_order = {book: index for index, book in enumerate(CANONICAL_BOOK_ORDER)}
    index = []
    for key, entry in grouped.items():
        glosses = [value for value, _ in entry["glosses"].most_common()]
        display_greek = (
            entry["lemmas"].most_common(1)[0][0]
            if entry["lemmas"]
            else entry["surfaces"].most_common(1)[0][0]
        )
        transliteration = (
            entry["transliterations"].most_common(1)[0][0]
            if entry["transliterations"]
            else ""
        )
        occurrence_records = sorted(
            entry["occurrences"],
            key=lambda record: (
                book_order.get(record.split("\t", 1)[0], 999),
                int(record.split("\t")[1]),
                int(record.split("\t")[2]),
            ),
        )

        preferred_glosses = definition_glosses_from_counter(entry["localGlosses"])
        related_glosses = related_glosses_from_counter(entry["glosses"], preferred_glosses)
        simple_definition = preferred_glosses[0] if preferred_glosses else "meaning shown by context"
        lemma = entry["lemmas"].most_common(1)[0][0] if entry["lemmas"] else ""
        search_terms = searchable_terms_from_glosses(preferred_glosses + related_glosses)

        index.append({
            "key": key,
            "displayGreek": display_greek,
            "lemma": lemma,
            "strongs": entry["strongs"].most_common(1)[0][0] if entry["strongs"] else "",
            "transliteration": transliteration,
            "simpleDefinition": simple_definition,
            "contextualDefinition": contextual_definition(preferred_glosses),
            "inDepthDefinition": expanded_definition(
                display_greek,
                lemma,
                preferred_glosses,
                len(occurrence_records),
            ),
            "usageSummary": usage_summary(
                preferred_glosses,
                entry["surfaces"],
                entry["books"],
                len(occurrence_records),
            ),
            "primaryGlosses": preferred_glosses,
            "relatedGlosses": related_glosses,
            "glosses": glosses,
            "searchTerms": search_terms[:96],
            "occurrences": occurrence_records,
        })

    return sorted(
        index,
        key=lambda entry: (-len(entry["occurrences"]), entry["displayGreek"], entry["key"]),
    )


def main() -> None:
    index = build_search_index()
    output_path = RESOURCES_DIR / "original-language-greek-search-index.json"
    output_path.write_text(
        json.dumps(index, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n",
        encoding="utf-8",
    )

    missing_definitions = [
        entry["displayGreek"] for entry in index
        if not entry["simpleDefinition"] or entry["simpleDefinition"] == "meaning shown by context"
    ]
    print(f"Wrote {len(index)} Greek search entries")
    print(f"Wrote {sum(len(entry['occurrences']) for entry in index)} Greek word occurrences")
    print(f"Entries needing fallback definitions: {len(missing_definitions)}")


if __name__ == "__main__":
    main()
