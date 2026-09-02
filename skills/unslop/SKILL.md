---
name: unslop
description: "Strip AI-writing tells and add human voice. Must always apply when drafting or editing prose meant for humans: docs, READMEs, comments, commit messages, replies, posts."
---

# Unslop

Edit text to remove AI patterns and add human voice.

## Process

1. Scan for the patterns below.
2. Rewrite. Preserve meaning, match intended tone.
3. Add soul (next section).
4. Self-audit: "what makes this obviously machine-generated?" Fix remaining tells.

## Adding soul

Removing patterns is half the job; sterile voiceless writing is just as obvious.

- **Have opinions.** React to facts instead of neutrally listing pros and cons.
- **Vary rhythm.** Short sentences. Then longer ones that take their time.
- **Acknowledge complexity.** "impressive but also kind of unsettling" beats "impressive".
- **Use "I" when it fits.** First person isn't unprofessional.
- **Let some mess in.** Perfect structure looks machine-made.
- **Be specific.** Not "concerning"; name the concrete thing and why it lands.

## Patterns to detect and fix

### Content

1. **Puffery.** "pivotal moment", "testament to", "evolving landscape". Cut it; state what happened.
2. **Name-dropping.** Listing outlets/sources without context. Pick one, say what was said.
3. **Superficial -ing phrases.** "highlighting...", "ensuring...", "showcasing...". Delete or expand with real substance.
4. **Promotional language.** "groundbreaking", "stunning", "vibrant". Neutral descriptions instead.
5. **Vague attributions.** "Experts believe", "reports suggest". Name the source or delete.
6. **Formulaic challenges.** "Despite challenges... continues to thrive." Replace with specific facts.

### Language

7. **Banned vocabulary:** additionally, crucial, delve, enduring, enhance, fostering, garner, interplay, intricate, landscape (abstract), pivotal, showcase, tapestry (abstract), testament, underscore, vibrant. Plain words instead.
8. **Fancy ways to say "is".** "serves as", "stands as", "boasts", "features". Say "is" or "has".
9. **"Not just X, but Y."** State the point directly.
10. **Rule of three.** Forcing ideas into threes. Use the natural number.
11. **Synonym cycling.** One term per concept; repeat it.
12. **False ranges.** "from X to Y" where X/Y aren't on a meaningful scale. List directly.

### Style

13. **Em dashes banned entirely.** Periods or commas only. No parentheses-as-dash, no hyphen substitutes. If a thought needs separation, end the sentence.
14. **Colon overuse.** Colons before lists/examples only; not mid-sentence connectors.
15. **Boldface overuse.** Don't bold every proper noun or acronym.
16. **Inline-header lists.** A bold label restating its own line is a tell; convert to prose.
17. **Title case headings.** Sentence case.
18. **Decorative emojis** in headings and bullets: remove.
19. **Curly quotes.** Straight quotes.

### Communication artifacts

20. **Chatbot phrases.** "I hope this helps!", "Let me know if...", "Of course!". Remove.
21. **Cutoff disclaimers.** "While specific details are limited..." Find sources or remove.
22. **Sycophancy.** "Great question! You're absolutely right!" Respond directly.

### Filler

23. **Filler phrases.** "in order to" -> "to"; "due to the fact that" -> "because"; "it is important to note that" -> delete.
24. **Hedging stacks.** "could potentially possibly be argued might" -> "may".
25. **Generic conclusions.** "The future looks bright." State specific plans or facts.

### Jargon

26. **Abstract metaphor nouns.** substrate, wedge, vector, nexus, primitive (noun), harness (metaphor), bedrock, paradigm, flywheel, north star, endgame. Pick the plain concrete word ("base", "add", "way").

### Plain speech

27. **Say what it does, not how it feels.** Name the mechanism or the number. If you can't restate a sentence as a concrete instruction, fact, or number, cut it. If it could appear unchanged in any other project's docs, cut it.
28. **Split dense sentences.** Reader shouldn't backtrack. One idea per sentence.
29. **Active voice.** Name the actor; passive only when the actor genuinely doesn't matter.
30. **Cut adverbs or use stronger verbs.** "runs quickly" -> "is fast"; "significantly improves" -> the measured delta.
31. **Prefer the plain word.** utilize->use, leverage->use, facilitate->help, numerous->many, in the event that->if.

Adapted from: github.com/cursor/plugins pstack/skills/unslop
