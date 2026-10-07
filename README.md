# tutor

An adaptive tutor skill for AI coding agents. One question at a time, difficulty
tuned to the individual, state that survives a clean context.

Built for [OpenCode](https://opencode.ai) / Claude Code / any agent that loads
`SKILL.md` from a skills directory.

## Why

Most "teach me X" prompts produce a wall of text: a curriculum, or a document
that either bores someone who already knows the basics or loses someone who
doesn't. The learner's actual level never enters into it.

`tutor` closes that loop. It asks one question, reads the answer, and lets that
answer decide what comes next — up, down, sideways into a gap that just appeared.
Miss a concept and it teaches it and re-asks before moving on. Say "I don't
know" and that's a useful signal, not a failure.

Every question, answer, verdict, and explanation is written to disk, so the next
session — with a clean context and no memory of this one — resumes exactly where
the learner left off and probes whether the recorded level still holds.

## Install

```sh
git clone https://github.com/xpressabhi/tutor.git ~/.agents/skills/tutor
```

Or symlink a checkout if you're keeping it in source control:

```sh
git clone https://github.com/xpressabhi/tutor.git ~/Documents/GitHub/tutor
ln -s ~/Documents/GitHub/tutor ~/.agents/skills/tutor
```

Works in `~/.agents/skills/` (OpenCode, universal), `~/.claude/skills/`
(Claude Code), and equivalents elsewhere.

## Use

```
tutor I want to learn python
tutor quiz me on SQL joins
tutor I forgot where I was with Rust
```

Slugify the topic and the skill creates `~/tutor/<topic>/` on first use.

## What it does

| | |
|---|---|
| **Calibrates** | A short opening assessment finds the learner's level — the ceiling, not the average |
| **Adapts** | Rung goes up on a correct answer, holds on partial, drops on a miss. Every answer read for reasoning, not just result |
| **Re-teaches** | A miss gets an explanation of the idea underneath, then an immediate re-ask in a fresh framing |
| **Resumes** | Every session starts by reading the ledger, then *probing* it — a three-week-old level is a claim, not evidence |
| **Steers** | Tangents are followed, then re-anchored. Wandering isn't being behind |
| **Runs code** | Verifies the learner's snippets against real output; builds questions whose answers were actually observed |
| **Draws** | Emits level-tagged HTML artifacts for concepts that need to be seen, at the learner's rung, not the maximal version |

Technical and non-technical subjects both. Code execution is opt-in by context —
a non-technical subject never triggers it.

## Workspace

Everything is plain markdown you can read, edit, and diff:

```
~/tutor/python/
  TOPIC.md          # mission, outline, learner profile
  LEDGER.md         # per-concept rung and verdict — read before every question
  sessions/
    2026-10-07.md   # append-only history
  artifacts/
    control-flow-r4.html
```

## Design

`DESIGN.md` covers the reasoning: why verdicts read the *how*, why the rung
ratchet is guarded, why no learning-style taxonomy. `FORMATS.md` has the file
templates.

Two deliberate omissions:

- **No spaced-repetition scheduler.** Shaky concepts get revisited opportunistically. A proper SRS needs per-concept decay intervals and a due queue — worth it once sessions are weeks apart, not on day one.
- **No source citations.** Code execution makes factual claims *about code* verifiable; claims about the world still come from the model, which says so when it's unsure.

## Layout

```
SKILL.md        # the skill
FORMATS.md      # file templates and fields
DESIGN.md       # rationale and scope decisions
scripts/run.sh  # sandboxed snippet runner (timeout, temp cleanup, no network)
```
