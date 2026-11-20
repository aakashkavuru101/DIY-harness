# 02: guard against rm -rf

Status: open
Part ID: PR6
Blocked by: 01

## What it makes work

The agent cannot run `rm -rf`; the block message tells it to delete the named files instead, or to ask the user.

## Acceptance

- The guard is `.harness/guards/rm-rf`, called by a Claude Code `PreToolUse` hook on Bash; its tests are `.harness/guards/rm-rf.test.sh`.
- Must block: `rm -rf build`. Must allow: `rm build/old.log`. Proof: `sh .harness/guards/rm-rf.test.sh` passes; its must-block test is red while the guard is missing.
- The block message says what was blocked, why, and what to do instead.
- Works in Claude Code.
