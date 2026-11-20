# STATE

- Stage: S5 Build
- Level: L0, because one script in one session needs only the goal, the pointers and one check
- Current ticket: the L0 build, under "Ticket" below
- Next step: build the `AGENTS.md` harness block (PR2): show its lines to the user, then write the ones they approve.

## Spec

- PR2: navigation pointers; answers: an agent finds the goal, the state and the check; lives at: the `AGENTS.md` harness block, with `CLAUDE.md` leading to it; proof: every pointer in the block resolves.
- QA1: one check that goes red; answers: `python3 -m unittest` passes after every change; lives at: `python3 -m unittest`, already there; proof: run on 2026-11-14, red on a seeded break and green once undone.
- PR1, CO1, CO2: already there.
Parked: none.
Overrides: none.

## Ticket

- The L0 build: the `AGENTS.md` harness block. Acceptance: every pointer in the block resolves.

## Open decisions

- None.

## Log

- 2026-11-12: S0 scan: Python, `clean.py`, tests in `test_clean.py`, `AGENTS.md` and `CLAUDE.md` with the user's notes.
- 2026-11-13: S1 goal approved; S2 chose L0.
- 2026-11-14: S3 spec approved, with QA1's proof run; S4 skipped at L0; the L0 build is the one ticket.
