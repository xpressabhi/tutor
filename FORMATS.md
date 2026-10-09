# Formats

Create these on first session. All paths relative to `~/tutor/<topic>/`.

```
TOPIC.md          # mission, running outline, learner profile
LEDGER.md         # per-concept state — read before every question
sessions/
  YYYY-MM-DD.md   # append-only: question, answer, verdict, teaching
sources/          # only when the learner has material to ground in
  <concept>.md
artifacts/
  <name>-r<n>.html
../LEARNER.md     # learner-level, shared by every topic (optional)
```

Create directories lazily — `sessions/`, `sources/`, and `artifacts/` only when first needed.

---

## TOPIC.md

```md
# Learning: {Topic}
Aliases: {other names the learner uses for this topic, so a later session finds this directory from the phrasing they actually say}

## Why
{1-3 sentences. The concrete outcome they are chasing. What changes when they
have this? Push past "to understand X" to the underlying thing.}

## Success looks like
- {Specific, observable thing they will be able to do}
- {Another}

## Sources
{`none` — questions come from the tutor's own knowledge, so it flags its own
uncertainty. Or list the material: paths, titles, a codebase, a book.}

## How this learner learns
{Pace, entry point (code before theory or the reverse), response to being wrong
(hint first or correction outright), tolerance for struggle, explain-back vs
show-back. Each line is an observation plus the evidence for it. Update as
sessions reveal more — this is what stops the tutor rediscarding known
preferences every session with a clean context.}

## Outline
- {Concept} — {rung reached, one-line state}
- {Concept} — not started

{Rewritten as concepts are encountered, not planned up front. Its job is to let
the learner see coverage and what is ahead.}
```

---

## LEDGER.md

Read before every question. One row per concept.

```md
# Ledger

| Concept | Rung | Last verdict | Attempts | Shaky | Next probe | Notes |
|---|---|---|---|---|---|---|
| {concept} | {1-5} | {correct/partial/wrong/none} | {n} | {yes/no} | {re-ask or clean re-probe owed, and why — or `—`} | {the errors themselves, ≤ ~30 words} |
| {concept} | — | — | 0 | — | — | queued after {x} |
```

Instantiate the block above only — the rules below stay in this file, not in the ledger.

**One row per concept, forever.** A concept that returns edits its existing row. Never add a second row for it, even when the thread was closed — two rows for one concept read to the next session as two different concepts, and it calibrates against whichever it happens to open on.

**Keep the row order stable** — first-touched, or alphabetical. Reshuffling the table every session makes the diff across sessions useless.

**Next probe is what the ratchet owes.** A rung rises only after a correct answer *and* a clean re-probe, so the re-probe is worth writing down: `clean re-probe owed (ratchet): novel scheduling case`, `re-ask owed at this rung: augmentation syntax`, or `—` when nothing is owed. A verdict with no next probe is one the next session has to reconstruct.

Notes carry the useful signal — "forgets the `if` clause" tells the next session what to probe, "weak here" tells it nothing. Keep them to the errors themselves, not the history of them; the history is in the session log, and the ledger is re-read before *every* question.

`Rung` is the learner-relative level, blank when never asked. `Attempts` is the consecutive count at the current rung — it resets when the concept changes rung — used to decide when to stop hammering and drop instead.

---

## sources/

Only when the learner has material to ground in. One note per concept, written by
reading their actual material. This is what makes an answer checkable — the tutor
can point at where it came from instead of asserting it.

Read their material first, then write one note per concept it covers. Do not
invent coverage the material does not have; a note for a concept the source never
mentions is worse than no note, because questions from it will be confidently
grounded in nothing.

```md
# {Concept}

From: {file path, section, page, commit, or URL}

{What the material actually says about this. In its terms — the source's framing
is usually better than yours, and matching it keeps the learner oriented when they
go read it themselves.}

## Worked example
{An example lifted from the material, or worked by running it. This is where code
subjects get their certainty.}

## Caveats
{What the source flags as an edge case, a limit, a common mistake. These are the
best rung-5 questions, and they come free from the source rather than being
invented.}
```

Cite the source when asking. "The docs say…" when grounded; a plain admission of
uncertainty when not. Both keep the learner able to trust you.

---

## sessions/YYYY-MM-DD.md

Append-only, chronological, human-readable. This is what they re-read to see
progress; the ledger is what you act on.

```md
# Session YYYY-MM-DD

## {HH:MM} — {concept}
**Rung {n}**

Q: {the question, verbatim}

A: {their answer, verbatim}

**Verdict: {correct/partial/wrong}** — {one line on the reasoning, not just the
result}

{Teaching, if any. Then the re-ask question and its answer as a new entry.}

---

## Steering
{What they steered into, what was covered, and the re-anchor question.}
```

Write every turn. The verdict line is the part that must not be lazy — "partial"
without saying *what was partial* is the log's equivalent of a guess.

---

## Session close

Written at the end of every sitting, in that day's file, before the session ends.
This is the first thing the next session reads.

```md
# Session close ({HH:MM})

**Covered today:** {concept → rung reached, one line each}
**In flight:** {the probe or re-ask that never got an answer — and the framing it
was going to use}
**Never asked:** {questions that were queued and the session ran out of room for}
**Next-session openers:**
1. {clean re-probe the ratchet owes — candidate for a rung up}
2. {another}
3. {new territory, if any}
```

One file per sitting. A sitting that crosses midnight starts a new dated file,
and the earlier one notes where the continuation lives.

---

## LEARNER.md

`~/tutor/LEARNER.md`, one level above the topic directories. Created once and
carried across every topic. Optional — worth creating once a second topic shows
up.

```md
# How this learner learns

{One line per durable observation, plus the evidence and the topic it came from.
Cross-topic truths only: "hint-first", "answers fast and terse", "recovers on the
first re-ask after a teach".}
```

When a new topic starts, this is a prior, not a finding. Confirm it in this topic
before relying on it — a learner can be terse with code and slow with prose — and
write the confirmation into the topic's own `TOPIC.md`. A line one topic
contradicts is corrected there rather than deleted: say which topic showed it and
how.
