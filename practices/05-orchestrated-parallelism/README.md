# 05 — Orchestrated Parallelism

**The idea:** the unit of work stopped being "one pass through everything."
Many single-purpose workers, each with a clean, isolated context, beat one
worker doing everything sequentially — as long as something synthesizes
their results afterward. This is the **fan-out-and-synthesize** shape, one
of six recurring orchestration patterns in the source brief (the others are
classify-and-act, adversarial verification, generate-and-filter, tournament,
and loop-until-done).

## What's here

- `data/*.txt` — three tiny toy "reports."
- `fanout.py` — stdlib `concurrent.futures` only: summarizes each file
  independently (the fan-out), then merges the summaries into one report
  (the synthesis).

## Try it yourself

```bash
cd practices/05-orchestrated-parallelism
python3 fanout.py
```

Each file is summarized without looking at the others — `summarize()`
never sees more than one file at a time, the same way a subagent in a real
workflow shouldn't need the full context every other subagent has. Only
`synthesize()` sees all the results together, and only the *summaries*, not
the original text.

## Exercise

Add a fourth `.txt` file to `data/` and re-run — no code changes needed,
`fanout.py` picks up whatever's in the folder. Then try breaking the
pattern on purpose: make `summarize()` also read every *other* file in the
loop (defeating the "clean, isolated context" property) and notice how
that couples the workers together for no real benefit here — a concrete
version of the brief's own caution that orchestration isn't free and should
be reserved for tasks that actually decompose into independent units.
