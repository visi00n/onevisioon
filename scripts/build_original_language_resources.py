#!/usr/bin/env python3
import csv
import io
import json
import re
import urllib.request
import zipfile
from collections import defaultdict
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
RESOURCES_DIR = REPO_ROOT / "onevisioon" / "Resources"

SBLGNT_BASE = "https://raw.githubusercontent.com/Faithlife/SBLGNT/master/data/sblgnt/text"
OPENGNT_BASE = "https://raw.githubusercontent.com/eliranwong/OpenGNT/master"
CENTER_BLC_BASE = "https://raw.githubusercontent.com/CenterBLC/LXX/main/tf/1935"
LXX_WORD_COUNT = 623_693

SBL_BOOKS = [
    ("Matt", "Matthew"),
    ("Mark", "Mark"),
    ("Luke", "Luke"),
    ("John", "John"),
    ("Acts", "Acts"),
    ("Rom", "Romans"),
    ("1Cor", "1 Corinthians"),
    ("2Cor", "2 Corinthians"),
    ("Gal", "Galatians"),
    ("Eph", "Ephesians"),
    ("Phil", "Philippians"),
    ("Col", "Colossians"),
    ("1Thess", "1 Thessalonians"),
    ("2Thess", "2 Thessalonians"),
    ("1Tim", "1 Timothy"),
    ("2Tim", "2 Timothy"),
    ("Titus", "Titus"),
    ("Phlm", "Philemon"),
    ("Heb", "Hebrews"),
    ("Jas", "James"),
    ("1Pet", "1 Peter"),
    ("2Pet", "2 Peter"),
    ("1John", "1 John"),
    ("2John", "2 John"),
    ("3John", "3 John"),
    ("Jude", "Jude"),
    ("Rev", "Revelation"),
]

OPENGNT_BOOKS = {
    "40": "Matthew",
    "41": "Mark",
    "42": "Luke",
    "43": "John",
    "44": "Acts",
    "45": "Romans",
    "46": "1 Corinthians",
    "47": "2 Corinthians",
    "48": "Galatians",
    "49": "Ephesians",
    "50": "Philippians",
    "51": "Colossians",
    "52": "1 Thessalonians",
    "53": "2 Thessalonians",
    "54": "1 Timothy",
    "55": "2 Timothy",
    "56": "Titus",
    "57": "Philemon",
    "58": "Hebrews",
    "59": "James",
    "60": "1 Peter",
    "61": "2 Peter",
    "62": "1 John",
    "63": "2 John",
    "64": "3 John",
    "65": "Jude",
    "66": "Revelation",
}

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

GREEK_TO_LATIN = str.maketrans({
    "Α": "A", "α": "a", "Ἀ": "A", "Ἁ": "Ha", "Ἄ": "A", "Ἅ": "Ha", "Ἆ": "A", "Ἇ": "Ha", "ἀ": "a", "ἁ": "ha", "ἄ": "a", "ἅ": "ha", "ἆ": "a", "ἇ": "ha", "ά": "a", "ὰ": "a", "ᾶ": "a", "ᾳ": "a", "ᾴ": "a",
    "Β": "B", "β": "b",
    "Γ": "G", "γ": "g",
    "Δ": "D", "δ": "d",
    "Ε": "E", "ε": "e", "Ἐ": "E", "Ἑ": "He", "Ἔ": "E", "Ἕ": "He", "ἐ": "e", "ἑ": "he", "ἔ": "e", "ἕ": "he", "έ": "e", "ὲ": "e",
    "Ζ": "Z", "ζ": "z",
    "Η": "E", "η": "e", "Ἠ": "E", "Ἡ": "He", "Ἤ": "E", "Ἥ": "He", "Ἦ": "E", "Ἧ": "He", "ἠ": "e", "ἡ": "he", "ἤ": "e", "ἥ": "he", "ἦ": "e", "ἧ": "he", "ή": "e", "ὴ": "e", "ῆ": "e", "ῃ": "e",
    "Θ": "Th", "θ": "th",
    "Ι": "I", "ι": "i", "Ἰ": "I", "Ἱ": "Hi", "Ἴ": "I", "Ἵ": "Hi", "Ἶ": "I", "Ἷ": "Hi", "ἰ": "i", "ἱ": "hi", "ἴ": "i", "ἵ": "hi", "ἶ": "i", "ἷ": "hi", "ί": "i", "ὶ": "i", "ῖ": "i", "ϊ": "i", "ΐ": "i",
    "Κ": "K", "κ": "k",
    "Λ": "L", "λ": "l",
    "Μ": "M", "μ": "m",
    "Ν": "N", "ν": "n",
    "Ξ": "X", "ξ": "x",
    "Ο": "O", "ο": "o", "Ὀ": "O", "Ὁ": "Ho", "Ὄ": "O", "Ὅ": "Ho", "ὀ": "o", "ὁ": "ho", "ὄ": "o", "ὅ": "ho", "ό": "o", "ὸ": "o",
    "Π": "P", "π": "p",
    "Ρ": "R", "ρ": "r", "Ῥ": "Rh", "ῥ": "rh",
    "Σ": "S", "σ": "s", "ς": "s",
    "Τ": "T", "τ": "t",
    "Υ": "Y", "υ": "y", "Ὑ": "Hy", "Ὕ": "Hy", "Ὗ": "Hy", "ὐ": "y", "ὑ": "hy", "ὔ": "y", "ὕ": "hy", "ὖ": "y", "ὗ": "hy", "ύ": "y", "ὺ": "y", "ῦ": "y", "ϋ": "y", "ΰ": "y",
    "Φ": "Ph", "φ": "ph",
    "Χ": "Ch", "χ": "ch",
    "Ψ": "Ps", "ψ": "ps",
    "Ω": "O", "ω": "o", "Ὠ": "O", "Ὡ": "Ho", "Ὤ": "O", "Ὥ": "Ho", "Ὦ": "O", "Ὧ": "Ho", "ὠ": "o", "ὡ": "ho", "ὤ": "o", "ὥ": "ho", "ὦ": "o", "ὧ": "ho", "ώ": "o", "ὼ": "o", "ῶ": "o", "ῳ": "o",
})


