# 07 — Loop Engineering: Four Shapes

**The idea:** the job shifts from "prompt the agent this turn" to "design
the small system that prompts the agent for you" — a loop that discovers
work, dispatches it, verifies the result, and decides the next step, with a
human touch point only where one is actually needed. Four shapes hand off
progressively more of that loop from human to system:

| Shape | Human hands off | Example in this repo |
|---|---|---|
| **Turn-based** | the check | Running any script in `practices/*` by hand and reading the output yourself |
| **Goal-based** | the stop condition | Re-running `practices/04-evals-over-intuition/analyze.py` after adding cases, until a specific root cause drops out of the top cluster |
| **Time-based** | the trigger | [`.github/workflows/scheduled-eval.yml`](../../.github/workflows/scheduled-eval.yml) — runs `analyze.py` on a schedule, no one has to remember to run it |
| **Proactive** | the prompt itself | [`.github/workflows/on-issue-check.yml`](../../.github/workflows/on-issue-check.yml) — fires automatically when an issue is labeled `practice-check`; nobody scheduled it or typed a prompt, the *event* is the trigger |

## Try it yourself

**Time-based:**
```bash
gh workflow run scheduled-eval.yml
gh run watch --exit-status
cat loop-log.md   # a new dated line should have been appended
```

**Proactive:**
```bash
gh issue create --title "check" --body "test" --label practice-check
# wait a few seconds, then:
gh issue list --state open
gh api repos/mmz2001/masters/issues/<number>/comments --jq '.[].body'
gh issue close <number>
```

## Why this is the odd one out

Every other practice in this repo (folders 01-06) is something you can
apply *within* a single turn-based session — verify before calling
something done, write a tighter brief, etc. Loop engineering is different:
it's about building something that keeps running *between* sessions,
without you re-invoking it each time. That's also why it's the one gap
flagged in `skill-guidance`'s cross-check of this brief — most work still
runs turn-based or, at best, time-based; the fully proactive shape (a
system that decides on its own whether a condition warrants escalating to
a human) isn't yet standard practice, here or anywhere else in this
project's tooling.
