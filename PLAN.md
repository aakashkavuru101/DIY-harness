# PLAN: milestone M1 (skeleton and vendoring)

GOAL lines: M1, DN1, C7, C8. Spec: docs/spec/01 section 5, 03 section 6, 05 section 1 and 3, 06 section 2, 07 section 9.
Decisions in force: docs/adr/0001 (D1, D6, D7, D10 confirmed) and docs/adr/0002.

M1 is done when every ticket below is closed and `scripts/check.sh` is green on checks 1 to 9
(check 10 when the `claude` CLI is present). Then stop and ask Aakash before M2.

## Tickets

Build in order. A ticket is unblocked when every ticket in its "Blocked by" is closed.
Mark a ticket closed by changing its `Status:` line, in the same commit as the work.

| # | File | Makes work | Blocked by |
| --- | --- | --- | --- |
| 01 | tickets/01-check-tracer.md | `scripts/check.sh` runs end to end with its own tests; check 9 | none |
| 02 | tickets/02-vendor-mattpocock.md | Eleven engine skills vendored unchanged; checks 1 and 8 (listing) | 01 |
| 03 | tickets/03-vendor-ponytail-adhd.md | Ponytail skills and i-have-adhd rules vendored; no telemetry files | 01 |
| 04 | tickets/04-playbooks-and-patches.md | Five playbooks, required patches, `vendor/PATCHES.md`; checks 2, 3, 8 (diff) | 02 |
| 05 | tickets/05-parent-stub-and-manifests.md | Parent skill stub and three manifests; checks 5, 7, 10 | 02, 03 |
| 06 | tickets/06-agents-md-and-remaining-checks.md | Generated `AGENTS.md`, `CLAUDE.md` symlink; checks 4, 6, no-network | 03, 05 |

## Rules for every ticket

- Tests live in `tests/check.test.sh` (plain shell, no dependency). Each check gets a
  must-fail fixture and a must-pass fixture under `tests/fixtures/`. Write them first and
  watch them go red.
- `check.sh` takes the repo root as an optional argument so tests can point it at a fixture.
- Vendoring copies from `upstream/` only. Nothing is fetched. Copy unchanged, commit, then
  patch in a separate commit (document 03 section 6).
- Out of M1: hook scripts, the real parent command, `install.sh`, `sync-upstream.sh`, evals,
  the D2 and D3 patches. If a ticket seems to need one, stop and say so.