def download_text(url: str) -> str:
    with urllib.request.urlopen(url) as response:
        return response.read().decode("utf-8")


def download_zip_member(url: str, suffix: str) -> str:
    data = urllib.request.urlopen(url).read()
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        member = next(name for name in archive.namelist() if name.endswith(suffix))
        return archive.read(member).decode("utf-8")


def download_tf_values(feature_name: str, limit: int = LXX_WORD_COUNT, default: str = "") -> list[str]:
    text = download_text(f"{CENTER_BLC_BASE}/{feature_name}.tf")

    values: list[str] = [default] * limit
    in_data = False
    sequential_index = 0
    for line in text.splitlines():
        if not in_data:
            if line.strip() == "":
                in_data = True
            continue

        if not line or line.startswith("@"):
            continue

        parts = line.split("\t", 1)
        if len(parts) == 2 and parts[0].isdigit():
            index = int(parts[0]) - 1
            if 0 <= index < limit:
                values[index] = parts[1]
            continue

        if sequential_index >= limit:
            break

        values[sequential_index] = line
        sequential_index += 1

    return values


def clean_sbl_text(text: str) -> str:
    text = re.sub(r"[⸀⸂⸃⸄⸅⸆⸇⸈⸉⸊⸋⸌⸍⸎⸏]", "", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def build_sblgnt_verses() -> dict[str, str]:
    verses: dict[str, str] = {}
    for abbreviation, book in SBL_BOOKS:
        text = download_text(f"{SBLGNT_BASE}/{abbreviation}.txt")
        for line in text.splitlines():
            if "\t" not in line:
                continue
            raw_reference, verse_text = line.split("\t", 1)
            match = re.match(r"^\S+\s+(\d+):(\d+)$", raw_reference)
            if not match:
                continue
            chapter, verse = match.groups()
            verses[f"{book} {int(chapter)}:{int(verse)}"] = clean_sbl_text(verse_text)
    return verses


def normalized_strongs(value: str) -> str:
    match = re.match(r"([GH])0*(\d+)", value.strip())
    if not match:
        return value.strip()
    return f"{match.group(1)}{int(match.group(2))}"


def strip_brackets(value: str) -> str:
    value = value.strip()
    if value.startswith("〔") and value.endswith("〕"):
        return value[1:-1]
    return value


def compact_values(value: str) -> list[str]:
    seen: set[str] = set()
    values: list[str] = []
    for piece in strip_brackets(value).split("｜"):
        cleaned = re.sub(r"<[^>]+>", "", piece).strip()
        if not cleaned or cleaned == "-" or cleaned in seen:
            continue
        seen.add(cleaned)
        values.append(cleaned)
    return values


def compact_lxx_glosses(*values: str) -> list[str]:
    seen: set[str] = set()
    glosses: list[str] = []
    for value in values:
        for piece in re.split(r"[;,]", value):
            cleaned = piece.strip()
            if not cleaned or cleaned == "-" or cleaned in seen:
                continue
            seen.add(cleaned)
            glosses.append(cleaned)
    return glosses


def plain_lemma_from_html(html: str) -> str:
    match = re.search(r"<n>(.*?)</n>", html)
    if not match:
        return ""
    return re.sub(r"<[^>]+>", "", match.group(1)).strip()


def build_lemma_map() -> dict[str, str]:
    text = download_zip_member(f"{OPENGNT_BASE}/OpenGNT_DictOGNT.csv.zip", "OpenGNT_DictOGNT.csv")
    lemmas: dict[str, str] = {}
    for line in text.splitlines():
        if "\t" not in line:
            continue
        strongs, html = line.split("\t", 1)
        lemma = plain_lemma_from_html(html)
        if lemma:
            lemmas[normalized_strongs(strongs)] = lemma
    return lemmas


def transliterate(value: str) -> str:
    cleaned = re.sub(r"[^\w\u0370-\u03ff\u1f00-\u1fff]", "", value)
    return cleaned.translate(GREEK_TO_LATIN)


def first_tantt_word(value: str) -> tuple[str, str, str] | None:
    for variant in strip_brackets(value).split(";"):
        parts = variant.split("=")
        if len(parts) >= 4 and parts[1].strip():
            return parts[1].strip(), normalized_strongs(parts[2]), parts[3].strip()
    return None


def build_greek_word_study() -> dict[str, list[dict[str, object]]]:
    lemmas = build_lemma_map()
    text = download_zip_member(
        f"{OPENGNT_BASE}/OpenGNT_keyedFeatures.csv.zip",
        "OpenGNT_keyedFeatures.csv",
    )
    reader = csv.DictReader(io.StringIO(text), delimiter="\t")
    grouped: dict[str, list[dict[str, object]]] = defaultdict(list)

    for row in reader:
        ref_parts = compact_values(row.get("〔book｜chapter｜verse〕", ""))
        if len(ref_parts) != 3:
            continue
        book = OPENGNT_BOOKS.get(ref_parts[0])
        if not book:
            continue

        tantt = first_tantt_word(row.get("〔TANTT〕", ""))
        if not tantt:
            continue

        surface, strongs, morphology = tantt
        reference = f"{book} {int(ref_parts[1])}:{int(ref_parts[2])}"
        glosses = compact_values(row.get("〔MounceGloss｜TyndaleHouseGloss｜OpenGNTGloss〕", ""))
        aligned = compact_values(row.get("〔TBESG｜IT｜LT｜ST｜Español〕", ""))
        order = len(grouped[reference]) + 1

        grouped[reference].append({
            "order": order,
            "surface": surface,
            "lemma": lemmas.get(strongs, ""),
            "strongs": strongs,
            "morphology": morphology,
            "transliteration": transliterate(surface),
            "glosses": glosses[:4],
            "alignedEnglish": aligned[0] if aligned else "",
        })

    return dict(sorted(grouped.items()))


def canonical_lxx_reference(raw_book: str, chapter: int, verse: int) -> tuple[str, int, int] | None:
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


def resource_slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")


def build_lxx_word_study_by_book() -> dict[str, dict[str, list[dict[str, object]]]]:
    books = download_tf_values("book")
    chapters = [int(value) for value in download_tf_values("chapter")]
    verses = [int(value) for value in download_tf_values("verse")]
    words = download_tf_values("word")
    lemmas = download_tf_values("lex_utf8")
    strongs_values = download_tf_values("strongs")
    morphology_values = download_tf_values("morphology")
    transliterations = download_tf_values("translit_SBL")
    gloss_values = download_tf_values("gloss")
    bol_gloss_values = download_tf_values("bol_gloss")

    grouped: dict[str, dict[str, list[dict[str, object]]]] = defaultdict(lambda: defaultdict(list))

    for raw_book, chapter, verse, word, lemma, strongs, morphology, transliteration, gloss, bol_gloss in zip(
        books,
        chapters,
        verses,
        words,
        lemmas,
        strongs_values,
        morphology_values,
        transliterations,
        gloss_values,
        bol_gloss_values,
    ):
        canonical = canonical_lxx_reference(raw_book, chapter, verse)
        if not canonical:
            continue

        book, canonical_chapter, canonical_verse = canonical
        reference = f"{book} {canonical_chapter}:{canonical_verse}"
        glosses = compact_lxx_glosses(gloss, bol_gloss)
        order = len(grouped[book][reference]) + 1

        grouped[book][reference].append({
            "order": order,
            "surface": word,
            "lemma": "" if lemma == "-" else lemma,
            "strongs": "" if strongs == "-" else normalized_strongs(strongs),
            "morphology": "" if morphology == "-" else morphology,
            "transliteration": "" if transliteration == "-" else transliteration,
            "glosses": glosses[:4],
            "alignedEnglish": glosses[0] if glosses else "",
        })

    return {
        book: dict(sorted(references.items()))
        for book, references in sorted(grouped.items())
    }


def write_json(path: Path, value: object) -> None:
    path.write_text(
        json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    RESOURCES_DIR.mkdir(parents=True, exist_ok=True)

    sblgnt_verses = build_sblgnt_verses()
    write_json(RESOURCES_DIR / "verses-sblgnt.json", sblgnt_verses)

    greek_word_study = build_greek_word_study()
    write_json(RESOURCES_DIR / "original-language-greek-nt.json", greek_word_study)

    lxx_word_study_by_book = build_lxx_word_study_by_book()
    for book, references in lxx_word_study_by_book.items():
        write_json(
            RESOURCES_DIR / f"original-language-greek-ot-{resource_slug(book)}.json",
            references,
        )

    print(f"Wrote {len(sblgnt_verses)} SBLGNT verses")
    print(f"Wrote {sum(len(tokens) for tokens in greek_word_study.values())} Greek word-study tokens")
    print(
        "Wrote "
        f"{sum(len(tokens) for references in lxx_word_study_by_book.values() for tokens in references.values())} "
        f"Septuagint word-study tokens across {len(lxx_word_study_by_book)} books"
    )


if __name__ == "__main__":
    main()
