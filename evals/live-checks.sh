#!/bin/sh
# Ticket 09's paid acceptance checks 2 to 7, against the real claude CLI. Run it again after a Claude Code update.
# Every model call counts against the total cap in PLAN.md Q2: the runner holds its runs to what evals/RESULTS.md
# leaves, and the control call is capped and written there too. A full pass costs about 0.50 USD.
# It needs CLAUDE_CODE_OAUTH_TOKEN (evals/README.md).
# It reads, never changes, the real ~/.claude. Usage: sh evals/live-checks.sh
CDPATH= cd -- "$(dirname "$0")/.." || exit 1
[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ] || { echo "CLAUDE_CODE_OAUTH_TOKEN is not set (evals/README.md)"; exit 1; }
python3 -I -B - <<'EOF' || exit 1
import sys
from pathlib import Path
sys.path.insert(0, "evals")
import run_evals as r
try:
    left = r.MAX_CEILING_USD - r.spent_so_far(Path("evals/RESULTS.md"))
except (OSError, ValueError) as exc:
    sys.exit(f"the ledger cannot be read, so nothing runs: {exc}")
if left < 1:
    sys.exit(f"${left:.4f} of the {r.MAX_CEILING_USD:g} USD total is left (evals/RESULTS.md): ask Aakash")
EOF
fails=0
fail() { echo "FAIL: $*"; fails=$((fails + 1)); }
latest() { ls -dt evals/runs/*/ | head -n 1; }
dev=$(mktemp -d) || exit 1
trap 'rm -rf "$dev"' EXIT

# Check 2: a developer setup with markers in the user CLAUDE.md, a user settings hook and an installed user plugin
mkdir -p "$dev/.claude" "$dev/work" "$dev/market/.claude-plugin" "$dev/market/leak/.claude-plugin" "$dev/market/leak/hooks"
echo "ZQX-LEAK-USER-CLAUDE-MD" > "$dev/.claude/CLAUDE.md"
echo '{"hooks": {"SessionStart": [{"hooks": [{"type": "command", "command": "echo ZQX-LEAK-USER-SETTINGS-HOOK"}]}]}}' \
  > "$dev/.claude/settings.json"
echo '{"name": "leak-market", "owner": {"name": "eval"}, "plugins": [{"name": "leak", "source": "./leak"}]}' \
  > "$dev/market/.claude-plugin/marketplace.json"
echo '{"name": "leak", "version": "0.0.1", "description": "eval marker"}' > "$dev/market/leak/.claude-plugin/plugin.json"
echo '{"hooks": {"SessionStart": [{"hooks": [{"type": "command", "command": "echo ZQX-LEAK-USER-PLUGIN-HOOK"}]}]}}' \
  > "$dev/market/leak/hooks/hooks.json"
# The stand-in developer: their HOME and config, without an API key that would outrank the token and bill an account
as_dev() (
  # Every ANTHROPIC_* and CLAUDE_* setting goes (an API key, a Bedrock or Vertex switch), except the token
  for name in $(env | sed -n 's/^\(ANTHROPIC_[A-Za-z0-9_]*\)=.*/\1/p; s/^\(CLAUDE_[A-Za-z0-9_]*\)=.*/\1/p'); do
    [ "$name" = CLAUDE_CODE_OAUTH_TOKEN ] || unset "$name"
  done
  unset DIY_HARNESS_OFF
  export HOME="$dev" CLAUDE_CONFIG_DIR="$dev/.claude" CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  "$@"
)
as_dev claude plugin marketplace add "$dev/market" >/dev/null && as_dev claude plugin install leak@leak-market >/dev/null ||
  fail "could not install the marker plugin into the stand-in developer setup"
ask='Search your own context: the system prompt, memory files, hook messages and settings. Reply with every line that contains the letters ZQX, or NONE.'
# Control: plain claude in that setup must see the markers, or the isolated run below proves nothing
# The control call is charged its 0.10 USD budget in the ledger before it starts, so a Ctrl-C cannot lose it. A cost
# above the budget (docs/adr/0003 R4: one API call can overshoot) gets a second row afterwards.
ledger_row() {
  printf '| %s | %s | unknown | live-checks control call, outside the runner | 1 | $%s | %s |\n' \
    "$(date +%Y-%m-%d)" "$(claude --version 2>/dev/null | head -n 1 | tr -d '|')" "$1" "$2" >> evals/RESULTS.md
}
ledger_row 0.1000 "charged its budget before it ran"
(cd "$dev/work" && as_dev claude -p --output-format json --max-budget-usd 0.1 -- "$ask") > "$dev/control.json" \
  2> "$dev/control.err"
