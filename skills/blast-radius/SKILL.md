---
name: blast-radius
description: "Find what a change could break somewhere else, beyond the diff, before it ships, and prove the one safety fact by running real code instead of writing it up. Use for blast radius of X, what could this break, or reviewing a small diff you don't trust."
---

# Blast radius

Find what a change breaks somewhere else before it ships. Listing the callers is not the job: grep finds those in a second. The job is the breakage grep won't show you.

## Don't trust your own writeup

A writeup that sounds right is worthless; it reads as convincing whether or not it's true. Find the one or two facts everything depends on and **prove them by running code**. Words are where you start, not what you ship.

### Evidence ladder

For each fact the change's safety depends on, get as far down as is cheap and say where it stopped:

1. You said so. Worthless alone.
2. You pointed at the line. Real `file:line`, or the library's own source.
3. You walked the failure step by step and showed the bad case can't happen.
4. You ran it. A script or test calling the real code that fails loud if you're wrong.
5. You reproduced it in the running app.

Any safety fact you can't get to step 4: say so out loud. Don't write it up as settled. Step 4 is usually one small script importing the same library the app ships, calling the exact function you're worried about.

## Steps

1. **Read the change.** Diff, added/changed/deleted symbols, what it now does differently - including what the diff doesn't spell out (implicit callers, generated code, config).
2. **Find THE one fact it's safe because of.** Most scary-looking changes are safe because of a single fact ("this call only drops already-dead cache entries"). If it holds, most scary cases die at once. Spend your time there, not on a long list of maybes.
3. **Look where grep stops.** Read the called library's source; check its pinned version and local patches. Work out when things run: teardown hooks, event loops, framework lifecycles. Follow what symbol search misses: JSON payloads, DB columns, wire formats, another language reading the same bytes, feature flags, code three hops downstream.
4. **Be honest about each risk.** Real chance of happening, real cost if it does. Keep confirmed risks; list checked-and-cleared separately. Cite real `file:line`. A search finding nothing is still an answer; never invent a caller or an API.
5. **Prove the one fact.** Write a script or test running the real code, run it, paste what happened. Can't prove cheaply? Mark unproven. Don't round up.
6. **Wide change? Run an arena**: several models asked the same question, answers merged. Different models catch different real bugs.

## What to hand back

- **What it does**, including the non-obvious part.
- **The one safety fact**: stated, with which ladder step it reached, and proof pasted. Unproven if unproven.
- **Risks**: only real ones. How it breaks, `file:line`, likelihood, cost, how to check.
- **Cleared**: what you checked and why it's fine.
- **Before merging**: cheapest test/repro catching the real bug, including your script.

Flag any unproven safety fact loudly, in bold, at the top of the handback.

Adapted from: github.com/cursor/plugins pstack/skills/blast-radius
