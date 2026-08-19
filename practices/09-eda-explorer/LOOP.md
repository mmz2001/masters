# LOOP.md — the real build log for practice 09

Same discipline as [practice 08](../08-adam-scanner-loop/LOOP.md): core logic
written and unit-tested first, decoupled from any UI; then the Shiny app;
then a headless `shinytest2` suite; then a deliberate "break it on purpose"
step to confirm the suite isn't just green because it's vacuous.

## Attempt 1 — core logic (`eda.R`)

Wrote `load_demo_dataset()`, `parse_uploaded_file()`, `parse_pasted_text()`,
`numeric_columns()`, `compute_correlation_matrix()`, `compute_mds()`.
Smoke-tested each function interactively via `Rscript` against `iris`,
`mtcars`, `ggplot2::diamonds`, a real uploaded CSV/XLSX round-trip, and
pasted CSV text — all worked first try. Wrote 20 `testthat` assertions
against `eda.R` alone (no Shiny, no browser): **20/20 passed on the first
run.**

Then, while designing the MDS tab's color-by picker, realized
`compute_mds()` as written drops rows (via `complete.cases()` and
row-cap sampling) with no way to know *which* rows survived — so a
"color by Species" picker in the app would have no reliable way to align
colors back to the right points. Fixed by adding an `extra_cols` parameter
that subsets alongside the same filtering/sampling and gets `cbind`'d into
the output, so the MDS output and the color column always stay row-aligned.
Added one more test for that (`extra_cols` survives row-cap and
complete-case filtering) — caught *before* it became a real bug, by
thinking through the next consumer of the function, not by a failing test.
**24/24 unit tests passing.**

## Attempt 2 — the app (`app.R`)

Sidebar picks a data source (demo dataset / upload CSV+Excel / paste CSV
text) and, per active tab, the relevant axis/color pickers. Main panel is
4 tabs, each one `plotly` output: 2D scatter, correlation heatmap, 3D
scatter, MDS. No logic duplicated from `eda.R` — the server functions are
thin wrappers that call it and hand the result to `plot_ly()`.

## Attempt 3 — headless `shinytest2` suite

Wrote a test that: loads the app, checks each of the 4 tabs for no
`shiny-output-error` **and** a rendered plotly widget, switches the demo
dataset (mtcars → diamonds → iris), uploads a small CSV, and pastes CSV
text — all through the actual running app, no manual clicking.
**First run: 17/17 app assertions + 24/24 unit tests = 41/41 green.**

## Verifying the verifier — and finding a real gap this time

Same as practice 08, broke something on purpose: renamed
`output$heatmap` to `output$heatmap_typo` in the server (a real bug — the
UI still calls `plotlyOutput("heatmap")`, so the tab would render nothing).

**Re-ran the suite. It stayed 41/41 green — a false pass.** The check
`has_plotly_widget()` was `grepl("plotly", html, fixed = TRUE)` against the
output div's HTML. Turns out `shiny::plotlyOutput()` puts a placeholder
`<div>` with a static CSS class *containing the word "plotly"* on the page
regardless of whether the server ever renders anything into it — so the
check was true before any real render happened, and stayed true after I
broke the render. The test suite was accidentally checking for the
*existence of the output slot in the UI*, not for *evidence a chart was
actually drawn*.

Fixed the check to look for `js-plotly-plot` instead — a class that
`Plotly.js` itself adds to the div only once it has actually drawn a chart
in the browser, which a static server-side placeholder can't fake.
Re-ran against the still-broken app: **now correctly fails**, exactly on
the "Correlation Heatmap" tab, with the expected assertion message.
Reverted the deliberate break. Re-ran clean: **41/41 green again.**

This is a more useful catch than practice 08's break-it-on-purpose step,
which just confirmed a good check still worked — this one found that the
*check itself* was silently vacuous from the start, and wouldn't have
caught a real regression in this tab if the deliberate-break step had
never been run.

## Attempt 4 — a real user hit a real environment gap (post-ship)

After shipping, a user opened the "3D Scatter" tab on this host and got a
raw browser error: WebGL disabled/unavailable. `plotly`'s `scatter3d`
trace always requires WebGL — there's no built-in non-WebGL fallback in
plotly.js — and on a shared HPC/corporate host, WebGL can be missing for
reasons this app has zero control over (IT policy, an embedded IDE viewer
webview without a software rasterizer, an old browser). This wasn't a bug
the test suite could have caught: the headless Chrome the suite runs
under (via `chromote`) does have working WebGL, so `test-app.R` never
exercised the no-WebGL path at all — a green suite proved the happy path
worked, not that the environment it assumed (WebGL present) always holds.

Fixed by adding a small client-side detection script (`tags$script` in the
`ui`, tries `canvas.getContext('webgl')` and reports the result via
`Shiny.setInputValue('webgl_available', ...)`), and branching
`output$scatter3d` on it: real interactive 3D when WebGL is available,
otherwise a 2D bubble chart (Z as marker size, with a visible note) so the
tab degrades instead of showing a raw browser error. Added one assertion
that `input$webgl_available` actually resolves to a boolean after load —
that's the part a future regression in the detection script itself would
break, even though the suite's Chrome will always take the "WebGL
available" branch and can never directly exercise the fallback branch.

**Lesson**: a headless test suite inherits the assumptions of whatever
environment it runs in. It can't tell you your code handles an environment
your test runner never sees — that gap only shows up when a *different*
environment (a real user's real browser) hits it. Handling that required
noticing the report, reasoning about *why* it could happen on a shared
host, and choosing a fix that degrades gracefully rather than assuming
away the problem — the "loop" here started from a human-reported failure,
not from a failing assertion.

## Which loop shape is this?

Goal-based, same as practice 08 (see
[practice 07](../07-loop-engineering)): the stop condition was "every
assertion passes, and I've confirmed the suite would actually fail on a
real bug" — not a turn count or a fixed number of attempts. The second
half of that condition is the one that actually mattered here. Attempt 4
is a reminder that goal-based loops only cover what the goal actually
checks — "all tests pass" said nothing about the one environment gap that
turned out to matter to a real user.
