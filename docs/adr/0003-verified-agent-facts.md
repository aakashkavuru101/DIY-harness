# ADR 0003: Agent facts verified before relying on them

Date: 2026-11-16 · Recorded by: Claude Code (builder), for Aakash's review · Status: Recorded · GOAL lines: M1, DN1, C11

Document 05 section 6 asks that each agent fact be confirmed against the agent's current version, and that
the version checked be recorded in an ADR. ADR 0002 defers the section 6 checklist to M4, except item 4,
which ticket 05 covers. This file records facts, not decisions; a decision found here goes to ADR 0001.

| Item | Fact | Version checked | Result | Enforced by |
| --- | --- | --- | --- | --- |
| 4a | `claude plugin validate . --strict` accepts the manifests | Claude Code 2.1.325 | Passes on this repo. `--strict` treats warnings as errors, so it needed `author` in `.claude-plugin/plugin.json` and `description` in `.claude-plugin/marketplace.json`; both were added. It rejected no field that document 05 requires. Its README and icon notes come from the plugin-directory profile (`--profile directory`) and do not change the result | `scripts/check.sh` check 10 |
| 4b | Claude Code plugin skill naming: `/diy-harness` or the namespaced `/diy-harness:diy-harness` | Not checked | Needs an installed plugin. Deferred to the M4 install smoke tests (DN2) | |
