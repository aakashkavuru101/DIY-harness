# Harness Engineering, November 2026

Document 09 of 09 · Draft v0.3 · 2026-11-16

> The practices the field has converged on this year, what each means, and where each lands in DIY-harness. Researched on 2026-11-16 from the sources in section 6. Claude Code treats this as the reasoning behind documents 02, 06, 07 and 08, and ships a condensed version as `references/PRACTICES.md`.

## 1. The shared model

Most 2026 writing agrees on one frame: **agent = model + harness.** The model supplies reasoning; the harness supplies context, limits and feedback. A harness has two kinds of control, with people placed between them:

![Guides steer before the agent acts; sensors check after](diagrams/08-guides-sensors.svg)

- **Guides** act before the agent does: steering files, scoped rules, skills, tool limits, specs.
- **Sensors** act after: tests, linters, type checks, architecture checks, review, evals.
- **Human gates** sit between, reserved for high-impact decisions, so nobody approves trivia.

This maps onto the five planes: Protocol, Cognition and Knowledge are mostly guides; Quality is mostly sensors; Integration sets what the agent can reach at all.

## 2. Practices and where they land

Status: **Have** = already in v0.1. **Added** = new in v0.2. **Parked** = noted, not built.

### Building and shaping the harness

| Practice | What it means | In DIY-harness | Status |
| --- | --- | --- | --- |
| Build from failure | Add a control when the agent actually fails, not because it might | Principle 3; KN8 failure log | Have, Added |
| Small root steering file | Keep it near 100 lines, as a table of contents to scoped rules | PR2 line budget; CO7 | Have, Added |
| No machine-written steering | Auto-generated context files have been measured to lower success and raise cost | The command never generates `AGENTS.md` content wholesale; every line is earned and approved | Added (rule in S5) |
| Scoped instructions | Load a rule only when the agent touches the paths it governs | CO7 | Added |
| Promote prose to checks | A convention ignored twice becomes a linter rule, type or structural test | QA7 | Have |
| Fail with the fix; quiet when green | Error messages carry the remedy; passing checks stay silent | Guard and check rules (document 07 section 4) | Added |
| Explicit, recorded defaults | When a step is skipped, record the choice instead of guessing silently | Gate skips logged in `STATE.md` | Have |
| Harness as reviewed code | Version it, change it by pull request | PR8; document 08 section 5 | Added |
| Garden against rot | Expiry conditions, regular pruning, a pass that flags stale docs | PR9, QA20, KN9 | Added |
| Simplify as models improve | Ablate rules on each new model; delete what no longer helps | QA19, QA20 | Added |

### Context engineering

| Practice | What it means | In DIY-harness | Status |
| --- | --- | --- | --- |
| Context is a budget | Quality degrades as context grows, well before the limit | CO6; fresh context per ticket | Have, Added |
| Write, select, compress, isolate | Persist to files; load on demand; compact at phase ends; isolate exploration in subagents | `STATE.md` and phase artefacts; skills on demand; CO6 | Have, Added |
| Cap tool output | Fixed-size results keep context small without breaking caching | CO6 | Added |
| Manage the tool surface | Fewer visible tools improve success, cost and latency together | CO8; CLI before MCP (IN1 before IN3) | Have, Added |

### Agents and orchestration

| Practice | What it means | In DIY-harness | Status |
| --- | --- | --- | --- |
| Separate making from judging | An agent grades its own work poorly; review in a separate context | QA4 two-axis review in fresh subagents | Have |
| More agents are not free | Extra roles and long handoff chains have lowered success in ablations; cap handoffs at about four | CO5 stays L4 and must be earned; the default is one agent plus reviewers | Have |
| Typed handoffs | Subagents exchange structured results, not prose | Subagent report templates in playbooks | Added |
| Workspace per task | Each parallel agent gets its own git worktree | IN11 | Added |
| Let the agent run the app | It starts its own instance, drives it, reads logs, and re-verifies | QA14 | Added |

### Evaluation and operations

