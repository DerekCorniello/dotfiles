---
name: sonar-complexity-fix
description: "Reduce cognitive complexity to <=15 per function without changing behavior. Use when Sonar flags complexity hotspots, the user mentions cognitive complexity, or a function has an unreadable match/if chain."
---

# Sonar Complexity Fix

Bring every function to cognitive complexity <= 15. Behavior must not change; tests stay green.

## Workflow

1. **Run the scanner.** The project usually wires it up already - check its config (`.env` plus an scanner invocation in agent config files or CI config) and run that exact invocation. Do not invent your own setup.
2. **Parse worst offenders**: list flagged functions sorted by complexity, highest first.
3. **Refactor each**, using these moves:
   - Extract cohesive branches into well-named helper functions.
   - Replace long `match`/`if-else` chains with dispatch tables (map from key to handler).
   - Early returns / guard clauses instead of nested conditionals.
   - Flatten boolean ladders into data.
4. **Verify**:
   - Re-run the scanner; confirm each target is now <= 15.
   - Run the test suite - all green, no test modified to accommodate behavior drift.

## Rules

- Never change observable behavior. If a refactor would, stop and flag it instead.
- Don't chase the metric with tricks that just relocate complexity into unreadable one-liners - readability is the goal, 15 is the proxy.
- Fix offenders in descending order until clean.

## Done when

- [ ] Scanner re-run reports no function above 15.
- [ ] Test suite fully green.
- [ ] No behavior change introduced.
