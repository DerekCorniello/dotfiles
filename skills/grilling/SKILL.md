---
name: grilling
description: "Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or before acting on any loose idea that still has open questions."
---

# Grilling

Interview the user relentlessly until you reach shared understanding. Map the topic as a **design tree**: every decision branches into the decisions that hang off it.

## Rules

1. **Facts are your job.** Never ask the user anything you could look up yourself (filesystem, docs, tools). Dispatch a readonly subagent to find it.
2. **Decisions are the user's.** Put each one to them explicitly and wait for their answer.
3. **Never act on the plan** until the user confirms you have reached shared understanding.
4. A question whose answer depends on another question still open this round belongs to a **later round**, not this one.

## Rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: what you can ask _now_ without guessing at answers you haven't heard yet.

Each round:

1. Recompute the frontier.
2. Ask the **whole frontier** in one message. Number each question and give your recommended answer.
3. Wait for answers. Do not proceed early.

Format each question:

```
? **Q<n> - <question title>**: <body; may include multiple choices>

-> <your recommended answer>
```

Each round of answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them.

If a frontier question needs a fact you are looking up, don't block on it: only questions downstream of that fact wait for the lookup. Ask the rest of the frontier now.

## Done when

- [ ] The frontier is empty: every branch of the design tree visited, nothing left silently assumed.
- [ ] The user has confirmed shared understanding.
- [ ] Only then: act, or hand off to execution.

Adapted from: github.com/mattpocock/skills skills/productivity/grilling
