---
description: Land the current branch through the full pre-merge gate
---
Land this branch:
1. Rebase onto the base branch cleanly (temp branch if needed); resolve conflicts favoring THIS branch's intent.
2. Full gate: fmt, lint/clippy zero warnings, build, tests. Fix failures on this branch before proceeding.
3. Verify GitHub state after push/merge actually shows MERGED - do not trust local exit codes alone; check with `gh pr view`.
4. Post-land: narrative recap of what shipped (short prose, not a checklist), plus any follow-ups worth ticketing.

Never force-push shared branches; ask first if history looks wrong.
