# Builder rules

Root `CLAUDE.md` is reserved for a generated symlink (docs/adr/0002). These are the rules.

1. Read `GOAL.md`, `PLAN.md` and the current ticket in `tickets/` first. The spec is in `docs/spec/`; decisions are in `docs/adr/`.
2. Build one ticket: the lowest-numbered open one whose blockers are closed.
3. Build test-first. Write the ticket's acceptance checks, watch them go red, then make them green.
4. Never edit a test, a check or `GOAL.md` to get to green.
5. A proposal that traces to no `GOAL.md` line starts with "Drift:". A pending decision in `docs/adr/0001` is Aakash's: ask, do not assume.
6. Before every commit, review the diff with katsuo: the `katsuo:reviewer` agent, in a fresh context, given the ticket (or Aakash's request, for a change with no ticket), these rules and `.katsuo/review.diff`. Fix or report every finding; fix Blockers and Majors test-first and review again, at most two rounds. A change that still fails after two rounds (any verdict but PASS) is logged in `docs/review-log.md`. Before its milestone closes, every logged change is reviewed again: its merged diff (`gh pr diff <n>`) together with the files it touched as they stand then. Fixes made during that re-review count as its rounds and are not logged again. If it still fails after two rounds, ask Aakash; the milestone stays open until he decides.
7. Commit only after Aakash approves. `upstream/` is read-only and never committed.
8. Stop after each ticket.
