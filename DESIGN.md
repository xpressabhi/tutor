# tutor — design

A subject-agnostic adaptive tutor. Runs as a live question-and-answer loop in the
terminal, tunes difficulty to the individual, and records enough state to resume
cold.

## Problem

`teach` emits self-contained HTML lessons you read later. Useful, but a different
model. The tutor problem is different: the next question depends on the answer to
the last one, delivered one at a time, with no friction between asking and adapting.

The existing `teach` skill has no adaptive loop, no question/answer log, and no
re-teach-on-miss behaviour. `tutor` is a standalone skill rather than an extension,
because the two have different primary artifacts (a lesson document vs. a
conversation) and different failure modes.

## Non-goals

- Not a curriculum engine. No upfront syllabus. Concepts accumulate as encountered.
- Not a lesson generator. No HTML lessons.
- Not a learning-style matcher. See "Tailoring" below.
- Not a course platform. One directory, plain markdown, no database, no UI.

## Workspace

Topic-scoped, one directory per subject: `~/tutor/<topic-slug>/`.

```
~/tutor/python/
  TOPIC.md          # subject, goal, running outline, learner profile
  LEDGER.md         # per-concept state — read on every question
  sessions/
    2026-10-07.md   # append-only: question, answer, verdict, teaching
  artifacts/
    control-flow-r4.html
```

Plain markdown. Everything the tutor needs is readable with `cat`, editable by
hand, and diffable in git if the user wants that.

### LEDGER.md

Small file, read before every question. One row per concept.

| concept | rung | last verdict | attempts | shaky | notes |
|---|---|---|---|---|---|
| list vs tuple | 2 | correct | 1 | no | |
| list comprehension | 3 | partial | 2 | yes | forgets the `if` clause |
| generators | 4 | — | 0 | — | queued after decorators |

`rung` is 1–5, calibrated **against the learner**, not the subject. What counts as
rung 3 differs per domain and per person: for one Python learner it is "apply it in
a case you haven't seen", for another arriving from C it is "explain why this
idiom exists when the obvious version also works".

Rung meanings, to be interpreted in-domain:

1. Recall a term or fact
2. Apply in a familiar case
3. Apply in a novel case, or explain why
4. Predict non-obvious behaviour, or choose between approaches
5. Edge cases, tradeoffs, where the rule breaks down

### sessions/*.md

Append-only, chronological, human-readable. Every turn: the question, the learner's
answer verbatim, the verdict, any teaching that followed, and the rung the next
question will use. This is the record the learner re-reads to see progress; the
ledger is the record the tutor acts on.

### TOPIC.md

Subject and goal, plus a running outline of concepts covered so far. Since there is
no pre-built map, the outline is written as concepts are first touched — it exists
so the learner can see coverage and see what is ahead, without a syllabus being
imposed. Also carries `## How this student learns` (see Tailoring).

## The turn cycle

```
pick next concept   ← read LEDGER.md, not memory
pick rung           ← learner's level on that concept, ±1 from last verdict
ask ONE question
receive answer
verdict: correct / partial / wrong / "don't know"
   ↓
update LEDGER row, append to today's session log
   ↓
correct  → rung up, or move to next concept
partial  → hold rung, re-ask with a different framing
wrong    → hold rung, teach, re-ask immediately
```

One question per message. Always. The loop depends on the reply arriving before the
next question is chosen.

### Verdicts read the how, not just the what

The verdict is not correctness. It is whether the understanding is real:

- **Conclusion right, reasoning wrong → `partial`.** A correct answer for the wrong
  reason is a guess, and filtering guesses is what the rung is for.
- **Hedging or rambling → `partial`.** "I think it's B, or maybe C, because…" is the
  shape of someone guessing.
- **Right answer, unexplained → `partial`.** Ask "why?" on the spot rather than
  crediting it.
- **Right answer, clean reasoning → `correct`.** The only thing that earns a rung up.

### Don't-know is a first-class answer

The most honest signal available, and treating it as failure is what makes learners
fake confidence. It logs as a miss and triggers a teaching turn. It does not lower
the rung permanently.

### Regression is live

A concept solid at rung 3 that returns with rung-2 reasoning has not deepened, it
has thinned — the rung comes down even though the answer was technically correct.
A single per-concept verdict would never catch this.

### Ratchet guard

