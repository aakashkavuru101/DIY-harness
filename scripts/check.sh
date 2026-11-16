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

# A Skill tool call names one or more quoted skills: 'Skill tool with `tdd`', 'Skill tool twice, for "a" and "b"'.
Q='[`"][A-Za-z0-9_-]+[`"]'
CALL="[Ss]kill tool (with|twice, for|for) ($Q(, | and |, and ))*"

# Check 2: every skill a Skill tool call names under skills/ is a model-invoked sibling folder skills/<name>/.
# The folder name must match exactly: a case-insensitive disk (macOS) would otherwise find skills/TDD as skills/tdd.
is_skill() { for d in skills/*/; do [ "$d" = "skills/$1/" ] && [ -f "${d}SKILL.md" ] && return 0; done; return 1; }
calls=$([ -d skills ] && grep -rnoE "$CALL$Q" skills)
while IFS= read -r c; do
  [ -n "$c" ] || continue
  file=${c%%:*}; rest=${c#*:}; loc="$file:${rest%%:*}"
  for name in $(printf '%s\n' "${rest#*:}" | sed 's/^[^`"]*//' | grep -oE "$Q" | tr -d '`"'); do
    if ! is_skill "$name"; then report 2 "$loc" "calls \`$name\`, but there is no skills/$name/SKILL.md"
    elif [ "$(frontmatter "skills/$name/SKILL.md" disable-model-invocation)" = true ]; then
      report 2 "$loc" "calls \`$name\`, which is user-invoked"
    fi
  done
done <<EOF
$calls
EOF

# Check 3 (doc 03 section 2): no line under skills/ names a dropped or parked skill, or tells the agent to call a
# user-invoked one (a playbook, or a skill with disable-model-invocation: true).
# Names that are also plain English words count only in reference forms; the others count wherever they appear.
# ponytail-review is listed too: merged into code-review (D3), never shipped as a skill.
DROPPED_WORDS="handoff triage teach"
DROPPED_NAMES="grill-me grill-with-docs ask-matt setup-matt-pocock-skills wayfinder improve-codebase-architecture
  to-questionnaire wait-what ponytail-gain ponytail-help ponytail-review"
USER_INVOKED=$(for f in skills/*/references/playbooks/*.md; do [ -f "$f" ] && basename "$f" .md; done
  for f in skills/*/SKILL.md; do
    [ -f "$f" ] && [ "$(frontmatter "$f" disable-model-invocation)" = true ] && basename "${f%/SKILL.md}"
  done)
# Reference forms of <name>: /name, ../name/, `name`, or a Skill tool call naming it
ref_re() { printf '%s' "(^|[^A-Za-z0-9_./-])/$1([^A-Za-z0-9_-]|\$)|\.\./$1/|$CALL[\`\"]$1[\`\"]$2"; }
# grep_locs <ERE>: file:line of every match under skills/
grep_locs() { [ -d skills ] && grep -rnE "$1" skills | cut -d: -f1,2; }
for name in $DROPPED_WORDS $DROPPED_NAMES; do
  case " $DROPPED_WORDS " in *" $name "*) re=$(ref_re "$name" "|\`$name\`") ;;
    *) re="(^|[^A-Za-z0-9_-])$name([^A-Za-z0-9_-]|\$)" ;; esac
  while IFS= read -r loc; do [ -n "$loc" ] && report 3 "$loc" "names dropped skill '$name'"; done <<EOF
$(grep_locs "$re")
EOF
done
for name in $USER_INVOKED; do
  while IFS= read -r loc; do
    case $loc in ""|"skills/$name/"*) continue ;; esac  # a skill may name itself ("re-run /diy-harness")
    report 3 "$loc" "tells the agent to call user-invoked '$name'"
  done <<EOF
$(grep_locs "$(ref_re "$name" "")")
EOF
done

# Check 5: a skill is user-invoked in every agent or in none. disable-model-invocation: true in SKILL.md goes with
# policy.allow_implicit_invocation: false in agents/openai.yaml, where that file exists (Codex defaults it to true).
for y in skills/*/agents/openai.yaml; do
  s=${y%/agents/openai.yaml}/SKILL.md
  [ -f "$y" ] && [ -f "$s" ] || continue
  dmi=$(frontmatter "$s" disable-model-invocation)
  aii=$(awk '/^[^ \t#]/ { top = $1 } top == "policy:" && $1 == "allow_implicit_invocation:" { gsub(/["\047]/, "", $2); print $2; exit }' "$y")
  if [ "$dmi" = true ] && [ "$aii" != false ]; then
    report 5 "${s%/SKILL.md}" "disable-model-invocation is true but agents/openai.yaml allow_implicit_invocation is ${aii:-unset (true)}"
  elif [ "$dmi" != true ] && [ "$aii" = false ]; then
    report 5 "${s%/SKILL.md}" "agents/openai.yaml allow_implicit_invocation is false but disable-model-invocation is ${dmi:-unset (false)}"
  fi
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
# uses the pinned commit, not the clone's checkout. An absent clone is skipped with a warning. Rows in the
# "DIY-harness's own files" section are DIY-harness's own work: listed, but not diffed against any upstream.
if [ -f vendor/UPSTREAM.md ]; then
  rows=$(awk -F'`' '/^## / { url = ($0 ~ /^## DIY-harness\047s own files/) ? "OWN" : ""; pin = "" }
    /^\| URL \|/ { split($0, u, " "); url = u[4] }
    /^\| Pinned commit \|/ { pin = $2 }
    /^\| `/ { print url "|" pin "|" $2 "|" $4 }' vendor/UPSTREAM.md)
  warned=
  while IFS='|' read -r url pin local up; do
    [ -n "$local" ] || continue
    if [ "$url" = OWN ]; then
      [ -f "$local" ] || report 8 "$local" "listed in vendor/UPSTREAM.md but missing"
      continue
    fi
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

# Check 7: one version across all manifests; each plugin.json has one.
first= firstf=
for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json; do
  [ -f "$m" ] || continue
  versions=$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$m" | sed 's/.*"\([^"]*\)"$/\1/')
  case $m in *plugin.json) [ -n "$versions" ] || report 7 "$m" "has no version" ;; esac
  for v in $versions; do
    [ -n "$first" ] || { first=$v; firstf=$m; }
    [ "$v" = "$first" ] || report 7 "$m" "version $v differs from $first in $firstf"
  done
done

# Manifest skills (doc 05 section 3): the .claude-plugin/plugin.json skills array lists exactly the folders under skills/.
if [ -f .claude-plugin/plugin.json ]; then
  in_array=$(tr -d '\n' < .claude-plugin/plugin.json | sed -n 's/.*"skills"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' |
    grep -oE '"[^"]*"' | tr -d '"' | sed 's|^\./||; s|/$||')
  folders=$(for d in skills/*/; do [ -d "$d" ] && printf '%s\n' "${d%/}"; done)
  for d in $folders; do
    printf '%s\n' "$in_array" | grep -qxF "$d" ||
      report manifest-skills "$d" "folder is not in the .claude-plugin/plugin.json skills array"
  done
  for e in $in_array; do
    printf '%s\n' "$folders" | grep -qxF "$e" ||
      report manifest-skills "$e" "is in the .claude-plugin/plugin.json skills array but is not a folder under skills/"
  done
  for e in $(printf '%s\n' "$in_array" | sort | uniq -d); do
    report manifest-skills "$e" "is listed more than once in the .claude-plugin/plugin.json skills array"
  done
fi

# Check 10: claude plugin validate . --strict, when there is a manifest and the claude CLI is on PATH.
if [ -f .claude-plugin/plugin.json ] || [ -f .claude-plugin/marketplace.json ]; then
  if command -v claude >/dev/null 2>&1; then
    # Validation is local; also keep the CLI from updating itself or sending anything (C7)
    if ! out=$(CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 DISABLE_AUTOUPDATER=1 claude plugin validate . --strict 2>&1); then
      report 10 .claude-plugin "claude plugin validate . --strict failed:"
      # The plugin-directory notes do not change the result, so only the manifest findings are shown;
      # if none match (a CLI error, say), the whole output is
      printf '%s\n' "$out" | awk '/^Plugin directory checks/ { skip = 1 } /Validation failed/ { skip = 0 }
        !skip && /✘|❯/' | sed 's/^ */    /' | grep . || printf '%s\n' "$out" | sed 's/^/    /'
    fi
  else
    echo "note: check 10 skipped: the claude CLI is not on PATH"
  fi
fi

exit "$failed"
