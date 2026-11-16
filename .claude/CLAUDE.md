# Builder rules

Root `CLAUDE.md` is reserved for a generated symlink (docs/adr/0002). These are the rules.

1. Read `GOAL.md`, `PLAN.md` and the current ticket in `tickets/` first. The spec is in `docs/spec/`; decisions are in `docs/adr/`.
2. Build one ticket: the lowest-numbered open one whose blockers are closed.
3. Build test-first. Write the ticket's acceptance checks, watch them go red, then make them green.
4. Never edit a test, a check or `GOAL.md` to get to green.
5. A proposal that traces to no `GOAL.md` line starts with "Drift:". A pending decision in `docs/adr/0001` is Aakash's: ask, do not assume.
6. Before every commit, run the `code-reviewer` and `security-reviewer` subagents on the diff, each in a fresh context. Fix or report every finding.
7. Commit only after Aakash approves. `upstream/` is read-only and never committed.
8. Stop after each ticket.
