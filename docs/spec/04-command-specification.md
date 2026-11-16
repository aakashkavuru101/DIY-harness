# Command Specification

Document 04 of 09 · Draft v0.3 · 2026-11-16

> The behaviour of `/diy-harness`, stage by stage, and every file it writes into the user's project. The parent `SKILL.md` should stay short (steps and completion criteria); detail lives in its `references/` files and is read when a stage needs it.

## 1. Invocation

| Form | Meaning |
| --- | --- |
| `/diy-harness` | Resume from `.harness/STATE.md`, or start at S0 if it does not exist |
| `/diy-harness <what the harness is for>` | Start, using the text as the opening of the S1 grilling |
| `/diy-harness status` | Show stage, level, current ticket, open decisions. Changes nothing |
| `/diy-harness level` | Run the S2 level assessment again on the current state |

In Codex the same forms follow the skill's name in Codex's own skill syntax. The argument parsing lives in the parent `SKILL.md`; keep it to these four forms.

## 2. The working agreement

This text is part of the always-on layer (document 05) and is also restated at the top of the parent `SKILL.md`. Claude Code may tighten the wording but must keep every rule.

- **Equals.** Finding facts is your job: read the repo, run commands, dispatch a subagent with a fresh context window. Never ask the user for a fact you could look up. Decisions are the user's: give your recommended answer, then wait. Push back when a decision contradicts `GOAL.md` or an earlier decision; the user rules.
- **Goal lock.** Once `.harness/GOAL.md` exists, read it before acting. Every proposal traces to a line in it. When one does not, begin the message with `Drift:`, name the gap, and ask whether to amend the goal or drop the work.
- **Earned parts.** Propose a harness part only when it answers an observed failure or a goal line, at or below the current level. Put everything else in `Parked`. The user may override; record the override and its reason in `SPEC.md`.
- **Stage gates.** A stage ends only when its completion criterion is met and the user confirms. Update `STATE.md`, then stop and ask before the next stage.
- **State on disk.** Keep `STATE.md` current enough that a fresh session in any agent can resume from it alone.
- **Their files are theirs.** Never overwrite content the user wrote. Edit `AGENTS.md` only between the harness markers. Confirm before any destructive action.

## 3. Stages

![The stage flow: seven stages, a gate after each, and the retro loop](diagrams/01-stage-flow.svg)

Each stage lists: purpose, steps, engine calls, outputs, the completion criterion, and level-specific behaviour. "Playbook" means a file under `references/playbooks/`.

### S0 Orient

**Purpose:** resume, or start cleanly.

1. If `.harness/STATE.md` exists, report stage, level, current ticket and next step, and continue there after the user confirms.
2. Otherwise, dispatch a subagent with a fresh context to scan the repo: language, existing check commands, CI, hooks, steering files, existing skills, whether there is code yet. It reports facts only.
3. Create `.harness/STATE.md` from the template.

**Done when:** the user has confirmed the stage to work in.

### S1 Lock the goal

**Purpose:** a goal sharp enough to steer by.

1. Call the Skill tool twice, for `grilling` and `domain-modeling`.
2. Aim the frontier at: the work the harness serves and who runs it; the goal in one sentence; observable done criteria; non-goals; which agents must run it; observed failures the user has already hit; constraints (data that must not leave, budget, deadlines); what must never happen in this repo; the autonomy tier the user wants (document 07 section 5).
3. Use `research` for any external fact a decision needs.
4. Write `.harness/GOAL.md`. Terms go to `GLOSSARY.md`; hard-to-reverse decisions to `docs/adr/`.

**Done when:** the grilling frontier is empty and the user has approved `GOAL.md` line by line.

### S2 Assess and choose a level

**Purpose:** decide how much harness this goal needs.

