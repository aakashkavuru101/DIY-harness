# Upstream sources

Every file DIY-harness takes from an upstream repository, at the pinned commit (GOAL.md C8).
Nothing is fetched: files are copied from local clones in `upstream/`. Local changes are
listed in `vendor/PATCHES.md`.

## mattpocock/skills

| Field | Value |
| --- | --- |
| URL | https://github.com/mattpocock/skills |
| Pinned commit | `5863806dd4e15c63174bee4e7515a4256792ecfa` |
| Commit date | 2026-11-12 |
| Licence | MIT, `vendor/LICENSES/mattpocock-skills` |

| File | Upstream path |
| --- | --- |
| `skills/code-review/agents/openai.yaml` | `skills/engineering/code-review/agents/openai.yaml` |
| `skills/code-review/SKILL.md` | `skills/engineering/code-review/SKILL.md` |
| `skills/codebase-design/agents/openai.yaml` | `skills/engineering/codebase-design/agents/openai.yaml` |
| `skills/codebase-design/DEEPENING.md` | `skills/engineering/codebase-design/DEEPENING.md` |
| `skills/codebase-design/DESIGN-IT-TWICE.md` | `skills/engineering/codebase-design/DESIGN-IT-TWICE.md` |
| `skills/codebase-design/SKILL.md` | `skills/engineering/codebase-design/SKILL.md` |
| `skills/diagnosing-bugs/agents/openai.yaml` | `skills/engineering/diagnosing-bugs/agents/openai.yaml` |
| `skills/diagnosing-bugs/scripts/hitl-loop.template.sh` | `skills/engineering/diagnosing-bugs/scripts/hitl-loop.template.sh` |
| `skills/diagnosing-bugs/SKILL.md` | `skills/engineering/diagnosing-bugs/SKILL.md` |
| `skills/domain-modeling/ADR-FORMAT.md` | `skills/engineering/domain-modeling/ADR-FORMAT.md` |
| `skills/domain-modeling/agents/openai.yaml` | `skills/engineering/domain-modeling/agents/openai.yaml` |
| `skills/domain-modeling/GLOSSARY-FORMAT.md` | `skills/engineering/domain-modeling/GLOSSARY-FORMAT.md` |
| `skills/domain-modeling/SKILL.md` | `skills/engineering/domain-modeling/SKILL.md` |
| `skills/pr/agents/openai.yaml` | `skills/engineering/pr/agents/openai.yaml` |
| `skills/pr/CREDITS.md` | `skills/engineering/pr/CREDITS.md` |
| `skills/pr/SKILL.md` | `skills/engineering/pr/SKILL.md` |
| `skills/prototype/agents/openai.yaml` | `skills/engineering/prototype/agents/openai.yaml` |
| `skills/prototype/LOGIC.md` | `skills/engineering/prototype/LOGIC.md` |
| `skills/prototype/SKILL.md` | `skills/engineering/prototype/SKILL.md` |
| `skills/prototype/UI.md` | `skills/engineering/prototype/UI.md` |
| `skills/research/agents/openai.yaml` | `skills/engineering/research/agents/openai.yaml` |
| `skills/research/SKILL.md` | `skills/engineering/research/SKILL.md` |
| `skills/tdd/agents/openai.yaml` | `skills/engineering/tdd/agents/openai.yaml` |
| `skills/tdd/mocking.md` | `skills/engineering/tdd/mocking.md` |
| `skills/tdd/SKILL.md` | `skills/engineering/tdd/SKILL.md` |
| `skills/tdd/tests.md` | `skills/engineering/tdd/tests.md` |
| `skills/wizard/agents/openai.yaml` | `skills/engineering/wizard/agents/openai.yaml` |
| `skills/wizard/SKILL.md` | `skills/engineering/wizard/SKILL.md` |
| `skills/wizard/template.sh` | `skills/engineering/wizard/template.sh` |
| `skills/grilling/agents/openai.yaml` | `skills/productivity/grilling/agents/openai.yaml` |
| `skills/grilling/SKILL.md` | `skills/productivity/grilling/SKILL.md` |
| `skills/writing-for-agents/agents/openai.yaml` | `skills/productivity/writing-for-agents/agents/openai.yaml` |
| `skills/writing-for-agents/SKILL-MECHANICS.md` | `skills/productivity/writing-for-agents/SKILL-MECHANICS.md` |
| `skills/writing-for-agents/SKILL.md` | `skills/productivity/writing-for-agents/SKILL.md` |

## DietrichGebert/ponytail

| Field | Value |
| --- | --- |
| URL | https://github.com/DietrichGebert/ponytail |
| Pinned commit | `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` |
| Commit date | 2026-10-29 |
| Licence | MIT, `vendor/LICENSES/ponytail` |

Not taken: the `ponytail-gain`, `ponytail-help` and `ponytail-review` skills, everything under
`hooks/` (band, statusline, webhooks), the board, and `assets/band/` (D7, GOAL.md N2).

| File | Upstream path |
| --- | --- |
| `skills/ponytail/SKILL.md` | `skills/ponytail/SKILL.md` |
| `skills/ponytail-audit/SKILL.md` | `skills/ponytail-audit/SKILL.md` |
| `skills/ponytail-debt/SKILL.md` | `skills/ponytail-debt/SKILL.md` |

## ayghri/i-have-adhd

| Field | Value |
| --- | --- |
| URL | https://github.com/ayghri/i-have-adhd |
| Pinned commit | `1ecea1993b7fce257ffbd686c070948b5e07eda6` |
| Commit date | 2026-10-11 |
| Licence | MIT, `vendor/LICENSES/i-have-adhd` |

Taken as an always-on rule only, with no skill folder (document 05 section 1). Not taken:
`skills/i-have-adhd/agents/` and the rest of the repository.

| File | Upstream path |
| --- | --- |
| `core/i-have-adhd.md` | `skills/i-have-adhd/SKILL.md` (body only: frontmatter block removed; `vendor/PATCHES.md` does not exist yet, ticket 04 records this change there) |
