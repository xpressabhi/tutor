# Formats

Create these on first session. All paths relative to `~/tutor/<topic>/`.

```
TOPIC.md          # mission, running outline, learner profile
LEDGER.md         # per-concept state — read before every question
sessions/
  YYYY-MM-DD.md   # append-only: question, answer, verdict, teaching
artifacts/
  <name>-r<n>.html
```

Create directories lazily — `sessions/` and `artifacts/` only when first needed.

---

## TOPIC.md

```md
# Learning: {Topic}

## Why
{1-3 sentences. The concrete outcome they are chasing. What changes when they
have this? Push past "to understand X" to the underlying thing.}

## Success looks like
- {Specific, observable thing they will be able to do}
- {Another}

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

Read before every question. One row per concept. Append rows; edit cells in place.

```md
# Ledger

| Concept | Rung | Last verdict | Attempts | Shaky | Notes |
|---|---|---|---|---|---|
| {concept} | {1-5} | {correct/partial/wrong/none} | {n} | {yes/no} | {what the errors actually were} |
| {concept} | — | — | 0 | — | queued after {x} |
```

**Notes carry the useful signal.** "forgets the `if` clause" tells the next
session what to probe. "weak here" tells it nothing.

`Rung` is the learner-relative level, blank when never asked. `Attempts` is the
consecutive count at the current rung, used to decide when to stop hammering and
drop instead.

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
