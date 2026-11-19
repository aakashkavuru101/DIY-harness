---
name: diy-harness
description: Build a custom harness for this project together with the user, as equals, one stage-gated step at a time, at any level from L0 to L4.
disable-model-invocation: true
---

# DIY-harness

Build this project's harness with the user, one stage at a time: S0 Orient, S1 Lock the goal, S2 Assess and choose a level, S3 Design, S4 Slice, S5 Build, S6 Run and retro. The state lives in `.harness/STATE.md`.

## The agreement, in short

- **Equals.** Look facts up yourself. Decisions are the user's: recommend an answer, then wait. Push back when a decision contradicts the goal or an earlier decision; the user rules.
- **Goal lock.** Once `.harness/GOAL.md` exists, read it before acting. A proposal that traces to no line in it starts with `Drift:`, names the gap, and asks whether to amend the goal or drop the work.
- **Earned parts.** Propose a part only for an observed failure or a goal line, at or below the current level. Park the rest. The user may override; record the override and its reason in `SPEC.md`.
- **Stage gates.** A stage ends when its criterion is met and the user confirms. Update `STATE.md`, then stop and ask.
- **State on disk.** Keep `.harness/STATE.md` good enough for a fresh session in any agent to resume from it alone.
- **Their files are theirs.** Never overwrite what the user wrote. Edit `AGENTS.md` only between the harness markers. Confirm before a destructive action.

## Every reply

From this command on, for the rest of the session:

1. Read `.harness/STATE.md` first, if it exists.
2. Make the first line the next action: something the user can do or answer now. No preamble.
3. Right after it, restate where the work stands on one line, such as `Stage: S5 Build · Ticket: 03`. Leave the ticket out when there is none.
4. End without a recap or a pleasantry.
5. Put at most 5 decisions or questions to the user in one reply, whatever their form: questions, a list of recommended answers to accept, a table. Say how many more wait; they come in later replies. The lines of a draft goal shown for approval do not count.

## What the user typed after the command

| Argument | Do this |
| --- | --- |
| none | Run S0 Orient below. |
| `status` | Read `.harness/STATE.md` and report the stage, the level, the current ticket and the open decisions. Change nothing: write no file and run no command that changes anything. If the file does not exist, say so and stop. |
| `level` | Run the S2 level assessment again on the current state: see "Run again" under S2 Assess and choose a level. |
| anything else | The text says what the harness is for and opens the S1 grilling. If `.harness/STATE.md` exists, run S0 Orient and take the text as input to the stage it names. Otherwise run steps 1 to 3 of S0 Orient, then start S1 Lock the goal in the same reply: the text is the user's choice of stage. |

## S0 Orient

Purpose: resume, or start cleanly.

**If `.harness/STATE.md` exists:** resume in the same reply. Do not ask whether to continue. Do not redo an earlier stage or rescan the repo.

- The stage is S0, S1 or S2: carry on with its next step now, under that stage's own rules. At S0, ask which stage to work in, as in step 4 below. At S1, run the next grilling round, with at most 5 decisions or questions in the reply; when the frontier is empty, run the gate instead and show the draft goal line by line for approval. At S2, run the assessment, steps 1 to 6, ending with the level proposal.
- The stage is S3 to S6: report the stage, the level, the current ticket and the next step from `STATE.md`, say that this stage is not built yet, and stop. Start no work on it.

The stage gates still hold: the S1 gate stops and asks before S2 starts, and the S2 gate waits for the user's level. The reply follows "Every reply": the next action on the first line, then the one-line stage restatement, no recap. Do not narrate what you read, re-checked or left unchanged.

**Otherwise:**

1. If the folder is not a git repository, ask the user whether to run `git init`: the harness relies on commits for review. Never run it before they say yes. Carry on with steps 2 to 4 either way.
2. Dispatch one subagent with a fresh context to scan the repo. Run it in the foreground, not in the background, and wait for its report before you reply. Its brief:
   - Use the file listing, reading and search tools, one simple command at a time, run from the repo's folder (no `cd`, no `git -C`). A chained or redirected shell command may be refused.
   - Report facts only, no advice: the language, the check commands that exist (test, lint, build), CI, hooks, steering files (`AGENTS.md`, `CLAUDE.md` and the like), existing skills, and whether there is code yet.
   - Secrets: for a file that holds or may hold secrets (`.env`, keys, tokens, credentials), report its path and the kind of secret, but never open it, and never print or search its contents.
3. Read [the template](references/templates/STATE.md), in this skill's own folder, and create `.harness/STATE.md` from it. Keep its headings and field names, fill in every field, and leave out its comments. The stage is S0 Orient, and one log line holds the scan's facts. Write no other file. Redact secrets and personal data in `STATE.md` and in every file under `.harness/`, now and at every later update: paths and kinds, never a value. If the template cannot be read, say so and ask the user to allow the read; do not improvise the file.
4. Tell the user what the scan found in a few lines, including any file that holds secrets. Ask which stage to work in, and recommend S1 Lock the goal.

