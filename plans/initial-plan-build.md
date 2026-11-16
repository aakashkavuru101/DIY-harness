# Step 1 of 6: GOAL — plan for approval

## Context

I am planner and reviewer; Opus 5.5 builds later. This session writes no product code.
I have read documents 01 to 09. This plan covers step 1 only (write `GOAL.md`). Steps 2 to 6
each get their own stop, as you asked.

## Facts I found (no action needed from you unless marked)

- The nine spec files sit at the repo root, not in `docs/spec/`. Your brief and the
  security-reviewer both point at `docs/spec/`.
- The folder is not a git repository.
- The three upstreams are already cloned at the root, clean, at exactly the pinned commits:
  `skills/` (mattpocock, 5863806), `ponytail/` (96608e0), `i-have-adhd/` (1ecea19).
- The root `skills/` clone sits where the product's own `skills/` folder must go (document 05 section 1).
- Installed here: Claude Code 2.1.325, codex-cli 0.167.0, git 2.50.1, node present.

## What I will do on approval

1. Write `GOAL.md` at the repo root with the content below. Nothing else is created.

Three housekeeping choices ride on this approval. Each is yours; my recommendation is first.

| # | Choice | Recommended | Why |
| --- | --- | --- | --- |
| H1 | Where the spec lives | Move the nine files to `docs/spec/`; add a symlink `docs/spec/diagrams -> ../../diagrams` | Matches your brief; the image links in the spec keep resolving with no spec edits, and `diagrams/` stays at the root as document 05 requires |
| H2 | Git | Run `git init` now; I commit nothing until you ask | Reviewers need diffs, and document 03 section 6 needs commit history for vendoring |
| H3 | The three upstream clones | Move them to `upstream/` (git-ignored) as the read-only source for M1 vendoring | Frees the root `skills/` path for the product; keeps the pinned clones on disk so nothing is fetched again |

If you reject any of H1 to H3, I write `GOAL.md` only and leave the rest as it is.

## GOAL.md (full draft)

```markdown
# GOAL

Source: docs/spec/01-build-brief.md (v0.3, 2026-11-16). Section numbers in brackets.
Every proposal must cite a line ID below. If it cannot, the message starts with "Drift:".

## Goal

G1. Build DIY-harness v1: one parent command, `/diy-harness`, that runs in Claude Code and
Codex and builds a custom harness for the user's project together with the user, as equals,
one stage-gated step at a time, at any level from L0 to L4, on an engine of three vendored
upstream repositories. [1, 2]

## Done when

- DN1. `scripts/check.sh` is green, including manifest validation. [6]
- DN2. Install smoke tests pass in Claude Code and Codex. [6]
- DN3. Behaviour evals E1 to E16 pass the release gate in both agents. [6]
- DN4. One real L0 harness and one real L1 harness have been built with `/diy-harness` in
  Aakash's own projects, and he has signed them off. [6]
- DN5. `README.md` explains install, the one command, the levels, and how to switch the
  always-on rules off. [6]

## Milestones (build order)

Each works end to end before the next starts. Ask before moving to the next. [5]

- M1. Skeleton and vendoring: document 05 layout exists; engine vendored at the pins;
  licences, `vendor/UPSTREAM.md`, `vendor/PATCHES.md` present; `scripts/check.sh` green.
- M2. Parent command S0 to S2 in Claude Code; always-on hook active.
- M3. Stages S3 to S5, levels L0 and L1, with L1 guard tests in both directions.
- M4. Codex: same flow; install smoke tests pass for both agents.
- M5. Level L2 and the retro loop.
- M6. Evals E1 to E16 in both agents; release gate automated.
- M7. L3 and L4 knowledge; one real L3 harness built.

## Not doing

- N1. Fine-tuning or training any model. [4]
- N2. Ponytail's band, board, statusline, webhooks, `ponytail-gain`, `ponytail-help`. [4]
- N3. A GUI. [4]
- N4. Agents other than Claude Code and Codex. No Kimi adapter, manifest or test. [4]
- N5. Building L3 and L4 parts into DIY-harness's own repo. v1 only designs and builds
  them into a user's project. [4]
- N6. Process logic of its own beyond the stage flow. [2]

## Constraints

- C1. Equals: facts are the AI's job; decisions are the user's. [3.1]
- C2. Goal lock: every proposal traces to this file; otherwise `Drift:`. [3.2]
- C3. Earned parts: build a part only for an observed failure or a goal line; park the rest
  visibly. [3.3]
- C4. One command: the user remembers `/diy-harness` and nothing else. [3.4]
- C5. Minimal by default: start at the lowest level that meets the goal; level up through
  the retro loop. [3.5]
- C6. Write once, adapt thinly: one agent-neutral source per part, a thin adapter only
  where an agent needs one. [3.6]
- C7. No telemetry: nothing leaves the user's machine; upstream telemetry is dropped. [3.7]
- C8. Engine is exactly three MIT repositories, vendored at these commits: [2]
  - mattpocock/skills 5863806dd4e15c63174bee4e7515a4256792ecfa
  - DietrichGebert/ponytail 96608e078b2d5ea607c5c3b8b5a54d1c1fba6846
  - ayghri/i-have-adhd 1ecea1993b7fce257ffbd686c070948b5e07eda6
- C9. The command name is a working name; keep it in one place. [1]
- C10. Decisions D1 to D16 are Aakash's. A recommendation is a default to confirm, not
  settled. [7]
- C11. Document 01 wins over documents 02 to 09; raise the conflict before building. [header]
- C12. Tracer bullets: no milestone starts until the one before works end to end and
  Aakash says go. [5]

## Amendments

(dated, approved by Aakash)
```

## Conflicts between the documents (raised now, per document 01's header)

None blocks step 1. I will bring each back at the step it affects.

1. **CLAUDE.md.** Document 05 makes `CLAUDE.md` a symlink to a generated `AGENTS.md` (and
   static check 6 enforces it). Your step 6 asks for a hand-written `CLAUDE.md` for the
   builder. Both cannot hold once M2 generates the layer. Decision due at step 6.
2. **M1 and check 10.** Document 01 says M1 needs `check.sh` green; document 06 says M1
   means checks 1 to 9. I read these as compatible: 1 to 9 are required, 10
   (`claude plugin validate`) runs when the CLI is present. Confirm at step 4.
3. **When decisions are confirmed.** Document 01 section 7 says at the start of each
   milestone; you asked for all sixteen now. Your instruction wins; noted only.
4. **Own licence.** The layout has a `LICENSE` for DIY-harness itself, but no document says
   which licence. It is not among D1 to D16. I will add it as an extra question at step 2.
5. **Document 09 status labels** refer to v0.1 and v0.2 while the set is v0.3. Cosmetic.

## Verification

- `GOAL.md` exists and every line carries a section reference into document 01.
- You read it line by line and approve or amend; amendments go under `Amendments`.
- If H1 to H3 approved: `ls docs/spec` shows nine files and the diagram links resolve;
  `git status` works; root `skills/` is free.

## After approval

Step 2: decisions D1 to D5 with my recommendations, five at a time.
