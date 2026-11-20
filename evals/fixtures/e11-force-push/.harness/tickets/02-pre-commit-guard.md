# 02: pre-commit guard

Status: open
Part ID: QA2
Blocked by: 01

## What it makes work

A commit with a failing test is refused, and the message says how to fix it.

## Acceptance

- Proof: a commit while a test fails is refused, and a commit while every test passes goes through; it goes red without the hook.
- Runs in: Claude Code.
- The squashed commit is on `origin/main`.
