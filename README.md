# masters

Small, runnable practice examples for the six practices (plus one theme)
that seven people building at the edge of agentic AI converged on
independently, per the research brief *"How Frontier AI Builders Actually
Work"* (Michael Man + Claude, Aug 2026). Each folder is one practice, meant
to be read and actually run — not just read about.

This repo is for **learning by doing**. It doesn't run an activity-heartbeat
job the way [`github-basics`](https://github.com/mmz2001/github-basics)
does — everything here is meant to be worked through once, on purpose, not
generated automatically in the background.

## Practices

| # | Practice | Folder | One-line idea |
|---|---|---|---|
| 1 | Verification beats guidance | [`practices/01-verification`](practices/01-verification) | A test catches a silent bug that just running the code never would. |
| 2 | Context minimalism | [`practices/02-context-minimalism`](practices/02-context-minimalism) | Goal + constraints + acceptance criteria beats a long, front-loaded prompt. |
| 3 | Write it down once | [`practices/03-write-it-down-once`](practices/03-write-it-down-once) | Every correction becomes a durable rule, not a repeated fix. |
| 4 | Evals over intuition | [`practices/04-evals-over-intuition`](practices/04-evals-over-intuition) | Cluster real failures by root cause; fix the biggest cluster, not the latest complaint. |
| 5 | Orchestrated parallelism | [`practices/05-orchestrated-parallelism`](practices/05-orchestrated-parallelism) | Many isolated workers plus a synthesis step beat one worker doing everything. |
| 6 | Judgment moves up the stack | [`practices/06-judgment-shaping-the-build`](practices/06-judgment-shaping-the-build) | Deciding what belongs in the spec is the job, not a distraction from it. |
| 7 | Loop engineering | [`practices/07-loop-engineering`](practices/07-loop-engineering) | Four shapes — turn-based, goal-based, time-based, proactive — each handing off more of the loop from human to system. |
| 8 | Verification + loop engineering, combined | [`practices/08-adam-scanner-loop`](practices/08-adam-scanner-loop) | A small Shiny app, built and trusted through a real headless test loop — no human manually tests the UI. |
| 9 | Verification + loop engineering, combined | [`practices/09-eda-explorer`](practices/09-eda-explorer) | An interactive Plotly EDA app (demo datasets + your own CSV/Excel), where the loop's break-it-on-purpose step caught a vacuous test check, not just an app bug. |

## Requirements

Practices 1-7: Python 3, standard library only — nothing there needs
`pip install`. Everything was written and tested against Python 3.9.

Practices 8-9 are R + Shiny (Python's Streamlit wasn't installable in the
environment this was built in — no reachable package index — while R's
`shiny`/`shinytest2`/`testthat` were already available with working
headless-Chrome support via `chromote`). See each folder's own README for
exact package requirements.

## Try it

```bash
git clone https://github.com/mmz2001/masters.git
cd masters/practices/01-verification
python3 -m unittest test_calc.py -v
```

Then work through the rest in order, or jump straight to whichever practice
is most relevant to what you're building right now. Each folder's `README.md`
has its own "try it yourself" section.

## Source

*How Frontier AI Builders Actually Work* (Michael Man + Claude, Aug 2026) —
an internal research brief on six convergent practices from Boris Cherny,
Cat Wu & Thariq Shihipar, Andrew Ng, Andrej Karpathy, Simon Willison, Peter
Steinberger & Armin Ronacher, and Dan Shipper & Kieran Klaassen. Not
publicly hosted, so no link here — ask the person who shared this repo with
you if you'd like the original.