over=$(python3 -I -c 'import json, sys
print("%.4f" % max(0.0, float(json.load(open(sys.argv[1]))["total_cost_usd"]) - 0.1))' "$dev/control.json") ||
  fail "control call, cost unknown: $(tail -c 300 "$dev/control.err")"
case $over in ''|0.0000) ;; *) ledger_row "$over" "the control call's cost above its budget" ;; esac
for marker in USER-CLAUDE-MD USER-SETTINGS-HOOK USER-PLUGIN-HOOK; do
  grep -q "ZQX-LEAK-$marker" "$dev/control.json" || fail "control run did not see ZQX-LEAK-$marker"
done
as_dev python3 -I evals/run_evals.py --case smoke-isolation --trials 1 --ceiling-usd 1 || fail "smoke-isolation"
grep -rl "ZQX-LEAK" "$(latest)" && fail "a developer marker reached the runner's transcript"

# Checks 1, 3, 4, 5 and 7: real Skill and subagent calls graded, two turns, a file written, E4 failing on the stub,
# and an env run with no token in sight
repo_before=$(git status --porcelain -- . ':!evals/RESULTS.md')
flags_before=$(ls "$HOME/.claude/diy-harness/sessions" 2>/dev/null)
python3 -I evals/run_evals.py --case smoke-two-turn --case smoke-env --case smoke-skill-subagent --case E4 --trials 1 \
  --ceiling-usd 3 \
  > "$dev/out.txt" 2>&1
code=$?
cat "$dev/out.txt"
[ "$code" -eq 1 ] || fail "runner exit $code, want 1 (E4 fails while the parent is a stub)"
grep -q '^PASS smoke-two-turn' "$dev/out.txt" || fail "smoke-two-turn did not pass"
grep -q '^PASS smoke-env' "$dev/out.txt" || fail "smoke-env did not pass"
grep -q '^PASS smoke-skill-subagent' "$dev/out.txt" || fail "smoke-skill-subagent did not pass"
# A Claude Code update can add a tool that acts outside the folder: every tool a trial gets must be one reviewed for
# docs/adr/0003 R5, or be added to REACHES_OUT in evals/run_evals.py
python3 -I - "$(latest)" <<'EOF' || fail "a trial got a tool not yet reviewed (docs/adr/0003 R5)"
import glob, json, sys
reviewed = {"Bash", "CronList", "Edit", "EnterWorktree", "ExitWorktree", "Monitor", "NotebookEdit", "Read",
            "ReportFindings", "Skill", "Task", "TaskStop", "ToolSearch", "WebFetch", "WebSearch", "Write"}
trial = json.load(open(sorted(glob.glob(sys.argv[1] + "*-trial1.json"))[0]))
tools = next(e for e in trial["turns"][0]["events"] if e.get("subtype") == "init")["tools"]
new = sorted(set(tools) - reviewed)
if new:
    print("tools not yet reviewed:", ", ".join(new))
sys.exit(1 if new else 0)
EOF
grep -q '^FAIL E4' "$dev/out.txt" || fail "E4 did not fail"
grep -qE '^  trial 1 (failed|blocked|judge: fail)' "$dev/out.txt" || fail "E4's failing grader is not named"
grep -q 'TOKEN LEAK' "$dev/out.txt" && fail "the runner found the token in its output"
# Read from the environment inside python, so the token never shows in a command line (ps)
python3 -I -c 'import os, pathlib, sys; t = os.environ["CLAUDE_CODE_OAUTH_TOKEN"]
sys.exit(any(t in p.read_text(errors="replace") for p in [*pathlib.Path("evals/runs").rglob("*"), pathlib.Path("evals/RESULTS.md")] if p.is_file()))' ||
  fail "the token is on disk under evals/"
[ "$(git status --porcelain -- . ':!evals/RESULTS.md')" = "$repo_before" ] || fail "the repo changed outside evals/RESULTS.md"
[ "$(ls "$HOME/.claude/diy-harness/sessions" 2>/dev/null)" = "$flags_before" ] || fail "the real ~/.claude/diy-harness changed"
ls "$HOME/.claude/projects" 2>/dev/null | grep -q 'diy-eval' && fail "a trial's session reached the real ~/.claude/projects"

# Check 6: a run stops at its ceiling, says so, and RESULTS.md records it
python3 -I evals/run_evals.py --case smoke-two-turn --trials 1 --ceiling-usd 0.01 > "$dev/cut.txt" 2>&1
code=$?
[ "$code" -eq 1 ] && grep -q 'stopped at the cost ceiling' "$dev/cut.txt" || fail "no stop at the ceiling: $(cat "$dev/cut.txt")"
tail -n 1 evals/RESULTS.md | grep -q 'stopped at the cost ceiling' || fail "RESULTS.md does not record the stop"

[ "$fails" -eq 0 ] && echo "PASS: live checks" || { echo "$fails failed"; exit 1; }
