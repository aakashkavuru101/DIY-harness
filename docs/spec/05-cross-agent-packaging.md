# Cross-Agent Packaging

Document 05 of 09 · Draft v0.3 · 2026-11-16

> One repository installs into Claude Code and Codex. Kimi Code is parked (document 01 section 4). This document gives the layout, the manifests, the always-on layer, install routes, and the facts Claude Code must verify against each agent's current documentation before relying on them.

## 1. Repository layout

```
diy-harness/
├── AGENTS.md                  # GENERATED always-on layer (the hook prints it); also the repo guide
├── CLAUDE.md -> AGENTS.md
├── README.md  NOTICE  LICENSE
├── core/
│   ├── agreement.md           # working agreement (document 04 section 2)
│   ├── i-have-adhd.md         # vendored i-have-adhd rules (always-on only, no skill folder)
│   └── build-agents-md.mjs    # concatenates agreement + ponytail rules + i-have-adhd rules
├── hooks/
│   ├── hooks.json             # SessionStart (and SubagentStart) for Claude Code and Codex
│   └── session-start.mjs      # emits the always-on layer; honours the off switches
├── skills/
│   ├── diy-harness/           # the parent command (user-invoked)
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   │       ├── HARNESS.md  LEVELS.md  PARTS.md  GUARDRAILS.md  OPS.md  PRACTICES.md
│   │       ├── playbooks/     # to-spec, to-tickets, implement, implement-spec, retro
│   │       └── templates/     # GOAL, STATE, SPEC, TICKET, EVAL
│   ├── grilling/  domain-modeling/  codebase-design/  prototype/  research/
│   ├── tdd/  code-review/  diagnosing-bugs/  wizard/  pr/  writing-for-agents/
│   └── ponytail/  ponytail-audit/  ponytail-debt/
├── diagrams/                  # the eight SVG flow diagrams
├── evals/                     # cases.jsonl, rubric.md, runners.example.json, run_evals.py, judge.py
├── vendor/
│   ├── UPSTREAM.md  PATCHES.md
│   └── LICENSES/              # mattpocock-skills, ponytail, i-have-adhd
├── scripts/
│   ├── check.sh               # static checks (document 06)
│   ├── install.sh             # manual install by symlink
│   └── sync-upstream.sh       # diff vendored files against upstream at a new commit
├── .claude-plugin/plugin.json  .claude-plugin/marketplace.json
└── .codex-plugin/plugin.json
```

All skill folders are **flat siblings** under `skills/`. This is load-bearing: the fallback "read `../<name>/SKILL.md`" resolves the same way in the repo, in a plugin install, and through `install.sh` symlinks.

## 2. The always-on layer

One generated text, delivered by the same hook mechanism in both agents.

| Agent | Delivery | Upstream precedent |
| --- | --- | --- |
| Claude Code | `SessionStart` hook prints the layer as hidden context on startup, resume, clear and compact; `SubagentStart` gives subagents the build and output rules | ponytail `hooks/claude-codex-hooks.json`; i-have-adhd `hooks/hooks.json` |
| Codex | Same hooks file; both upstreams ship one hooks file for Claude Code and Codex | Same |

Rules for the layer:

- **Single source.** `core/build-agents-md.mjs` builds `AGENTS.md` from `core/agreement.md`, the body of `skills/ponytail/SKILL.md`, and `core/i-have-adhd.md`. `check.sh` fails if the committed `AGENTS.md` differs from a fresh build.
- **Order** follows the precedence in document 03 section 4: agreement, then ponytail, then i-have-adhd.
- **Off switches.** "stop ponytail" and "stop adhd mode" (both upstream phrases) switch a rule set off for the session. In Claude Code and Codex the hook reads a flag file written by a small `UserPromptSubmit` tracker, as ponytail does. Document the switches in the README.
- **Budget.** Measure the layer's token count in M2 and record it in the README. If it exceeds about 4,000 tokens, trim i-have-adhd's examples first; keep every rule.

## 3. Manifests

| File | Agent | Must contain |
| --- | --- | --- |
| `.claude-plugin/plugin.json` | Claude Code | name, version, description, licence, `skills` array listing every folder under `skills/`, `hooks` pointing at `hooks/hooks.json` |
| `.claude-plugin/marketplace.json` | Claude Code and Codex marketplaces | the repo's own marketplace entry |
| `.codex-plugin/plugin.json` | Codex | name, version, `skills: "./skills/"`, `interface` block (displayName, shortDescription) |
| `skills/*/agents/openai.yaml` | Codex skill picker | `interface.display_name`, `interface.short_description`; for the parent, `policy.allow_implicit_invocation: false` |

The parent's frontmatter sets `disable-model-invocation: true`, and its `openai.yaml` sets `allow_implicit_invocation: false`. Keep the two in sync (Matt's convention): it is user-invoked in every agent or in none. One `version` field drives all manifests; `check.sh` fails on a mismatch.

## 4. Install routes

| Agent | Managed install (updates itself) | Manual install |
| --- | --- | --- |
| Claude Code | `claude plugin marketplace add <org>/diy-harness` then `claude plugin install diy-harness@<marketplace>` | `scripts/install.sh` links each skill into `~/.claude/skills/` |
| Codex | `codex plugin marketplace add <org>/diy-harness` then `codex plugin add diy-harness@<marketplace>` | `scripts/install.sh` links into `~/.agents/skills/` |

Install one route per agent. Both routes together give every skill twice. `<org>` is open (decision D11).

### install.sh behaviour

- Links every folder under `skills/` into each target directory the user selects (default: both).
- Refuses to write through a target that is itself a symlink into the repo (Matt's `link-skills.sh` guards against this; copy that guard).
- Warns when a same-named skill from an upstream plugin is already installed (decision D6).
- Manual install has no hooks. It prints how to get the always-on layer: use the plugin route, or point the agent's global `AGENTS.md` at the generated file.

## 5. How the command is invoked in each agent

| Agent | Invocation | Skill-to-skill calls |
| --- | --- | --- |
| Claude Code | `/diy-harness` (plugin skills may appear namespaced, as `/diy-harness:diy-harness`) | Skill tool |
| Codex | From the skill picker or by name, per Codex's current skill syntax | Codex skill mechanism; else the sibling-file fallback |

## 6. Verify before relying on (M4 checklist)

These came from upstream files and documentation read on 2026-11-16. Claude Code confirms each against the agent's current docs, then records the version checked in an ADR.

1. Codex runs `SessionStart` and `SubagentStart` hooks from a plugin's hooks file, as ponytail and i-have-adhd assume.
2. Codex subagents fork the parent conversation by default (Matt's repo says so), so every dispatch must ask for a fresh context.
3. How Codex users invoke a named skill, whether a plugin skill is namespaced, and whether one Codex skill can call another (otherwise use the sibling-file fallback).
4. Claude Code plugin skill naming, and whether `claude plugin validate . --strict` accepts the manifest.
5. For each agent: which tool types fire a pre-tool hook (shell, file edit, MCP call), and how deny rules and the built-in sandbox are configured (document 07 section 6).
6. For each agent: whether it can export logs or metrics to OpenTelemetry natively, and which hook can write a session record (document 08 section 3).
