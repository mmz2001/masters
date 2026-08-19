# 08 — ADaM Scanner Loop: Verification + Loop Engineering, for Real

**The idea:** practices 01 (verification) and 07 (loop engineering) aren't
just concepts — combined, they let you build and trust a whole feature
without a human manually testing the UI. This folder is that, done for
real against a small Shiny app, not simulated for the README.

## What's here

- `data/generate_synthetic_adam.R` — generates a small, entirely fictional
  ADSL-shaped dataset (`synthetic_adsl.csv`): a made-up study
  (`SYNTH-001`), made-up drug (`ZYNTH`), made-up subjects. One row per
  subject, with treatment arm, demographics, and population flags —
  the standard ADaM "subject-level analysis dataset" shape.
- `scanner.R` — the scanning logic, decoupled from any UI: schema
  discovery, distinct-value enumeration for low-cardinality columns, and
  per-arm subject counts (optionally filtered by a population flag).
  Modeled on the *idea* behind an internal `adam-scanner` skill's
  three-phase design — rewritten from scratch here, over synthetic data
  only. **No code or data from that skill is used in this repo.**
- `app.R` — a small Shiny app: upload a CSV or use the bundled synthetic
  one, pick a treatment variable and an optional population flag, see the
  three tables `scanner.R` produces.
- `tests/testthat/test-scanner.R` — plain unit tests on the scanning logic
  alone (fast, no browser).
- `tests/testthat/test-app.R` — a `shinytest2` test that drives the actual
  running app headlessly (via `chromote`, headless Chrome) and checks the
  rendered tables match what `scanner.R` computes directly.
- `LOOP.md` — an honest log of the real build loop, including the one
  domain-modeling mistake it caught and a deliberate "break it on purpose"
  step to confirm the test suite isn't vacuously green.

## Why synthetic data, not real ADaM data

This is a public repo. Real ADaM datasets are clinical trial data —
scanning a real one, or even shipping a real trial's column/schema
structure, doesn't belong here. Every value in `synthetic_adsl.csv` is
generated from a fixed random seed for a fictional study; `SYNTH-001` and
`ZYNTH` don't exist.

## Try it yourself

```bash
cd practices/08-adam-scanner-loop

# Regenerate the synthetic data (optional — a copy is already checked in)
Rscript data/generate_synthetic_adam.R data/synthetic_adsl.csv

# Run the whole test suite headlessly — this is the loop, not a demo of it
Rscript -e 'shinytest2::test_app(app_dir=".")'

# Only then, if you want to see it interactively:
Rscript -e 'shiny::runApp(".")'
```

Requires R with `shiny`, `shinytest2`, `testthat`, and a Chrome/Chromium
binary on `PATH` (for headless browser automation via `chromote`).
