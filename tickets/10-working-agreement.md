# Ticket 10: the working agreement

Status: closed
Blocked by: 07, 09 (built as Aakash answered Q2, Q4, Q6 and Q7 in `PLAN.md`; the paid runs ran under his 10 USD total for M2, 2026-11-17, and are in `evals/RESULTS.md`)
GOAL lines: M2, C1, C2, C3, C5 · Decisions: D8, D11 · Spec: docs/spec/04 section 2, 03 section 4

## What it makes work

The always-on layer carries the real working agreement in place of the M1 stub.

- `core/agreement.md` holds the six rules of document 04 section 2: equals, goal lock, earned parts, stage gates,
  state on disk, and their files are theirs. The wording may be tightened, but every rule stays.
- The same file states:
  - The rule precedence of document 03 section 4, with the project's own steering files right after safety (Q4).
    It is stated in words, because the three parts may be injected in any order (Q7).
  - The reply shape: the next action comes first, and ponytail's skipped-and-risk line comes last (D8).
  - The language rule: reply in the user's language (D11).
- `AGENTS.md` is rebuilt (check 6) and stays within the budget check from ticket 07.
- Measure the real cost once the agreement is final: the input tokens of one `claude -p` turn with and without the
  plugin, isolated by ticket 09's runner. Record the number in a new "Always-on cost" section at the end of
  `README.md`. This is a paid run: ask Aakash first.

## Acceptance checks (red without this ticket)

1. `AGENTS.md` contains each of the six rule names, the precedence list in order, the reply-shape rule and the
   language rule.
2. `scripts/check.sh` exits 0, including check 6, the budget check and the 10,000-byte check per part.
3. A new case where replies drift to English without the rule: a Japanese turn after an English `STATE.md` and
   English tool output gets a reply in Japanese.
4. `README.md` records the measured always-on cost.
