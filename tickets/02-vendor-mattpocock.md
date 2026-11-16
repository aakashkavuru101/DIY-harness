# Ticket 02: vendor the mattpocock engine skills

Status: open
Blocked by: 01
GOAL lines: M1, C8 · Spec: docs/spec/03 sections 2 and 6, 05 section 1, 06 section 2 (checks 1, 8)

## What it makes work

The eleven model-invoked engine skills sit as flat siblings under `skills/`, unchanged from
the pin, and `check.sh` proves it.

- Copy each folder whole from `upstream/skills/skills/` to `skills/<name>/`:
  `engineering/`: code-review, codebase-design, diagnosing-bugs, domain-modeling, pr,
  prototype, research, tdd, wizard. `productivity/`: grilling, writing-for-agents.
- `vendor/UPSTREAM.md`: per repo, URL, pinned commit, date, licence, and every file taken
  with its upstream path. Start it with the mattpocock section.
- Check 1: every `skills/*/SKILL.md` has frontmatter with `name` equal to the folder name
  and a `description`.
- Check 8, listing half: every file under `skills/` is listed in `vendor/UPSTREAM.md`
  (files marked as DIY-harness's own are exempt; ticket 05 adds the first).

Do not patch anything here. `code-review` still points at `/setup-matt-pocock-skills`;
ticket 04 fixes that and adds the check that catches it.

## Acceptance checks (red without this ticket)

1. Fixture skill whose `name` differs from its folder: `check.sh` fails on check 1.
2. Fixture skill with no `description`: fails on check 1.
3. Fixture with a file under `skills/` missing from `UPSTREAM.md`: fails on check 8.
4. Real repo: `diff -r upstream/skills/skills/<group>/<name> skills/<name>` is empty for all eleven.
5. Real repo: `scripts/check.sh` exits 0 and `sh tests/check.test.sh` passes.