1. If the repo has code, call the Skill tool with `ponytail-audit` for a ranked baseline (part QA11). Store it in `.harness/research/audit-<date>.md`.
2. List the safety facts: secrets in reach, existing deny rules, hooks, sandbox state, installed MCP servers and skills.
3. Read `references/LEVELS.md` and `references/PARTS.md`. Map each goal line and observed failure to the parts that answer it.
4. Apply the ponytail ladder to each part: does it need to exist; is it already in the repo; can an existing tool do it.
5. Propose a level with one line per part saying what it answers. Use the grilling format so "yes" accepts the recommendation.

**Done when:** the user has chosen a level, and `STATE.md` records it with the reason.

### S3 Design

**Purpose:** the smallest set of parts that meets the goal.

1. Switch ponytail to ultra for this stage (D9): question every part.
2. Walk the five planes in order, one grilling round per plane, offering only parts at or below the chosen level whose trigger has fired.
3. Run two cross-cutting rounds. **Threat round:** walk threats T1 to T10 (`references/GUARDRAILS.md`) and keep only those real for this repo. **Operations round** (L2 and above): what will be recorded, which metrics decide things, and how the harness will be changed and pruned (`references/OPS.md`).
4. For each part, state: what it answers, where it lives, the adapter per agent if any, the proof that goes red without it, and (from L2) its expiry condition. Use `codebase-design` vocabulary for seams.
5. When a design question needs a runnable answer, call the Skill tool with `prototype`.
6. Follow the `to-spec` playbook to write `.harness/SPEC.md` from the template.

**Done when:** every part names its justification and proof, unjustified ideas are in `Parked`, and the user has approved the spec.

### S4 Slice

**Purpose:** a build order that works end to end at every step.

1. Follow the `to-tickets` playbook: one tracer-bullet ticket per part (or per batch of a wide change), each with its proof as acceptance and its blocking edges.
2. Show the list (title, part, blocked by), at most five per screen, and ask whether the granularity and edges are right.

**Level behaviour:** at L0, skip this stage; the build is one ticket written into `STATE.md`.

**Done when:** the user has approved the ticket list and `STATE.md` names the first unblocked ticket.

### S5 Build

**Purpose:** one part working, proved, reviewed and committed.

1. Follow the `implement` playbook for the next unblocked ticket. State its title first.
2. Agree the proof with the user: the command or eval that goes red without this part.
3. Call the Skill tool with `tdd` for logic at agreed seams. For prose parts (steering, skills), write the eval case first in `.harness/evals/`.
4. Call the Skill tool with `writing-for-agents` before writing any steering file or skill. Never generate steering content wholesale: each line is earned and approved.
5. For a guard, write two tests first: one action it must block and one it must allow. The block message states the fix.
6. When a check stays red after two attempts, call the Skill tool with `diagnosing-bugs`. When a step only a human can do appears, call the Skill tool with `wizard`.
7. Call the Skill tool with `code-review`; the spec is `SPEC.md` plus the ticket.
8. Show the diff summary and both review axes. On approval, commit, tick the ticket, update `STATE.md`. At L2 and above, call the Skill tool with `pr` when the work goes up as a pull request.
9. Recommend a fresh context before the next ticket.

**Level behaviour:** at L4, the user may choose the `implement-spec` playbook to run ready tickets in parallel.

**Done when:** the proof is green, review findings are resolved or accepted by the user, and `STATE.md` is updated.

### S6 Run and retro

**Purpose:** grow the harness from what real use shows.

1. The user runs the harness on real work, in any agent the goal names.
2. Follow the `retro` playbook on that session. Report drift first, then the categories in the playbook. From L2, read the transcript; from L3, read the telemetry: guard blocks and overrides, parts that never fired, cost per merged change.
3. Call the Skill tool with `ponytail-debt` and add any shortcut that has reached its upgrade condition.
4. Check levels: a finding whose part sits above the current level is a level-up proposal; a no-op part, or a control past its expiry condition, is a deletion proposal.
5. Add each accepted failure to the failure log (KN8) with its root cause and the control that answers it.
6. Each accepted finding becomes a ticket; return to S5.

**Level behaviour:** at L0 and L1, offer the retro but do not require it.

