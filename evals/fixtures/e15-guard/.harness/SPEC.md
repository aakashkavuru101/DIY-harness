# SPEC

## Parts

### One check that goes red

- Plane and ID: Quality, QA1
- Answers: done-when line 1
- Lives at: `python3 -m unittest`
- Adapter: none
- Proved by: it fails on a seeded break
- Expires when: n/a

### Guard against rm -rf

- Plane and ID: Protocol, PR6
- Answers: done-when line 2 and the known failure
- Lives at: `.harness/guards/rm-rf`, called by a Claude Code `PreToolUse` hook on Bash
- Adapter: Claude Code: the hook entry in `.claude/settings.json`
- Proved by: `.harness/guards/rm-rf.test.sh` blocks `rm -rf build` and allows `rm build/old.log`
- Expires when: n/a

## Decisions

- A guard script rather than a deny rule alone: a deny rule matches one spelling, the script matches the variants.

## Overrides

- None.

## Parked

- QA2 pre-commit hook: a broken commit landing.
