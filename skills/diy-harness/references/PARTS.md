# The parts catalogue

Every part a harness may contain: its ID, the minimum level at which it may be proposed, and the trigger that earns it. A part whose trigger has not fired is not proposed, whatever the level ([LEVELS.md](LEVELS.md)).

## Protocol

| ID | Part | Min | Earned by |
| --- | --- | --- | --- |
| PR1 | Goal lock: `.harness/GOAL.md` | L0 | Always built |
| PR2 | Navigation pointers: `AGENTS.md`, with `CLAUDE.md` as a symlink | L0 | Always built |
| PR3 | Working agreement: equals, stage gates | L1 | Work spans more than one session or person |
| PR4 | State handoff: `.harness/STATE.md` | L1 | Work spans more than one session |
| PR5 | Mid-session drift hook | L3 | Drift observed despite PR1 |
| PR6 | Destructive-action guardrails (force push, mass delete, schema drop) | L1 | Risky repo, or a destructive action observed |
| PR7 | Autonomy tier: what the agent may do without asking | L1 | The agent is given more than read-and-ask |
| PR8 | Protected harness paths: checks, hooks, CI and `GOAL.md` outside the agent's write set | L2 | The agent edited a test or check to reach green |
| PR9 | Expiry condition on every control | L2 | Always on from L2 |

## Cognition

| ID | Part | Min | Earned by |
| --- | --- | --- | --- |
| CO1 | Always-on build rules (ponytail) | L0 | Always on (user can switch off) |
| CO2 | Always-on output rules (i-have-adhd) | L0 | Always on (user can switch off) |
| CO3 | Project skills for recurring procedures | L2 | The same procedure explained to the agent twice |
| CO4 | Model and effort routing | L3 | Cost or quality problem across a task mix |
| CO5 | Parallel implementer subagents over a ticket graph | L4 | Serial build is the bottleneck on multi-ticket specs |
| CO6 | Context policy: phase artefacts, fresh context per ticket, subagent isolation, capped tool output | L2 | Quality fell late in long sessions |
| CO7 | Path-scoped instructions | L2 | Root steering file over budget, or rules irrelevant to most tasks |
| CO8 | Tool-surface limits per task and per subagent | L3 | Wrong tool chosen, or a subagent held tools it never needed |

## Knowledge

| ID | Part | Min | Earned by |
| --- | --- | --- | --- |
| KN1 | Glossary: `GLOSSARY.md` | L1 | First term conflict or overloaded word |
| KN2 | Decision records: `docs/adr/` | L1 | First hard-to-reverse decision |
| KN3 | Reference docs behind pointers | L2 | Agent lacked a convention it could not look up |
| KN4 | Spec and tickets flow for product work | L2 | Multi-session product builds |
| KN5 | Debt ledger: `shortcut:` comments and `ponytail-debt` | L2 | A deliberate shortcut was taken |
| KN6 | Cited research notes: `.harness/research/` | L2 | A decision needs external facts |
| KN7 | Cross-project memory | L4 | The same lesson relearned in two projects |
| KN8 | Failure log: incident, root cause, control added | L1 | The first observed failure |
| KN9 | Doc-gardening pass that flags stale docs and pointers | L3 | A doc contradicted the code |

## Integration

| ID | Part | Min | Earned by |
| --- | --- | --- | --- |
| IN1 | CLI inventory as pointers in `AGENTS.md` | L1 | Agent missed a tool the repo already has |
| IN2 | Human-only step scripts (`wizard`) | L2 | A human-only step blocked the agent or repeated |
| IN3 | MCP servers, configured per agent | L3 | A system the work needs has no usable CLI |
| IN4 | CI and pull-request flow | L2 | Changes go through review by others |
| IN5 | Permissions and secrets policy | L4 | Team or client data in reach of the agent |
| IN6 | Deny rules and secret-path protection | L1 | Secrets or credentials reachable from the repo or home directory |
| IN7 | OS sandbox with a network egress allowlist | L2 | The agent runs commands without per-command approval |
| IN8 | Untrusted-content rule: issues, comments, web pages and tool results are data | L2 | The agent reads content the user did not write |
| IN9 | Dependency guard: no install without approval, lockfile, release cooldown | L2 | The agent added or invented a package |
| IN10 | MCP and skill allowlist with version and description pinning | L3 | Any third-party MCP server or skill is installed |
| IN11 | Git worktree per task | L4 | Parallel agents (with CO5) |

## Quality

| ID | Part | Min | Earned by |
| --- | --- | --- | --- |
| QA1 | One check command that goes red | L0 | Always built |
| QA2 | Pre-commit guardrail running QA1 | L1 | A broken commit landed |
| QA3 | TDD at agreed seams (`tdd`) | L1 | Non-trivial logic in scope |
| QA4 | Two-axis review per change (`code-review`) | L1 | Work goes beyond one-off |
| QA5 | CI job running QA1 | L2 | More than one person or machine |
| QA6 | `CODING_STANDARDS.md`, judgement calls only | L2 | The reviewer missed a judgement issue |
| QA7 | Custom deterministic checks | L2 | A mechanical mistake happened twice |
| QA8 | Retro loop (stage S6) | L2 | Always on from L2 |
| QA9 | Behaviour evals for the harness: `.harness/evals/` | L3 | A prose part (steering, skill) needs proof it changes behaviour |
| QA10 | Eval release gate in CI | L4 | Harness changes ship to other people |
| QA11 | Baseline repo audit (`ponytail-audit`) | L1 | The repo already has code |
| QA12 | Local-only cost and token tracking | L3 | Cost is in the goal |
| QA13 | Guard tests in both directions | L1 | Any guard exists |
| QA14 | App-level verification: the agent starts the app, drives it and reads logs | L2 | "Done" was claimed but behaviour was broken |
| QA15 | Regression eval suite, run in batches | L3 | A harness change broke something else |
| QA16 | Capability evals drawn from real failures | L3 | A behaviour the agent cannot yet do reliably |
| QA17 | Trajectory checks on tool calls and file changes | L3 | Right answer by the wrong route (tests skipped) |
| QA18 | Session telemetry in local JSON lines; optional OpenTelemetry export | L3 | Nobody can say what happened, or whether a change helped |
| QA19 | Model and agent upgrade protocol | L3 | A new model or agent version |
| QA20 | Ablation and pruning review | L3 | The harness has grown, or the model improved |
| QA21 | Transcript review cadence | L2 | Always on from L2, with the retro |
| QA22 | Incident runbook and kill switch | L4 | Other people use the harness |
| QA23 | Judge calibration against human grading | L4 | Model-graded evals gate releases |
