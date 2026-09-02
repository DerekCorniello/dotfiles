---
name: long-term-fix
description: "Fix root causes only - no hacks, no hardcoding, no workarounds, no TODOs. Use when fixing a bug, silencing a warning is tempting, or the user says 'fix it properly', 'no band-aids', or 'root cause'."
---

# Long-Term Fix

Every fix addresses the cause. A patch that makes the symptom go away without explaining why it happened is not done.

## Forbidden

- Magic values hardcoded to make a test or case pass.
- Workarounds for symptoms of an upstream bug.
- `TODO` / `FIXME` left in place of a real fix.
- Suppression attributes (`allow(dead_code)`, lint ignores, similar) to silence failures instead of resolving them.
- `try`/`catch` (or equivalent) swallowing import, init, or config errors so the process "starts anyway".
- Narrow special-cases keyed to the exact input that failed.

## Rules

1. First explain **why** the bug happens; state it in one sentence before touching code.
2. If the proper fix needs a refactor, propose the refactor in 2-3 sentences, then do it right.
3. Fix at the layer that owns the problem: a bad invariant is fixed where it is established, not where it detonates.
4. If a value looks like a constant, name it and derive it - never inline it to "make it work".
5. Errors from startup/import paths propagate loudly; fail fast with context.

## Done when

- [ ] The stated cause is addressed by the change.
- [ ] No magic values: every constant named or derived.
- [ ] Compiles/lints clean with **zero** suppression attributes added.
- [ ] No new TODO/FIXME comments introduced.
- [ ] Existing tests pass; a regression test covers the original failure where practical.
