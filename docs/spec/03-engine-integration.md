# Engine Integration

Document 03 of 09 · Draft v0.3 · 2026-11-16

> How the three upstream repositories become the engine under `/diy-harness`: what each skill becomes, which stage calls it, where they conflict, and the decisions to confirm with Aakash.

## 1. Three ways the parent calls the engine

The parent command is **user-invoked**: only the human starts it. Matt Pocock's skills enforce a hard rule: a user-invoked skill can call **model-invoked** skills, but never another user-invoked one. So every upstream skill is wired in one of three ways:

| Kind | What it is | How the parent calls it |
| --- | --- | --- |
| **Engine skill** | An upstream model-invoked skill, vendored as a sibling skill folder | "Call the Skill tool with `<name>`". If the agent has no Skill tool, read `../<name>/SKILL.md` and follow it |
| **Stage playbook** | An upstream user-invoked command, vendored as a reference file inside the parent | "Read `references/playbooks/<name>.md` and follow it" |
| **Always-on rule** | An upstream mode skill whose rules apply to every turn | Injected at session start by a hook, in both agents; never called |

Playbooks carry no description, so they cost no context and can never fire by accident. Engine skills keep their descriptions, so the agent can also reach them on its own mid-task.

![How the parent command reaches the three upstream repositories](diagrams/04-engine-wiring.svg)

## 2. Inventory: every upstream skill and its fate

### mattpocock/skills (pin 5863806)

| Upstream skill | Upstream invocation | Becomes | Stages |
| --- | --- | --- | --- |
| grilling | model | Engine skill | S1, S2, S3, S4 |
| domain-modeling | model | Engine skill | S1, S3 |
| codebase-design | model | Engine skill | S3, S5 |
| prototype | model | Engine skill | S3 (when a design question needs a runnable answer) |
| research | model | Engine skill | S1 to S3 (external facts, part KN6) |
| tdd | model | Engine skill | S5 |
| code-review | model | Engine skill, **patched** (D3) | S5 |
| diagnosing-bugs | model | Engine skill | S5 (when a check stays red) |
| wizard | model | Engine skill | S5 (part IN2) |
| pr | model | Engine skill | S5 at L2 and above (part IN4) |
| writing-for-agents | model | Engine skill | S3, S5, S6 (whenever a steering file or skill is written) |
| to-spec | user | Playbook, **patched**: writes `.harness/SPEC.md` | S3 |
| to-tickets | user | Playbook, **patched**: writes `.harness/tickets/` | S4 |
| implement | user | Playbook | S5 |
| implement-spec | user | Playbook, L4 only (part CO5) | S5 |
| retro | user | Playbook, **patched**: drift and level checks first | S6 |
| handoff | user | Dropped: `STATE.md` is the handoff. Keep its redaction rule in the template | |
| grill-me, grill-with-docs | user | Dropped: the parent calls grilling and domain-modeling directly | |
| ask-matt | user | Dropped: the parent is the router | |
| setup-matt-pocock-skills | user | Dropped: S0 orientation replaces it; trackers are local files | |
| triage, wayfinder, improve-codebase-architecture | user | Parked for v2 | |
| teach, to-questionnaire, wait-what | user | Dropped | |
| misc/git-guardrails-claude-code | (frozen) | Source material for part PR6 | |
| misc/setup-pre-commit | (frozen) | Source material for part QA2 | |

### DietrichGebert/ponytail (pin 96608e0)

| Upstream skill or file | Becomes | Stages |
| --- | --- | --- |
| ponytail (rules) | Always-on rule (part CO1); skill kept only for level switching: lite, full, ultra | All |
| ponytail-review | Merged into the code-review Standards axis (D3); not shipped as a skill | S5 |
| ponytail-audit | Engine skill | S2 (part QA11), S6 at L2 and above |
| ponytail-debt | Engine skill | S6 (part KN5) |
| ponytail-gain, ponytail-help | Dropped | |
| SessionStart and SubagentStart hooks | Pattern reused for our own always-on hook | |
| band, board, statusline, webhooks | Dropped (no telemetry) | |

### ayghri/i-have-adhd (pin 1ecea19)

| Upstream skill or file | Becomes | Stages |
| --- | --- | --- |
| i-have-adhd (rules) | Always-on rule (part CO2) | All |
| always-on hooks | Pattern reused for our own always-on hook | |
| `scripts/run_evals.py`, `judge.py`, `evals/rubric.md`, `cases.jsonl` | Adapted into DIY-harness's own evals and the QA9 template (document 06) | M6 |

## 3. Stage map

| Stage | Purpose | Engine skills | Playbooks | Always-on |
| --- | --- | --- | --- | --- |
| S0 Orient | Resume or start | (subagent scan of repo) | | All three rule sets |
| S1 Lock | Goal, glossary, failures | grilling, domain-modeling, research | | |
| S2 Assess | Audit, propose level | ponytail-audit, grilling | | |
| S3 Design | Pick parts, write spec | codebase-design, writing-for-agents, prototype, research, grilling | to-spec | |
| S4 Slice | Tracer-bullet tickets | grilling (quiz) | to-tickets | |
| S5 Build | One ticket at a time | tdd, code-review, diagnosing-bugs, wizard, pr, writing-for-agents | implement, implement-spec (L4) | |
| S6 Retro | Learn, level up or down | ponytail-debt, ponytail-audit, writing-for-agents | retro | |

