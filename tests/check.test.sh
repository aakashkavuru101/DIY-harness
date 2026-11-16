#!/bin/sh
# Runs scripts/check.sh against fixtures and the real repo. Usage: sh tests/check.test.sh
CDPATH= cd -- "$(dirname "$0")/.." || exit 1
fx=tests/fixtures
fails=0 skips=0

fail() { echo "FAIL: $*"; fails=$((fails + 1)); }

# expect <fixture-root> <exit: 0|nonzero> [text the output must contain]...
expect() {
  root=$1 want=$2; shift 2
  out=$(sh scripts/check.sh "$root" 2>&1); code=$?
  if [ "$want" = 0 ] && [ "$code" -ne 0 ]; then fail "$root: exit $code, want 0. Output: $out"; fi
  if [ "$want" = nonzero ] && [ "$code" -eq 0 ]; then fail "$root: exit 0, want non-zero"; fi
  for text in "$@"; do
    case $out in *"$text"*) ;; *) fail "$root: output lacks '$text'. Output: $out" ;; esac
  done
}

# Check 9: licences and NOTICE
expect "$fx/check9-pass" 0
expect "$fx/check9-missing-licence" nonzero "check 9" "vendor/LICENSES/ponytail"
expect "$fx/check9-notice-missing-author" nonzero "check 9" "NOTICE" "DietrichGebert"
# Symlink fixture is built at run time: a committed symlink becomes a plain file where git has core.symlinks=false
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
cp -R "$fx/check9-pass/." "$tmp/" && rm "$tmp/vendor/LICENSES/ponytail" && ln -s ../../NOTICE "$tmp/vendor/LICENSES/ponytail"
expect "$tmp" nonzero "check 9" "vendor/LICENSES/ponytail" "symlink"
expect "$fx/check9-licence-is-dir" nonzero "check 9" "vendor/LICENSES/ponytail"
expect "$fx/check9-notice-missing" nonzero "check 9" "NOTICE: missing"
expect "$fx/check9-notice-slug-only" nonzero "check 9" "NOTICE" "DietrichGebert"

# Check 1: skill frontmatter. Check 8 (listing): every file under skills/ is in vendor/UPSTREAM.md
expect "$fx/skills-pass" 0
expect "$fx/check1-name-mismatch" nonzero "check 1" "skills/demo/SKILL.md" "name"
expect "$fx/check1-no-description" nonzero "check 1" "skills/demo/SKILL.md" "description"
expect "$fx/check1-unclosed-frontmatter" nonzero "check 1" "skills/demo/SKILL.md" "frontmatter"
expect "$fx/check8-unlisted-file" nonzero "check 8" "skills/demo/EXTRA.md"
expect "$fx/check8-prose-only" nonzero "check 8" "skills/demo/agents/openai.yaml"
expect "$fx/check8-unlisted-ponytail" nonzero "check 8" "skills/ponytail/SKILL.md"

# Check 2: "Call the Skill tool with <name>" names a model-invoked sibling. Check 3: no dropped or user-invoked skill named.
expect "$fx/calls-pass" 0
expect "$fx/check2-unknown-skill" nonzero "check 2" "skills/demo/SKILL.md" "nope"
expect "$fx/check2-user-invoked" nonzero "check 2" "skills/demo/SKILL.md" "manual"
expect "$fx/check3-dropped-in-playbook" nonzero "check 3" "skills/parent/references/playbooks/to-spec.md" "setup-matt-pocock-skills"
expect "$fx/check3-user-invoked-playbook" nonzero "check 3" "skills/parent/references/playbooks/flow.md" "to-tickets"

# Check 8, diff half: a vendored file that differs from its upstream clone at the pin needs a vendor/PATCHES.md row.
# Built at run time because the upstream clone must be a git repository.
g8="$tmp/diff8" src="$tmp/diff8/upstream/demo"
mkdir -p "$g8" "$src/skills/x/demo/agents" && cp -R "$fx/skills-pass/." "$g8/" &&
  cp "$g8/skills/demo/SKILL.md" "$src/skills/x/demo/SKILL.md" &&
  cp "$g8/skills/demo/agents/openai.yaml" "$src/skills/x/demo/agents/openai.yaml" &&
  git -C "$src" init -q && git -C "$src" add -A &&
  git -C "$src" -c user.name=t -c user.email=t@example.invalid -c commit.gpgsign=false commit -qm pin || exit 1
pin=$(git -C "$src" rev-parse HEAD)
upstream_md() {
  printf '# Upstream\n\n## owner/demo\n\n| Field | Value |\n| --- | --- |\n| URL | https://example.invalid/owner/demo |\n'
  printf '| Pinned commit | `%s` |\n\n| File | Upstream path |\n| --- | --- |\n' "$1"
  printf '| `skills/demo/SKILL.md` | `skills/x/demo/SKILL.md` |\n| `skills/demo/agents/openai.yaml` | `skills/x/demo/agents/openai.yaml` |\n'
}
upstream_md "$pin" > "$g8/vendor/UPSTREAM.md"
expect "$g8" 0
echo "local change" >> "$g8/skills/demo/SKILL.md"
expect "$g8" nonzero "check 8" "skills/demo/SKILL.md" "vendor/PATCHES.md"
printf '| File | Why | Decision |\n| --- | --- | --- |\n| `skills/demo/SKILL.md` | test patch | none |\n' > "$g8/vendor/PATCHES.md"
expect "$g8" 0
# The comparison is against the pin, not the clone's current HEAD
echo "moved on" >> "$src/skills/x/demo/agents/openai.yaml" &&
  git -C "$src" -c user.name=t -c user.email=t@example.invalid -c commit.gpgsign=false commit -qam later || exit 1