**Done when:** every finding is a ticket or rejected by the user, and `STATE.md` records the decision.

## 4. Files written into the user's project

`.harness/` holds the build process's own files (goal, state, spec and tickets of the harness being built) and the evals that test the harness itself. The other paths are harness parts for the user's ongoing work; document 02 section 3 explains the difference.

| Path | From level | Written in | Notes |
| --- | --- | --- | --- |
| `.harness/STATE.md` | L0 | S0 | Stage, level, ticket, open decisions, log |
| `.harness/GOAL.md` | L0 | S1 | The goal lock |
| `AGENTS.md` (harness block) | L0 | S5 | Pointers only, between `<!-- diy-harness:start -->` and `<!-- diy-harness:end -->` |
| `CLAUDE.md` | L0 | S5 | Symlink to `AGENTS.md`; if one exists with content, ask first |
| Check command wiring | L0 | S5 | Reuse the repo's own command when one exists |
| `GLOSSARY.md`, `docs/adr/` | L1 | S1 onward | Created lazily, by domain-modeling |
| `.harness/SPEC.md` | L1 | S3 | At L0 the spec is a short section in `STATE.md` |
| `.harness/tickets/NN-<slug>.md` | L1 | S4 | One file per ticket |
| Pre-commit hook | L1 | S5 | Use the repo's hook manager if it has one |
| `.harness/research/` | L1 | S1 onward | Audit output, cited notes |
| `.agents/skills/`, `.claude/skills` symlink | L2 | S5 | Project skills |
| `CODING_STANDARDS.md` | L2 | S5 | Judgement calls only |
| `.harness/retro/<date>.md` | L2 | S6 | One per retro |
| `.harness/FAILURES.md` | L1 | S6 | Failure log: incident, root cause, control, expiry condition |
| Deny rules and guard scripts, with tests | L1 | S5 | Agent settings plus `.harness/guards/`; protected paths from L2 |
| `.harness/telemetry/` | L3 | S5 | Local JSON lines, git-ignored |
| `.harness/evals/` | L3 | S5 | Cases, rubric, runner config |

## 5. Templates

Ship these under `references/templates/`. Each must fit on one screen.

**GOAL.md:** Goal (one sentence) · Done when (checkable list) · Not doing · Runs in (agents and versions) · Known failures (what ran, what went wrong) · Constraints · Amendments (dated, user-approved).

**STATE.md:** Stage · Level and reason · Current ticket · Next step (one sentence) · Open decisions · Log (one line per event, pointing at files and commits rather than copying them). Redact secrets and personal data, as Matt's `handoff` requires.

**SPEC.md:** Parts (per part: plane and ID, answers, lives at, adapter, proved by, expires when) · Decisions (with ADR numbers) · Overrides (part, reason, date) · Parked (idea, and the failure that would earn it).

**TICKET.md:** Title · Status · Part ID · Blocked by · What it makes work (user's view) · Acceptance (the proof, and that it goes red without the part; works in each agent under "Runs in").

**EVAL case:** ID · Agent · Starting state (files present) · Prompt · Passing behaviour (observable) · Blocking behaviour (fails the case outright).

## 6. Edge cases

| Situation | Behaviour |
| --- | --- |
| Not a git repository | Ask before running `git init`; the harness relies on commits for review |
| No check command exists | QA1 becomes the first ticket; propose the cheapest real check the language offers |
| Agent has no Skill tool | Read `../<name>/SKILL.md` relative to the parent and follow it |
| User skips a gate ("just do it") | Allowed for the current stage only. Record it in the `STATE.md` log; the next stage gates again |
| User asks for a part with no trigger | Recommend parking it with the reason; if the user insists, build it and record the override |
| Existing `AGENTS.md` or `CLAUDE.md` with content | Keep it; add the harness block between markers; ask before creating the symlink |
| Session nears the context limit mid-stage | Update `STATE.md`, then recommend a fresh session at the next stage boundary |
