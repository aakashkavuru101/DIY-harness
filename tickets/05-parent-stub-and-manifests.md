# Ticket 05: parent stub and manifests

Status: closed
Blocked by: 02, 03
GOAL lines: M1, C4, C9, N4 · Spec: docs/spec/05 sections 1 and 3, 06 section 2 (checks 5, 7, 10)

## What it makes work

Claude Code and Codex can both recognise the repo as a plugin with one user-invoked
command, even though the command does nothing yet.

- `skills/diy-harness/SKILL.md`: stub. Frontmatter `name: diy-harness`, a `description`,
  `disable-model-invocation: true`. Body: one line saying the stage flow arrives in M2.
- `skills/diy-harness/agents/openai.yaml`: `interface.display_name`,
  `interface.short_description`, `policy.allow_implicit_invocation: false`.
- `.claude-plugin/plugin.json`: name, version, description, licence, `skills` array listing
  every folder under `skills/`. No `hooks` entry yet (M2 adds `hooks/hooks.json`).
- `.claude-plugin/marketplace.json`: the repo's own entry; owner is the `<org>` placeholder (D11 pending).
- `.codex-plugin/plugin.json`: name, version, `skills: "./skills/"`, `interface` block.
- The command name appears in one place a rename would start from (C9): record where in
  the ticket's commit message.
- Check 5: `disable-model-invocation` in each `SKILL.md` matches `allow_implicit_invocation`
  in its `agents/openai.yaml`, where that file exists.
- Check 7: `version` is identical across all manifests.
- Check 10: `claude plugin validate . --strict` passes when the `claude` CLI is on PATH;
  skipped with a printed note otherwise.
- `check.sh` also fails if the `skills` array and the folders under `skills/` differ.

## Acceptance checks (red without this ticket)

1. Fixture with `disable-model-invocation: true` and `allow_implicit_invocation: true`: fails on check 5.
2. Fixture with two manifests on different versions: fails on check 7.
3. Fixture with a skill folder missing from the `skills` array: fails.
4. Real repo: `claude plugin validate . --strict` exits 0 (Claude Code 2.1.325 is installed here).
   If it rejects a field document 05 requires, stop and report; do not bend the manifest silently.
5. Real repo: `scripts/check.sh` exits 0 and `sh tests/check.test.sh` passes.