expect "$g8" 0
upstream_md 0000000000000000000000000000000000000000 > "$g8/vendor/UPSTREAM.md"
expect "$g8" nonzero "check 8" "skills/demo/SKILL.md" "pin"
upstream_md "$pin" > "$g8/vendor/UPSTREAM.md" && rm -rf "$g8/upstream"
expect "$g8" 0 "warning" "upstream/demo"

# No-telemetry check (spec 07 section 9, D7): no band, board, statusline or webhook file outside the exempt dirs
expect "$fx/telemetry-pass" 0
expect "$fx/telemetry-statusline" nonzero "check no-telemetry" "hooks/ponytail-statusline.sh"
# In a git work tree only files git sees count: a git-ignored copy (worktree, build output) is not "in the repo"
gt="$tmp/gitrepo"
mkdir -p "$gt" && cp -R "$fx/skills-pass/." "$gt/" && git -C "$gt" init -q && printf 'nested/\n' > "$gt/.gitignore" &&
  mkdir -p "$gt/nested/hooks" && echo x > "$gt/nested/hooks/claude-band.json"
expect "$gt" 0
mkdir -p "$gt/hooks" && echo x > "$gt/hooks/claude-band.json"
expect "$gt" nonzero "check no-telemetry" "hooks/claude-band.json"

# The real repo
expect . 0
grep -rq setup-matt-pocock-skills skills && fail "skills/ still mentions setup-matt-pocock-skills"
for f in skills/diy-harness/references/playbooks/to-spec.md skills/diy-harness/references/playbooks/to-tickets.md \
  skills/diy-harness/references/playbooks/implement.md skills/diy-harness/references/playbooks/implement-spec.md \
  skills/diy-harness/references/playbooks/retro.md; do
  if [ ! -f "$f" ]; then fail "$f missing"
  elif [ "$(head -n 1 "$f")" = "---" ]; then fail "$f starts with a frontmatter block"; fi
done

# Vendored files are identical to upstream, except files with a vendor/PATCHES.md row
# (upstream/ is git-ignored, so absent in a fresh clone)
patched() { [ -f vendor/PATCHES.md ] && grep -qF "| \`$1\` |" vendor/PATCHES.md; }
# same_or_patched <upstream dir> <local dir>: no file added or missing; a differing file must be patched
same_or_patched() {
  d=$(diff -rq "$1" "$2" 2>&1) && return
  while IFS= read -r l; do
    case $l in
      "Files $1/"*" and $2/"*" differ") f=${l#* and }; f=${f% differ}
        patched "$f" || fail "$f differs from $1 and has no vendor/PATCHES.md row" ;;
      *) fail "$2: $l" ;;
    esac
  done <<EOF
$d
EOF
}
if [ -d upstream ]; then
  for pair in mattpocock-skills:skills ponytail:ponytail i-have-adhd:i-have-adhd; do
    cmp -s "vendor/LICENSES/${pair%%:*}" "upstream/${pair#*:}/LICENSE" ||
      fail "vendor/LICENSES/${pair%%:*} differs from upstream/${pair#*:}/LICENSE"
  done
  # The eleven mattpocock engine skills
  for gn in engineering/code-review engineering/codebase-design engineering/diagnosing-bugs \
    engineering/domain-modeling engineering/pr engineering/prototype engineering/research \
    engineering/tdd engineering/wizard productivity/grilling productivity/writing-for-agents; do
    same_or_patched "upstream/skills/skills/$gn" "skills/${gn#*/}"
  done
  # The five playbooks, from the user-invoked upstream SKILL.md files
  for n in to-spec to-tickets implement implement-spec retro; do
    f=skills/diy-harness/references/playbooks/$n.md
    cmp -s "upstream/skills/skills/engineering/$n/SKILL.md" "$f" || patched "$f" ||
      fail "$f differs from upstream/skills/skills/engineering/$n/SKILL.md and has no vendor/PATCHES.md row"
  done
  # The three ponytail skills
  for n in ponytail ponytail-audit ponytail-debt; do
    same_or_patched "upstream/ponytail/skills/$n" "skills/$n"
  done
  # With upstream/ present the real repo gives no warnings
  case $(sh scripts/check.sh . 2>&1) in *warning*) fail "check.sh warns on the real repo with upstream/ present" ;; esac
  # core/i-have-adhd.md is the upstream SKILL.md minus its leading --- frontmatter block
  src=upstream/i-have-adhd/skills/i-have-adhd/SKILL.md
  end=$(awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { print NR; exit }' "$src")
  if [ -z "$end" ]; then fail "$src has no frontmatter block"
  else tail -n "+$((end + 1))" "$src" | cmp -s - core/i-have-adhd.md ||
    fail "core/i-have-adhd.md is not $src minus its frontmatter"; fi
else
  echo "SKIP: upstream/ absent, licence and skill identity not checked"; skips=1
fi

[ "$fails" -eq 0 ] && echo "PASS ($skips skipped)" || { echo "$fails failed"; exit 1; }