## 4. Rule precedence

When two rules collide, the higher one wins:

1. The agent's own system prompt and harness rules (tool-call announcements, permissions).
2. Safety: confirm before destructive actions; never cut validation, security, data-loss handling or accessibility.
3. The working agreement: equals, goal lock, stage gates.
4. Ponytail build rules.
5. i-have-adhd output rules.

i-have-adhd itself says a rule that fights the task or the harness loses, while the shape stays. This order makes that explicit for all three.

## 5. Decisions (confirm each with Aakash)

| ID | Decision | Conflict | Recommendation |
| --- | --- | --- | --- |
| D1 | How the parent calls upstream user-invoked commands | Matt's rule forbids user-invoked to user-invoked calls | Vendor them as stage playbooks inside the parent. Do not flip them to model-invoked: that adds context load and lets them fire by accident |
| D2 | Question cap during grilling | i-have-adhd caps visible lists at 5; Matt rejected caps on the *total* number of questions | Show at most 5 questions per round; carry the rest of the frontier into the next round. No cap on the total. i-have-adhd rule 9 already says to retain items and show them when they become next. Patch `grilling` accordingly |
| D3 | Which review | Matt's `code-review` (Standards and Spec axes, parallel subagents) versus `ponytail-review` (correct, safe, load, tested, fast, lean; reads connected code) | Keep Matt's two-axis structure. Feed the Standards subagent the repo's standards plus ponytail-review's checklist; keep Fowler's smells under "lean". Ship one review skill. Record the patch in `vendor/PATCHES.md` |
| D4 | How much testing | Matt's TDD writes a test every slice; ponytail asks for one small test on non-trivial logic | TDD only at seams agreed with the user, for non-trivial logic. Trivial changes need no test. Prose parts are proved by evals |
| D5 | Always-on content and cost | Three rule sets in every session cost context | Inject one generated file: working agreement, ponytail full, i-have-adhd. Measure its token cost in M2. Off switches: "stop ponytail", "stop adhd mode" |
| D6 | Name collisions with upstream plugins | Vendored skills share names with the upstream plugins | Keep upstream names so internal calls resolve. README tells users to uninstall the upstream plugins; `check.sh` warns on duplicates |
| D7 | Telemetry | Ponytail's band writes a ledger and can call a webhook | Drop band, board, statusline and webhooks entirely |
| D8 | Ponytail's closing risk line versus i-have-adhd's "no closers" | Ponytail ends each reply with what was skipped and any risk | Keep the risk line: it is information, not a pleasantry. Make it the last line, after the next action |
| D9 | Ponytail level default | lite, full or ultra | Full by default. Ultra during S3 design, where questioning every part is the point |
| D10 | Upstream sync policy | Upstreams change weekly | Pinned commits. `scripts/sync-upstream.sh` shows the diff; re-run evals before bumping a pin |
| D11 | Product name, GitHub organisation, language | Open | Aakash decides. Language options: English, Japanese, or bilingual prompts with output in the user's language |
| D12 | Telemetry | Principle 7 (nothing leaves the machine) versus the need to measure | Local JSON lines by default. Export only by explicit opt-in to a backend the user owns; no backend is bundled |
| D13 | Content capture in telemetry | Transcripts help diagnosis but hold code and data | Off by default. Opt-in per project, with redaction |
| D14 | Default autonomy tier | Speed versus safety | Tier B (ask on write) at L0 and L1; propose tier C only once the sandbox, deny rules and protected paths exist |
| D15 | Sandbox when the built-in one is unavailable | An agent's sandbox may not support the user's platform or setup | Fall back to a container or dev container; say so plainly at S3 |
| D16 | Eval trials and budget | More trials cost tokens; single runs are noisy | 3 trials per case by default; 5 on critical cases; a per-run cost ceiling the user sets |

## 6. Vendoring mechanics

- Copy each upstream folder unchanged first, commit, then apply patches as separate commits. That keeps every local change visible in history.
- `vendor/UPSTREAM.md` lists, per repo: URL, pinned commit, date, licence, and every file taken.
- `vendor/PATCHES.md` lists every local change: file, why, and the decision ID that caused it.
- `vendor/LICENSES/` holds the three MIT licence texts; `NOTICE` credits the three authors.
- Matt's skills point at `/setup-matt-pocock-skills` for the issue tracker. Every such line is patched to point at `.harness/SPEC.md` and `.harness/tickets/` (the only known site at the pin is in `code-review`; `check.sh` must fail if any reference to an absent skill remains).
- Matt's skills say to start every subagent with a fresh context window, because Codex forks the parent conversation by default. Keep that instruction wherever a subagent is dispatched, including in the parent.
