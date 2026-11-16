# DIY-harness: Build Brief

Document 01 of 09 · Draft v0.3 · 2026-11-16 · Owner: Aakash Kavuru · Builder: Claude Code

> Read this document first. It says what to build, in what order, and how we will know it is done. Documents 02 to 09 hold the detail. Where they disagree with this brief, this brief wins; raise the conflict before building.

## 1. What we are building

**DIY-harness** is one parent command, `/diy-harness`, that runs inside **Claude Code and Codex**. When a user runs it in a project, the AI and the user build a custom **harness** for that project together, as equals, one stage-gated step at a time.

A harness is the environment that keeps a coding agent pointed at one goal: steering files, skills, knowledge, tool access and quality checks (defined fully in document 02). ![The stage flow of the parent command](diagrams/01-stage-flow.svg)

DIY-harness can build anything from a tiny low-intensity harness (level L0) to an advanced, instrumented, multi-agent harness (level L4), and it grows the harness only when real use earns the next part.

The product name is a working name. The command name will change once the name is decided; keep it in one place (see document 05).

## 2. The engine: three upstream repositories

DIY-harness has no process logic of its own beyond the stage flow. Its engine is three MIT-licensed repositories, vendored at pinned commits and called in stages by the parent command:

| Repo | Role in the engine | Pinned commit |
| --- | --- | --- |
| mattpocock/skills | **Process**: grilling, domain modelling, TDD, two-axis review, spec, tickets, retro | 5863806dd4e15c63174bee4e7515a4256792ecfa |
| DietrichGebert/ponytail | **Build discipline**: smallest complete change, review checklist, repo audit, debt ledger | 96608e078b2d5ea607c5c3b8b5a54d1c1fba6846 |
| ayghri/i-have-adhd | **Output shape**: action first, numbered steps, state restated every turn, no tangents; plus an eval method | 1ecea1993b7fce257ffbd686c070948b5e07eda6 |

How each one is wired in, and the conflicts between them, are in document 03.

## 3. Principles (these decide every open question)

1. **Equals.** Facts are the AI's job (it reads, runs and looks things up). Decisions are the user's (the AI recommends, the user rules). Neither side is "in the loop" of the other.
2. **Goal lock.** Once the goal is written, every proposal traces to it. Anything that does not is called out as `Drift:` before work continues.
3. **Earned parts.** A harness part is built only when it answers an observed failure or a goal line. The rest is parked, visibly.
4. **One command.** The user remembers `/diy-harness` and nothing else. Stages call the engine; the user never has to.
5. **Minimal by default, advanced when earned.** Start at the lowest level that meets the goal. Level up through the retro loop, not up front.
6. **Write once, adapt thinly.** Every part has one agent-neutral source plus a thin adapter per agent only where that agent needs one.
7. **No telemetry.** Nothing leaves the user's machine. Upstream telemetry features are dropped.

## 4. Scope

### In scope for v1

- The parent command and its stage flow, S0 to S6 (document 04).
- The harness knowledge base the command reasons from: theory, five planes, levels L0 to L4, parts catalogue (document 02).
- Vendored engine skills and stage playbooks, with licences, pins and a patch log (document 03).
- An always-on layer (working agreement, build rules, output rules) that is active in both agents (document 05).
- Packaging and install for Claude Code and Codex (document 05).
- Static checks, install smoke tests and behaviour evals with a release gate (document 06).
- Guardrail knowledge and parts: threat model, six layers, autonomy tiers (document 07).
- Operations knowledge and parts: telemetry, metrics, upgrade protocol, pruning (document 08).
- A practices reference that keeps the command current with 2026 harness engineering (document 09).

### Out of scope for v1

- Fine-tuning or training any model.
- Ponytail's band, board, statusline, webhooks, `ponytail-gain` and `ponytail-help`.
- A GUI. Everything runs in the agent's own terminal UI.
- Agents other than Claude Code and Codex. Kimi Code is parked: the agent-neutral sources (`AGENTS.md`, flat skill folders, git-hook checks) keep it cheap to add later, but build no Kimi adapter, manifest or test now.
- Building the L3 and L4 parts *themselves* into DIY-harness. v1 must be able to *design and build them into a user's project* through the stage flow; it does not need them in its own repo.

## 5. Build order (milestones)

Build as tracer bullets: each milestone works end to end before the next starts. Ask before moving to the next milestone.

| # | Milestone | Done when |
| --- | --- | --- |
| M1 | Skeleton and vendoring | Repo layout from document 05 exists; engine vendored at the pins; licences, `vendor/UPSTREAM.md` and `vendor/PATCHES.md` present; `scripts/check.sh` runs the static checks and is green |
| M2 | Parent command S0 to S2 in Claude Code | `/diy-harness` resumes or starts, locks a goal with grilling, writes `GOAL.md` and `STATE.md`, and proposes a level; the always-on hook is active |
| M3 | Stages S3 to S5, levels L0 and L1 | A user can build a complete L0 and L1 harness in a real project, including the L1 guardrail parts with tests in both directions |
| M4 | Codex | The same flow works in Codex; install smoke tests pass for both agents |
| M5 | Level L2 and the retro loop | S6 retro, debt ledger and level-up work; an L2 harness can be built, including sandbox, untrusted-content and dependency guards |
| M6 | Evals and release gate | Cases E1 to E16 run in both agents; the release gate in document 06 is automated |
| M7 | L3 and L4 knowledge | Parts catalogue entries for L3 and L4 are complete with adapters and proofs; an L3 harness with telemetry and eval suites has been built in one real project |

## 6. Acceptance for v1

v1 is done when all of these hold:

- `scripts/check.sh` is green, including manifest validation.
- Install smoke tests pass in Claude Code and Codex.
- Behaviour evals E1 to E16 pass the release gate in both agents (document 06).
- One real L0 harness and one real L1 harness have been built with `/diy-harness` in Aakash's own projects, and he has signed them off.
- `README.md` explains install, the one command, the levels, and how to switch the always-on rules off.

## 7. Decisions Claude Code must not take alone

Document 03 section 5 lists sixteen decisions (D1 to D16) with a recommendation for each. Treat every recommendation as a default to confirm with Aakash at the start of the relevant milestone, not as settled. Three are fully open: the product name, the GitHub organisation, and the language policy for prompts and outputs (English, Japanese or both).

## 8. The document set

| # | Document | Use it for |
| --- | --- | --- |
| 01 | Build Brief (this) | What, why, order, acceptance |
| 02 | Harness Theory and Levels | What a harness is, the five planes, L0 to L4, the parts catalogue |
| 03 | Engine Integration | Every upstream skill, which stage calls it, conflicts and decisions |
| 04 | Command Specification | The parent command stage by stage, files it writes, templates |
| 05 | Cross-Agent Packaging | Repo layout, manifests, always-on layer, install, adapters |
| 06 | Evals and Acceptance | Static checks, smoke tests, behaviour cases, rubric, release gate, eval engineering |
| 07 | Guardrails | Threat model, six layers, guard rules, autonomy tiers, adapters |
| 08 | LLM-ops for Harnesses | Telemetry, metrics, safe change, upgrades, cost, incidents, pruning |
| 09 | Harness Engineering, November 2026 | Current practice, what was adopted and why, sources |

Every diagram in the PDFs is also shipped as a standalone SVG under `diagrams/`.
