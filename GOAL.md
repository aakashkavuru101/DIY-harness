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
