# GOAL

## Goal

A harness that keeps `clean.py` correct while an agent changes it, for the one developer who runs the script.

## Done when

- `python3 -m unittest` runs before every commit.
- A commit is refused while a test fails.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

- The agent once committed with a failing test.

## Constraints

- Standard library only.
- The agent asks before every commit.

## Amendments

(none)
