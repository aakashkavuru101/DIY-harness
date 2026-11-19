# ADR 0001: Decisions D1 to D16

Date: 2026-11-16 · Decider: Aakash · Source: docs/spec/03-engine-integration.md section 5 · GOAL line: C10

**Confirmed** means Aakash approved the document 03 recommendation, on 2026-11-16 for M1 and again at the
start of M2 (same date); a note records his words where he added to it. Where document 03 made no
recommendation (D11), the row records his answer.
**Pending** means the recommendation is only a default. Confirm it with Aakash at the start of
the milestone listed before building on it.

| ID | Decision | Answer (document 03 recommendation) | Status | Confirm at |
| --- | --- | --- | --- | --- |
| D1 | How the parent calls upstream user-invoked commands | Vendor them as stage playbooks inside the parent | Confirmed | |
| D2 | Question cap during grilling | At most 5 per round, no cap on the total; patch `grilling` | Confirmed | |
| D3 | Which review | Matt's two-axis `code-review`, Standards axis fed ponytail-review's checklist | Pending | M3 |
| D4 | How much testing | TDD only at agreed seams for non-trivial logic | Pending | M3 |
| D5 | Always-on content and cost | One generated file; measure tokens; off switches. Aakash: "keep D5, always ON, but consider the risk and ways to manage and mitigate it". The builder's proposal for that is the D5 table in `PLAN.md`; he accepted its nine mitigations as built on 2026-11-19 | Confirmed | |
| D6 | Name collisions with upstream plugins | Keep upstream names; README says uninstall upstream; `check.sh` warns | Confirmed | |
| D7 | Ponytail telemetry | Drop band, board, statusline and webhooks entirely | Confirmed | |
| D8 | Ponytail's closing risk line | Keep it as the last line, after the next action | Confirmed | |
| D9 | Ponytail level default | Full; ultra during S3 | Confirmed | |
| D10 | Upstream sync policy | Pinned commits; `scripts/sync-upstream.sh` shows the diff; evals before a bump | Confirmed | |
| D11 | Product name, GitHub organisation, language | Organisation: `aakashkavuru101`. Language: prompts in English, replies in the user's language. Name: `diy-harness` stays a working name (C9). A rename must also change: the `DIY_HARNESS_OFF` variable, the `diy-harness/` folder under the Claude config folder, and the `diy-harness` text in the hook messages (`hooks/`) | Organisation and language confirmed; name pending | No milestone set: Aakash chooses the name |
| D12 | Harness telemetry | Local JSON lines; export only by opt-in | Pending | M7 |
| D13 | Content capture in telemetry | Off by default; opt-in with redaction | Pending | M7 |
| D14 | Default autonomy tier | Tier B at L0 and L1 | Pending | M3 |
| D15 | Sandbox fallback | Container or dev container; say so at S3 | Pending | M5 |
| D16 | Eval trials and budget | 3 trials, 5 on critical cases, user-set cost ceiling | Pending | M6 |
