---
description: Dependency-safe merge order across repos, concisely
---
Determine the merge/ship order for my currently open PRs (across the org if multiple repos are involved):
1. Map dependencies: which PRs depend on which (API changes, version bumps, cross-repo imports, stacked branches).
2. Output the order as a numbered list, one line per PR: `N. <repo>#<num> <title> - why here`.
3. Flag anything that can merge in parallel and anything blocked with a one-line reason.
Concise. No essays. $ARGUMENTS
