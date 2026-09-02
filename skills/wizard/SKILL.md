---
name: wizard
description: "Generate an interactive bash script that walks a human through steps only they can perform. Use for provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or one-off migrations and cutovers. Do not use for steps the agent could perform itself."
---

# Wizard

A **wizard** is a bash script that walks a human step by step through a manual procedure: tedious by hand, tedious to re-explain every time. It opens each URL, says exactly what to click and copy, captures values, writes them where they belong, confirms at every stage, and shows stages remaining.

Ephemeral by default: built for one run, saved to a scratch path, deleted when done. Commit it only when the user wants a repeatable setup path in the repo.

The script itself must provide:

- Stage-by-stage progress with `TOTAL_STAGES` and a closing summary.
- Confirmation gates before any irreversible action.
- Hidden secret entry (read without echoing).
- Idempotent env-file upserts (safe to re-run).
- Cross-platform URL opening where available.

## Process

### 1. Scope the procedure

Read the repo first; don't ask cold. For setup: env files, READMEs, compose files, framework config, CI workflow files (every secrets/vars reference is a value the wizard must produce). For migration: current state, target state, irreversible actions between them.

Then show the user the ordered stage list and the values each produces. They may add, drop, reorder.

**Done when:** every stage is named in order, and each captured value has (a) where the human gets it, (b) where it's written (env file, CI secret, both, nowhere), (c) whether it's secret or public.

### 2. Map each stage's journey

Write the precise human path per stage: which URL to open, what to do there, which variable the shown value fills ("Dashboard -> Developers -> API keys -> Reveal test key -> copy"). Where you don't know the current UI or exact command, say so and ask or check docs. **Never invent steps that may not exist**, and never include steps you could have done yourself: if you can run it, run it outside the wizard.

**Done when:** every stage traces to instructions a stranger could follow.

### 3. Author the script

One stage per step, dependency order, one focused task per stage so nothing needed scrolls away. Open the URL before asking for its value; hide anything secret; persist every captured value; confirm before irreversible actions.

### 4. Verify and hand off

- `bash -n <script>`; run shellcheck if available; `chmod +x`.
- Do not run it end-to-end yourself (it opens browsers, blocks on input). Trace statically instead: every value from step 1 is captured and lands where step 1 said; every CI secret name exactly matches a reference in CI config.
- Tell the user how to run it. If repeatable, commit and link from the README.

Adapted from: github.com/mattpocock/skills skills/engineering/wizard
