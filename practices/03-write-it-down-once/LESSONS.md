# Lessons

One entry per correction, written once, so it never has to be given twice.
Format: the rule itself, then **Why** (what prompted it) and **How to
apply** (when it kicks in).

---

## 2026-08-19 — Percentages as fractions, not whole numbers

**Rule:** when a function takes a rate or percentage, document (and test)
whether it expects `0.20` or `20` — and pick one convention per codebase.

**Why:** `practices/01-verification/calc.py`'s `apply_discount` took a whole
number (`20`) but the sibling function `total_after_tax` took a fraction
(`0.08`) — the exact kind of silent mismatch a test catches immediately and
a casual read of the code doesn't.

**How to apply:** whenever adding a new rate/percentage parameter, check
the convention used by neighboring functions in the same file first, rather
than picking whichever feels natural in isolation.

---

<!-- Add your own entries below this line, oldest first. -->
