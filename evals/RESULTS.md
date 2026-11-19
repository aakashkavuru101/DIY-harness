# Eval results

One line per paid run: every run of `evals/run_evals.py`, and any other paid check. The Cost column is the ledger for
the total cap in PLAN.md Q2. The runner gives a run at most what is left and starts none below 0.10 USD; a call can
still pass the cap by part of itself (docs/adr/0003 R4). A row added by hand needs all 7 cells and a cost written like
$0.1234, or nothing runs. Cost is Claude Code's own estimate (`total_cost_usd`) in US dollars; on a claude.ai plan it
is plan usage, not a bill.

| Date | Claude Code | Model | Cases | Trials | Cost | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-11-16 | 2.1.325 (Claude Code) | unknown | ticket 07 live check, outside the runner | 1 | $0.4100 | reported as $0.41 |
| 2026-11-16 | 2.1.325 (Claude Code) | unknown | ticket 08 live checks, outside the runner | 3 | $0.5008 | the session's total after its three runs |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | ticket 09 probes and control calls, outside the runner | 25 | $1.2000 | upper bound: 2 full probes $0.0707, 19 probes stopped at init at up to $0.045 each, 4 control calls at up to $0.08 each |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-isolation | 1 | $0.0562 | 0 of 1 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn, smoke-env, E4 | 1 | $0.2280 | 1 of 3 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn | 1 | $0.0430 | 0 of 1 cases passed; stopped at the cost ceiling ($0.0430 of $0.01) |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-isolation | 1 | $0.0528 | 0 of 1 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn, smoke-env, E4 | 1 | $0.1866 | 1 of 3 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn | 1 | $0.0424 | 0 of 1 cases passed; stopped at the cost ceiling ($0.0424 of $0.01) |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-isolation | 1 | $0.0569 | 1 of 1 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn, smoke-env, E4 | 1 | $0.1846 | 2 of 3 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn | 1 | $0.0422 | 0 of 1 cases passed; stopped at the cost ceiling ($0.0422 of $0.01) |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-isolation | 1 | $0.0813 | 1 of 1 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn, smoke-env, smoke-skill-subagent, E4 | 1 | $0.2718 | 3 of 4 cases passed |
| 2026-11-16 | 2.1.325 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn | 1 | $0.0419 | 0 of 1 cases passed; stopped at the cost ceiling ($0.0419 of $0.01; the dearest call so far cost $0.0419) |
| 2026-11-17 | 2.1.326 (Claude Code) | claude-sonnet-5-5 | lang-ja | 3 | $0.2176 | 0 of 1 cases passed |
| 2026-11-17 | 2.1.326 (Claude Code) | claude-sonnet-5-5 | lang-ja | 3 | $0.2050 | 1 of 1 cases passed |
| 2026-11-17 | 2.1.326 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn | 1 | $0.0866 | 1 of 1 cases passed |
| 2026-11-17 | 2.1.326 (Claude Code) | claude-sonnet-5-5 | smoke-two-turn (no plugin) | 1 | $0.0412 | 1 of 1 cases passed |
| 2026-11-18 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E12, s0-status, s0-fresh, s0-no-git, s0-secret | 1 | $0.3418 | 0 of 5 cases passed |
| 2026-11-18 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E4, E12, s0-status, s0-fresh, s0-no-git, s0-secret | 1 | $0.6339 | 6 of 6 cases passed |
| 2026-11-18 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | s0-fresh, s0-no-git, s0-secret | 1 | $0.3888 | 2 of 3 cases passed |
| 2026-11-18 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | s0-fresh | 1 | $0.1187 | 1 of 1 cases passed |
| 2026-11-18 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E4, E12, s0-status, s0-fresh, s0-no-git, s0-secret | 3 | $1.8679 | 6 of 6 cases passed |
| 2026-11-19 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E1, E3, E9, s1-skip-gate | 1 | $0.5123 | 1 of 4 cases passed |
| 2026-11-19 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E1, E3, E9, s1-skip-gate | 1 | $0.5224 | 2 of 4 cases passed |
| 2026-11-19 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E3, E9 | 1 | $0.2452 | 1 of 2 cases passed |
| 2026-11-19 | 2.1.327 (Claude Code) | claude-sonnet-5-5 | E3, s1-skip-gate | 1 | $0.2171 | 2 of 2 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E4, E12, s0-status, E1, E3, E9, s1-skip-gate | 3 | $2.5422 | 6 of 7 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E4, E12, s0-status, E3, E9, s1-skip-gate | 3 | $2.0634 | 6 of 6 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E4, E12, s0-status, E1, E3, E9, s1-skip-gate | 3 | $2.4170 | 7 of 7 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E1, E6, s2-no-check, s2-secret, s2-level | 1 | $0.6526 | 0 of 5 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E1, E6, s2-no-check, s2-secret, s2-level | 1 | $0.9930 | 4 of 5 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E1 | 1 | $0.2931 | 1 of 1 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E4, E12, E3, E9, s1-skip-gate, E1, E6, s2-gate-l1, s2-no-check, s2-secret, s2-level | 3 | $5.4084 | 6 of 11 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E9, s1-skip-gate, E1, E6, s2-level | 1 | $1.0186 | 3 of 5 cases passed |
| 2026-11-19 | 2.1.328 (Claude Code) | claude-sonnet-5-5 | E4, E12, E3, E9, E1, E6, s2-level | 3 | $3.7520 | 5 of 7 cases passed |
