# 03: pre-commit guard

Status: open
Part ID: QA2
Blocked by: 01

## What it makes work

A commit with a failing test is refused, and the message says how to fix it.

## Acceptance

- Must block: a commit while a test fails is refused.
- Must allow: a commit while every test passes goes through.
