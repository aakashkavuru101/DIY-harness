#!/bin/sh
# Static checks (docs/spec/06 section 2). Usage: scripts/check.sh [repo-root]
# Prints one line per failure: "check <n>: <file>: <why>". Exits non-zero if any failed.
root=${1:-$(dirname "$0")/..}
CDPATH= cd -- "$root" || { echo "check.sh: cannot enter $root"; exit 2; }
failed=0

report() { echo "check $1: $2: $3"; failed=1; }

# frontmatter <file> <key>: value of a top-level key in the leading --- block, quotes stripped
frontmatter() {
  awk -v key="$2" 'NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    index($0, key ":") == 1 { v = substr($0, length(key) + 2); gsub(/^[ \t]+|[ \t]+$/, "", v)
      if (v ~ /^".*"$/ || v ~ /^\047.*\047$/) v = substr(v, 2, length(v) - 2); print v; exit }' "$1"
}

# Check 1: every skills/*/SKILL.md has frontmatter with name == folder and a description.
for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  dir=${f%/SKILL.md}; dir=${dir#skills/}
  if ! awk 'NR == 1 && $0 != "---" { exit 1 } NR > 1 && $0 == "---" { ok = 1; exit } END { exit !ok }' "$f"; then
    report 1 "$f" "frontmatter must open and close with a --- line"; continue
  fi
  name=$(frontmatter "$f" name)
  [ "$name" = "$dir" ] || report 1 "$f" "frontmatter name '$name' does not match folder '$dir'"
  [ -n "$(frontmatter "$f" description)" ] || report 1 "$f" "frontmatter has no description"
done

# Check 8 (listing half): every file under skills/ is a table row in vendor/UPSTREAM.md, first cell `skills/...`.
if [ -d skills ]; then
  # .DS_Store is git-ignored macOS clutter, never vendored
  unlisted=$(find skills -type f ! -name .DS_Store | sort | while IFS= read -r f; do
    [ -f vendor/UPSTREAM.md ] && grep -q "^| \`$(printf '%s' "$f" | sed 's/[][\.*^$]/\\&/g')\` |" vendor/UPSTREAM.md || echo "$f"
  done)
  while IFS= read -r f; do
    [ -n "$f" ] && report 8 "$f" "not listed in vendor/UPSTREAM.md"
  done <<EOF
$unlisted
EOF
fi

# Check 9: three licence texts in vendor/LICENSES/, NOTICE names all three authors.
for name in mattpocock-skills ponytail i-have-adhd; do
  f=vendor/LICENSES/$name
  if [ -L "$f" ]; then report 9 "$f" "is a symlink, must be a copied file"
  elif [ ! -f "$f" ] || [ ! -s "$f" ]; then report 9 "$f" "licence text missing or empty"; fi
done
if [ -f NOTICE ]; then
  for author in "Matt Pocock" "DietrichGebert" "Ayoub Ghriss"; do
    # "by <author>" so the repo slug DietrichGebert/ponytail alone does not count as credit
    grep -qwF "by $author" NOTICE || report 9 NOTICE "does not credit 'by $author'"
  done
else
  report 9 NOTICE "missing"
fi

exit "$failed"
