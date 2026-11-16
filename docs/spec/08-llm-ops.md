# LLM-ops for Harnesses

Document 08 of 09 · Draft v0.3 · 2026-11-16

> How a harness is operated after it is built: observed, measured, changed safely, kept cheap, and pruned. This is LLM-ops for the *agent plus harness* system on a developer's machine and in CI. It is not about serving models. Part IDs refer to the catalogue in document 02.

## 1. The operating loop

![The harness operating loop](diagrams/07-llmops-loop.svg)

A harness that is never measured only grows. The loop has six steps, and each maps to parts the command can build:

| Step | Question | Parts |
| --- | --- | --- |
| 1. Instrument | Is every session leaving a record? | QA18 |
| 2. Observe | What did the agent actually do, and what did it cost? | QA18, QA12, QA21 |
| 3. Diagnose | Which harness gap caused this failure? | KN8, QA8 |
| 4. Change | One harness change, reviewed like code | PR8, QA7, CO3 |
| 5. Verify | Did the change help, and did it break anything else? | QA15, QA16, QA20 |
| 6. Release and watch | Roll out, compare, keep or revert | QA19, QA10, QA22 |

## 2. Privacy stance

Principle 7 of the build brief stands: **nothing leaves the machine by default.**

- Telemetry is written to local files under `.harness/telemetry/`, which is git-ignored.
- Prompt and response *content* is not captured by default. Records hold counts, names, timings and outcomes. Content capture is an explicit opt-in per project, with redaction of secrets and personal data.
- Export to an observability backend is an explicit opt-in, to a backend the user owns or has approved. Retention, region and access are the user's decisions, recorded in an ADR.

## 3. What to record

One JSON line per event. Keep the schema small and stable.

| Record | Fields |
| --- | --- |
| Session | id, start and end, agent and version, model, harness version, level, stage, ticket |
| Turn | index, input tokens, output tokens, cached tokens, duration |
| Tool call | tool name, duration, success or failure |
| Guard | which guard, blocked or allowed, overridden or not |
| Skill | which skill fired, by user or by model |
| Check | which check, pass or fail, duration |
| Protocol | drift flagged, gate skipped, goal amended, level changed |
| Outcome | ticket done, commits, later reverted or reworked |

### How it is captured

- **Hooks write the records.** A post-tool hook and a session-end hook append lines; where an agent lacks a hook, the check scripts and git hooks write what they can see.
- **Native export where the agent has it.** Some agents can export logs and metrics to an OpenTelemetry backend directly; use that rather than rebuilding it.
- **OpenTelemetry naming for anything exported.** Use the GenAI semantic conventions (`gen_ai.*` attributes; agent, tool and MCP spans; an event for evaluation results). They are still marked Development and moved to their own repository in mid-2026, so **pin the convention version** the harness emits and expect renames.

## 4. Metrics that decide things

Collect few; each one must be able to change a decision.

| Metric | Reads as | Decision it drives |
| --- | --- | --- |
| Cost and agent time per merged change | Efficiency of the whole system | Did this harness change help? |
| First-pass check rate | How often work is green on the first try | Are the guides good enough? |
| Rework rate (reverts, follow-up fixes) | Quality that escaped the sensors | Is review catching enough? |
| Drift flags per session | Goal-lock pressure | Is the goal too vague, or tickets too big? |
| Guard blocks, and overrides | Guard value, and false positives | Keep, fix or remove a guard |
| Skill and rule fire rate | Use | A part that never fires is a no-op: prune it |
| Context size at stage end | Context health | Split tickets, or reset context sooner |
| Cache hit rate | Prompt stability | Stop rewriting the stable prefix |

## 5. Changing the harness safely

The harness is code. It gets the same discipline.

1. **Version it.** One harness version string, written into `STATE.md` and every telemetry record, bumped on any change to steering, skills, hooks or checks.
2. **Change through review.** Harness files are protected paths (PR8); changes arrive as a reviewed pull request with the failure-log entry that justifies them.
3. **One change at a time.** Otherwise the metrics cannot say which change helped.
4. **Changelog.** One line per change: what, why, which failure, expiry condition.
5. **Roll back with git.** A harness change that hurts is reverted, not patched around.

### Model and agent upgrade protocol (QA19)

A new model or a new agent version changes behaviour as much as a harness edit does. Before moving a pin:

1. Record the current model, agent version and metrics as the baseline.
2. Run the regression suite (QA15) on the new version, in batches.
3. Run the capability suite (QA16): what got better?
4. **Ablate:** switch off rules and guides one at a time on the new version. Any that no longer change the result are deleted. Harnesses shrink as models improve.
5. Canary on one project for a week of real work; compare section 4 metrics.
6. Move the pin, record it in an ADR, and keep the previous pin as the rollback.

## 6. Cost and context control

| Lever | What to do | Part |
| --- | --- | --- |
| Routing | Send each task type to the cheapest model and effort that passes its evals | CO4 |
| Stable prefix | Keep the always-on layer and steering byte-stable within a session so caching holds; never regenerate them mid-session | CO6 |
| Capped tool output | Cap every tool result at a fixed size; write the rest to a file and return the path | CO6 |
| Phase artefacts | End each stage in a short file, then start the next stage in a fresh context | PR4, CO6 |
| Subagent isolation | Search and exploration run in a subagent that returns file and line ranges, not transcripts | CO6, CO8 |
| Budgets | A token or cost ceiling per ticket; on reaching it the agent stops, reports and asks | QA12, PR7 |
| Fewer tools | Every visible tool costs context on every turn | CO8 |

Quality falls as context fills, well before the window is full. Treat context as a budget to manage from the start, not a limit to hit.

## 7. Incidents

An incident is any time the agent did something the harness should have stopped: a destructive action, a leaked secret, a followed injection, a weakened check.

1. **Stop.** Use the kill switch (QA22): one documented action that disables the agent's autonomy in that project, per agent.
2. **Preserve.** Keep the transcript and the telemetry for the session.
3. **Classify** against threats T1 to T10 (document 07) and name the layer that should have caught it.
4. **Record** in the failure log (KN8): what ran, what went wrong, root cause.
5. **Fix** with the cheapest enforced control, add an eval case that reproduces it, and give the control an expiry condition.
6. **Share** the entry if others use the harness.

## 8. Maintenance cadence

| When | Do |
| --- | --- |
| Every retro (S6) | Read transcripts behind any surprising metric; turn findings into tickets |
| Monthly | Prune: no-op rules, guards that never fired, controls past their expiry condition, docs that no longer match the code (KN9) |
| On a new model or agent version | Run the upgrade protocol |
| On an upstream engine change | Read the diff, run the evals, then move the pin |
| On an incident | Run section 7 the same day |

## 9. Ops parts by level

| Level | Ops parts the command may propose |
| --- | --- |
| L0 | None. `STATE.md` is the only record |
| L1 | KN8 failure log |
| L2 | QA8 retro, QA21 transcript review, PR9 expiry conditions, CO6 context policy, harness version and changelog |
| L3 | QA18 telemetry, QA12 cost tracking, QA15 to QA17 eval suites, QA19 upgrade protocol, QA20 ablation and pruning, CO4 routing |
| L4 | QA10 eval release gate, QA22 runbook and kill switch, QA23 judge calibration, optional export to an owned backend |

## 10. Tooling stance

DIY-harness ships no observability product and depends on none. Local JSON lines and a small report script are the default. For teams that want dashboards, the harness emits OpenTelemetry so any compatible backend can ingest it; prefer one that can be self-hosted, and treat the choice as the user's decision (D12 in document 03).
