---
name: arena
description: "Spawn N parallel candidate attempts at the same task, cross-review them, pick a base, graft the strongest parts of the losers into it. Use for arena requests, or whenever one attempt at a non-trivial artifact would lock in the wrong shape."
---

# Arena

Fan out N parallel attempts at the same task. Read every candidate end to end. Pick the strongest as base. Graft the losers' best ideas into it. Verify the synthesis.

Open a todolist with one entry per phase before launching anything; the arena runs autonomously and the list keeps phases from silently disappearing.

## Phase A: Frame

The candidates receive the same prompt, so the prompt is the contract.

1. State the artifact each candidate produces.
2. Derive a rubric: what success looks like for _this_ task, turned into 3-6 concrete gradeable criteria. Concrete: "adds a --dry-run flag that skips writes". Vague: "code is correct".
3. Pick runners: **different models where available** (diverse priors); same model N times only when the work is generation-bound rather than judgment-sensitive.
4. Assign output paths: one per candidate (git worktree where possible, else `.arena/<slug>/candidate-<n>/ (repo-local, gitignored)`). Shared output paths are shared mutable state; never allow it.

## Phase B: Fan out

Spawn all N subagents in one message, backgrounded, each with: the task, shared grounding inputs, its own output path, and instructions to produce the artifact **plus a short rationale** naming alternatives considered and rejected. Without rationale, grafting later is guesswork.

A candidate that produces nothing is dropped; proceed with N-1 and note the dropout.

## Phase C: Cross-judge

After all candidates complete, spawn one readonly judge subagent - **a different model from the parent's family if available**. It sees the rubric and candidates by path label, scores criterion by criterion, recommends a base with rationale. Spawn only after all candidates finish; judging partial output reports false dropouts. It runs in parallel with your own reading.

## Phase D: Pick

Read every candidate end to end before picking; skimming surfaces only whichever looks most familiar. Score against rubric criteria, not holistic feel. Compare with the cross-judge: agreement confirms; disagreement means someone is biased or the rubric was ambiguous - read both rationales before deciding.

Tie-break toward the cleaner boundary / smaller surface a future maintainer can extend without breaking invariants.

Record pick + reason in a short synthesis note alongside the base artifact, including the judge's verdict.

## Phase E: Graft

Walk each loser once more; usually one or two things per candidate are worth porting. Fold grafts in by hand so the result stays coherent under one mental model. Never paste mechanically.

Record what was grafted, from which candidate, and what was rejected and why. Rejection notes are the highest-signal part of the record.

Convergence signal: if all N converge on the same shape, ship the consensus shape, no graft needed. Wild divergence means Phase A was under-specified: reframe and re-run rather than averaging the divergence.

## Phase F: Verify

The synthesized artifact holds up under the same scrutiny as any other output; the arena earns no pass. If verification finds a problem the arena missed: either Phase A was wrong (re-frame, re-run) or a candidate caught it and you missed the graft (back to Phase E). Don't paper over.

**Done when:** one synthesized artifact + one synthesis note exists, naming the base, grafts with sources, rejections, dropouts, and verification result.

Adapted from: github.com/cursor/plugins pstack/skills/arena
