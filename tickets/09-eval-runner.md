# Ticket 09: the eval runner

Status: closed
Blocked by: none (built as Aakash answered Q2, Q3 and Q9 in `PLAN.md`; he set the Q2 cost cap to 10 USD in total for all paid runs in M2, 2026-11-17)
GOAL lines: M2, DN3, C7 · Decisions: D16 (pending, M6) · Spec: docs/spec/06 sections 4 and 5, 03 section 2

## What it makes work

An eval case runs in Claude Code from start to finish, isolated from the developer's own setup, over several
turns, under a cost ceiling, and gets a graded verdict. Each later prose ticket can then write its case first and
watch it fail.

- `evals/cases.jsonl`: one case per line, with these fields:
  - ID, fixture, and whether the copy is a git repo;
  - the prompt and the follow-up turns;
  - passes, blocks, and the code graders.
- `evals/fixtures/<name>/`: the starting repo state for a case.
- `evals/run_evals.py`, adapted from i-have-adhd's `scripts/run_evals.py` (MIT, at the pin). It is listed in the
  "own files" section of `vendor/UPSTREAM.md` with an "adapted from" note, and credited in `NOTICE` if code is
  copied. Per case and trial it does the following:
  - It copies the fixture into a temporary folder and makes it a git repo unless the case says not to.
  - It runs `claude -p` there with only this plugin loaded and none of the developer's settings, CLAUDE.md,
    memory, MCP servers, plugins or hooks. Each trial gets a throwaway config folder (`CLAUDE_CONFIG_DIR`, and
    `HOME` if needed), so the hooks' flags and the session files also stay out of the real `~/.claude`.
    - Sign-in (Q9): the runner passes on `CLAUDE_CODE_OAUTH_TOKEN`, which Aakash exports in his shell after running
      `claude setup-token` once. It never writes the token anywhere. It sets `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`, so
      the agent's tool subprocesses do not inherit the token. Verify what that variable strips, and record it in
      `docs/adr/0003`.
    - Use `--strict-mcp-config`, `--setting-sources` and `--plugin-dir`.
    - Do not copy upstream's `--disable-slash-commands`, `--tools ""` or `--no-session-persistence`: they would
      block `/diy-harness`, every graded tool call, and `--resume`.
    - Check what upstream's `--safe-mode` disables before using it.
  - It allows edits inside the temporary folder only, through an explicit tool list or `acceptEdits`. There is no
    permission bypass.
  - It runs follow-up turns in the same session with `--session-id` and then `--resume`. A turn may be a fixed
    message, or "repeat this answer until a grader holds, at most N turns", for grilling rounds of unknown count.
  - It snapshots the temporary folder after each turn, so a grader can tell which turn wrote a file.
  - It caps each run's cost with `--max-budget-usd`, at the ceiling from Q2.
  - It saves the transcript under `evals/runs/`, which is git-ignored.
  - Code graders check what happened: files written or not, file contents, tool calls (for example a Skill call
    for `grilling`, or a subagent dispatch), whether `STATE.md` changed, and "no write outside an allowed set
    before turn X" (for E1 and Q1). They never check the wording.
- `evals/judge.py`: one judge call for a condition only wording can show, such as "numbered questions with
  recommended answers". It returns pass or fail with a reason.
- The runner prints pass or fail per case, the trials, and the cost. It appends date, CLI version, model, cases,
  trials and cost to `evals/RESULTS.md`, and exits non-zero on any fail.
- Out of this ticket: the baseline condition, the rubric scores and the release gate (M6).

## Acceptance checks (red without this ticket)

1. Grader unit tests run from `tests/check.test.sh` on recorded transcripts and snapshots, with no model call.
   Cases: a file written, a file not written, a Skill call made, no Skill call made, a subagent dispatched,
   `STATE.md` changed, and a write before the allowed turn. Each verdict is right. The repeat-until turn rule
   stops when its grader holds, and at N turns otherwise.
2. Isolation: markers placed in the developer's user settings, user `CLAUDE.md` and a user plugin's hook do not
   appear in the runner's transcript.
3. A two-turn smoke case that needs no parent command passes. The second turn sees the first turn's context.
4. A case that writes a file in its temporary folder passes. Nothing changes outside the temporary folder and
   the throwaway config folder.
5. Case E4 (document 06 section 4) is in `evals/cases.jsonl` with its fixture. It runs end to end and fails,
   because the parent is still a stub, and the failing grader is named.
6. A run stops at the cost ceiling and reports it. `evals/RESULTS.md` gets one line per run with its cost.
7. The token never lands on disk. Before it finishes, the runner checks every saved transcript and `evals/RESULTS.md`
   for the token's value, and fails loudly if it finds it. A grader unit test covers this with a dummy token. A run
   in which the agent runs `env` shows no token.
8. `scripts/check.sh` exits 0, and its link and telemetry checks cover the new files.
