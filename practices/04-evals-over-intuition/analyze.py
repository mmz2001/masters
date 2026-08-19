"""Group toy bug reports by root cause and surface the biggest cluster first.

The point isn't the clustering code — it's the discipline: pull real
failure cases, group by root cause, and fix the biggest cluster first,
instead of fixing whichever case was reported most recently.
"""
import json
import sys
from collections import Counter
from pathlib import Path

CASES_FILE = Path(__file__).parent / "cases.jsonl"


def load_cases(path):
    cases = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                cases.append(json.loads(line))
    return cases


def main():
    cases = load_cases(CASES_FILE)
    counts = Counter(c["root_cause"] for c in cases)

    print(f"{len(cases)} cases loaded, {len(counts)} distinct root causes:\n")
    for cause, n in counts.most_common():
        print(f"  {n:>2}  {cause}")

    biggest_cause, biggest_n = counts.most_common(1)[0]
    print(f"\nFix first: '{biggest_cause}' ({biggest_n}/{len(cases)} cases)"
          f" — not case #{cases[-1]['id']} just because it's the most recent.")


if __name__ == "__main__":
    sys.exit(main())
