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
expect "$fx/check8-unlisted-file" nonzero "check 8" "skills/demo/EXTRA.md"

# The real repo
expect . 0

# The eleven mattpocock engine skills are vendored unchanged from the pin
if [ -d upstream ]; then
  for gn in engineering/code-review engineering/codebase-design engineering/diagnosing-bugs \
    engineering/domain-modeling engineering/pr engineering/prototype engineering/research \
    engineering/tdd engineering/wizard productivity/grilling productivity/writing-for-agents; do
    diff -r "upstream/skills/skills/$gn" "skills/${gn#*/}" >/dev/null 2>&1 ||
      fail "skills/${gn#*/} differs from upstream/skills/skills/$gn"
  done
fi

# Vendored licences are byte-identical to upstream (upstream/ is git-ignored, so absent in a fresh clone)
if [ -d upstream ]; then
  for pair in mattpocock-skills:skills ponytail:ponytail i-have-adhd:i-have-adhd; do
    cmp -s "vendor/LICENSES/${pair%%:*}" "upstream/${pair#*:}/LICENSE" ||
      fail "vendor/LICENSES/${pair%%:*} differs from upstream/${pair#*:}/LICENSE"
  done
else
  echo "SKIP: upstream/ absent, licence byte-identity not checked"; skips=1
fi

[ "$fails" -eq 0 ] && echo "PASS ($skips skipped)" || { echo "$fails failed"; exit 1; }
