---
name: pr-feedback-sweep
description: "Sweep reviewer and bot feedback across all open PRs of a repo or org, apply repo-wide fixes everywhere they apply, and drive every PR green. Use when the user mentions PR feedback backlog, review comments pile-up, 'sweep the PRs', or bot comments like Sonar/Greptile across many branches."
---

# PR Feedback Sweep

Close out outstanding review feedback on every open PR until all are green.

## Scope

One repo (`owner/repo`) or an org (all repos with open PRs). Confirm scope if ambiguous.

## Workflow

1. List open PRs. For each, fetch unresolved comments from human reviewers and bots (e.g. Greptile, Sonar) via the platform CLI/API.
2. Classify each comment:
   - **Repo-wide**: same issue exists on other PRs / main (pattern, missing test style, lint rule, API misuse).
   - **Per-PR**: specific to that branch's changes.
3. For repo-wide items, fix the pattern across **ALL** affected PRs, not just where it was flagged. Check every open branch for the pattern before pushing.
4. Per-PR items: fix on that branch.
5. Commit per PR branch - plain messages, **NEVER add co-author trailers or generated-by footers**. Push.
6. Re-check each PR after push (CI + re-run of bot reviews). Repeat the loop until every PR has no unresolved feedback and green status.

## Report

End with a table:

```
| PR | Feedback count | Fixed | Status |
|----|---------------|-------|--------|
```

Status: `green` / `blocked (<reason>)`. Note anything you deliberately did not fix and why.

## Done when

- [ ] Every open PR's feedback addressed or explicitly reported as blocked.
- [ ] Repo-wide patterns fixed on every affected branch.
- [ ] All pushes are clean commits without co-author trailers.
- [ ] All touched PRs green.
