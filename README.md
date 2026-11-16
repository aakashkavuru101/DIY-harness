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