Rung rises only after a correct answer **and** a clean re-probe of that rung later.
Otherwise every lucky guess walks the learner up a ladder they haven't climbed, and
they end up lost three concepts past where they actually are. Overshooting easy by
one costs a session; overshooting hard costs the thread.

### Bounded teaching

Explain the idea underneath the missed question, not the answer to it. Then re-ask
immediately in a fresh framing — never the identical question. Roughly three
attempts at a rung before dropping it instead of hammering. After that, lower the
rung and mark the concept shaky.

Concepts marked shaky get revisited. That is what the log earns.

## Cold start

Clean context each session. Resume protocol, before the first question:

1. Read `TOPIC.md` — subject, goal, learner profile
2. Read `LEDGER.md` — concepts, rungs, verdict history, shaky flags
3. Read the tail of the most recent `sessions/*.md` — what was **in flight**, the
   concept mid-way through, any question never asked
4. Recompute the opening rung for each concept

Then **probe rather than trust**. The first question of every session is the
last-covered concept at its recorded rung, in a framing the log shows is new. A
ledger entry from three weeks ago is a claim, not evidence. If the probe misses,
the recorded rung was optimistic and drops. No comment on the gap — nobody wants a
session that opens by being told what they used to know.

Long gaps decay the rung: open one below what's recorded and let correct answers
walk it back up.

## Artifacts

A concept that genuinely needs to be *seen* — control flow, a comparison table, a
state machine, a worked example, anatomy — gets one self-contained HTML file in
`artifacts/`, opened for the learner. Three hard rules:

- **At the learner's rung.** A diagram for a rung-2 learner labels the parts and
  traces one path. The same diagram for a rung-4 learner adds what breaks at the
  boundaries. Never the maximal version.
- **Bounded.** One idea, screen or two. If it needs scrolling to see the point, it
  is two artifacts.
- **Earned.** Most concepts are better as a question and a paragraph. Artifacts are
  for shapes prose cannot carry.

Filenames carry the rung (`control-flow-r4.html`) so a later session can regenerate
the same concept at a different rung.

## Source grounding

