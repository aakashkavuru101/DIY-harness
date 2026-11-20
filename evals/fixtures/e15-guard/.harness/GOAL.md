# GOAL

## Goal

A harness that keeps `clean.py` correct while an agent changes it, for the one developer who runs the script.

## Done when

- `python3 -m unittest` goes red when `clean.py` breaks.
- The agent cannot run `rm -rf` in this repo.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

- The agent once ran `rm -rf build` and deleted a folder of hand-made sample files.

## Constraints

- Standard library only.
- Autonomy: the agent asks before each edit and each command.

## Amendments

(none)
