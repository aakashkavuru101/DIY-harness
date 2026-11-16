# ADR 0003: Agent facts verified before relying on them

Date: 2026-11-16 · Recorded by: Claude Code (builder), for Aakash's review · Status: Recorded · GOAL lines: M1, M2, DN1, C11

Document 05 section 6 asks that each agent fact be confirmed against the agent's current version, and that
the version checked be recorded in an ADR. ADR 0002 defers the section 6 checklist to M4, except item 4,
which ticket 05 covers in part: 4a is checked, 4b waits for M4. This file records facts, not decisions; a decision found here goes to ADR 0001.

| Item | Fact | Version checked | Result | Enforced by |
| --- | --- | --- | --- | --- |
| 4a | `claude plugin validate . --strict` accepts the manifests | Claude Code 2.1.325 | Passes on this repo. `--strict` treats warnings as errors, so it needed `author` in `.claude-plugin/plugin.json` and `description` in `.claude-plugin/marketplace.json`; both were added. It rejected no field that document 05 requires. Its README and icon notes come from the plugin-directory profile (`--profile directory`) and do not change the result | `scripts/check.sh` check 10 |
| 4b | Claude Code plugin skill naming: `/diy-harness` or the namespaced `/diy-harness:diy-harness` | Not checked | Aakash, 2026-11-16: "it is diy-harness", the bare form `/diy-harness`, not the namespaced one. This is the requirement in G1 and C4, not an observed behaviour (a working name: the name part of D11 is pending). Not observed on an installed plugin. M4 checks whether typing it starts the parent (document 05 section 6 item 4); document 06 section 3 does not test this yet | |

Rows H1 to H5 are the Claude Code hook facts that ticket 07 relies on (M2). Each is quoted from the Claude Code docs
(code.claude.com/docs/en/hooks and /plugins/manifest-reference, read 2026-11-16; the pages are not pinned to a
version). The installed CLI is 2.1.325. "Docs" in the Result column means read in the docs; "Observed" means seen in a
run on 2.1.325.

| Item | Fact | Version checked | Result | Enforced by |
| --- | --- | --- | --- | --- |
| H1 | `SessionStart` output format | Docs; observed on CLI 2.1.325 | Docs: "Claude Code adds a SessionStart hook's plain-text stdout to Claude's context." The hook prints plain text. Observed 2026-11-16 in one `claude -p --plugin-dir` run: the main agent quoted all three header lines | `tests/check.test.sh` (hook output) |
| H2 | `SubagentStart` output format | Docs; observed on CLI 2.1.325 | Docs: `SubagentStart` "can inject context into the subagent" through `hookSpecificOutput.additionalContext`. The docs list the events whose plain stdout reaches Claude as "`UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`, and `PostModelSwitch`"; `SubagentStart` is not among them, so the hook prints JSON. Observed in the same run: a dispatched subagent quoted the ponytail and i-have-adhd headers, and not the agreement header | `tests/check.test.sh` (JSON shape) |
| H3 | Cap on one hook's output | Docs; CLI 2.1.325 | Docs: "A hook's `additionalContext`, `systemMessage`, and `initialUserMessage` strings, and its plain stdout, are capped at 10,000 characters." Longer text goes to a file, and Claude gets the path and a preview of up to 2,000 characters. Hence one run per rule set (PLAN.md Q7). Observed: the parts can arrive in any order. That run showed agreement, then i-have-adhd, then ponytail, so the precedence must be stated in words (ticket 10) | `scripts/check.sh` budget check, 10,000 bytes per part |
| H4 | `hooks/hooks.json` loads automatically | Docs; CLI 2.1.325 | Docs, manifest reference: "Claude Code merges whatever you declare with `hooks/hooks.json` when that file exists." `claude plugin validate . --strict` passes on 2.1.325 with or without a manifest `hooks` entry, so it does not show double registration. Observed: the live `--plugin-dir` run loaded `hooks/hooks.json` with no manifest entry. The entry is left out (PLAN.md Q8, ADR 0002) | `scripts/check.sh` hooks-wiring check |
| H5 | `timeout` and failures | Docs; CLI 2.1.325 | Docs: `timeout`: "Seconds before canceling". The default is "600 for `command`, `http`, and `mcp_tool`". "Claude Code cancels a `command`, `http`, or `mcp_tool` hook that reaches its `timeout`, discarding the hook's output." Any other non-zero exit is a "Non-blocking error ... The action goes ahead". On exit 2, `SessionStart` and `SubagentStart` show "stderr to user only". The hook always exits 0, and each entry sets `timeout: 10` | `tests/check.test.sh` (hooks.json wiring) |
