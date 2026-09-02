---
name: wayfinder
description: "Plan oversized work (more than one session can hold) as a shared map of decision tickets on the issue tracker, resolved one at a time until the way forward is clear. Use when a loose idea is too big for one session and the route to the destination isn't visible yet."
---

# Wayfinder

A loose idea has arrived: too big for one session, wrapped in fog. Wayfinding finds the way, it doesn't charge at the destination. Chart it as a **shared map** on the repo's issue tracker, then work **decision tickets** one at a time until the route is clear.

## Plan, don't do

Wayfinder plans by default. Each ticket resolves a decision, not a slice of build. The map is done when the way is clear with nothing left to decide. The pull to just do the work is usually the signal you've reached the edge of the map: stop and hand off. Only carry execution into the map if the effort's Notes explicitly override this.

## The Map

One tracker issue labelled `wayfinder:map`, the canonical artifact. Its tickets are child issues. The map is an **index, not a store**: each decision lives in exactly one place, its ticket. The map gists and links; it never restates.

Body sections:

```markdown
## Destination
<what reaching the end looks like; one or two lines>

## Notes
<domain, standing preferences, skills sessions should consult>

## Decisions so far
- [<closed ticket title>](link): <one-line gist of the answer>

## Not yet specified
<fog: in-scope questions too dim to ticket yet>

## Out of scope
<work ruled beyond the destination>
```

Refer to maps and tickets **by name** (title) in everything the human reads, never by bare ids. Names wrap links; links ride inside names.

## Tickets

Each ticket is a child issue, body = the question, sized to one session's capacity. Label it one of:

- **research** (agent-alone): surface a fact from docs, APIs, or resources outside the working tree. Resolve via a readonly subagent.
- **prototype** (with human): make a cheap rough artifact to react to when "how should it look/behave" is the key question.
- **grilling** (with human): conversation. The default. Never answer your own questions on a human-in-the-loop ticket.
- **task**: manual work that unblocks a decision (signup, access, data move). Agent-driven where possible; otherwise hand the human a precise checklist.

**Concurrency:** claim a ticket by assigning it **before any work**; an open, unassigned ticket is unclaimed. Wire blocking via the tracker's native dependencies when available. The **frontier** = open, unblocked, unclaimed tickets. Expect concurrent sessions; never resolve more than one ticket per session (research excepted).

## Fog of war

Don't chart what you can't yet see. Beyond live tickets lies fog: questions you can tell are coming but can't pin down because they hang on open decisions. Resolving a ticket clears fog ahead of it, graduating whatever is now specifiable into fresh tickets.

**Fog or ticket?** Can you state the question precisely _now_? Ticket when sharp, even if blocked. Fog when not; don't pre-slice fog into ticket-sized pieces.

Out-of-scope work never graduates. Close mis-scoped tickets and leave one line in Out of scope with why.

## Charting (one session)

1. Name the destination via grilling; it fixes scope.
2. Grill breadth-first across the whole space. If no fog surfaces (journey fits one session), no map is needed: say so and ask how to proceed.
3. Create the map: Destination, Notes, sketched fog.
4. Create specifiable tickets as children; wire blocking edges second pass.
5. Fire research subagents in parallel.
6. Stop: charting resolves nothing by hand.

## Working the map

1. Load the map (low-res view, not every body).
2. Take the user-named ticket, else first frontier ticket. Claim it first.
3. Resolve it, zooming into related tickets on demand.
4. Post the answer as a resolution comment, close, append gist + link to Decisions so far.
5. Graduate newly-specifiable fog; add surfaced tickets; rule out-of-scope findings; update tickets invalidated by the answer.

Adapted from: github.com/mattpocock/skills skills/engineering/wayfinder