| Practice | What it means | In DIY-harness | Status |
| --- | --- | --- | --- |
| Behavioural evals beside benchmarks | Small checks on observable actions explain *why* a score moved | Document 06 section 7; QA9 | Have, Added |
| Evals from real failures | Twenty to fifty frozen tasks drawn from what actually went wrong | QA16; KN8 feeds the suite | Added |
| Capability and regression suites | One suite to climb, one that must stay near 100% | QA15, QA16 | Added |
| Grade the trajectory | Assert on tool calls and file changes, not on the wording of the answer | QA17 | Added |
| Several trials, batched | Single runs are noisy; track pass rates over batches | Document 06 section 5 | Added |
| Eval-driven changes | Write the eval before the harness change, as TDD does for code | S5 step 3 | Have |
| Measure real use | Which skills fire, how often guards block, cost per merged change | QA18; document 08 | Added |
| Portable telemetry | OpenTelemetry GenAI conventions, pinned while they are still in development | Document 08 section 3 | Added |

### Security

| Practice | What it means | In DIY-harness | Status |
| --- | --- | --- | --- |
| Enforce, do not ask | Prose and approval prompts are weak; deny rules, hooks and sandboxes are strong | Document 07 | Added |
| Hooks as the cross-agent control point | One policy in front of several agents | PR5, PR6, IN6 adapters | Have, Added |
| Treat fetched content as data | Issues, comments, pages and tool results never carry instructions | IN8 | Added |
| Pin the tool supply chain | Allowlist MCP servers and skills; pin versions and descriptions | IN10 | Added |
| Guard dependencies | No install without approval; avoid just-published releases | IN9 | Added |

## 3. Deliberately not adopted

| Idea | Why not |
| --- | --- |
| A multi-agent team by default | Evidence this year points the other way for most work; it is an L4 part that must be earned |
| Installing skill packs by default | Start lean. DIY-harness vendors exactly three, pinned and reviewed, and installs nothing else |
| Generating steering files automatically | Measured to hurt; conflicts with earned parts |
| "Ask me" rules as protection | Prompts get approved by habit |
| Blocking a merge on one eval run | Single runs are noisy; gate on batches and trends, except the critical cases |
| A hosted observability dependency | Conflicts with principle 7; local first, export by choice |

## 4. Still moving: verify before relying on

| Area | State on 2026-11-16 | What to do |
| --- | --- | --- |
| OpenTelemetry GenAI conventions | In development; moved to a dedicated repository in mid-2026; reports of stability conflict | Pin the version emitted; isolate naming in one module |
| Hook coverage | Differs by agent and by tool type | Test every guard in every agent, both directions |
| MCP trust | Tool descriptions are unsigned and can change after approval | Pin and diff descriptions; prefer CLIs |
| Built-in agent memory | New features in several agents this year | Keep `STATE.md` and the failure log as the source of truth; treat built-in memory as a cache |
| Steering-file standards | `AGENTS.md` is the cross-agent convention | Keep `AGENTS.md` as the single source |

## 5. What changed in the spec because of this

- Document 02: 25 new parts across the five planes; levels updated.
- Document 03: decisions D12 to D16.
- Document 04: a threat round and an operations round in S3; guard tests in S5; telemetry and expiry review in S6.
- Document 06: eval engineering for the harnesses the command builds; cases E13 to E16.
- Documents 07 and 08: new.

## 6. Sources

Read on 2026-11-16. Claude Code re-checks anything it builds against the primary source.

- Anthropic, "Demystifying evals for AI agents": https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- Google Developers Blog, "The Anatomy of Harness Engineering": https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/
- Thoughtworks, "Engineering the harness": https://www.thoughtworks.com/en-us/insights/blog/architecture/engineering-the-harness-a-practical-pattern-for-reliable-coding-agents
- Marmelab, "The State Of AI Harness Engineering 2026": https://marmelab.com/blog/2026/09/24/the-state-of-ai-harness-engineering-2026.html
- LangChain, "What Is Eval-Driven Development?": https://www.langchain.com/blog/what-is-eval-driven-development
- Endor Labs, "The case for hook-based governance across agent platforms": https://endorlabs.com/learn/when-the-guardrails-slip-the-case-for-hook-based-governance-across-agent-platforms
- Software Mansion, "Agentic Engineering: Security": https://agentic-engineering.swmansion.com/becoming-productive/security/
- Greptime, "How OpenTelemetry Traces LLM Calls, Agent Reasoning, and MCP Tools": https://www.greptime.com/blogs/2026-05-09-opentelemetry-genai-semantic-conventions
- Practical DevSecOps, "MCP Tool Poisoning Attacks": https://www.practical-devsecops.com/mcp-tool-poisoning/
- Louis Bouchard, "Context Engineering in 2026": https://www.louisbouchard.ai/context-engineering-2026/
