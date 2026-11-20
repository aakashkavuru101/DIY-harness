# 03: the check is green again

Status: open
Part ID: QA1
Blocked by: 02

## What it makes work

`python3 -m unittest` passes, so the pre-commit guard lets a good commit through.

## Acceptance

- Proof: `python3 -m unittest` passes, and the guard lets a commit through; it goes red while `clean.py` keeps blank rows.
- Runs in: Claude Code.
