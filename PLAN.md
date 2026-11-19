# PLAN

Milestones M1 and M2, both done. Each ticket is closed by changing its `Status:` line, in the same commit as the work.
A ticket is unblocked when every ticket in its "Blocked by" is closed. Build in order.

## M1: skeleton and vendoring (done)

GOAL lines: M1, DN1, C7, C8. Spec: docs/spec/01 section 5, 03 section 6, 05 section 1 and 3, 06 section 2, 07 section 9.
Decisions in force: docs/adr/0001 (D1, D6, D7, D10 confirmed) and docs/adr/0002.

M1 is done when every ticket below is closed and `scripts/check.sh` is green on checks 1 to 9
(check 10 when the `claude` CLI is present). Then stop and ask Aakash before M2.

| # | File | Makes work | Blocked by |
| --- | --- | --- | --- |
| 01 | tickets/01-check-tracer.md | `scripts/check.sh` runs end to end with its own tests; check 9 | none |
| 02 | tickets/02-vendor-mattpocock.md | Eleven engine skills vendored unchanged; checks 1 and 8 (listing) | 01 |
| 03 | tickets/03-vendor-ponytail-adhd.md | Ponytail skills and i-have-adhd rules vendored; no telemetry files | 01 |
| 04 | tickets/04-playbooks-and-patches.md | Five playbooks, required patches, `vendor/PATCHES.md`; checks 2, 3, 8 (diff) | 02 |
| 05 | tickets/05-parent-stub-and-manifests.md | Parent skill stub and three manifests; checks 5, 7, 10 | 02, 03 |
| 06 | tickets/06-agents-md-and-remaining-checks.md | Generated `AGENTS.md`, `CLAUDE.md` symlink; checks 4, 6, no-network | 03, 05 |

Out of M1: hook scripts, the real parent command, `install.sh`, `sync-upstream.sh`, evals,
the D2 and D3 patches.

## M2: parent command S0 to S2 in Claude Code (done)

GOAL lines: M2, G1, C1 to C5, C7, C9, C12. Spec: docs/spec/01 section 5, 03 sections 3 and 4, 04 sections 1 to 3
(S0 to S2), 4, 5 and 6, 05 section 2, 06 sections 4 to 6, 07 section 9.
Decisions in force: docs/adr/0001 (D1, D2, D5 to D10 confirmed; D11 organisation and language confirmed, name
pending), docs/adr/0002, docs/adr/0003.

M2 is done when every ticket below is closed, `scripts/check.sh` is green, the always-on hook is active in
Claude Code, and eval cases E1, E3, E4, E6, E9 and E12 pass in Claude Code (document 06 section 6) under the
trial rule in Q2, and every M2 change in `docs/review-log.md` has been reviewed again and passes, or Aakash has decided on it.
Then stop and ask Aakash before M3.

Closed on 2026-11-19. Tickets 07 to 13 are closed, `scripts/check.sh` is green, the always-on hook is active in
Claude Code (check 8 of `tickets/07-always-on-hook.md`, observed on 2026-11-16: `docs/adr/0003` H1), and the six cases pass on the final text (the
proving run, 16 of 16 cases, with E1's saved trials graded again under its new write checks:
`tickets/13-s2-assess-and-level.md`). Of the eight changes in
`docs/review-log.md`, five pass their re-review: rows 1, 2, 3 and 7, and row 8, which is the change that closed M2
(PR #20, re-reviewed on 2026-11-19). Aakash decided on rows 4, 5 and 6 after a third review: row 5 is fixed (that
fix is row 8), and rows 4 and 6 are the first M3 ticket ("Carried into M3", below). He asked for the M3
plan next, with no paid run until he has seen its cost figure.

| # | File | Makes work | Blocked by |
| --- | --- | --- | --- |
| 07 | tickets/07-always-on-hook.md | The always-on layer reaches every Claude Code session and subagent; budget check | none |
| 08 | tickets/08-off-switches.md | "stop ponytail", "stop adhd mode" and "normal mode", for a session or for good | 07 |
| 09 | tickets/09-eval-runner.md | Eval cases run in Claude Code, isolated, multi-turn, capped, and graded | none |
| 10 | tickets/10-working-agreement.md | The real working agreement in the always-on layer | 07, 09 |
| 11 | tickets/11-s0-orient.md | `/diy-harness` resumes from `STATE.md` or starts cleanly; `status`; E4 and E12 | 09, 10 |
| 12 | tickets/12-s1-lock-the-goal.md | S1 grills, writes `GOAL.md` and gates; D2 patch to `grilling` | 11 |
| 13 | tickets/13-s2-assess-and-level.md | S2 audits, proposes a level and records it; `level` | 12 |

