# Ticket 04: playbooks and required patches

Status: closed
Blocked by: 02
GOAL lines: M1, C4, C8 · Spec: docs/spec/03 sections 1, 2 and 6, 06 section 2 (checks 2, 3, 8), ADR 0001 (D1)

## What it makes work

The five user-invoked upstream commands become description-free playbooks inside the
parent, no vendored file points at a skill that is not shipped, and every local change is
on record.

- Copy each upstream `SKILL.md` unchanged to
  `skills/diy-harness/references/playbooks/<name>.md`: to-spec, to-tickets, implement,
  implement-spec, retro (all under `upstream/skills/skills/engineering/`). Commit, then
  patch in a separate commit.
- Patches, each listed in `vendor/PATCHES.md` (file, why, decision ID):
  - Strip the frontmatter from the five playbooks (D1: no description, cannot fire).
  - Every `/setup-matt-pocock-skills` line points at `.harness/SPEC.md` and
    `.harness/tickets/` instead. Document 03 says the only site is `code-review`; at the pin
    it also appears in to-spec, to-tickets and implement-spec. Patch all of them.
  - Any reference to another dropped or user-invoked skill that check 3 finds.
  - The i-have-adhd frontmatter removal from ticket 03.
- Check 2: every "Call the Skill tool with `<name>`" names an existing sibling folder under
  `skills/` that is model-invoked.
- Check 3: no skill or playbook tells the agent to call a user-invoked skill, and no line
  names a dropped skill (the Dropped and Parked rows in document 03 section 2).
- Check 8, diff half: every file that differs from `upstream/` at the pin is listed in
  `vendor/PATCHES.md`. When `upstream/` is absent, skip this half with a printed warning.

Out of scope: the content patches for to-spec, to-tickets and retro (M3, M5) and the D2
and D3 patches. If check 2 fails because a playbook calls a skill that is not shipped,
stop and report it; do not vendor more skills.

## Acceptance checks (red without this ticket)

1. Fixture skill saying "Call the Skill tool with `nope`": fails on check 2.
2. Fixture playbook mentioning `/setup-matt-pocock-skills`: fails on check 3.
3. Fixture with a vendored file changed and no `PATCHES.md` entry: fails on check 8.
4. Real repo: `grep -r setup-matt-pocock-skills skills/` finds nothing.
5. Real repo: no playbook starts with a frontmatter block.
6. Real repo: `scripts/check.sh` exits 0 and `sh tests/check.test.sh` passes.
