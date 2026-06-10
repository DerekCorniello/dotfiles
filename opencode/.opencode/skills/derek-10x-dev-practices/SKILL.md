---
name: derek-10x-dev-practices
description: Global development practices and engineering preferences for Derek's repositories.
--- 

# Derek's Development Practices

## Core Principle

Code is read far more often than it is written.

Optimize for readability, maintainability, correctness, and simplicity before performance, abstraction, or cleverness.

Ensure you understand the problem, requirements, constraints, and goals before writing code. Ask clarifying questions when necessary.

Ensure you address all of the problems/feedback that the user sends you.

---

## Communication

* Be concise and direct.
* Challenge questionable architectural or engineering decisions and explain concerns clearly.
* Explain tradeoffs before making significant changes.
* Prefer concrete examples over abstract explanations.
* Ask clarifying questions when requirements, constraints, or goals are unclear.
* Gather sufficient context before making recommendations.
* After making changes, ensure any affected documentation is updated.
* Never add emojis, em-dashes or other non-standard characters that cannot be typed on a standard keyboard. Use ASCII characters only.

---

## Engineering

* Favor readability over cleverness.
* Prefer simple solutions before introducing additional complexity.
* Avoid unnecessary dependencies.
* Generate tests for non-trivial logic.
* Leave code in a better state than it was found.
* Avoid large unrelated refactors while implementing a feature.
* Prefer explicit error handling over hidden failures or silent fallbacks.
* Never ignore pre-existing issues, warnings, or errors without explicit approval.
* Always add ci/cd pipelines, linters, formatters, and tests when setting up a new repository or project.
* Prefer local pre-commit hooks for linters, formatters, and tests when practical, and longer-running checks in ci/cd pipelines.
* Always run linters, formatters, and tests.

### Comments

* Write comments sparingly.
* Comments should explain *why*, not *what*.
* Avoid comments that merely restate the code.
* Remove outdated comments when modifying code.

---

## Design

### General

* Prefer strong, static typing when practical.
* Favor simple, composable designs over complex object hierarchies.
* Maintainability and readability take priority over performance unless performance requirements are explicitly stated.
* Never allow for backwards compatibility unless specifically required or requested.
* Avoid overengineering.
* Avoid designing for hypothetical future requirements.
* If the right approach is unclear, prefer a reversible solution over an irreversible one.
* Only 10/10 quality work is acceptable.

### Abstractions

* Introduce abstractions only when they solve a real problem.
* Prefer eliminating accidental duplication.
* Do not create abstractions prematurely.
* A small amount of duplication is often preferable to a poor abstraction.
* Separate concerns when doing so improves clarity and maintainability.
* Avoid unnecessary layers, wrappers, managers, services, factories, or indirection.

### Code Organization

* Keep files, functions, and types focused and cohesive.
* Break down code that becomes difficult to understand or navigate.
* Avoid God objects, God functions, and highly coupled modules.
* Prefer clear module boundaries and explicit responsibilities.

---

## Dependencies

Before adding a dependency:

1. Determine whether the standard library is sufficient.
2. Determine whether existing project dependencies already solve the problem.
3. Justify the value provided by the new dependency.

Favor fewer dependencies when reasonable.

---

## Safety

* Never create commits, push, force-push, rebase, reset, or modify Git history without explicit approval.
* Never read `.env` files.
* Never expose secrets, tokens, credentials, or sensitive configuration values.
* Respect repository-specific instructions and constraints.

---

## Workflow

When working in a repository:

1. Read `README.md`.
2. Read `AGENTS.md`.
3. Explore and understand the existing codebase before making changes.
4. Follow established project conventions unless there is a compelling reason not to.
5. Update relevant documentation after changes are complete.

Repository-specific instructions always take precedence over these global preferences.

---

## Tooling

- Important - The following commands are aliased:
    - grep -> rg
    - cd -> zoxide
    - cat -> bat
- If you are doing exploratory work, please run agents in parallel or use explore tools
- Whenever something isn't obvious as far as details / implementation goes, use a web search tool
- Use the tools at your disposal frequently!

---

Final note: Do not be afraid to offer to edit this document if you have suggestions for improving it. It is intended to be a living document that evolves as our practices and preferences evolve.
