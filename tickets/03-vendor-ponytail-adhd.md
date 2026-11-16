# Ticket 03: vendor ponytail and i-have-adhd

Status: closed
Blocked by: 01
GOAL lines: M1, C7, C8, N2 · Spec: docs/spec/03 section 2, 05 section 1, ADR 0001 (D7)

## What it makes work

The build-discipline skills and the output rules are vendored, with every telemetry feature
left behind.

- Copy whole from `upstream/ponytail/skills/` to `skills/`: `ponytail`, `ponytail-audit`,
  `ponytail-debt`.
- `core/i-have-adhd.md`: the body of `upstream/i-have-adhd/skills/i-have-adhd/SKILL.md`,
  with the frontmatter removed (always-on only, no skill folder). List the frontmatter
  removal in `vendor/PATCHES.md` if that file exists yet; otherwise note it for ticket 04.
- Extend `vendor/UPSTREAM.md` with the ponytail and i-have-adhd sections.
- Not taken: `ponytail-gain`, `ponytail-help`, `ponytail-review`, anything under
  `upstream/ponytail/hooks/` (band, statusline, webhooks), the board. No hook scripts in M1.
- New check (document 07 section 9, D7): no file in the repo outside `upstream/`, `docs/`,
  `plans/` and `tests/fixtures/` is one of the dropped telemetry files
  (band, board, statusline, webhook by name).

The vendored ponytail skills may mention `ponytail-review`, `ponytail-gain` or
`ponytail-help`. Leave the text unchanged here; ticket 04's check 3 decides the patch.

## Acceptance checks (red without this ticket)

1. Fixture containing `hooks/ponytail-statusline.sh`: `check.sh` fails and names the file.
2. Fixture with a ponytail file under `skills/` not listed in `UPSTREAM.md`: fails on check 8.
3. Real repo: `diff -r upstream/ponytail/skills/<name> skills/<name>` is empty for all three.
4. Real repo: `core/i-have-adhd.md` equals the upstream SKILL.md minus its frontmatter block.
5. Real repo: `scripts/check.sh` exits 0 and `sh tests/check.test.sh` passes.
