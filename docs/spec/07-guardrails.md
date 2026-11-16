# Guardrails

Document 07 of 09 · Draft v0.3 · 2026-11-16

> What can go wrong when an agent works in a repository, the layers that stop it, and the guardrail parts `/diy-harness` can build at each level. Guardrails here cover two things: staying on the goal, and staying safe. Part IDs refer to the catalogue in document 02.

## 1. Why guardrails are a layer stack, not a rule list

Three facts from 2026 practice shape this document:

- **A written rule is advice, not a control.** A model can ignore prose. One survey of public steering files found that only a small fraction of the security rules written in them were backed by anything that enforces them. In DIY-harness, every safety rule in prose must point at the control that enforces it, or be deleted.
- **A coding agent meets all three conditions for data theft at once:** it can read private data, it reads content other people wrote, and it can send data out. You cannot remove the first, so the harness limits the other two.
- **The agent's own safety features can fail.** Vulnerabilities disclosed this year were in the vendors' permission prompts and deny-rule engines themselves. So no single layer is trusted; each one assumes the layer before it may slip.

## 2. Threat model

Each row is a failure the harness should stop, where it enters, and the parts that answer it.

| # | Threat | How it enters | Stopped by |
| --- | --- | --- | --- |
| T1 | Goal drift: the agent does work nobody asked for | A long session, a tempting side task | PR1, PR3, PR5 |
| T2 | Destructive action: force push, mass delete, schema drop, infrastructure destroy | A plausible-looking command mid-task | PR6, PR7, IN7 |
| T3 | Secret exposure: keys, tokens, `.env`, SSH keys read or printed | File reads, environment variables, logs | IN6, IN7 |
| T4 | Injected instructions in content the user did not write | Issues, pull-request comments, READMEs, web pages, tool results | IN8, IN7, PR7 |
| T5 | Poisoned or silently changed tool descriptions | A third-party MCP server, at install or after an update | IN10, IN3 |
| T6 | Malicious skill, plugin or hook | Public skill marketplaces and repos | IN10 |
| T7 | Bad dependency: invented, squatted or freshly compromised package | The agent runs an install | IN9 |
| T8 | The agent weakens its own checks: edits a test, a hook or the goal to get to green | Pressure to finish a red build | PR8, QA4 |
| T9 | Runaway loop or cost | Retry loops, wide subagent fan-out | QA12, CO6, PR7 |
| T10 | Data leaving the machine | Telemetry, webhooks, pasted content | IN7, QA18 (local by default) |

## 3. The six layers

![The six guardrail layers, from advice to enforcement](diagrams/05-guardrail-layers.svg)

| Layer | Kind | What it does | Can the model bypass it? |
| --- | --- | --- | --- |
| 1. Guides | Advice | Goal lock, scoped rules, the untrusted-content rule | Yes. Never the only defence for a safety rule |
| 2. Tool surface | Structure | The agent and each subagent see only the tools the task needs; a reviewer gets read-only tools | No: a tool it cannot see cannot be called |
| 3. Permission policy | Enforced by the agent | Deny rules for secret paths and dangerous commands; narrow allowlists | Only through a bug in the agent |
| 4. Hooks | Enforced by our code | A script runs before a tool call and can veto it; pattern-based, deterministic | No, where the hook fires (see section 6) |
| 5. Sandbox | Enforced by the operating system | The process cannot write outside the workspace or reach hosts off the allowlist | No |
| 6. Sensors and gates | After the action | Checks, two-axis review, CI; a human signs off high-impact changes | No |

Underneath all six: **a clean environment.** A secret that is not on the machine, or not in the agent's reach, cannot leak. Prefer short-lived, narrowly scoped credentials for anything the agent can touch.

## 4. Rules for building a guard

1. **Match patterns, not descriptions.** A regular expression catches the variants of a dangerous command that a sentence misses.
2. **Test both directions (QA13).** Every guard ships with at least one case it must block and one it must allow. A guard tested only for blocking drifts toward blocking everything, and then people switch it off.
3. **Fail with the fix.** A blocked action returns a message saying what was blocked, why, and what to do instead. That message lands in the agent's context and steers the next step.
4. **Quiet when green.** A passing check prints almost nothing. A failing one prints everything needed to correct it.
5. **Do not end a policy in "ask me".** Most prompts get approved by habit. Deny what must never happen; allow what is safe; ask only at the human gates in section 5.
6. **Protect the guards (PR8).** Checks, hooks, CI configuration and `GOAL.md` sit outside the agent's write set. A change to any of them fails and waits for a person.
7. **Give every guard an expiry condition (PR9).** Record the incident it exists for and the condition under which it can be removed.
8. **Log every block** to local telemetry (QA18), so a retro can see which guards fire, and which never do.

