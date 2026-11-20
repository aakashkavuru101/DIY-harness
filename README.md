# DIY-harness
DIY-harness: build a custom agent harness for your project with /diy-harness

## The command

Run `/diy-harness` in your project. It builds the harness with you one stage at a time, and at the end of each stage it stops and asks before the next. Its state lives in `.harness/STATE.md`, so a later `/diy-harness` carries on where you stopped.

| Stage | What happens |
| --- | --- |
| S0 Orient | Resumes from `.harness/STATE.md`, or scans the repo and starts cleanly |
| S1 Lock the goal | Questions with recommended answers, then `.harness/GOAL.md`, which you approve line by line |
| S2 Assess and choose a level | Audits the repo and proposes a level, with the reason; you choose |
| S3 Design | The smallest set of parts that meets the goal, each with its proof; every other idea is parked |
| S4 Slice | One ticket per part, in build order. Skipped at L0 |
| S5 Build | One ticket per pass: the proof goes red, the part is built, the proof goes green, the change is reviewed, and it is committed when you say yes |

`/diy-harness status` reports the stage, the level, the ticket and the open decisions, and changes nothing. `/diy-harness level` assesses the repo again.

A level is a ceiling: a part is built only when a goal line or an observed failure calls for it.

- **L0** holds the goal, the state with its spec, a block of pointers between markers in your `AGENTS.md` (with `CLAUDE.md` linked to it, or kept and pointing at it when you already have one), and one check command that goes red on a break.
- **L1** can add a spec and tickets, a glossary and decision records, tests at seams you agree, a two-axis review per change, a pre-commit hook that runs the check, and guards against secret reads and destructive commands. Each guard is a script with one test it must block and one it must allow.

Not built yet: stage S6 (run and retro), Codex, and levels above L1. At L2 or above, S3 parks the higher parts and says why.

## Off switches

DIY-harness adds two rule sets to every session: ponytail (build rules) and i-have-adhd (output rules). Switch them off with a prompt that is exactly one of these:

| Prompt | Switches off |
| --- | --- |
| "stop ponytail" | ponytail |
| "stop adhd mode" | i-have-adhd |
| "normal mode" | both |

The switch lasts for the session: it survives resume and compaction, and `/clear` or a new session brings the rules back. A session left unused for more than 7 days loses its switch.

To switch one off for good, set `DIY_HARNESS_OFF` to `ponytail`, `adhd` or `ponytail,adhd`. In `~/.claude/settings.json` it applies everywhere; in a project's `.claude/settings.json`, only there:

```json
{ "env": { "DIY_HARNESS_OFF": "adhd" } }
```

The working agreement has no off switch.

If you also have the upstream ponytail or i-have-adhd plugins installed, uninstall them: otherwise their rules load a second time.

## Always-on cost

DIY-harness adds 5,479 input tokens to every request. Measured on 2026-11-17 with Claude Code 2.1.326 and claude-sonnet-5-5: the first request of a session carried 17,966 input tokens with the plugin and 12,487 without it (`evals/run_evals.py --case smoke-two-turn --trials 1`, then the same with `--no-plugin`).

About 3,000 of the added tokens are the three rule sets (12,085 bytes, estimated as bytes / 4). That is within their 4,000-token budget, by the same estimate `scripts/check.sh` enforces. The rest is outside that budget and was not broken down; it includes the list of the plugin's skills. Claude Code caches all of it after a session's first request, and switching a rule set off removes its share.
