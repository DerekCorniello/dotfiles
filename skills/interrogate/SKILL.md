---
name: interrogate
description: "Use for interrogate, adversarial review, multi-model review, challenge this, stress test this code, find blind spots, or tear this apart. Multiple independent reviewers challenge changes from different angles; diversity is the signal."
---

# Interrogate

Spawn one reviewer per available model to adversarially review code changes. Each gets the same prompt and rubric. The adversarial signal comes from model diversity, not assigned personas: models differ in blind spots, priors, and reasoning patterns. Cross-model agreement is high-confidence; lone-reviewer findings are worth reading but weighted lower.

The deliverable is a synthesized verdict. **Never auto-apply changes.**

## Step 1: Determine scope

Identify what to review from context: files or diff the user pointed at; else the full changeset vs the appropriate base branch (`git diff main...HEAD`); else files referenced by recent work. Package the diff plus surrounding context reviewers need.

## Step 2: State the intent

Before spawning reviewers, write one clear paragraph on what this code is trying to accomplish, derived from the user's message, commit messages, PR description, and the code itself. Reviewers challenge whether the work achieves the intent well, not whether the intent is correct. Unsure of intent? Ask before proceeding.

## Step 3: Spawn reviewers

Launch all reviewers in parallel in a single message, each a readonly subagent. Use a **different model per reviewer when configured models are available**; fall back to N copies of the strongest reasoning model otherwise, keeping labels Reviewer A/B/C/D... Each receives the identical filled template:

1. The stated intent
2. The diff or file contents
3. The rubric: correctness, security, maintainability, performance, API design, error handling, tests, edge cases
4. Instruction to produce structured findings: each finding = location, issue, severity, suggested fix

If a model slug fails to resolve, pick the closest equivalent (highest-reasoning tier of the same family) and continue; don't block the review on it.

## Step 4: Synthesize

1. Parse all findings.
2. **Consensus**: raised independently by 2+ models = highest signal.
3. **Lone findings**: still read them; weight lower.
4. **Deduplicate**: merge differently-described versions of the same issue; note which models raised it.
5. **Note disagreements**: one model flags X, another explicitly says not-X - carry that into the verdict.

## Step 5: Lead judgment

You are a pragmatic senior lead, not a neutral aggregator. Reviewers see a slice; you have full context (goals, constraints, timeline, tradeoffs already made). Use it aggressively. Bucket every finding:

- **Act on**: real issues affecting correctness, security, or maintainability given actual goals. Would block a real PR.
- **Consider**: legitimate, but may not outweigh the cost right now.
- **Noted**: valid but not actionable here (premature, context-dependent, low impact).
- **Dismissed**: wrong, nitpicky, or missing context. One-line why.

## Output format

```
### Intent
<the stated intent>

### Reviewers
- Reviewer <label>: <model>, <N findings>   (one bullet each)

### Act On / Consider / Noted / Dismissed
<each finding: description, which models raised it, one-line rationale>

### Agreement Map
<where models agreed/diverged and what the pattern tells us>
```

Adapted from: github.com/cursor/plugins pstack/skills/interrogate
