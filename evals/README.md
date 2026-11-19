# Evals

Behaviour eval cases for DIY-harness in Claude Code (document 06 sections 4 and 5, ticket 09). Each case runs
`claude -p` in a throwaway copy of its fixture with only this plugin loaded (besides Claude Code's built-in
plugins), and code graders check what happened.

## Sign in once

A trial runs in a throwaway config folder, so it cannot use your normal login. Run this in your own terminal, not
inside a Claude Code session, so the token never lands in a transcript:

```sh
claude setup-token
```

The runner reads the token from `CLAUDE_CODE_OAUTH_TOKEN`. Set it for the eval command only, not in your shell
profile: Claude Code prefers that variable over your normal login, so every session you start would use it. On macOS,
keep it in the keychain. The first command asks for the token once; the second runs the evals with it:

```sh
security add-generic-password -a "$USER" -s claude-eval-token -w
CLAUDE_CODE_OAUTH_TOKEN="$(security find-generic-password -a "$USER" -s claude-eval-token -w)" python3 evals/run_evals.py
```

The runner passes the token to each trial and never writes it anywhere. Before it finishes, it checks everything it
saved for the token. Bash commands and hooks inside a trial do not get it (`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`).

## Run

```sh
python3 evals/run_evals.py                          # every case, 3 trials each
python3 evals/run_evals.py --case E4 --trials 1     # one case, one trial
sh evals/live-checks.sh                             # the runner's own paid checks (ticket 09)
```

| Option | Default | Meaning |
| --- | --- | --- |
| `--case ID` | all | Run only this case; repeatable |
| `--trials N` | 3 | Trials per case. A case passes when at least two thirds of them pass and none blocks (PLAN.md Q2) |
| `--ceiling-usd USD` | what is left | The ceiling for this run. All paid runs together stay within the cap in PLAN.md Q2 (32 USD for M2), counted in [RESULTS.md](RESULTS.md); the run gets at most what is left, and none starts below 0.10 USD. One call gets at most 1 USD; a call that needs more stops the run. No call starts unless that still covers the dearest call so far |
| `--no-plugin` | off | Run without this plugin, to measure what it adds (the "Always-on cost" section of the root README). RESULTS.md marks the row "(no plugin)" |

Claude Code checks a call's budget only after each API call, so a call dearer than any before it can still take the
run past the ceiling by part of that call (docs/adr/0003 R4). Each run prints pass or fail per case, the failing
graders, and the cost. It appends one line to
[RESULTS.md](RESULTS.md) and exits non-zero on any failure. Transcripts go to `evals/runs/`, which git ignores.

## Cases

`cases.jsonl` holds one case per line; its fixture is `fixtures/<fixture>/`, copied into a git repo unless
`"git": false`.

| Field | Meaning |
| --- | --- |
| `id`, `fixture`, `prompt` | The case, its starting state, and the first message |
| `turns` | Follow-ups in the same session: `{"say": ...}` once, or with `"until": <check>, "max": N` repeated until the check holds, at most N times |
| `passes`, `blocks` | What passes and what fails the case outright, in words (document 06 section 4) |
| `pass_checks` | Checks that must all hold for a trial to pass |
| `block_checks` | Checks that must not hold. One that holds blocks the whole case |
| `allow` | Permission rules for `--allowedTools`, such as `Bash(env)`. File edits inside the copy are always allowed, except in its `.claude/`; so is reading this plugin's `skills/` folder |

| Check | Holds when |
| --- | --- |
| `{"check": "changed", "path": G}` | A file matching glob G differs from the fixture at the end (created, changed or deleted) |
| `{"check": "contains", "path": P, "pattern": R}` | File P matches regular expression R at the end |
| `{"check": "tool", "name": R, "input": {field: R}}` | A tool call, a subagent's included, has a name matching R and those input fields |
| `{"check": "writes_only", "allowed": [G], "before_turn": N}` | Every file written in turns before N matches an allowed glob |
| `{"check": "transcript", "pattern": R}` | Anything in the session's event stream (a reply, a tool call, a tool result, as JSON text) matches R. For a value that must never show, such as a secret |
| `{"check": "judge", "condition": C}` | A judge call (`judge.py`) finds C in the replies. Use it only for what the wording alone shows. It sees each turn's final reply only, not text the agent wrote before a tool call |

Any check takes `"not": true` to invert it. In globs, `*` also matches `/`.
