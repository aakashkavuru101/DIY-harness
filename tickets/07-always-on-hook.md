# Ticket 07: the always-on hook

Status: closed
Blocked by: none (built as Aakash answered Q7 and Q8 in `PLAN.md`)
GOAL lines: M2, C6, C7 · Decisions: D5, D6, D11, Q7, Q8 · Spec: docs/spec/05 sections 2 and 3, 07 section 9

## What it makes work

Every Claude Code session and subagent starts with the always-on layer, and a broken hook can never block a session.

- `hooks/hooks.json` runs `hooks/session-start.mjs` once per rule set, because Claude Code caps one hook's output at
  10,000 characters (Q7). Each entry sets a `timeout`. The script gets the event name and the part as arguments:
  - `SessionStart` (matcher `startup|resume|clear|compact`) runs it three times: `agreement`, `ponytail`, `adhd`.
  - `SubagentStart` runs it twice: `ponytail` and `adhd`. A subagent gets the build and output rules, not the
    agreement.
- `hooks/session-start.mjs` prints one header line, then the part:
  - The header names the rule set and its off phrases, so the agent can see and report a duplicate injected by an
    upstream plugin (D6).
  - For `SessionStart` the output is plain text. For `SubagentStart` it is JSON `hookSpecificOutput.additionalContext`,
    the only form the Claude Code docs give for that event.
  - It builds the part with `core/build-agents-md.mjs`'s own code, so the hook and the committed `AGENTS.md` cannot
    differ. The build is exported per part, and the script keeps its command line.
  - It finds its files from its own path, not from an environment variable.
  - It does not read stdin in this ticket, so stdin that is missing, garbled or never closes cannot stop it. Ticket 08
    adds reading stdin.
  - When a source file is missing, it prints nothing. It always exits 0.
- `.claude-plugin/plugin.json` has no `hooks` entry. Claude Code loads `hooks/hooks.json` by itself and merges any
  hooks file the manifest names, so naming it would risk registering every hook twice (Q8).
- `.claude-plugin/marketplace.json`: owner `aakashkavuru101` (D11).
- New checks in `scripts/check.sh`:
  - Budget: `AGENTS.md` at most about 4,000 tokens, estimated as bytes divided by 4. Over budget, trim i-have-adhd's
    examples first and keep every rule.
  - Each part the hook prints, header included, fits in 10,000 bytes. Bytes are never fewer than characters, so the
    check is safe.
  - Wiring: `plugin.json` must not name `hooks/hooks.json`.
- `docs/adr/0003` records, with the doc quotes and the CLI version:
  - the output format for each event;
  - that `hooks/hooks.json` loads automatically and is merged with any hooks file the manifest names;
  - the 10,000-character cap;
  - the default `timeout`;
  - what a non-zero exit does.

  The header text carries the working name; ticket 08 adds it to the rename list in the ADR 0001 D11 row.

## Acceptance checks (red without this ticket)

1. `SessionStart` with each of `agreement`, `ponytail` and `adhd` prints its header line and then exactly that part,
   as plain text.
2. `SubagentStart` with `ponytail` or `adhd` prints JSON whose `hookEventName` is `SubagentStart` and whose
   `additionalContext` is the header plus the part. `SubagentStart` with `agreement` prints nothing, and
   `hooks/hooks.json` wires `SubagentStart` only to `ponytail` and `adhd`.
3. With a source file missing, it prints nothing and exits 0.
4. With stdin that is not JSON, or that never closes, it still prints its part within 2 seconds and exits 0.
5. A fixture whose `plugin.json` names `hooks/hooks.json` fails the wiring check. The real repo passes it and has
   `hooks/hooks.json`.
6. A fixture with an `AGENTS.md` over 16,000 bytes fails the budget check. A fixture with one part over 10,000 bytes
   fails the per-part check. The real repo passes both.
7. Real repo: `scripts/check.sh` exits 0, including no-network on the real `hooks/` and check 10.
8. In a Claude Code session with the plugin loaded, the agent can quote the three header lines. This is checked once
   and recorded in the PR. It costs a session, so ask Aakash first, or he runs it himself.
