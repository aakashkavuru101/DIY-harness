# DIY-harness
DIY-harness: build a custom agent harness for your project with /diy-harness

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
