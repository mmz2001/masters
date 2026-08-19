# 02 — Context Minimalism

**The idea:** the old habit was to front-load every possible instruction
into a prompt (long system prompts, exhaustive tool lists, step-by-step
scripts). The current one is the opposite: state the goal, the constraints,
and how you'll know it's done — then get out of the way. If an agent asks
too many clarifying questions, that's usually a sign the brief was
incomplete, not that it needs more hand-holding.

## The three-part brief template

```
Goal:              what success looks like, in plain language.
Constraints:        what not to touch, and any hard limits.
Acceptance criteria: how you'll know it's actually done.
```

## Try it — rewrite this bloated prompt

**Before** (context-engineered, ~120 words, still ambiguous):

> I want you to add a caching layer to the API. Please use an in-memory
> cache, or maybe Redis if that's easier, whichever you think is best.
> Make sure you consider TTLs, and think about invalidation strategy, and
> also think about whether this should be per-endpoint or global, and
> check how the existing rate limiter works first because it might
> interact with this, and also look at how other similar systems do
> caching, and write some tests, and update the README, and let me know if
> you have questions before starting, and also don't break anything that's
> already working, and try to keep the diff small if you can.

**After** (goal / constraints / acceptance criteria, ~40 words, less
ambiguous despite being shorter):

```
Goal: cache GET /reports/:id responses to cut average latency below 50ms.
Constraints: in-memory only (no new infra); don't touch the rate limiter.
Acceptance criteria: a 2nd request for the same id returns in <5ms in a
  local test; cache entries expire after 5 minutes.
```

Notice the "after" version is *shorter* but removes ambiguity instead of
adding it — every open question in the "before" version (which cache?
which invalidation? tests? docs?) either has a clear default now or was
cut because it didn't actually matter to the goal.

## Exercise

Pick a real task you'd normally hand off with a long prompt. Rewrite it
using the three-part template above. If you can't fill in "acceptance
criteria" concretely, that's usually the sign the goal itself was still
vague — fix that before writing more prompt.
