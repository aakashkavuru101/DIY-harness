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

# Check 2: every "Skill tool with `<name>`" (or "<name>") under skills/ names a model-invoked sibling skills/<name>/.
calls=$([ -d skills ] && grep -rnoiE 'skill tool with [`"][A-Za-z0-9_-]+[`"]' skills)
while IFS= read -r c; do
  [ -n "$c" ] || continue
  file=${c%%:*}; rest=${c#*:}; loc="$file:${rest%%:*}"
  name=$(printf '%s' "${rest#*:}" | sed 's/.*[`"]\([A-Za-z0-9_-]*\)[`"]$/\1/')
  if [ ! -f "skills/$name/SKILL.md" ]; then report 2 "$loc" "calls \`$name\`, but skills/$name/SKILL.md does not exist"
  elif [ "$(frontmatter "skills/$name/SKILL.md" disable-model-invocation)" = true ]; then
    report 2 "$loc" "calls \`$name\`, which is user-invoked"
  fi
done <<EOF
$calls
EOF

# Check 3 (doc 03 section 2): no line under skills/ names a dropped or parked skill, or tells the agent to call a
# user-invoked one (a playbook, or a skill with disable-model-invocation: true). Only reference forms count
# (/name, ../name/, "Skill tool with name", and `name` for dropped ones): triage, teach, handoff are also plain words.
# ponytail-review is listed too: merged into code-review (D3), never shipped as a skill.
DROPPED="handoff grill-me grill-with-docs ask-matt setup-matt-pocock-skills triage wayfinder
  improve-codebase-architecture teach to-questionnaire wait-what ponytail-gain ponytail-help ponytail-review"
USER_INVOKED=$(for f in skills/*/references/playbooks/*.md; do [ -f "$f" ] && basename "$f" .md; done
  for f in skills/*/SKILL.md; do
    [ -f "$f" ] && [ "$(frontmatter "$f" disable-model-invocation)" = true ] && basename "${f%/SKILL.md}"
  done)
# refs <name> <extra ERE alternative>: file:line of every reference to <name> under skills/
refs() {
  [ -d skills ] && grep -rnE "(^|[^A-Za-z0-9_./-])/$1([^A-Za-z0-9_-]|\$)|\.\./$1/|[Ss]kill tool with [\`\"]$1[\`\"]$2" skills |
    cut -d: -f1,2
}
for name in $DROPPED; do
  while IFS= read -r loc; do [ -n "$loc" ] && report 3 "$loc" "names dropped skill '$name'"; done <<EOF
$(refs "$name" "|\`$name\`")
EOF
done
for name in $USER_INVOKED; do
  while IFS= read -r loc; do [ -n "$loc" ] && report 3 "$loc" "tells the agent to call user-invoked '$name'"; done <<EOF
$(refs "$name" "")
EOF
done

# listed <file> <table.md>: <file> is the first cell of a table row in <table.md>
listed() { [ -f "$2" ] && grep -q "^| \`$(printf '%s' "$1" | sed 's/[][\.*^$]/\\&/g')\` |" "$2"; }

# Check 8 (listing half): every file under skills/ is a table row in vendor/UPSTREAM.md, first cell `skills/...`.
if [ -d skills ]; then
  # .DS_Store is git-ignored macOS clutter, never vendored
  unlisted=$(find skills -type f ! -name .DS_Store | sort | while IFS= read -r f; do
    listed "$f" vendor/UPSTREAM.md || echo "$f"
  done)
  while IFS= read -r f; do
    [ -n "$f" ] && report 8 "$f" "not listed in vendor/UPSTREAM.md"
  done <<EOF
$unlisted
EOF
fi

# Check 8 (diff half): every file in vendor/UPSTREAM.md that differs from its upstream clone at the pinned commit
# has a vendor/PATCHES.md row. A section's clone is upstream/<last part of its URL> (ADR 0002 H3). The comparison
# uses the pinned commit, not the clone's checkout. An absent clone is skipped with a warning.
if [ -f vendor/UPSTREAM.md ]; then
  rows=$(awk -F'`' '/^## / { url = ""; pin = "" }
    /^\| URL \|/ { split($0, u, " "); url = u[4] }
    /^\| Pinned commit \|/ { pin = $2 }
    /^\| `/ { print url "|" pin "|" $2 "|" $4 }' vendor/UPSTREAM.md)
  warned=
  while IFS='|' read -r url pin local up; do
    [ -n "$local" ] || continue
    if [ -z "$url" ] || [ -z "$pin" ]; then
      echo "warning: check 8: $local: no URL or pinned commit above its row in vendor/UPSTREAM.md, diff not checked" >&2
      continue
    fi
    clone=upstream/${url##*/}
    if [ ! -d "$clone" ]; then
      case " $warned " in *" $clone "*) ;; *) echo "warning: check 8: $clone absent, diff half skipped for it" >&2
        warned="$warned $clone" ;; esac
    elif [ ! -f "$local" ]; then report 8 "$local" "listed in vendor/UPSTREAM.md but missing"
    elif ! git -C "$clone" cat-file -e "$pin:$up" 2>/dev/null; then report 8 "$local" "$clone has no $up at pin $pin"
    elif ! git -C "$clone" show "$pin:$up" | cmp -s - "$local" && ! listed "$local" vendor/PATCHES.md; then
      report 8 "$local" "differs from $clone at the pin and has no vendor/PATCHES.md row"
    fi
  done <<EOF
$rows
EOF
fi

# No-telemetry check (spec 07 section 9, D7): ponytail's band, board, statusline and webhooks stay dropped.
# A path matches when one of those words is a whole token (split on / - _ .), so keyboard.md does not.
# "In the repo" means what git sees (tracked, or untracked and not ignored), so ignored copies such as
# nested worktrees do not count. Outside a git work tree every file counts.
repo_files() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then git ls-files -co --exclude-standard
  else find . -path ./.git -prune -o ! -type d -print | sed 's|^\./||'; fi
}
dropped=$(repo_files | grep -vE '^(upstream|docs|plans|tests/fixtures)/' |
  grep -iE '(^|[/._-])(band|board|statusline|webhooks?)([/._-]|$)' | sort)
while IFS= read -r f; do
  [ -n "$f" ] && report no-telemetry "$f" "dropped telemetry file (band, board, statusline, webhook)"
done <<EOF
$dropped
EOF

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