### Questions for Aakash

Tickets that depend on one name it. Aakash answered Q1 to Q9 on 2026-11-16: Q1 to Q6 as recommended; Q7 to Q9 as
the "Builder's recommendation" column says. He set Q2's cost ceiling the same day: "cost is 5 USD max", and made it a
total on 2026-11-17: "total cap not to exceed 5 USD", then raised it the same day: "i am increasing the cap to 10 USD
for full M2". On 2026-11-19, with 1.20 USD left before ticket 12's 3-trial run, he raised it to 20 USD, and the same day,
with 2.24 USD left before ticket 13's 3-trial run and the M2 acceptance run, to 32 USD. The M2 re-review then
found text to fix and cases with no run on the final text; he chose to fix and prove them, which raised it to 39 USD.
All paid runs together, the live checks of tickets 07 and 08 included, stay within 39 USD; `evals/RESULTS.md`
is the ledger, and `evals/run_evals.py` gives a run at most what is left. Claude Code checks a budget only after
each API call, so the runner starts no call unless what is left covers the dearest call so far; a call dearer than all
before it can still overshoot by part of itself (`docs/adr/0003` R4). Q7 to Q9 came from checking the Claude Code docs for ticket 07; the
facts are in `docs/adr/0003` (H1 to H8, R1 to R9).

| # | Question | Conflict | Builder's recommendation (accepted) | Blocks |
| --- | --- | --- | --- | --- |
| Q1 | What may be written before the goal is approved? | E1 fails on any write before approval (document 06 section 4). Yet S0 creates `STATE.md`; the S1 gate has the user approve `GOAL.md` line by line, which implies the file exists; `domain-modeling` updates `GLOSSARY.md` "right there" and `research` writes a notes file; S2 stores the audit in `.harness/research/`. `GLOSSARY.md`, `docs/adr/` and `.harness/research/` are "from L1" (document 04 section 4), but no level exists before S2. `STATE.md` must fit on one screen and point at files rather than copy them (document 04 section 5), so it cannot hold the notes | (b): writes under `.harness/` are allowed before approval, and E1's "any file" means files outside `.harness/`. The draft `GOAL.md` and research notes live in `.harness/`. `GLOSSARY.md` and `docs/adr/` wait until the goal is approved and S2 picks L1 or above, by a parent instruction to `domain-modeling`; a vendor patch (with a decision ID and a PATCHES row) only if an eval shows the instruction fails. The alternative, (a): hold the draft goal, terms and notes in the conversation and write them all on approval | 11, 12, 13 |
| Q2 | How many trials per case in M2, what counts as a pass, and what cost ceiling per run? | Document 06 section 5 asks for 3 trials, and warns that all-trials rules belong only on critical cases ("scope absolute rules to what must never happen"). None of the six M2 cases is critical. D16 (trials and budget) is due at M6 | 3 trials per case; a case passes when at least 2 of 3 pass and no trial hits its blocking behaviour; a ceiling per run that Aakash sets. Until then, ask before every paid run (since 2026-11-19: a 39 USD total for M2, see above) | 09 to 13 |
| Q3 | Build the eval runner in M2? | Document 03 section 2 schedules adapting i-have-adhd's runner for M6; document 06 section 6 needs cases passing in M2 | Yes: a minimal runner in M2 (ticket 09); the rubric, judge scores, baseline and release gate stay in M6 | 09 |
| Q4 | Where do the project's own steering files rank? | Document 03 section 4 orders system rules, safety, the agreement, ponytail and i-have-adhd, but not the user's own `CLAUDE.md` or `AGENTS.md` | Right after safety, above the agreement: the user's own rules beat DIY-harness's | 10 |
| Q5 | Three readings of the M2 cases in document 06 section 4 | E4 "continues ticket 03", but S5 arrives in M3. E12 says "any stage, any turn", but the stage is only known once the parent has read `STATE.md`. A repo with no check command (document 04 section 6) has no case | E4 passes when the agent offers to continue ticket 03 and waits (document 04 S0 step 1). E12's turns are `/diy-harness` and then one ordinary turn in the same session. The no-check-command edge gets its own new case in ticket 13, and E1 stays as written. Since 2026-11-19 a resume no longer waits for a confirm, and E1 passes at L0 or at L2, whichever fits the goal's autonomy line: see the "Resume" and "Levels" rows of `docs/adr/0002` | 11, 13 |
| Q6 | Accept the agreement as always on everywhere? | The agreement has no off switch (document 05 section 2 names only ponytail and i-have-adhd), and its "equals" rule (give the recommended answer, then wait) changes how the agent works in every project, even one that never ran `/diy-harness` | Accept it as a residual risk for M2, because its goal-lock and stage rules already apply only once `.harness/` exists. Revisit after the M3 real-project trials | 10 |
| Q7 | How does the layer fit Claude Code's cap of 10,000 characters per hook output? Longer text goes to a file and Claude sees a 2,000-character preview | The layer is already 9,919 characters with the stub agreement; the subagent layer (ponytail and i-have-adhd) is 9,808, which leaves almost no room for a header or growth | One hook run per rule set, each under 10,000 characters; vendored text unchanged; `AGENTS.md` stays the one source. The runs may happen in parallel, so the agreement states the precedence in words (ticket 10). The budget check also enforces 10,000 characters per part | 07, 10 |
| Q8 | Name `hooks/hooks.json` in `plugin.json`? | Document 05 section 3 asks for it; the Claude Code docs say `hooks/hooks.json` loads automatically and is merged with any hooks file the manifest names, so it may register twice | Leave the entry out, as upstream i-have-adhd does; the manifest check asserts `hooks/hooks.json` exists; ADR 0003 records the doc quote, and ADR 0002 records the deviation from document 05 section 3 | 07 |
| Q9 | How do isolated eval runs sign in? | A throwaway `CLAUDE_CONFIG_DIR` has no login (Claude Code docs, authentication) | Aakash runs `claude setup-token` once and exports the token as `CLAUDE_CODE_OAUTH_TOKEN` in his shell, outside the repo; it never enters the repo or a transcript. As built: the token is set for the eval command only, never exported in a shell profile, because the variable overrides the normal login in every session (`docs/adr/0003` R3, `evals/README.md`) | 09 |

