# Ticket 08: off switches

Status: closed
Blocked by: 07
GOAL lines: M2, DN5, C1, C7, C9 · Decisions: D5 · Spec: docs/spec/05 section 2

## What it makes work

A user can switch ponytail or i-have-adhd off for one session, or for good, either everywhere or in one project.

- `hooks/prompt-tracker.mjs` on `UserPromptSubmit`. Its `hooks.json` entry sets a `timeout`, and a fallback timer
  of 1 second or less means stdin that never closes cannot stall a prompt (upstream's tracker has the same guard).
  It matches the whole prompt, trimmed, ignoring case and trailing punctuation, as upstream ponytail does. "Add a
  normal mode toggle" switches nothing off.
  - "stop ponytail" turns ponytail off for the session.
  - "stop adhd mode" turns i-have-adhd off for the session.
  - "normal mode" turns both off. The layer already promises this phrase for both rule sets.
  - Each adds one context line saying what is off and how to get it back: a new session.
- Session flags live in `<config>/diy-harness/sessions/<session_id>`, where `<config>` is `CLAUDE_CONFIG_DIR` or
  `~/.claude`.
  - A relative `CLAUDE_CONFIG_DIR` is ignored, because the hook runs in the user's project.
  - A flag holds only which rule sets are off, never prompt text.
  - A session ID that is not `[A-Za-z0-9_-]` is ignored.
  - Flags are written through a temp file and a rename, never through an existing symlink.
  - At session start, flags older than 7 days are deleted. Only regular files named like a flag are deleted, and
    symlinks are never followed.
- `hooks/session-start.mjs` now reads stdin for the session ID, with the same fallback timer. On stdin that is
  missing, garbled or never closes, it fails open and prints its part. It leaves out a rule set that is off for
  this session, for the main session and its subagents, for as long as Claude Code keeps the same session ID.
- Verify, and record in `docs/adr/0003` with the CLI version: whether resume, `/clear` and compaction keep the
  session ID, and whether `SubagentStart` input carries the parent's session ID. Upstream ponytail keeps the off
  state only across compaction, by design. Tell the user what survives in the context line.
- Persistent switch: the environment variable `DIY_HARNESS_OFF`, a comma list of `ponytail` and `adhd`.
  - The agreement has no off switch.
  - In user settings it applies everywhere. In a project's `.claude/settings.json` it applies to that project only.
  - The hook's first line names any rule set it switched off.
  - Verify that hooks see the `env` values from settings, and record the result in `docs/adr/0003`.
- `README.md`: a short "Off switches" section added after the existing text. It names the phrases and
  `DIY_HARNESS_OFF`, and says to uninstall the upstream ponytail and i-have-adhd plugins, which would otherwise
  inject their rules a second time (D6).
- `DIY_HARNESS_OFF` and the `diy-harness/` config folder carry the working name (C9). List both in the ADR 0001
  D11 row as things a rename must change.

## Acceptance checks (red without this ticket)

1. "stop ponytail" in session A: the next `SessionStart` for A, and a subagent of A, have no ponytail; session B
   still has it. For each source (resume, clear, compact), the result matches the verified behaviour recorded in
   ADR 0003.
2. "stop adhd mode" does the same for i-have-adhd; "normal mode" for both.
3. "please add a normal mode toggle" switches nothing off.
4. `DIY_HARNESS_OFF=ponytail` leaves out ponytail and says so in the first line; `DIY_HARNESS_OFF=all` changes
   nothing.
5. A session ID of `../x` writes no file; malformed stdin exits 0 with no output; a relative `CLAUDE_CONFIG_DIR` is
   not used.
6. A flag dated 8 days ago is deleted at the next session start. A non-flag file and a symlink in the same folder
   survive, and the symlink's target is untouched. The flag file never contains the prompt.
7. `README.md` names "stop ponytail", "stop adhd mode", "normal mode" and `DIY_HARNESS_OFF`, and says to
   uninstall the upstream plugins.
8. With stdin that never closes, the tracker exits 0 within 2 seconds and writes no flag, and `session-start.mjs`
   prints its part within 2 seconds.
9. `scripts/check.sh` exits 0, including no-network on `hooks/`.
