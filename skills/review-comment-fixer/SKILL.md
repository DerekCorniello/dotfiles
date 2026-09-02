---
name: review-comment-fixer
description: "Take pasted code-review comments (Path/Line/Comment), locate the code, fix what's clearly correct, and surface disagreements as short questions instead of blindly applying. Use when the user pastes review feedback to address."
---

# Review Comment Fixer

Process pasted review comments. Expected template per item:

```
Path: <file>
Line: <line or range>
Comment: <reviewer text>
```

## Workflow

1. **Locate** the code for each comment; read enough surrounding context to judge intent, not just the line.
2. **Classify** each:
   - **FIX**: suggestion is clearly correct and preserves intent -> apply it directly.
   - **DISCUSS**: you disagree, the suggestion breaks intent, or it's ambiguous -> do NOT apply.
3. Apply FIX items. Keep changes minimal and consistent with surrounding style.
4. Present DISCUSS items as short questions to the user - one or two sentences each, stating your position and why. Wait for their ruling before touching that code.

## Rules

- Never blindly apply a suggestion that breaks intent, even if the reviewer insisted - escalate as DISCUSS.
- A technically-correct nit that damages readability still counts as DISCUSS.
- If two comments conflict, resolve via DISCUSS.
- Report at the end: applied count, discussed count, list of questions.

## Done when

- [ ] Every FIX applied.
- [ ] Every DISCUSS presented as a question and awaiting the user's answer.
- [ ] Summary table of comments -> action given.
