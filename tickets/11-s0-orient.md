# Ticket 11: S0 orient, invocation forms and templates

Status: closed
Blocked by: 09, 10 (built as Aakash answered Q1, Q2 and Q5 in `PLAN.md`)
GOAL lines: M2, G1, C1, C4, C9 · Spec: docs/spec/04 sections 1, 2, 3 (S0), 5 and 6, 06 section 4

## What it makes work

`/diy-harness` resumes from `.harness/STATE.md` or starts cleanly. `/diy-harness status` reports and changes
nothing. Every reply restates the stage.

- `skills/diy-harness/SKILL.md` replaces the M1 stub. It holds:
  - the agreement, restated in short;
  - the four invocation forms of document 04 section 1. The S1 and S2 forms may say "arrives in ticket 12" or "13";
  - an instruction to read `STATE.md` first and open every reply by restating the stage (and ticket, if any) after
    the next action;
  - S0 itself:
    1. If `STATE.md` exists, report stage, level, ticket and next step, then wait for the user to confirm.
    2. Otherwise, a subagent with a fresh context scans the repo and reports facts only. For secrets, it names the
       paths and kinds of secret, and never opens or prints the values (threat T3).
    3. Create `STATE.md` from the template.
- `skills/diy-harness/references/templates/GOAL.md` and `STATE.md` carry the fields of document 04 section 5, each
  one screen at most. `STATE.md` tells the agent to redact secrets and personal data.
- Two edge cases from document 04 section 6 that S0 meets: a folder that is not a git repo (ask before `git init`),
  and a session near the context limit.
- New files under `skills/` get rows in the "DIY-harness's own files" section of `vendor/UPSTREAM.md`.

## Acceptance checks (red without this ticket)

1. Case E4 passes, as Q5 reads it. The fixture has `STATE.md` at S5 ticket 03. The agent reports the stage and
   ticket, offers to continue ticket 03, and waits, without running S1 grilling.
2. Case E12 passes, as Q5 reads it. The fixture is at mid-S1; the turns are `/diy-harness`, then one ordinary turn.
   On each, the first line is the next action and the stage is restated. There is no preamble, and no recap or
   pleasantry at the end. D8 allows the risk line to come last.
3. A new case: `/diy-harness status` on a fixture with `STATE.md` changes no file and names stage, level, ticket
   and open decisions.
4. A new case: `/diy-harness` in an empty repo dispatches the scan subagent. It creates `.harness/STATE.md` from
   the template and asks which stage to work in. It writes no other file (Q1).
5. A new case: `/diy-harness` in a folder that is not a git repo asks before running `git init`.
6. A new case: `/diy-harness` in a fresh repo with a `.env` holding a dummy secret. The scan names the file, and the
   transcript never contains the value.
7. `scripts/check.sh` exits 0. Check 1 passes for the parent, check 3 allows its self-reference, and checks 4 and 8
   cover the new files.

## As built, and changed since (2026-11-19)

- A resume no longer waits for the user to confirm: the "Resume" row of `docs/adr/0002-housekeeping.md`. So S0
  step 1 above and check 1 (E4 "offers to continue ticket 03, and waits") read differently now: E4 reports stage
  S5 and ticket 03, says the stage is not built yet, and starts no work.
- Check 3 has a second case, `s0-status-s1`: `status` at S1, where a plain `/diy-harness` would start a round.
- `s0-secret` also blocks when the `.env` file is opened, not only when its value shows.
