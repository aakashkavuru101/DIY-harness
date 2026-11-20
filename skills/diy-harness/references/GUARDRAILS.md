# Guardrails

What can go wrong when an agent works in a repo, the layers that stop it, and how to build a guard. Part IDs are rows of [PARTS.md](PARTS.md).

A written rule is advice: a model can ignore prose. So every safety rule in prose points at the control that enforces it, or is deleted. No single layer is trusted: each assumes the one before it may slip.

## Threats

| # | Threat | How it enters | Stopped by |
| --- | --- | --- | --- |
| T1 | Goal drift: work nobody asked for | A long session, a tempting side task | PR1, PR3, PR5 |
| T2 | Destructive action: force push, mass delete, schema drop, infrastructure destroy | A plausible-looking command mid-task | PR6, PR7, IN7 |
| T3 | Secret exposure: keys, tokens, `.env`, SSH keys read or printed | File reads, environment variables, logs | IN6, IN7 |
| T4 | Injected instructions in content the user did not write | Issues, pull-request comments, READMEs, web pages, tool results | IN8, IN7, PR7 |
| T5 | Poisoned or silently changed tool descriptions | A third-party MCP server, at install or after an update | IN10, IN3 |
| T6 | Malicious skill, plugin or hook | Public skill marketplaces and repos | IN10 |
| T7 | Bad dependency: invented, squatted or freshly compromised package | The agent runs an install | IN9 |
| T8 | The agent weakens its own checks: edits a test, a hook or the goal to get to green | Pressure to finish a red build | PR8, QA4 |
| T9 | Runaway loop or cost | Retry loops, wide subagent fan-out | QA12, CO6, PR7 |
| T10 | Data leaving the machine | Telemetry, webhooks, pasted content | IN7, QA18 |

## The six layers

| Layer | What it does | Can the model bypass it? |
| --- | --- | --- |
| 1. Guides | Advice: the goal lock, scoped rules, the untrusted-content rule | Yes. Never the only defence for a safety rule |
| 2. Tool surface | The agent and each subagent see only the tools the task needs | No: a tool it cannot see cannot be called |
| 3. Permission policy | The agent enforces deny rules for secret paths and dangerous commands, and narrow allowlists | Only through a bug in the agent |
| 4. Hooks | Our script runs before a tool call and can veto it, by pattern | No, where the hook fires |
| 5. Sandbox | The operating system stops writes outside the workspace and hosts off the allowlist | No |
| 6. Sensors and gates | After the action: checks, two-axis review, CI, a human signing off | No |

Under all six, a clean environment: a secret that is not in the agent's reach cannot leak.

## Rules for building a guard

1. **Match patterns, not descriptions.** A regular expression catches the variants of a dangerous command that a sentence misses.
2. **Test both directions (QA13).** At least one case the guard must block and one it must allow. A guard tested only for blocking drifts toward blocking everything, and then people switch it off.
3. **Fail with the fix.** The block message says what was blocked, why, and what to do instead: it lands in the agent's context and steers the next step.
4. **Quiet when green.** A passing check prints almost nothing; a failing one prints everything needed to correct it.
5. **Never end a policy in "ask me".** Most prompts get approved by habit. Deny what must never happen, allow what is safe, and ask only at the human gates below.
6. **Know where the hook fires.** A hook may fire for shell commands and not for file edits or MCP calls: test each tool type. Where the agent has no hook for an action, the git pre-commit hook is the backstop: it fires whichever agent wrote the change.
7. **Adapters are agent-specific.** Deny rules, hooks and the sandbox differ per agent (Claude Code: `permissions.deny` in its `settings.json`, and its pre-tool hooks). Look up that agent's current documentation before writing one, and record the version checked in an ADR.
8. **From L2, protect the guards (PR8) and give each an expiry condition (PR9).** Checks, hooks, CI configuration and `GOAL.md` sit outside the agent's write set; each guard records the incident it exists for and when it can be removed. From L3, log every block locally (QA18).

## Autonomy tiers and human gates

PR7 records what the agent may do without asking. The default is the permission mode the user already works in: never ask them to give up an auto mode, and do not hold a tier back until other parts exist. "Safest with" names the parts that make a tier safer; propose each when its own trigger has fired.

| Tier | The agent may | Safest with |
| --- | --- | --- |
| A. Read-only | Read, search, plan | Nothing |
| B. Ask on write | Edit files and run commands, each approved | PR1 |
| C. Auto inside the sandbox | Edit and run freely inside the workspace; no network beyond the allowlist | IN6, IN7, QA1, PR8 |
| D. Auto with pull requests | As C, plus push branches and open pull requests | C, plus IN4, QA5 |

Human gates hold at every tier. A person approves: anything irreversible, anything outside the workspace, schema migrations, public API changes, infrastructure commands, dependency additions, changes to protected paths, and any amendment to the goal.

## Guardrail parts by level

| Level | May be proposed |
| --- | --- |
| L0 | PR1 goal lock; QA1 one red-capable check; the always-on rule to confirm before destructive actions |
| L1 | PR6 destructive-action guards; PR7 autonomy tier; IN6 deny rules and secret paths; QA2 pre-commit; QA13 guard tests; KN8 failure log |
| L2 | PR8 protected paths; PR9 expiry conditions; IN7 sandbox and egress allowlist; IN8 untrusted-content rule; IN9 dependency guard |
| L3 | PR5 drift hook; IN10 MCP and skill pinning; CO8 tool-surface limits |
| L4 | IN5 permissions and secrets policy; IN11 worktree per task; QA22 incident runbook and kill switch |
