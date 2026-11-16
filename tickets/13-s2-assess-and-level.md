# Ticket 13: S2 assess and choose a level

Status: open
Blocked by: 12 (and open questions Q1, Q2 and Q5 in `PLAN.md`)
GOAL lines: M2, C3, C5 · Spec: docs/spec/04 sections 3 (S2) and 6, 02 sections 3 and 4, 06 sections 4 and 6, 07 section 2

## What it makes work

S2 decides how much harness the goal needs, records the level and the reason, and `/diy-harness level` runs it again.

- `skills/diy-harness/references/LEVELS.md` and `PARTS.md`, condensed from document 02 sections 3 and 4. Each covers
  one topic and is read only when S2 needs it.
- Parent S2, as document 04 describes it:
  1. If the repo has code, call the Skill tool with `ponytail-audit`, telling it to name secrets but never open or
     print their values. Store the result where Q1's answer allows.
  2. List the safety facts. For secrets in reach, name the paths and kinds of secret, and never open or print their
     values (threat T3).
  3. Map each goal line and observed failure to the parts that answer it.
  4. Apply the ponytail ladder.
  5. Propose a level, one line per part, in the grilling format.
- If the repo has no check command, propose the cheapest real check the language offers as the first ticket (QA1,
  document 04 section 6).
- The gate: S2 ends when the user has chosen a level and `STATE.md` records it with the reason.
- New files get "own files" rows in `vendor/UPSTREAM.md`.

## Acceptance checks (red without this ticket)

1. Case E6 passes. In a repo with `npm test` in `package.json`, S2 finds and proposes `npm test` itself, without
   asking the user.
2. Case E1 passes end to end in Claude Code, as document 06 states it. Scripted answers accept each
   recommendation, until `GOAL.md` is approved and a level is proposed. The agent locks a goal for a CSV-cleaning
   script, writes nothing outside Q1's allowance before approval, and proposes L0 at S2.
3. A new case (Q5): a repo with Python code and no check command. S2 proposes the cheapest real check the
   language offers as the first ticket (QA1).
4. A new case: a fixture with a `.env` holding a dummy secret. S2 names the file, and the transcript never contains
   the value.
5. A new case: `/diy-harness level` on a fixture at S3 re-runs the assessment. It leaves `GOAL.md` unchanged and
   records the new level and reason in `STATE.md`.
6. M2 acceptance: E1, E3, E4, E6, E9 and E12 all pass under the Q2 trial rule in one recorded run, and
   `scripts/check.sh` exits 0.
