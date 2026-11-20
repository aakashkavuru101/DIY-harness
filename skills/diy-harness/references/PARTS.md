# The parts catalogue

Every part a harness may contain: its ID, the minimum level at which it may be proposed, the trigger that earns it, and its proof: the check, test or eval that goes red without it. A part whose trigger has not fired is not proposed, whatever the level. When a trigger counts as fired is in [LEVELS.md](LEVELS.md), under "Minimal by default".

## Protocol

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| PR1 | Goal lock: `.harness/GOAL.md` | L0 | Always built | Eval: an off-goal request gets a `Drift:` reply |
| PR2 | Navigation pointers: `AGENTS.md`, with `CLAUDE.md` as a symlink | L0 | Always built | Check: every pointer resolves; file stays under the line budget |
| PR3 | Working agreement: equals, stage gates | L1 | Work spans more than one session or person | Eval: agent asks before a decision, never before a fact |
| PR4 | State handoff: `.harness/STATE.md` | L1 | Work spans more than one session | Eval: a fresh session resumes from the file alone |
| PR5 | Mid-session drift hook | L3 | Drift observed despite PR1 | Hook test: goal re-injected; drift flagged mid-task |
| PR6 | Destructive-action guardrails (force push, mass delete, schema drop) | L1 | Risky repo, or a destructive action observed | Test: blocked command is refused; safe command allowed |
| PR7 | Autonomy tier: what the agent may do without asking | L1 | The goal's autonomy line was broken, or the user asks for enforcement | Test: an action above the tier is stopped |
| PR8 | Protected harness paths: checks, hooks, CI and `GOAL.md` outside the agent's write set | L2 | The agent edited a test or check to reach green | Test: an edit to a protected path is blocked |
| PR9 | Expiry condition on every control | L2 | Always on from L2 | Check: every part in `SPEC.md` has an expiry line |

## Cognition

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| CO1 | Always-on build rules (ponytail) | L0 | Always on (user can switch off) | Eval: reuse beats new code on a seeded task |
| CO2 | Always-on output rules (i-have-adhd) | L0 | Always on (user can switch off) | Eval: first line is an action; state restated |
| CO3 | Project skills for recurring procedures | L2 | The same procedure explained to the agent twice | Eval: the procedure runs from its trigger word |
| CO4 | Model and effort routing | L3 | Cost or quality problem across a task mix | Eval: routed run meets quality at lower cost |
| CO5 | Parallel implementer subagents over a ticket graph | L4 | Serial build is the bottleneck on multi-ticket specs | Test: ready tickets run in parallel on one integration branch |
| CO6 | Context policy: phase artefacts, fresh context per ticket, subagent isolation, capped tool output | L2 | Quality fell late in long sessions | Eval: a late-session task matches fresh-session quality |
| CO7 | Path-scoped instructions | L2 | Root steering file over budget, or rules irrelevant to most tasks | Check: root under budget; a scoped rule loads only on its paths |
| CO8 | Tool-surface limits per task and per subagent | L3 | Wrong tool chosen, or a subagent held tools it never needed | Test: the reviewer subagent has read-only tools |

## Knowledge

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| KN1 | Glossary: `GLOSSARY.md` | L1 | First term conflict or overloaded word | Eval: agent uses the canonical term |
| KN2 | Decision records: `docs/adr/` | L1 | First hard-to-reverse decision | Check: ADR exists for each decision marked as one |
| KN3 | Reference docs behind pointers | L2 | Agent lacked a convention it could not look up | Eval: the agent reaches the doc from its pointer |
| KN4 | Spec and tickets flow for product work | L2 | Multi-session product builds | Check: every ticket names its spec and blockers |
| KN5 | Debt ledger: `shortcut:` comments and `ponytail-debt` | L2 | A deliberate shortcut was taken | Check: ledger lists every `shortcut:` comment |
| KN6 | Cited research notes: `.harness/research/` | L2 | A decision needs external facts | Check: every claim carries a source |
| KN7 | Cross-project memory | L4 | The same lesson relearned in two projects | Eval: the lesson applies in a new project |
| KN8 | Failure log: incident, root cause, control added | L1 | The first observed failure | Check: every control links to an entry |
| KN9 | Doc-gardening pass that flags stale docs and pointers | L3 | A doc contradicted the code | Check: a planted stale pointer is flagged |

## Integration

| ID | Part | Min | Earned by | Proved by |
| --- | --- | --- | --- | --- |
| IN1 | CLI inventory as pointers in `AGENTS.md` | L1 | Agent missed a tool the repo already has | Eval: agent uses the listed CLI |
| IN2 | Human-only step scripts (`wizard`) | L2 | A human-only step blocked the agent or repeated | Test: the script captures each value it needs |
| IN3 | MCP servers, configured per agent | L3 | A system the work needs has no usable CLI | Test: the tool call succeeds in each agent |
| IN4 | CI and pull-request flow | L2 | Changes go through review by others | Check: CI runs the check command on every push |
| IN5 | Permissions and secrets policy | L4 | Team or client data in reach of the agent | Test: a denied action is refused in each agent |
| IN6 | Deny rules and secret-path protection | L1 | Secrets or credentials reachable from the repo or home directory | Test: a secret read is denied; a normal read is allowed |
| IN7 | OS sandbox with a network egress allowlist | L2 | The user asks for one, or a command the agent ran unasked did harm; the permission mode alone does not earn it | Test: a write outside the workspace and a call to an unlisted host both fail |
| IN8 | Untrusted-content rule: issues, comments, web pages and tool results are data | L2 | The agent reads content the user did not write | Eval: a planted instruction is flagged, not followed |
| IN9 | Dependency guard: no install without approval, lockfile, release cooldown | L2 | The agent added or invented a package | Test: an unapproved install is blocked |
| IN10 | MCP and skill allowlist with version and description pinning | L3 | Any third-party MCP server or skill is installed | Check: a changed description fails the pin |
| IN11 | Git worktree per task | L4 | Parallel agents (with CO5) | Test: two tasks do not collide |

## Quality

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
