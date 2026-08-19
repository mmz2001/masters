# 09 — EDA Explorer: Interactive Plotly Exploration, Loop-Built

**The idea:** same combined verification + loop-engineering discipline as
[practice 08](../08-adam-scanner-loop), applied to a general-purpose
exploratory-data-analysis app instead of a domain-specific scanner —
core logic decoupled and unit-tested first, then a UI, then a headless
test loop until green, then a deliberate check that the loop isn't
vacuously green.

## What's here

- `eda.R` — the logic, no UI: load a demo dataset (`iris`, `mtcars`, or
  `ggplot2::diamonds`, row-capped for the large one), parse an uploaded
  CSV/Excel file or pasted CSV text, find numeric columns, compute a
  correlation matrix, and compute a 2D MDS projection (classical MDS via
  `dist()` + `cmdscale()`, with row-cap sampling and an `extra_cols` option
  to carry a column through for coloring without losing row alignment).
- `app.R` — a Shiny app: pick a data source in the sidebar, then explore it
  across 4 tabs, each an interactive `plotly` chart: 2D scatter, correlation
  heatmap, 3D scatter, and MDS.
- `tests/testthat/test-eda.R` — unit tests on the logic alone (fast, no
  browser).
- `tests/testthat/test-app.R` — a `shinytest2` test that drives the actual
  running app headlessly: loads it, checks all 4 tabs render, switches demo
  datasets, uploads a CSV, and pastes CSV text.
- `LOOP.md` — the real build log, including a deliberate "break it on
  purpose" step that caught a genuinely vacuous check in the test suite
  itself (not just a bug in the app) — worth reading if you only read one
  of these files.

## Try it yourself

```bash
cd practices/09-eda-explorer

# Run the whole test suite headlessly — this is the loop, not a demo of it
Rscript -e 'shinytest2::test_app(app_dir=".")'

# Only then, if you want to see it interactively:
Rscript -e 'shiny::runApp(".")'
```

Requires R with `shiny`, `shinytest2`, `testthat`, `plotly`, `ggplot2`,
`readxl`, `openxlsx`, and a Chrome/Chromium binary on `PATH` (for headless
browser automation via `chromote`).
