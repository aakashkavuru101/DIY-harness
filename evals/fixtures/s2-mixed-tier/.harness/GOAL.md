# GOAL

## Goal

A harness that keeps `clean.py` correct while an agent changes it, for the one developer who runs the script.

## Done when

- `python3 -m unittest` passes after every change.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

(none yet)

## Constraints

- Standard library only.
- Autonomy: the agent may edit the script and run it on sample files in this repo; it asks before any delete and before any file outside the repo.

## Amendments

(none)
