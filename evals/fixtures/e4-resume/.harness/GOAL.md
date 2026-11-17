# GOAL

## Goal

A harness that keeps `clean.py` correct while an agent changes it.

## Done when

- `python3 -m unittest` runs before every commit.
- A pre-commit guard refuses a commit when a test fails.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

- The agent once committed with a failing test.

## Constraints

- Standard library only.

## Amendments

(none)
