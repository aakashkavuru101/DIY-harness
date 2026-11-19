# Local patches

Every local change to a vendored file, against the upstream file at the pin in `vendor/UPSTREAM.md`.
`scripts/check.sh` check 8 fails if a vendored file differs from upstream and has no row here.
One row per change; a file can have several.

| File | Change | Why | Cause |
| --- | --- | --- | --- |
| `core/i-have-adhd.md` | Frontmatter block removed; body unchanged | Always-on rule only, with no skill folder | Doc 05 section 1 (ticket 03) |
| `skills/diy-harness/references/playbooks/to-spec.md` | Frontmatter block removed | A playbook carries no description, so it costs no context and cannot fire by accident | D1 |
| `skills/diy-harness/references/playbooks/to-tickets.md` | Frontmatter block removed | As above | D1 |
| `skills/diy-harness/references/playbooks/implement.md` | Frontmatter block removed | As above | D1 |
| `skills/diy-harness/references/playbooks/implement-spec.md` | Frontmatter block removed. This also removes the description's `/to-spec` and `/to-tickets`, which check 3 flags as calls to user-invoked commands | As above | D1 |
| `skills/diy-harness/references/playbooks/retro.md` | Frontmatter block removed | As above | D1 |
| `skills/code-review/SKILL.md` | Upstream line 13, "tell the user to run `/setup-matt-pocock-skills`", now says the tracker is local: `.harness/SPEC.md` and `.harness/tickets/` | `setup-matt-pocock-skills` is dropped; trackers are local files | Doc 03 sections 2 and 6 |
| `skills/diy-harness/references/playbooks/implement-spec.md` | Upstream line 9: the same replacement | As above | Doc 03 sections 2 and 6 |
| `skills/diy-harness/references/playbooks/to-spec.md` | Upstream line 9: the same replacement. The pointer to a configured "triage label vocabulary" goes with it; step 3 still names the `ready-for-agent` label | As above | Doc 03 sections 2 and 6 |
| `skills/diy-harness/references/playbooks/to-tickets.md` | Upstream line 11: the same replacement as `to-spec.md` | As above | Doc 03 sections 2 and 6 |
| `skills/diy-harness/references/playbooks/to-tickets.md` | Upstream line 60, "the tracker `/setup-matt-pocock-skills` configured", now says the tracker is local files in `.harness/tickets/`. The local-files bullet below still says `.scratch/<feature-slug>/issues/`; the M3 content patch changes it | As above | Doc 03 sections 2 and 6 |
| `skills/grilling/SKILL.md` | Upstream line 8, "Ask the whole frontier in one round", now asks at most 5 questions of the frontier per round; the rest carry over to the next round, none is dropped, and the total has no cap | A round of 8 or 10 questions is more than the reader can act on (i-have-adhd rule 9); eval case E9 fails without the patch | D2 |
