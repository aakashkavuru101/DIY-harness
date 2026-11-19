# STATE

- Stage: S1 Lock the goal
- Level: not chosen yet (S2 chooses it)
- Current ticket: none
- Next step: the user answers the eight open decisions below; none depends on another.

## Open decisions

- Agents: must the harness run in Claude Code only, or in Codex as well? Recommended: Claude Code only.
- Done when: is "no row is dropped silently" a done-when line? Recommended: yes.
- Data: may sample rows from real CSV files be shown to the agent? Recommended: no, synthetic rows only.
- Budget: is there a monthly spending limit for agent usage? Recommended: none beyond the current plan.
- Deadline: must the harness work by a fixed date? Recommended: no deadline.
- Autonomy: may the agent commit without asking each time? Recommended: no, it asks before every commit.
- Non-goal: is CI out of scope? Recommended: yes, out of scope.
- Never: may the agent ever overwrite an input CSV file? Recommended: never.

## Log

- 2026-11-12: S0 scan: Python, one script (`clean.py`), tests in `test_clean.py`, no CI, no hooks.
- 2026-11-13: S1 started: the harness is for `clean.py`, a CSV-cleaning script that one developer runs.
