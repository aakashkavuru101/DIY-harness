# Harness Theory and Levels

Document 02 of 09 · Draft v0.3 · 2026-11-16

> This is the knowledge DIY-harness reasons from. Claude Code ships its content inside the parent command as `references/HARNESS.md`, `references/LEVELS.md` and `references/PARTS.md` (document 05 has the layout). The command reads these files when it designs; it does not improvise what a harness is.

## 1. What a harness is

A **model** predicts text. An **agent** is a model in a loop with tools. A **harness** is everything around that loop that decides what the agent sees, what it may do, how it thinks about this work, and how anyone knows its output is right.

The same model in two harnesses behaves like two different engineers. Most failures people blame on the model (skipping the goal, inventing APIs, bloated diffs, forgetting yesterday's decision) are harness failures: the agent lacked a pointer, a check, a fact, or a stop.

A harness is **per project and per goal**. It lives in the project's repository, in plain files, so it travels with the code and works in any agent that reads those files.

### What a harness is not

- Not an agent. DIY-harness builds the environment first, and agents come later, inside it.
- Not a framework that owns the process. Every part is a small file the user can read, edit or delete.
- Not a prompt. Prompts are one part type (steering, skills). Checks, knowledge and integrations matter as much.

## 2. The five planes

Every harness part belongs to exactly one plane. The planes come from Aakash's harness build brief v0.1.

| Plane | Question it answers | Typical parts |
| --- | --- | --- |
| **Protocol** | How do the agent and the human work together, and what stops drift? | Goal lock, navigation file, working agreement, state handoff, guardrails |
| **Cognition** | How does the agent think about this work? | Always-on rules, project skills, model and effort routing, subagent orchestration |
| **Knowledge** | What does the agent know without asking? | Glossary, ADRs, reference docs, spec and tickets, debt ledger, memory |
| **Integration** | What can the agent reach? | CLIs, human-only step scripts, MCP servers, CI, permissions and secrets |
| **Quality** | How does anyone know the work is right? | Check command, pre-commit and CI guardrails, TDD seams, review, standards, retro, evals, telemetry |

![The five planes around the agent loop](diagrams/02-five-planes.svg)

Guardrails (document 07) and operations (document 08) are not extra planes. They are cross-cutting views: each guardrail or ops part sits in one of the five planes above.

### The two loads

Every part spends one of two budgets (from Matt Pocock's `writing-for-agents`):

- **Context load**: tokens and attention in the agent's window. Anything always loaded (steering lines, skill descriptions, always-on rules) costs on every turn.
- **Cognitive load**: what the human must remember. Every command, file or convention the human must know about.

DIY-harness keeps both low: steering files hold pointers, not content; mechanical rules become checks, not prose; one command replaces many.

### Mechanical versus judgement

A rule is **mechanical** when a script can decide it (a banned API, a file location, an import shape). Mechanical rules become deterministic checks. A rule is a **judgement call** when only a reader can decide it (naming, cross-file consistency). Judgement rules go to `CODING_STANDARDS.md`, which the reviewer reads, not the implementer.

## 3. Levels L0 to L4

![Levels L0 to L4](diagrams/03-levels.svg)

A level is a **ceiling**, not a package. It sets which parts the command may propose. Within the ceiling, a part is still built only when its trigger has fired (an observed failure or a goal line). Levels are cumulative: L2 includes everything L1 may contain.

| Level | Name | For | Setup with the user | Ceremony per change |
| --- | --- | --- | --- | --- |
| **L0** | Seed | A script, a spike, a one-session task | About 15 minutes | Goal, build, one check |
| **L1** | Guarded | A solo repo worked across several sessions | About 1 hour | Goal, test at agreed seams, review, commit |
| **L2** | Structured | Multi-week feature work, a small team | Half a day | Spec, tickets, build loop, CI, retro |
| **L3** | Instrumented | Client delivery, cost-sensitive or risky work | 1 to 2 days | L2 plus mid-session hooks, evals, routing |
| **L4** | Orchestrated | Production, several agents, organisation-wide use | Several days, then ongoing | L3 plus parallel agents, eval release gates, permissions |

### Process versus parts

Two things are easy to confuse, so keep them apart:

- **The build process** is how `/diy-harness` builds a harness: goal, spec, tickets, TDD, review, commit (document 04). It runs at every level, scaled down at L0, because building the harness is itself work that must stay on goal.
- **The parts** are what the finished harness gives the user's ongoing work (the catalogue below). Levels govern parts, not the process. For example, part KN4 is a spec-and-tickets flow for the user's *product* work; it is separate from the `.harness/SPEC.md` and tickets the build process uses to build the harness.

### How the command picks a level

1. After the goal is locked (stage S1), list the observed failures and goal lines.
2. Map each to the parts that answer it (catalogue below). The highest **minimum level** among the needed parts is the proposed level.
3. Apply the ponytail ladder to each part: does it need to exist, is it already in the repo, can an existing tool do it? Drop what fails the ladder.
4. Propose the level with a one-line reason per part. The user decides, and may go higher or lower.

### When to change level

- **Level up** when a retro (stage S6) finds a failure whose answering part sits above the current level.
- **Level down** when a retro finds parts that are no-ops (they never changed the agent's behaviour). Delete them.
- A level change is a decision: the command proposes it and the user rules.

### What each level contains

**L0 Seed.** Goal lock, navigation pointers, always-on build and output rules, one check command that goes red. Stage S4 (slicing) is skipped: the build is one ticket.

**L1 Guarded.** Adds the working agreement, state handoff, glossary, ADRs, a failure log, a CLI inventory, an autonomy tier, deny rules for secrets and destructive commands with tests in both directions, a pre-commit guardrail, TDD at agreed seams, two-axis review per change, and a baseline audit when the repo already has code.

**L2 Structured.** Adds the spec and tickets flow, reference docs behind pointers, project skills for recurring procedures, the debt ledger, human-only step scripts, CI with the check command, coding standards for judgement calls, custom deterministic checks, and the retro loop with transcript review. Also from L2: a sandbox with an egress allowlist, the untrusted-content rule, a dependency guard, protected harness paths, expiry conditions, a context policy, path-scoped instructions, and app-level verification.

**L3 Instrumented.** Adds a mid-session drift hook, model and effort routing, MCP servers where no CLI exists (allowlisted and pinned), tool-surface limits, local session telemetry and cost tracking, regression and capability eval suites with trajectory checks, the model and agent upgrade protocol, ablation and pruning reviews, and doc-gardening.

**L4 Orchestrated.** Adds parallel implementer subagents over a ticket graph with a worktree per task, cross-project memory, a permissions and secrets policy, an eval release gate in CI with calibrated judges, an incident runbook and kill switch, and a verified matrix of every part in every agent the goal names.

## 4. The parts catalogue

Each part has an ID, its plane, the minimum level at which it may be proposed, the trigger that earns it, and the proof that shows it works (a check or eval that goes red without it). Claude Code turns each row into an entry in `references/PARTS.md` with: what it is, where it lives in the user's project, the adapter per agent if any, and how to build it.

### Protocol

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| PR1 | Goal lock: `.harness/GOAL.md` | L0 | Always built | Eval: an off-goal request gets a `Drift:` reply |
| PR2 | Navigation pointers: `AGENTS.md`, with `CLAUDE.md` as a symlink | L0 | Always built | Check: every pointer resolves; file stays under the line budget |
| PR3 | Working agreement: equals, stage gates | L1 | Work spans more than one session or person | Eval: agent asks before a decision, never before a fact |
| PR4 | State handoff: `.harness/STATE.md` | L1 | Work spans more than one session | Eval: a fresh session resumes from the file alone |
| PR5 | Mid-session drift hook | L3 | Drift observed despite PR1 | Hook test: goal re-injected; drift flagged mid-task |
| PR6 | Destructive-action guardrails (force push, mass delete, schema drop) | L1 | Risky repo, or a destructive action observed | Test: blocked command is refused; safe command allowed |
| PR7 | Autonomy tier: what the agent may do without asking | L1 | The agent is given more than read-and-ask | Test: an action above the tier is stopped |
| PR8 | Protected harness paths: checks, hooks, CI and `GOAL.md` outside the agent's write set | L2 | The agent edited a test or check to reach green | Test: an edit to a protected path is blocked |
| PR9 | Expiry condition on every control | L2 | Always on from L2 | Check: every part in `SPEC.md` has an expiry line |

### Cognition

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| CO1 | Always-on build rules (ponytail) | L0 | Always on (user can switch off) | Eval: reuse beats new code on a seeded task |
| CO2 | Always-on output rules (i-have-adhd) | L0 | Always on (user can switch off) | Eval: first line is an action; state restated |
| CO3 | Project skills for recurring procedures | L2 | The same procedure explained to the agent twice | Eval: the procedure runs from its trigger word |
| CO4 | Model and effort routing (link to Shogun) | L3 | Cost or quality problem across a task mix | Eval: routed run meets quality at lower cost |
| CO5 | Parallel implementer subagents over a ticket graph | L4 | Serial build is the bottleneck on multi-ticket specs | Test: ready tickets run in parallel on one integration branch |
| CO6 | Context policy: phase artefacts, fresh context per ticket, subagent isolation, capped tool output | L2 | Quality fell late in long sessions | Eval: a late-session task matches fresh-session quality |
| CO7 | Path-scoped instructions | L2 | Root steering file over budget, or rules irrelevant to most tasks | Check: root under budget; a scoped rule loads only on its paths |
| CO8 | Tool-surface limits per task and per subagent | L3 | Wrong tool chosen, or a subagent held tools it never needed | Test: the reviewer subagent has read-only tools |

### Knowledge

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| KN1 | Glossary: `GLOSSARY.md` | L1 | First term conflict or overloaded word | Eval: agent uses the canonical term |
| KN2 | Decision records: `docs/adr/` | L1 | First hard-to-reverse decision | Check: ADR exists for each decision marked as one |
| KN3 | Reference docs behind pointers | L2 | Agent lacked a convention it could not look up | Eval: the agent reaches the doc from its pointer |
| KN4 | Spec and tickets flow for product work (`docs/specs/`, `docs/tickets/` or the team's tracker) | L2 | Multi-session product builds | Check: every ticket names its spec and blockers |
| KN5 | Debt ledger: `shortcut:` comments and `ponytail-debt` | L2 | A deliberate shortcut was taken | Check: ledger lists every `shortcut:` comment |
| KN6 | Cited research notes: `.harness/research/` | L2 | A decision needs external facts | Check: every claim carries a source |
| KN7 | Cross-project memory | L4 | The same lesson relearned in two projects | Eval: the lesson applies in a new project |
| KN8 | Failure log: incident, root cause, control added | L1 | The first observed failure | Check: every control links to an entry |
| KN9 | Doc-gardening pass that flags stale docs and pointers | L3 | A doc contradicted the code | Check: a planted stale pointer is flagged |

### Integration

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| IN1 | CLI inventory as pointers in `AGENTS.md` | L1 | Agent missed a tool the repo already has | Eval: agent uses the listed CLI |
| IN2 | Human-only step scripts (`wizard`) | L2 | A human-only step blocked the agent or repeated | Test: the script captures each value it needs |
| IN3 | MCP servers, configured per agent | L3 | A system the work needs has no usable CLI | Test: the tool call succeeds in each agent |
| IN4 | CI and pull-request flow | L2 | Changes go through review by others | Check: CI runs the check command on every push |
| IN5 | Permissions and secrets policy | L4 | Team or client data in reach of the agent | Test: a denied action is refused in each agent |
| IN6 | Deny rules and secret-path protection | L1 | Secrets or credentials reachable from the repo or home directory | Test: a secret read is denied; a normal read is allowed |
| IN7 | OS sandbox with a network egress allowlist | L2 | The agent runs commands without per-command approval | Test: a write outside the workspace and a call to an unlisted host both fail |
| IN8 | Untrusted-content rule: issues, comments, web pages and tool results are data | L2 | The agent reads content the user did not write | Eval: a planted instruction is flagged, not followed |
| IN9 | Dependency guard: no install without approval, lockfile, release cooldown | L2 | The agent added or invented a package | Test: an unapproved install is blocked |
| IN10 | MCP and skill allowlist with version and description pinning | L3 | Any third-party MCP server or skill is installed | Check: a changed description fails the pin |
| IN11 | Git worktree per task | L4 | Parallel agents (with CO5) | Test: two tasks do not collide |

### Quality

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| QA1 | One check command that goes red | L0 | Always built | Check: the command fails on a seeded break |
| QA2 | Pre-commit guardrail running QA1 | L1 | A broken commit landed | Test: a failing commit is blocked |
| QA3 | TDD at agreed seams (`tdd`) | L1 | Non-trivial logic in scope | Check: each agreed seam has a test |
| QA4 | Two-axis review per change (`code-review`) | L1 | Work goes beyond one-off | Eval: a seeded spec miss and standard breach are both reported |
| QA5 | CI job running QA1 | L2 | More than one person or machine | Check: CI fails on a seeded break |
| QA6 | `CODING_STANDARDS.md`, judgement calls only | L2 | The reviewer missed a judgement issue | Eval: the reviewer cites the standard |
| QA7 | Custom deterministic checks | L2 | A mechanical mistake happened twice | Check: the check fails on the mistake |
| QA8 | Retro loop (stage S6) | L2 | Always on from L2 | Check: every finding is a ticket or rejected |
| QA9 | Behaviour evals for the harness: `.harness/evals/` | L3 | A prose part (steering, skill) needs proof it changes behaviour | Eval: candidate beats baseline on the rubric |
| QA10 | Eval release gate in CI | L4 | Harness changes ship to other people | Check: CI blocks a change that fails the gate |
| QA11 | Baseline repo audit (`ponytail-audit`) | L1 | The repo already has code | Check: ranked findings exist before design |
| QA12 | Local-only cost and token tracking | L3 | Cost is in the goal | Check: nothing is sent off the machine |
| QA13 | Guard tests in both directions | L1 | Any guard exists | Check: each guard has a must-block and a must-allow test |
| QA14 | App-level verification: the agent starts the app, drives it and reads logs | L2 | "Done" was claimed but behaviour was broken | Eval: a bug is reproduced and re-verified by running |
| QA15 | Regression eval suite, run in batches | L3 | A harness change broke something else | Check: suite stays near 100%; trend tracked |
| QA16 | Capability evals drawn from real failures | L3 | A behaviour the agent cannot yet do reliably | Eval: pass rate climbs across changes |
| QA17 | Trajectory checks on tool calls and file changes | L3 | Right answer by the wrong route (tests skipped) | Eval: the asserted step is present |
| QA18 | Session telemetry in local JSON lines; optional OpenTelemetry export | L3 | Nobody can say what happened, or whether a change helped | Check: every session has a record; nothing exported unless opted in |
| QA19 | Model and agent upgrade protocol | L3 | A new model or agent version | Check: a regression run is recorded before the pin moves |
| QA20 | Ablation and pruning review | L3 | The harness has grown, or the model improved | Check: every part has a last-shown-useful date |
| QA21 | Transcript review cadence | L2 | Always on from L2, with the retro | Check: each retro cites transcripts |
| QA22 | Incident runbook and kill switch | L4 | Other people use the harness | Test: the kill switch stops autonomy in each agent |
| QA23 | Judge calibration against human grading | L4 | Model-graded evals gate releases | Check: agreement is measured and recorded |

## 5. Portability rule for every part

The harness must run in every agent the goal names. Every part has one agent-neutral source and, only where needed, a thin adapter:

- Steering: `AGENTS.md` is the source; `CLAUDE.md` is a symlink to it.
- Project skills: `.agents/skills/<name>/SKILL.md`; `.claude/skills` is a symlink to it.
- Checks: plain scripts wired into git hooks and CI, so they fire whichever agent wrote the code.
- Hooks, MCP configuration and permissions are agent-specific adapters. Before writing one, look up that agent's current documentation and record the version checked in an ADR.
