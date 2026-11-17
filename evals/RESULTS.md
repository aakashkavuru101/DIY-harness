# Eval results

One line per run of `evals/run_evals.py`. Cost is Claude Code's own estimate (`total_cost_usd`) in US dollars;
on a claude.ai plan it is plan usage, not a bill.

| Date | Claude Code | Model | Cases | Trials | Cost | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
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