Done when: the user has confirmed the stage to work in. On a resume at S1 or later, `STATE.md` already names it.

## S1 Lock the goal

Purpose: a goal sharp enough to steer by.

1. Call the Skill tool twice, for `grilling` and `domain-modeling`, and follow both within this limit: until the goal is approved, write only under `.harness/`. `GLOSSARY.md` and `docs/adr/` wait until S2 has chosen L1 or above; until then, note resolved terms and hard-to-reverse decisions in `.harness/research/notes.md`.
2. Aim the grilling frontier at nine topics:
   - the work the harness serves and who runs it;
   - the goal in one sentence;
   - observable done criteria;
   - non-goals;
   - which agents must run it;
   - observed failures the user has already hit;
   - constraints (data that must not leave, budget, deadlines);
   - what must never happen in this repo;
   - the autonomy tier the user wants: how much the agent may do without asking.

   Leave out a topic that the user's opening text, `STATE.md` or the draft goal already settles. The open decisions in `STATE.md` are the frontier. Look facts up yourself; ask only for decisions.

   Before the first round, set the stage in `STATE.md` to `S1 Lock the goal` and write the frontier under its open decisions, so a fresh session resumes here.
3. For an external fact a decision needs, call the Skill tool with `research`. Its notes file goes in `.harness/research/`.
4. After each round of answers, update the draft `.harness/GOAL.md`. Create it from [the template](references/templates/GOAL.md): keep its seven headings, leave out its comments, and head it `# GOAL (draft, not approved)`. Update the open decisions and the log in `STATE.md` too. Secrets and personal data stay out of all of them: paths and kinds, never a value.
5. The gate. When the frontier is empty, show the draft goal line by line, numbered, and ask the user to approve or change each line. A gap or a rewording you want to raise is a question for a round before the gate, not a line mixed into the approval: a bare "ok" approves the lines as shown. Once they approve every line:
   - make the heading of `GOAL.md` `# GOAL`;
   - in `STATE.md`, set the stage to `S2 Assess and choose a level`, set the next step, and log the approval;
   - stop, and ask whether to start S2. Do not start S2 in the same reply.

If the user skips the gate ("just do it") with questions still open or lines not approved: take your recommended answers, finish `GOAL.md` the same way, log the skipped S1 gate and what you assumed in `STATE.md`, tell the user in one line that the skip is logged, and move on to S2 without asking again. A skip covers this stage only: S2 gates again.

Done when: the frontier is empty and the user has approved `GOAL.md` line by line.

## S2 Assess and choose a level

Purpose: decide how much harness this goal needs.

1. If the repo has code, call the Skill tool with `ponytail-audit` for a ranked baseline. Tell it: name a file that holds or may hold secrets by its path and the kind of secret, and never open it, print it or search its contents. A small repo still gets the audit: it is short when there is little to find. Save the report as `.harness/research/audit-<date>.md`. The report is not the reply: give it at most 3 lines in the reply, and carry on with steps 2 to 6 in the same reply.
2. List the safety facts, looked up, not asked: secrets in reach (paths and kinds: never open such a file, and never print or search its contents), existing deny rules, hooks, the sandbox state, and installed MCP servers and skills.
3. Find the check command yourself: read the package manifest's scripts, the Makefile, the CI files and the test folders. Never ask the user what the test or check command is; name the one you found. If the repo has none, propose the cheapest real check the language offers without installing anything, as the first ticket.
4. Read [LEVELS.md](references/LEVELS.md) and [PARTS.md](references/PARTS.md), in this skill's own folder. Map each goal line and each observed failure to the parts that answer it.
5. Apply the ponytail ladder to each part: does it need to exist, is it already in the repo, can an existing tool do it? Drop what fails.
6. Propose the level: the highest minimum level among the parts that remain, which is the lowest level that meets the goal. In doubt between two levels, propose the lower one and name the failure that would earn the next. Give one line per part saying what it answers, at most 5 lines per group, with the check command and the secrets you found. Use the grilling format, so "yes" accepts the level you recommend. Then stop and wait: the level is the user's decision.

The gate. Once the user has chosen a level:

- record it in `STATE.md` with the reason: the level field reads like `- Level: L1, because <the reason in one clause>`, and the log gets a line;
- at L1 or above, move the terms and decisions parked in `.harness/research/notes.md` to `GLOSSARY.md` and `docs/adr/`, in the formats `domain-modeling` gives. If those files exist, add to them, never overwrite;
- set the stage to `S3 Design`, then stop. S3 is not built yet: say so.

Done when: the user has chosen a level, and `STATE.md` records it with the reason.

Run again (`level`). Run steps 1 to 6 on the current state, whatever the stage. In step 1, reuse the newest `.harness/research/audit-*.md` when one exists, and run the audit when none does. Leave `.harness/GOAL.md` unchanged. Once the user has chosen, follow the first two points of the gate; the stage stays as it is, unless it is S2. Without an approved `GOAL.md`, say so and stop.

## When the session nears its context limit

Update `.harness/STATE.md`, then recommend a fresh session at the next stage boundary.
