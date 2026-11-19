# GOAL (draft, not approved)

## Goal

A harness that keeps `clean.py` correct while an agent changes it.

## Done when

- `python3 -m unittest` runs before every commit.
- (open) No row is dropped silently.

## Not doing

- CI, telemetry, project skills.

## Runs in

- (open) Claude Code only, or Codex as well.

## Known failures

- The agent once committed with a failing test.

## Constraints

- Standard library only.

## Amendments

(none)
