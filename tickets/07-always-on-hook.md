# Ticket 07: the always-on hook

Status: open
Blocked by: none
GOAL lines: M2, C6, C7 · Decisions: D5, D6, D11 · Spec: docs/spec/05 sections 2 and 3, 07 section 9

## What it makes work

Every Claude Code session and subagent starts with the always-on layer, and a broken or stuck hook can never
block a session.

- `hooks/hooks.json`:
  - `SessionStart`, with matcher `startup|resume|clear|compact`, and `SubagentStart`. Both run
    `hooks/session-start.mjs`, passing the event name as an argument, so the output format is known without
    reading stdin. Each entry sets a `timeout`.
  - A subagent gets the build and output rules (ponytail, i-have-adhd), not the agreement.
- `hooks/session-start.mjs`:
  - It builds the layer with `core/build-agents-md.mjs`'s own code, so the hook and the committed `AGENTS.md` cannot
    differ. The build is exported as a function, and the script keeps its command line.
  - The first line names the rule sets loaded and the off phrases, so the agent can see and report a duplicate
    from an upstream plugin (D6).
  - It finds its files from its own path, not from an environment variable.
  - It fails open: on stdin that is missing, unreadable or never closes, it prints the full layer for its event, as
    upstream ponytail does. A fallback timer of 1 second or less covers stdin that never closes (upstream ponytail
    hung sessions without one). It prints nothing only when a source file is missing. It always exits 0.
- Verify against the current Claude Code docs and record each result in `docs/adr/0003` with the CLI version:
  - The output format for each event. A subagent may need JSON `hookSpecificOutput.additionalContext`.
  - Whether `hooks/hooks.json` loads automatically. If it does, a `hooks` entry in `plugin.json` that names the same
    file may load it twice. Document 05 section 3 asks for that entry, but upstream i-have-adhd ships without one.
    If the two disagree, raise it with Aakash before acceptance check 5.
- `.claude-plugin/marketplace.json`: owner `aakashkavuru101` (D11).
- Budget check in `scripts/check.sh`: fails when `AGENTS.md` is estimated over 4,000 tokens. The estimate is bytes
  divided by 4, and the comment says so. Over budget, trim i-have-adhd's examples first and keep every rule.

## Acceptance checks (red without this ticket)

1. Given `SessionStart` input on stdin, the hook prints the header line and then exactly the built layer, in the
   verified format.
2. Given `SubagentStart` input, it prints ponytail and i-have-adhd and no agreement, in the verified format (JSON
   if verification says so).
3. With a source file missing, it prints nothing and exits 0.
4. With stdin that is not JSON, or that never closes, it prints the full layer for its event within 2 seconds and
   exits 0.
5. The manifest check enforces the hook wiring that verification found correct, and a fixture without that wiring
   fails it.
6. Fixture with an `AGENTS.md` over the budget: fails the budget check. The real repo passes it.
7. Real repo: `scripts/check.sh` exits 0, including no-network on the real `hooks/` and check 10.
8. In a Claude Code session with the plugin loaded, the agent can quote the header line. This is checked by hand
   once and recorded in the PR.
