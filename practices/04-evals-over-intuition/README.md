# 04 — Evals and Error Analysis Over Intuition

**The idea:** the clearest predictor of whether a team's fixes actually
help isn't model choice or cleverness — it's whether they run a disciplined
loop of pulling real failure cases, grouping them by root cause, and fixing
the biggest cluster first, instead of guessing or chasing whatever was
reported most recently.

## What's here

- `cases.jsonl` — 10 toy bug reports, each pre-labeled with a root cause
  (labeling real cases like this is normally the hard part; here it's
  given so you can focus on the clustering step).
- `analyze.py` — stdlib only, no dependencies: groups the cases by root
  cause and prints the biggest cluster first.

## Try it yourself

```bash
cd practices/04-evals-over-intuition
python3 analyze.py
```

You should see `regex-too-strict` come out on top with 4/10 cases — even
though the most *recent* case (#10) is also a regex bug, the point is you'd
reach the same "fix the regex" conclusion whether case #10 had just come in
or not, because the decision comes from the data, not from whichever report
is freshest in your head.

## Exercise

Add 2-3 more cases to `cases.jsonl` with a new root cause of your own
choosing, and re-run `analyze.py`. Notice how the ranking updates — the
"what to fix first" answer is a function of the data file, not of anyone's
memory of which bugs felt most urgent.
