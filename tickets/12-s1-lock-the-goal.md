# Ticket 12: S1 lock the goal, and the D2 grilling patch

Status: closed
Blocked by: 11 (built as Aakash answered Q1 and Q2 in `PLAN.md`)
GOAL lines: M2, C1, C2, C3 · Decisions: D2 · Spec: docs/spec/04 sections 3 (S1) and 6, 03 section 5 (D2), 06 section 4

## What it makes work

S1 grills the user until the goal is sharp enough to steer by, writes `.harness/GOAL.md`, then stops at the gate.

- Parent S1, as document 04 describes it:
  - Call the Skill tool twice, for `grilling` and `domain-modeling`.
  - Aim the frontier at the nine topics listed there.
  - Use `research` for external facts.
  - Write `GOAL.md` from the template.
  - Terms, decisions and research notes are written only where Q1's answer allows, and only when it allows.
- The gate: S1 ends when the frontier is empty and the user has approved `GOAL.md` line by line. The agent then
  updates `STATE.md`, stops, and asks before S2. A user who skips the gate ("just do it") skips it for this stage
  only, and the skip is recorded in the `STATE.md` log (document 04 section 6).
- D2 patch to `skills/grilling/SKILL.md`:
  - at most 5 questions per round;
  - the rest of the frontier carries over to the next round;
  - no cap on the total.

  The patch gets a `vendor/PATCHES.md` row and its own commit.

## Acceptance checks (red without this ticket)

1. Case E9 passes. Fixture: `STATE.md` at S1 with 8 open decisions that do not depend on each other. The agent
   shows at most 5, and the next round brings the other 3. i-have-adhd's rule 9 may already make this pass
   without the patch. If so, follow the M2 rule for cases that are green before the change, and ask Aakash
   whether the D2 patch is still earned.
2. Case E3 passes. S1 has just been approved and the user says "ok". The agent updates `STATE.md`, stops, and asks
   before S2.
3. Case E1, first half. The agent starts S1 grilling with numbered questions and recommended answers. Before the
   goal is approved, it writes only the files Q1 allows.
4. A new case: after the user approves the goal line by line, `.harness/GOAL.md` exists with the seven template
   fields of document 04 section 5.
5. A new case: "just do it" at the S1 gate moves on to S2 and records the skip in the `STATE.md` log.
6. `scripts/check.sh` exits 0. Check 2 passes for the two Skill calls, and check 8 diff passes with the new
   PATCHES row.

## As built (2026-11-19)

- Check 1: E9 was blocked without the D2 patch (a round of 10 questions), so the patch is earned.
- Check 4 has no case of its own. E9 covers the draft `GOAL.md` created from the template with its seven fields;
  E3 covers the approval that removes the draft mark.
- Check 5: case `s1-skip-gate` already passed before any S1 text existed, so it is not a red proof of the skip
  paragraph. Aakash was asked on 2026-11-19 and kept the paragraph, with the case as a regression guard. Its
  "this stage only" half cannot be tested until S2 exists (ticket 13).
- Until S2 picks a level, S1 parks terms and hard-to-reverse decisions in `.harness/research/notes.md` (Q1);
  ticket 13 moves them.
