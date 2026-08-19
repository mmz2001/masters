# 06 — Judgment Moves Up the Stack

**The idea:** as agents absorb more of the execution, what's left for the
human moves upstream — deciding what should exist at all, what tradeoffs
are acceptable, and what "good" actually looks like. This is "shaping the
build": bringing product sense and context to decide what belongs in the
spec, since an agent can increasingly deliver against whatever spec it's
handed. It's also the discipline behind "finding your unknowns" — knowing
your own codebase and tools well enough to spot the gap between what you
told the agent and what's actually true, before it causes a problem.

## Exercise — turn a vague ask into a scoped build

Below is a one-line ask, deliberately underspecified. Before writing (or
delegating) any code, write out:

1. **What should exist** — what's actually in scope, and just as
   important, what's explicitly *not* in scope for this pass.
2. **What tradeoffs are acceptable** — e.g. is a slower-but-simpler
   approach fine, or does this need to scale to real load right now?
3. **What "good" looks like** — a concrete, checkable definition of done
   (this connects back to `02-context-minimalism`'s acceptance criteria).

> "Add search to the app."

There's no single right answer — the point of the exercise is noticing how
many real decisions are hiding inside four words (search over what data?
exact match or fuzzy? indexed or scanned live? results ranked how?), and
that answering them is the actual job, not a distraction from it.

## A blind-spot pass

Once you've scoped something in an area you don't know well, do one more
pass: *"Given what I've told you about the goal, what are my likely
unknown unknowns here?"* The strongest builders don't have zero gaps
between what they think is true and what's actually true — they just have
fewer, because they ask this question early instead of finding out the
gap existed only after something broke.
