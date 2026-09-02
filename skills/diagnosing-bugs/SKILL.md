---
name: diagnosing-bugs
description: "Diagnosis loop for hard bugs and performance regressions. Use when the user says diagnose/debug this, or reports something broken, throwing, failing, or slow."
---

# Diagnosing Bugs

A discipline for hard bugs. Skip phases only with explicit justification.

## Phase 1: Build a feedback loop FIRST

**This is the skill.** Everything else is mechanical. A tight pass/fail signal that goes red on _this_ bug guarantees you find the cause; bisection and hypothesis-testing just consume it. No loop means no amount of staring at code will save you. Be aggressive. Refuse to give up.

Ways to build one, roughly in order:

1. Failing test at whatever seam reaches the bug (unit / integration / e2e).
2. Curl or HTTP script against a running dev server.
3. CLI invocation with fixture input, diffed against known-good output.
4. Headless browser script driving the UI, asserting on DOM/console/network.
5. Replay a captured trace (saved payload, request log) through the code path in isolation.
6. Throwaway minimal harness exercising just the buggy path.
7. Property/fuzz loop for "sometimes wrong" bugs: many random inputs, watch for the failure mode.
8. Bisection harness between two known states, so bisect can run it.
9. Differential loop: same input through old vs new version, diff outputs.

**Tighten it:** faster (skip unrelated init), sharper (assert the exact symptom, not "didn't crash"), deterministic (pin time, seed RNG, freeze network). Flaky bugs: raise the reproduction rate until debuggable (loop triggers, add stress).

If no loop is possible, stop and say so. List what you tried; ask for access, captured artifacts, or permission to instrument. Do not hypothesize without a loop.

**Done when:** one command exists that you have already run at least once (show redacted output), drives the real bug path, asserts the user's exact symptom, is deterministic, and runs in seconds.

Reading code to build a theory before that command exists is the exact failure this skill prevents. Stop.

## Phase 2: Reproduce + minimise

Run the loop; confirm it fails with the symptom the **user** described, reproducibly. Then shrink to the smallest scenario still going red: cut inputs/callers/config one at a time, re-run after each cut, keep only what's load-bearing. A minimal repro shrinks the hypothesis space.

**Done when:** every remaining element of the repro is load-bearing.

## Phase 3: Hypothesise

Generate **3-5 ranked hypotheses** before testing any. Single-hypothesis generation anchors on the first plausible idea. Each must be falsifiable: state its prediction ("if X is the cause, changing Y makes the bug disappear"). No prediction = vibe = discard or sharpen.

Show the ranked list to the user before testing; they often re-rank instantly. Proceed with your ranking if they're away.

## Phase 4: Instrument

One variable at a time; each probe maps to a specific prediction. Prefer debugger/REPL inspection, then targeted logs at boundaries distinguishing hypotheses. Never "log everything and grep".

Tag every temporary log with a unique prefix, e.g. `[DEBUG-a4f2]`. Tagged logs die in cleanup; untagged logs survive forever.

Perf regressions: logs are usually wrong. Baseline measurement first (profiler, timing harness, query plan), then bisect. Measure first, fix second.

## Phase 5: Fix + regression test

Write the regression test **before** the fix, but only if a **correct seam** exists: one where the test exercises the real bug pattern as it occurs at the call site. Too-shallow seams give false confidence. If no correct seam exists, that is itself the finding: note it and flag it.

With a correct seam: minimised repro -> failing test -> watch it fail -> fix -> watch it pass -> re-run the original un-minimised scenario.

## Phase 6: Cleanup

- [ ] Original repro no longer reproduces.
- [ ] Regression test passes (or missing seam documented).
- [ ] All `[DEBUG-...]` instrumentation removed (one grep on the prefix).
- [ ] Throwaway prototypes deleted or clearly marked.
- [ ] The confirmed cause stated in the commit/PR message.

Adapted from: github.com/mattpocock/skills skills/engineering/diagnosing-bugs