### D5: always on, with its risks managed

Aakash on D5 (2026-11-16): "keep D5, always ON, but consider the risk and ways to manage and mitigate it".
This table was the builder's proposal for that. Aakash accepted the nine mitigations as built on 2026-11-19. Upstream i-have-adhd makes
its own always-on mode opt-in (a flag file); DIY-harness turns it on by default, so the off switches and the
budget carry more weight here.

| Risk | Mitigation | Ticket |
| --- | --- | --- |
| Context cost in every session, in every project | Budget check in `check.sh` (about 4,000 tokens, document 05 section 2); the real count is measured in isolation once the agreement is final and goes in the README; over budget, trim i-have-adhd's examples first and keep every rule. Measured: 5,479 tokens per request, of which about 3,000 (the three rule sets) are under the budget check and the rest are not broken down | 07, 10 |
| A broken or stuck hook blocks or slows a session | Every hook (session start and the prompt tracker) never exits non-zero, has a `timeout` in `hooks.json`, and has a fallback timer for stdin that never closes; tests for each. On unreadable input the session-start hook fails open: it prints its rule set | 07, 08 |
| Hook code runs in every session (supply chain) | No network (check exists); short enough to read. Ticket 07 reads only the plugin's own files, located from its own path. Ticket 08 adds reading `CLAUDE_CONFIG_DIR` and `DIY_HARNESS_OFF` and writing flags under the config folder, with the limits in the "flag files" row | 07, 08 |
| The layer is lost after `/clear` or compaction | The SessionStart matcher covers startup, resume, clear and compact | 07 |
| The rules change how the agent works in projects that never ran `/diy-harness` | Per-session off phrases, a persistent off switch per rule set (user-wide or per project), both documented in the README. The agreement stays on: Q6 | 08 |
| A rule set is injected twice when an upstream ponytail or i-have-adhd plugin is also installed (D6) | The README says to uninstall the upstream plugins; the hook's first line names the rule sets it loaded, so the agent can see and report a duplicate | 07, 08 |
| The layer fights the agent's system prompt, or the project's own steering files | The agreement states the precedence of document 03 section 4; where project steering ranks is Q4 | 10 |
| Off-switch flag files leak data, follow symlinks or grow without bound | Flags hold only which rule set is off, never prompt text; session IDs are validated; writes go through a temp file and rename; pruning touches only regular files named like a flag, never follows a symlink; a relative `CLAUDE_CONFIG_DIR` is ignored | 08 |
| The agreement (which holds the L0 guardrail "confirm before destructive actions") is switched off by a cloned repo's settings | `DIY_HARNESS_OFF` accepts only `ponytail` and `adhd`; the agreement has no off switch (document 05 section 2 names only those two); a rule set switched off by it is named in the hook's first line | 08 |

### Rules for M2 tickets

- The rules for every ticket, below, still hold.
- Prose (skills, references, the agreement) is proved by eval cases: write the case first, watch it fail, then
  make it pass (document 04 S5 step 3). Static checks still cover structure.