## 5. Autonomy tiers and human gates

PR7 sets, per project, what the agent may do without asking. The command proposes the lowest tier that meets the goal.

| Tier | The agent may | Needs first |
| --- | --- | --- |
| A. Read-only | Read, search, plan | Nothing |
| B. Ask on write | Edit files and run commands, each approved | PR1 |
| C. Auto inside the sandbox | Edit and run freely inside the workspace; no network beyond the allowlist | IN6, IN7, QA1, PR8 |
| D. Auto with pull requests | As C, plus push branches and open pull requests | C, plus IN4, QA5 |

**Human gates** apply at every tier. A person approves: anything irreversible, anything outside the workspace, schema migrations, public API changes, infrastructure commands, dependency additions, changes to protected paths, and any amendment to the goal. Routine decisions proceed on recorded defaults.

## 6. Adapters per agent

Layers 3 to 5 are agent-specific. The table lists the mechanism to look for; Claude Code confirms each against current documentation before building (document 05 section 6) and records the version checked.

| Layer | Claude Code | Codex |
| --- | --- | --- |
| 3. Permission policy | `permissions.deny` and allow rules in `settings.json` (user and project) | Approval policy and rules in Codex configuration |
| 4. Hooks | `PreToolUse` and related hooks | Hooks exist; confirm which tool types fire them |
| 5. Sandbox | Built-in sandbox on OS primitives | Built-in sandbox modes |

**Known gaps to test for, not assume away:**

- A hook may fire for shell commands but not for file-edit patches or MCP tool calls. Test each tool type in each agent.
- Hooks start after the agent process does. Anything that acts at start-up (environment variables, project settings loaded on open) needs a wrapper or a clean environment, not a hook.
- Where an agent has no hook for an action, the git pre-commit hook and CI are the backstop: they fire whichever agent wrote the change.

## 7. Guardrail parts by level

| Level | Guardrail parts the command may propose |
| --- | --- |
| L0 | PR1 goal lock; QA1 one red-capable check; the always-on rule to confirm before destructive actions |
| L1 | PR6 destructive-action guards; PR7 autonomy tier; IN6 deny rules and secret paths; QA2 pre-commit; QA13 guard tests; KN8 failure log |
| L2 | PR8 protected paths; PR9 expiry conditions; IN7 sandbox and egress allowlist; IN8 untrusted-content rule; IN9 dependency guard |
| L3 | PR5 drift hook; IN10 MCP and skill pinning; CO8 tool-surface limits |
| L4 | IN5 permissions and secrets policy; IN11 worktree per task; QA22 incident runbook and kill switch |

## 8. Where guardrails enter the stage flow

- **S1 Lock:** the grilling asks what must never happen in this repo, what data is in reach, and which autonomy tier the user wants.
- **S2 Assess:** the audit lists secrets in reach, existing deny rules, hooks, sandbox state and installed MCP servers and skills.
- **S3 Design:** one grilling round walks threats T1 to T10 and proposes only the parts whose threat is real for this repo.
- **S5 Build:** each guard is built test-first, both directions, then reviewed.
- **S6 Retro:** read the block log. A guard that never fired is a pruning candidate; a block the user overrode twice is a false positive to fix.

## 9. DIY-harness's own supply chain

DIY-harness vendors three third-party repositories, so it is itself a supply-chain risk and holds itself to IN10:

- Engine code is pinned to commits. A pin moves only after a human reads the diff from `scripts/sync-upstream.sh` and the evals pass.
- Hooks are short, readable scripts with no network calls. `check.sh` fails if any file under `hooks/` references a network API.
- Nothing is fetched at run time. No telemetry leaves the machine.

## 10. What guardrails are not

Evals measure behaviour; they are not a security control. A passing eval suite says the agent usually behaves, not that it cannot misbehave. Only layers 2 to 5 make an action impossible.
