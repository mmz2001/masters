"""Fan-out-and-synthesize: process several files independently, then merge.

Each file gets its own worker (its own "clean context") instead of one
pass reading all files in sequence. The synthesis step below only looks at
each worker's summary, not the original files, the way a top-level
orchestrator only sees what each subagent reports back.
"""
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

DATA_DIR = Path(__file__).parent / "data"


def summarize(path):
    """One 'worker': independently summarizes a single file."""
    text = path.read_text()
    words = text.split()
    sentences = [s for s in text.replace("\n", " ").split(".") if s.strip()]
    return {
        "file": path.name,
        "word_count": len(words),
        "sentence_count": len(sentences),
        "first_sentence": sentences[0].strip() if sentences else "",
    }


def synthesize(summaries):
    """The merge step: combines independent results into one report."""
    total_words = sum(s["word_count"] for s in summaries)
    lines = [f"Fan-out summary across {len(summaries)} files ({total_words} words total):"]
    for s in sorted(summaries, key=lambda s: s["file"]):
        lines.append(f"  {s['file']}: {s['sentence_count']} sentences — \"{s['first_sentence']}.\"")
    return "\n".join(lines)


def main():
    files = sorted(DATA_DIR.glob("*.txt"))
    if not files:
        print("No .txt files found in data/", file=sys.stderr)
        return 1

    with ThreadPoolExecutor(max_workers=len(files)) as pool:
        summaries = list(pool.map(summarize, files))

    print(synthesize(summaries))
    return 0


if __name__ == "__main__":
    sys.exit(main())
