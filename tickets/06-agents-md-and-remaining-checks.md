# Ticket 06: generated AGENTS.md and the remaining checks

Status: open
Blocked by: 03, 05
GOAL lines: M1, DN1, C6, C7 · Spec: docs/spec/05 sections 1 and 2, 06 section 2 (checks 4, 6), 07 section 9

## What it makes work

The always-on layer has a single generated source, and `check.sh` covers all of checks
1 to 9, which closes M1.

- `core/agreement.md`: stub working agreement with a heading and one line; the real text
  arrives in M2 (document 04 section 2).
- `core/build-agents-md.mjs`: Node, no dependencies. Concatenates `core/agreement.md`, the
  body of `skills/ponytail/SKILL.md`, and `core/i-have-adhd.md`, in that order, to stdout
  or `AGENTS.md`.
- `AGENTS.md`: the committed output. `CLAUDE.md` at the root is a symlink to it.
  The builder rules stay in `.claude/CLAUDE.md` (ADR 0002).
- Check 6: committed `AGENTS.md` equals a fresh build.
- Check 4: every relative link in every tracked Markdown file resolves. Skip `upstream/`.
- No-network check: `check.sh` fails if any file under `hooks/` references a network API
  (`fetch(`, `http`/`https` modules or URLs, `curl`, `wget`, `net`/`dgram` sockets).
  `hooks/` is empty in M1; the check must pass on an absent folder.
- `README.md`: a short stub so the layout is complete; real content is DN5.

## Acceptance checks (red without this ticket)

1. Fixture where `AGENTS.md` has one extra line: fails on check 6.
2. Fixture with a Markdown link to a missing file: fails on check 4 and names the file and link.
3. Fixture with `hooks/x.mjs` containing `fetch("https://example.com")`: fails the no-network check.
4. Fixture with a clean `hooks/x.mjs`: passes.
5. Real repo: `readlink CLAUDE.md` prints `AGENTS.md`.
6. Real repo: the three sections of `AGENTS.md` appear in the order agreement, ponytail, i-have-adhd.
7. Real repo: `scripts/check.sh` exits 0 with checks 1 to 9 all run, and `sh tests/check.test.sh` passes.

After this ticket: M1 is done. Stop and ask Aakash before M2.
