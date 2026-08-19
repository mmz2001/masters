# 01 — Verification Beats Guidance

**The idea:** giving an agent (or yourself) a way to check the work — a
test, a browser, a log tail — is worth more than another paragraph of
instructions. A model (or a person moving fast) writes with complete
conviction whether or not it's right; the review step is what catches that,
not extra care in the prompt.

## What's here

- `calc.py` — two small functions. One of them has a bug.
- `test_calc.py` — a test suite that should catch it.

## Try it yourself

```bash
cd practices/01-verification

# 1. Run the demo — it "works," no error, no crash:
python3 calc.py
# $100 with 20% off: -1900   <- clearly wrong, but nothing complained

# 2. Run the actual verification step:
python3 -m unittest test_calc.py -v
# test_apply_discount FAILS — now you have a concrete signal, not a hunch

# 3. Fix calc.py's apply_discount() so the discount is a percentage,
#    not a raw multiplier.

# 4. Re-run the test — it should go green:
python3 -m unittest test_calc.py -v
```

**The lesson isn't "write tests."** It's that step 1 (just running it) gave
zero signal that anything was wrong — the bug is silent. Step 2 (a real
check) is what turned "looks fine" into "here's exactly what's broken."
That's the whole practice: don't call something done until you've checked
it against something outside your own read of the code.
