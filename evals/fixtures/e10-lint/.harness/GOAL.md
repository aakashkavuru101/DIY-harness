# GOAL

## Goal

A harness that keeps `clean.js` from breaking while an agent changes it, for the one developer who runs it.

## Done when

- Every change to `clean.js` is checked before it is committed.

## Not doing

- CI, telemetry, project skills.

## Runs in

- Claude Code.

## Known failures

- The agent once committed a syntax error in `clean.js`.

## Constraints

- Autonomy: the agent asks before each edit and each command.

## Amendments

(none)
