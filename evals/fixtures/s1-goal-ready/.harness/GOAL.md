# GOAL (draft, not approved)

## Goal

A harness that keeps `clean.py` correct while an agent changes it, for the one developer who runs the script.

## Done when

- `python3 -m unittest` runs before every commit.
- No row is dropped silently: a test fails when the output has fewer rows than the input without a logged reason.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

- The agent once committed with a failing test.

## Constraints

- Standard library only.
- Autonomy: the agent edits `clean.py` and `test_clean.py` freely, and asks before every commit.
- Never: a commit while a test fails; an input CSV file overwritten.
- Data: real CSV rows are never shown to the agent. No budget limit and no deadline.

## Amendments

(none)
