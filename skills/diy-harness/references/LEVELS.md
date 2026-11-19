# Levels L0 to L4

A level is a **ceiling**, not a package. It sets which parts may be proposed. Within the ceiling, a part is still built only when its trigger has fired: an observed failure or a goal line. Levels are cumulative: L2 may contain everything L1 may.

| Level | Name | For | Setup with the user | Ceremony per change |
| --- | --- | --- | --- | --- |
| **L0** | Seed | A script, a spike, a one-session task | About 15 minutes | Goal, build, one check |
| **L1** | Guarded | A solo repo worked across several sessions | About 1 hour | Goal, test at agreed seams, review, commit |
| **L2** | Structured | Multi-week feature work, a small team | Half a day | Spec, tickets, build loop, CI, retro |
| **L3** | Instrumented | Client delivery, cost-sensitive or risky work | 1 to 2 days | L2 plus mid-session hooks, evals, routing |
| **L4** | Orchestrated | Production, several agents, organisation-wide use | Several days, then ongoing | L3 plus parallel agents, eval release gates, permissions |

Levels govern the parts the finished harness gives the user's ongoing work. They do not govern the build process (goal, spec, tickets, review, commit), which runs at every level, scaled down at L0.

## How to pick a level

1. List the goal lines and the observed failures in `.harness/GOAL.md`.
2. Map each to the parts that answer it ([PARTS.md](PARTS.md)). A part counts only when its "Earned by" trigger has fired.
3. Apply the ponytail ladder to each part: does it need to exist, is it already in the repo, can an existing tool do it? Drop what fails.
4. The proposed level is the highest minimum level among the parts that remain. Nothing remains above L0: propose L0.

   Minimal by default: propose the lowest level that meets the goal. A trigger has fired only when a failure was observed, or a goal line cannot be met by anything at a lower level. A constraint the agent can simply follow (keep the changelog current, use British spelling) needs no part until it has been broken once. The same holds for a rule the goal states for the agent, such as an autonomy tier or a "never" line: at L0 the goal and the steering pointers carry it, and it earns an enforcing part of its own (PR7, PR6) only once it has been broken, or when the user asks for enforcement. In doubt, propose the lower level and name the failure that would earn the next one: a level goes up later, through a retro.

   Safety does not wait for a failure: a safety fact found in the repo or in the goal is a fired trigger for the part that answers it. Three things count: a secret or credential in reach (IN6); a destructive command the work really needs, such as a force push, a mass delete or a schema drop (PR6); and an autonomy tier in the goal that lets the agent run commands without asking each time, the tests included (PR7 and the sandbox, IN7, so at least L2). An autonomy line that only lets the agent edit files, that has it ask before every command, or that says nothing about running commands, is a stated rule as above. The ladder in step 3 still applies: it can show that a part is already there (a sandbox already switched on), never that a safety fact needs no part.
5. Propose it with one line per part saying what the part answers. The user decides, and may go higher or lower.

## What each level may contain

- **L0 Seed.** Goal lock, navigation pointers, always-on build and output rules, one check command that goes red. Stage S4 is skipped: the build is one ticket.
- **L1 Guarded.** Adds the working agreement, state handoff, glossary, ADRs, a failure log, a CLI inventory, an autonomy tier, deny rules for secrets and destructive commands with tests in both directions, a pre-commit guardrail, TDD at agreed seams, two-axis review per change, and a baseline audit when the repo already has code.
- **L2 Structured.** Adds the spec and tickets flow, reference docs, project skills, the debt ledger, human-only step scripts, CI, coding standards, custom checks, the retro loop, a sandbox with an egress allowlist, the untrusted-content rule, a dependency guard, protected harness paths, expiry conditions, a context policy, path-scoped instructions and app-level verification.
- **L3 Instrumented.** Adds a mid-session drift hook, model and effort routing, MCP servers where no CLI exists, tool-surface limits, local telemetry and cost tracking, eval suites with trajectory checks, the upgrade protocol, pruning reviews and doc-gardening.
- **L4 Orchestrated.** Adds parallel implementer subagents with a worktree per task, cross-project memory, a permissions and secrets policy, an eval release gate in CI, an incident runbook and kill switch, and a verified matrix of every part in every agent.

## When to change level

- **Up:** a retro finds a failure whose answering part sits above the current level.
- **Down:** a retro finds parts that never changed the agent's behaviour. Delete them.
- A level change is a decision: propose it, and the user rules.