- A case that already passes before the change is kept as a regression guard, and the change needs another proof
  that goes red without it. If none exists, the change is not earned (C3): say so and ask Aakash.
- Running an eval case costs plan usage. All paid runs together stay within 39 USD for M2 (Q2), counted in
  `evals/RESULTS.md`, and each run's cost is reported to Aakash. Work that would pass the total asks him first.
- Ledger rows are committed with the PR of the work that paid for them, and never removed.
- Out of M2: stages S3 to S6, Codex, `install.sh`, `sync-upstream.sh`, the baseline condition, rubric scores and
  the release gate (M6), the D3 and D4 patches. If a ticket seems to need one, stop and say so.

### Carried into M3

Work M2 left for later, each with the file that says why:

- The first M3 ticket: rows 4 and 6 of `docs/review-log.md`, which Aakash carried into M3 on 2026-11-19 after
  the third review. Fix test-first, then prove with a paid run inside M3's cost figure. The 8 cases that read the
  changed text (`s0-status`, `s0-status-s1`, E1, E6, `s2-gate-l1`, `s2-no-check`, `s2-secret`, `s2-level`) cost
  3.80 USD at 3 trials in the proving run's transcripts, so about 4.25 USD with the judge calls.
  - Decided by Aakash: `status` lists the open decisions and invites no answer, so a reply such as "reply yes to
    accept" fails case `s0-status-s1` (`docs/adr/0002`, "Status").
  - Decided by Aakash: `LEVELS.md` names the tier that runs some commands freely and asks before others as a
    safety fact, and says the level stays L2 when a sandbox is already on (`docs/adr/0002`, "Levels").
  - From the third review's minor findings, the builder's proposal for that ticket: the judge of `s0-status-s1`
    requires the level and the ticket outright; static pins for the sentences E1 relies on ("IN7, so at least
    L2", the "stated rule" sentence, "never that a safety fact needs no part").
- E1 can pass on a goal the user never saw: in one proving trial the agent took the scripted answer as a gate
  skip and headed the goal "approval skipped". The case only checks that the draft mark is gone; that trial
  failed on its level alone (`tickets/13-s2-assess-and-level.md`, "Third review").
- E1's strict write check covers turns 1 and 2 and every turn before the last. So from turn 3 on, the turn that
  records the level may write `GLOSSARY.md` and `docs/adr/` whatever the level, and whether or not the user
  accepted it: an L0 trial that does so is not blocked. When that turn is turn 3, this is looser than the check
  it replaced. The ninth turn of a trial that never records a level is not checked strictly either. A last turn
  that ends in an error is checked strictly even if it recorded the level
  (`tests/test_evals.py`, the `shortcut:` note). If M3 stops E1 from reading its scripted answer as a gate skip,
  turn 3 can be strict again.
- Revisit the always-on agreement after the M3 real-project trials (Q6).
- Break down the always-on cost: 5,479 tokens per request were measured, and about 2,450 of them are outside the
  budget check (`README.md`, "Always-on cost").
- E4 returns to document 06's "continues ticket 03" when S5 is built (`docs/adr/0002`, "Resume").
- `PARTS.md` lacks the "Proved by" column that S3 needs (`tickets/13-s2-assess-and-level.md`).
- The permission prompt for a skill's own template read in a real install is unchecked until the M4 smoke test
  (`docs/adr/0003` R9).
- Not proved by a case yet: "add to them, never overwrite" at the S2 gate, `level` reusing a saved audit, a resume
  at stage S0, and the first line of the "not built yet" reply (`tickets/13-s2-assess-and-level.md`). Also four
  sentences added in the M2 re-review: "do not dispatch the scan again" on a resume (1 of 9 resumes did, in the
  second acceptance run), `research` told the secrets rule, secret files kept out of tree-wide searches, and
  servers, hooks and rules listed by name only.
- `evals/run_evals.py`: a ledger row whose first cell is `---` or `Date` is skipped as a header, and a second
  signal that lands inside `finish()` can lose the run's ledger row. Both were left as they are.
- The parent `SKILL.md` holds S0 to S2 inline. Move stage detail to `references/` before S3 to S6 double it
  (document 04's header: the parent stays short).

## Rules for every ticket

- Tests live in `tests/check.test.sh` (plain shell, no dependency). Each check gets a
  must-fail fixture and a must-pass fixture under `tests/fixtures/`. Write them first and
  watch them go red.
- `check.sh` takes the repo root as an optional argument so tests can point it at a fixture.
- Vendoring copies from `upstream/` only. Nothing is fetched. Copy unchanged, commit, then
  patch in a separate commit (document 03 section 6).
