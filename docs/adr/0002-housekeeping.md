# ADR 0002: Repo housekeeping

Date: 2026-11-16 · Decider: Aakash · Status: Confirmed · GOAL lines: C8, C11, M1

| Item | Decision | Why |
| --- | --- | --- |
| H1 Spec location | The nine spec files live in `docs/spec/`. `docs/spec/diagrams` is a symlink to `../../diagrams` | Image links in the spec resolve unchanged; `diagrams/` stays at the root as document 05 requires |
| H2 Git | Repo initialised 2026-11-16. Commits only after Aakash approves | Reviewers need diffs; document 03 section 6 needs commit history |
| H3 Upstream clones | The three clones live in `upstream/` (git-ignored), at the pins in GOAL.md C8. Read-only source for vendoring; nothing is fetched | Frees root `skills/` for the product |
| Own licence | MIT | Same as the three upstreams; no document names one |
| Builder rules | `.claude/CLAUDE.md`, hand-written. Root `CLAUDE.md` is reserved for the symlink to the generated `AGENTS.md` (document 05 section 1, static check 6) | Resolves the conflict between document 05 and the planner brief |
| M1 and check 10 | Checks 1 to 9 are required for M1. Check 10 runs when the `claude` CLI is present | Reconciles document 01 section 5 with document 06 section 2 |
| Step 3 VERIFY | Deferred to M4 (document 05 section 6 is the M4 checklist) | Only item 4 touches M1; ticket 05 covers it |
| Hook wiring (2026-11-16, `PLAN.md` Q8) | `.claude-plugin/plugin.json` has no `hooks` entry; `hooks/hooks.json` is loaded by convention. This departs from document 05 section 3, which lists a `hooks` field pointing at `hooks/hooks.json` | The Claude Code plugin manifest reference: "Claude Code merges whatever you declare with `hooks/hooks.json` when that file exists", so naming it may register every hook twice; upstream i-have-adhd ships without the entry. The doc quote and CLI version go in ADR 0003 with ticket 07 |
| Resume (2026-11-19, decided by Aakash) | When `.harness/STATE.md` exists, `/diy-harness` resumes in the same reply, with no confirm turn: it carries on with the next step of a built stage, and for a stage not built yet it reports and stops. The stage gates are unchanged, with one effect to know: the S1 gate sets `STATE.md` to S2 and then asks "start S2?", so a later `/diy-harness` starts S2 without asking again; typing the command counts as the yes. This departs from document 04 section 3, S0 step 1 ("continue there after the user confirms"), and from the Q5 reading of E4 in `PLAN.md` ("offers to continue ticket 03 and waits"). Until S5 is built, E4 passes when the reply names stage S5, ticket 03 and its next step, says the stage is not built yet, and starts no work; in M3 it returns to document 06's "continues ticket 03" | The agent ran ahead of the confirm turn in about one resume in three, through four rewordings of that step (`tickets/13-s2-assess-and-level.md`) |
