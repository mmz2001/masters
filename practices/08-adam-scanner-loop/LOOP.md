# LOOP.md — the actual build loop, not a staged one

This is a real log of building this practice, kept honest rather than
cleaned up after the fact. The point isn't that everything passed on the
first try — it's that every check ran automatically and nothing was
verified by a human clicking through a browser.

## Attempt 1 — wrong shape (caught by judgment, not by a test)

First pass generated *ARDS*-shaped synthetic data (aggregated
results: one row per statistic per treatment per visit — means, standard
errors) and a scanner over that shape. The internal skill this practice is
modeled on (`adam-scanner`) actually scans **ADaM** data — subject-level
datasets like ADSL, one row per subject, with population flags and
treatment arms as columns. Aggregated results and subject-level records
share a lot of surface vocabulary ("treatment arm," "population flag") but
are structurally different things to scan.

No test caught this, because none had been written yet — this was a
domain-modeling mismatch, not a code bug. A green test suite proves the
code does what the tests say; it doesn't prove the tests describe the
right target. That check is still a human judgment call (see
[`06-judgment-shaping-the-build`](../06-judgment-shaping-the-build)) — the
loop in this folder automates everything *downstream* of "did we scope
the right thing," not that step itself.

Fixed by discarding the ARDS generator/data and rebuilding
`data/generate_synthetic_adam.R` to emit an ADSL-shaped dataset instead:
one row per (fictional) subject, `USUBJID`/`ARM`/`ARMCD`/`TRT01PN` plus
demographics and population flags (`ITTFL`, `SAFFL`, `COMPLFL`).

## Attempt 2 — the actual self-testing loop, run for real

1. `Rscript generate_synthetic_adam.R synthetic_adsl.csv` — ran clean,
   60 rows, 3 arms x 20 subjects, verified by reading the CSV head and
   an arm-count tally before moving on.
2. `Rscript -e 'testthat::test_file("test-scanner.R")'` — **13/13 passed
   on the first run.** Schema discovery, value enumeration, and per-arm
   counts (with and without a population filter) all matched expectations
   against a small hand-built toy data frame.
3. `Rscript -e 'shinytest2::test_app(app_dir=".")'` — **25 app assertions
   + 13 scanner assertions, 38/38 passed on the first run**, headless,
   via `chromote` (headless Chrome), no browser window, no human.

## Verifying the verifier

38/38 green on the first try is a little suspicious for a UI layer — so
before trusting it, the loop deliberately broke `app.R` (hardcoded the
treatment variable to `"AGE"` instead of reading `input$trt_var`) and
reran the exact same suite:

```
[ FAIL 12 | WARN 0 | SKIP 0 | PASS 13 ]
```

The break was caught immediately and specifically (the per-arm-count
assertions failed, exactly where the bug was). Reverted the change, reran,
back to 38/38. Only after seeing it fail on a real bug is a passing suite
worth trusting — this is the same idea as
[`01-verification`](../01-verification)'s "run it red before you trust it
green," applied to a whole test suite instead of one function.

## Which loop shape is this?

**Goal-based** (see [`07-loop-engineering`](../07-loop-engineering)): the
stop condition was "every test passes, and I've confirmed the suite isn't
vacuously green" — not a fixed number of turns, not a schedule, not an
external event. The human handed off the *check* itself; nothing here
needed a person to open a browser and click through the UI at any point.
