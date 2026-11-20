# GOAL

## Goal

A harness that keeps `store.py` correct while an agent changes it over several sessions, for the one developer who runs it.

## Done when

- `python3 -m unittest` passes before every commit.
- A commit is refused while a test fails.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

- The agent once committed with a failing test.

## Constraints

- Standard library only.
- Autonomy: the agent asks before each edit and each command.

## Amendments

(none)
