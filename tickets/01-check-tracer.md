# Ticket 01: check.sh tracer

Status: open
Blocked by: none
GOAL lines: M1, DN1 · Spec: docs/spec/06 section 2 (check 9), 03 section 6, 05 section 1

## What it makes work

`scripts/check.sh` exists, runs end to end, and enforces its first real check, so every
later ticket only adds a check and its fixtures.

- `scripts/check.sh [root]`: runs each check, prints one line per failure naming the check
  number and the file, exits non-zero if any failed.
- `tests/check.test.sh`: runs `check.sh` against fixtures and asserts exit code and message.
- Check 9: `vendor/LICENSES/` holds the three MIT texts (`mattpocock-skills`, `ponytail`,
  `i-have-adhd`, copied from `upstream/*/LICENSE`), and `NOTICE` names all three authors.
- `LICENSE` (MIT, DIY-harness's own) and `NOTICE` at the root.

## Acceptance checks (red without this ticket)

1. `sh tests/check.test.sh` passes.
2. Fixture with one licence file missing: `check.sh` exits non-zero and names check 9 and the file.
3. Fixture with `NOTICE` missing one author: exits non-zero, names check 9.
4. Fixture with all three licences and a full `NOTICE`: exits 0.
5. `scripts/check.sh` on the real repo exits 0.
6. Each file in `vendor/LICENSES/` is byte-identical to its `upstream/*/LICENSE`.
