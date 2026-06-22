#!/usr/bin/env python3
import json
import re
import urllib.request
from collections import defaultdict
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RESOURCES_DIR = REPO_ROOT / "onevisioon" / "Resources"
CENTER_BLC_BASE = "https://raw.githubusercontent.com/CenterBLC/LXX/main/tf/1935"
WORD_COUNT = 623_693

CANONICAL_LXX_BOOKS = {
    "Gen": "Genesis",
    "Exod": "Exodus",
    "Lev": "Leviticus",
    "Num": "Numbers",
    "Deut": "Deuteronomy",
    "Josh": "Joshua",
    "Judg": "Judges",
    "Ruth": "Ruth",
    "1Sam": "1 Samuel",
    "2Sam": "2 Samuel",
    "1Kgs": "1 Kings",
    "2Kgs": "2 Kings",
    "1Chr": "1 Chronicles",
    "2Chr": "2 Chronicles",
    "Esth": "Esther",
    "Job": "Job",
    "Ps": "Psalms",
    "Prov": "Proverbs",
    "Qoh": "Ecclesiastes",
    "Cant": "Song of Solomon",
    "Isa": "Isaiah",
    "Jer": "Jeremiah",
    "Lam": "Lamentations",
    "Ezek": "Ezekiel",
    "Dan": "Daniel",
    "Hos": "Hosea",
    "Joel": "Joel",
    "Amos": "Amos",
    "Obad": "Obadiah",
    "Jonah": "Jonah",
    "Mic": "Micah",
    "Nah": "Nahum",
    "Hab": "Habakkuk",
    "Zeph": "Zephaniah",
    "Hag": "Haggai",
    "Zech": "Zechariah",
    "Mal": "Malachi",
}


def download_tf_values(feature_name: str, limit: int = WORD_COUNT) -> list[str]:
    with urllib.request.urlopen(f"{CENTER_BLC_BASE}/{feature_name}.tf", timeout=90) as response:
        text = response.read().decode("utf-8")

    values: list[str] = []
    in_data = False
    for line in text.splitlines():
        if not in_data:
            if line.strip() == "":
                in_data = True
            continue

        if not line or line.startswith("@"):
            continue

        values.append(line.split("\t", 1)[-1])
        if len(values) >= limit:
            break

    if len(values) != limit:
        raise RuntimeError(f"{feature_name}.tf returned {len(values)} values, expected {limit}")

    return values


def canonical_reference(raw_book: str, chapter: int, verse: int) -> tuple[str, int, int] | None:
    if chapter < 1 or verse < 1:
        return None

    if raw_book == "2Esdr":
        if 1 <= chapter <= 10:
            return "Ezra", chapter, verse
        if 11 <= chapter <= 23:
            return "Nehemiah", chapter - 10, verse
        return None

    book = CANONICAL_LXX_BOOKS.get(raw_book)
    if not book:
        return None

    return book, chapter, verse


def clean_verse_text(words: list[str]) -> str:
    text = " ".join(words)
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([,.;:!?])", r"\1", text)
    return text.strip()


def build_lxx_old_testament() -> dict[str, str]:
    books = download_tf_values("book")
    chapters = [int(value) for value in download_tf_values("chapter")]
    verses = [int(value) for value in download_tf_values("verse")]
    words = download_tf_values("word")

    grouped: dict[tuple[str, int, int], list[str]] = defaultdict(list)
    for raw_book, chapter, verse, word in zip(books, chapters, verses, words):
        reference = canonical_reference(raw_book, chapter, verse)
        if not reference:
            continue
        grouped[reference].append(word)

    output: dict[str, str] = {}
    for (book, chapter, verse), verse_words in grouped.items():
        text = clean_verse_text(verse_words)
        if text:
            output[f"{book} {chapter}:{verse}"] = text

    return output


def main() -> None:
    RESOURCES_DIR.mkdir(parents=True, exist_ok=True)

    lxx_old_testament = build_lxx_old_testament()
    sblgnt_path = RESOURCES_DIR / "verses-sblgnt.json"
    sblgnt_new_testament = json.loads(sblgnt_path.read_text(encoding="utf-8"))

    greek_bible = {**lxx_old_testament, **sblgnt_new_testament}
    output_path = RESOURCES_DIR / "verses-greek.json"
    output_path.write_text(
        json.dumps(greek_bible, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {len(lxx_old_testament)} Greek OT verses")
    print(f"Wrote {len(sblgnt_new_testament)} Greek NT verses")
    print(f"Wrote {len(greek_bible)} total Greek Bible verses to {output_path}")


if __name__ == "__main__":
    main()