Added after reading [bevibing/tutor-skills](https://github.com/bevibing/tutor-skills)
— a sibling skill with a different architecture, not a fork of this one.

The hole it fills: this skill's knowledge otherwise comes from the model, so a
factually wrong claim is indistinguishable from a right one. Code execution
closes that gap for claims *about code* — you run it, so you know. It does
nothing for claims about the world.

The borrowed idea is generation: when the learner has material, read it and write
per-concept notes carrying where each fact came from. Then a question can name its
source, and an ungrounded question can be labelled as such. Two claims with the
same confidence level stop looking identical, which is the whole point.

What was not taken:

- **Obsidian.** A viewer, not a mechanism — and Obsidian opens any folder as a
  vault, so `~/tutor/<topic>/` is browsable that way with zero skill changes and no
  dependency. The learning happens in the dialogue; the notes are the residue.
- **The 9-phase vault pipeline.** This skill is one loop. A generator feeding a
  quizzer is a different shape, and adopting the phases would add a second skill and
  a second failure mode for no gain in the loop itself.
- **Their proficiency model.** Percentage-of-correct over batches of four MCQ. It
  cannot see whether an answer was reasoned or guessed, so the ratchet guard and
  regression detection both become unavailable. A one-question loop can.

Their batch cadence is the deeper difference: four questions land before any
adaptation happens, so within a round the tutor cannot respond to the learner. That
is why the two skills are complementary rather than competing — theirs is strong
for working through a vault of your own documents, this one for a subject learned
over time.

## Tailoring

The learner's method is observed, not assigned. Signals read in the first session
and continuously after:

- **Pace** — long sessions or short bursts sets session length and question density
- **Response to being wrong** — immediate correction, or a hint and a chance to
  self-correct first. Defaulting wrong is demoralizing for one learner and
  frustrating for another
- **Explain-back vs show-back** — does producing the explanation work better, or
  being shown one and reproducing it? Both legitimate; in-session evidence decides
- **Tolerance for struggle** — grind the hard question, or hand over scaffolding?
  Read from whether hints get pushed away
- **Entry point** — code before theory or the reverse; diagram before prose or the
  reverse
- **Background overlap** — prior domain knowledge moves the opening rung, not the
  concept list

Deliberately excluded: visual/auditory/kinesthetic matching. No evidence supports it,
and it is the standard move a "personalized tutor" makes. Tailoring is only real if
it is grounded in what actually happens in front of it.

Observations are written to `TOPIC.md` under `## How this student learns`, each with
its evidence. Without this the tutor rediscovers known preferences every session and
the learner re-explains themselves to a clean context.

Stated preferences are followed. "Just give me the answer" is recorded and honoured.

**The method adapts; the bar does not.** Framing, format, entry point, rung, session
length, artifact vs prose — all free. The rung is derived from demonstrated
capability and moves on its own terms. The standard behind the rung does not move.
Tailoring how something is taught is personalization; lowering the standard until
nothing is challenging is coddling, and a tutor that does that teaches nothing.

## Code execution

For technical subjects the tutor writes and runs code. Three uses:

1. **Verifying the learner's answer.** They paste code; the tutor runs it and
   compares actual output against the expected. No guessing about what their
   snippet prints.
2. **Producing the answer.** When a question is "what does this print", the tutor
   runs it rather than reasoning about semantics from memory.
3. **Generating a fresh question.** Scaffolding with known output — code whose
   result the tutor has actually observed — which makes the expected answer certain
   instead of assumed.

Non-technical subjects never trigger any of this. It activates on asking for code,
pasting code, or any question whose answer is a program's output.

Execution goes through a helper (`scripts/run.sh`) so the rules hold the same way
every session:

- **Timeout**, default 10s, so an infinite loop fails instead of hanging
- **Temp file per run**, discarded after — the learner's workspace is never
  polluted with scratch files
- **Stdout, stderr, and exit code** all captured. A traceback is often the most
  instructive output there is
- **No install, no network.** If a snippet needs a package that isn't there, the
  tutor says so rather than fetching it
- **Interpreter chosen per subject** — `python3`, `node`, `bash` — and if none
  matches, the tutor falls back to asking the learner to run it and paste the
  output

The tutor runs code to check facts about code. It does not run code to decide what
to teach, and it never silently executes something the learner cannot see.

## Steering

The learner may interrupt at any time — a rabbit hole, a tangent, a question about
something unrelated. This is healthy and gets no pushback.

The excursion is followed wherever it goes, for as long as it stays interesting. It
is recorded in the session log under `## Steering`, with topics noted as `asked
about` so a later session doesn't rediscover them from scratch.

Then it re-anchors. Once the excursion resolves:

1. One question at the learner's recorded rung on the concept where the steering
   began — a re-anchor, not a test, and framed as picking up where they left off
2. Back to the ledger from there

Steering changes what gets covered. It does not change the rung, and it is not
logged as a miss. A learner who wanders is not thereby behind, and the re-anchor
exists to confirm that rather than to catch them up on lost ground.

If the steering turned out to be the better use of the session — the thing they
actually care about is a prerequisite for the concept on the ledger — the ledger is
reordered to put it first. The mission is theirs; chasing their curiosity is how
motivation stays intact. Record the reordering in the log.

## Harness portability

Plain prose over plain files. No tool names, no vendor API, no assumption that a
particular agent runtime is present — so the skill loads in OpenCode, Claude Code,
Cursor, or anything else that reads `SKILL.md`.

Three places where harnesses genuinely differ, each handled by degrading rather
than failing:

- **No execution.** Sandboxed or read-only skill directory, no shell, an agent that
  cannot run code: ask the learner to run it and read the output back. If that is
  impossible too, say the output is unverified. Predicting it would reintroduce
  exactly the ungrounded claim source-grounding exists to remove.
- **No file opening.** Some environments cannot surface an HTML artifact. Print the
  path, or carry the idea in prose that turn.
- **No writable filesystem.** The loop still runs in-session; it simply cannot
  resume. Say so rather than implying state is being kept.

Frontmatter carries only `name` and `description`, the two portable keys.
Harness-specific keys (`disable-model-invocation`, `argument-hint`, `allowed-tools`)
change how the skill is reached, not what it does.

## Scope

Deliberately not built:

- No spaced repetition scheduler. Revisiting shaky concepts is opportunistic,
  driven by what the loop encounters. A proper SRS needs per-concept decay intervals
  and a due queue — worth it once sessions are weeks apart, not on day one.
- No curriculum. Concepts accumulate as encountered; the outline exists so the
  learner can see coverage, not to constrain it.
- No vault generator. Source notes are written for the concepts the learner's own
  material happens to cover, in one pass. Structured generation as its own pipeline
  is a different skill.
