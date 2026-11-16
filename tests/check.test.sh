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
# refute <text>: the output of the last expect must not contain <text>
refute() { case $out in *"$1"*) fail "$root: output has '$1'. Output: $out" ;; esac; }

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
expect "$fx/check2-twice-for" nonzero "check 2" "skills/demo/SKILL.md" "nope"
refute "\`demo\`"
expect "$fx/check2-wrong-case" nonzero "check 2" "skills/demo/SKILL.md" "Demo"
p=skills/parent/references/playbooks/forms.md
expect "$fx/check3-forms" nonzero "check 3: $p:1:" "check 3: $p:2:" "check 3: $p:4:" "check 3: $p:5:" "check 3: $p:6:" "check 3: $p:7:"
refute "check 3: $p:3:"
expect "$fx/skills-pass" 0 "warning: check 8: skills/demo/SKILL.md: no URL or pinned commit"

# Check 5: disable-model-invocation matches allow_implicit_invocation. Check 7: one version across manifests.
# Manifest skills: the .claude-plugin skills array equals the folders under skills/.
# Check 10: claude plugin validate . --strict, when the claude CLI is on PATH.
expect "$fx/manifests-pass" 0
expect "$fx/check5-mismatch" nonzero "check 5" "skills/starter"
expect "$fx/check5-implicit-off" nonzero "check 5" "skills/demo"
expect "$fx/check7-version-mismatch" nonzero "check 7" ".codex-plugin/plugin.json" "2.0.0"
expect "$fx/skills-array-missing" nonzero "check manifest-skills" "skills/demo"
expect "$fx/skills-array-extra" nonzero "check manifest-skills" "skills/ghost"
# Variants built at run time from manifests-pass and check5-mismatch
v="$tmp/variant"
mkvariant() { rm -rf "$v" && mkdir -p "$v" && cp -R "$fx/$1/." "$v/"; }
mkvariant manifests-pass
sed -i.bak 's|"./skills/demo", "./skills/starter"|"./skills/demo", "./skills/starter", "./vendor", "./skills/demo"|' "$v/.claude-plugin/plugin.json"
expect "$v" nonzero "check manifest-skills: vendor:" "check manifest-skills: skills/demo: is listed more than once"
mkvariant manifests-pass
sed -i.bak '/"version"/d' "$v/.codex-plugin/plugin.json"
expect "$v" nonzero "check 7" ".codex-plugin/plugin.json" "has no version"
mkvariant check5-mismatch
printf 'interface:\n  display_name: "Starter"\n' > "$v/skills/starter/agents/openai.yaml"
expect "$v" nonzero "check 5" "skills/starter" "unset"
if command -v claude >/dev/null 2>&1; then
  # Depends on the CLI: claude 2.1.325 --strict rejects a plugin.json with no author. If a later CLI accepts it,
  # this line goes red for that reason, not because check 10 broke.
  expect "$fx/check10-invalid" nonzero "check 10" ".claude-plugin"
else
  echo "SKIP: claude CLI not on PATH, check 10 failure not exercised"; skips=$((skips + 1))
fi
# Without the CLI check 10 is skipped with a printed note, not failed
out=$(PATH=/usr/bin:/bin sh scripts/check.sh "$fx/manifests-pass" 2>&1) || fail "manifests-pass without claude on PATH: $out"
case $out in *"check 10 skipped"*) ;; *) fail "no 'check 10 skipped' note without claude on PATH. Output: $out" ;; esac

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
# A patched file that is deleted is still caught: its PATCHES.md row does not excuse a missing file
mv "$g8/skills/demo/SKILL.md" "$tmp/SKILL.md.keep"
expect "$g8" nonzero "check 8" "skills/demo/SKILL.md" "missing"
mv "$tmp/SKILL.md.keep" "$g8/skills/demo/SKILL.md"
# The comparison is against the pin, not the clone's current HEAD
echo "moved on" >> "$src/skills/x/demo/agents/openai.yaml" &&
  git -C "$src" -c user.name=t -c user.email=t@example.invalid -c commit.gpgsign=false commit -qam later || exit 1
expect "$g8" 0
# A file in the "DIY-harness's own files" section counts as listed and is not diffed against any upstream
{ upstream_md "$pin"; printf "\n## DIY-harness's own files\n\n| File | Upstream path |\n| --- | --- |\n| \`skills/demo/OWN.md\` | none |\n"; } > "$g8/vendor/UPSTREAM.md"
echo "own" > "$g8/skills/demo/OWN.md"
expect "$g8" 0
refute "OWN.md"
rm "$g8/skills/demo/OWN.md"
expect "$g8" nonzero "check 8" "skills/demo/OWN.md" "missing"
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

# Check 4: every relative link in a Markdown file resolves, relative to that file
expect "$fx/check4-pass" 0
expect "$fx/check4-broken-link" nonzero "check 4: README.md:3:" "docs/missing.md" "check 4: README.md:5:" "missing.svg" \
  "check 4: README.md:7:" "gone.md" "check 4: docs/x.md:1:" "../nope.md" "check 4: docs/x.md:3:" "'NOTICE'" \
  "check 4: README.md:11: link 'docs/X.md'" "check 4: README.md:11: link 'Docs/x.md'"
refute "README.md:9:"
# A link that leaves the repo does not resolve for a reader, even if the target exists on this machine
mkdir -p "$tmp/c4/root" && cp -R "$fx/check9-pass/." "$tmp/c4/root/" && echo x > "$tmp/c4/outside.md" &&
  echo '[out](../outside.md) and [up](../)' > "$tmp/c4/root/README.md" || exit 1
expect "$tmp/c4/root" nonzero "check 4: README.md:1:" "'../outside.md'" "'../'" "outside the repo"
# In a git work tree a non-ASCII name is still checked: git quotes such names unless told not to
mkdir -p "$tmp/c4/git" && cp -R "$fx/check9-pass/." "$tmp/c4/git/" && git -C "$tmp/c4/git" init -q &&
  echo '[gone](gone.md)' > "$tmp/c4/git/café.md" || exit 1
expect "$tmp/c4/git" nonzero "check 4: café.md:1:" "'gone.md'"

# Check 6: the committed AGENTS.md equals a fresh build. Built at run time around a copy of the real
# core/build-agents-md.mjs, so the fixture cannot drift from the script it tests.
c6="$tmp/c6"
mkdir -p "$c6/core" "$c6/skills/ponytail" && cp -R "$fx/check9-pass/." "$c6/" && cp core/build-agents-md.mjs "$c6/core/" &&
  printf '# Agreement\n\nBe equals.\n' > "$c6/core/agreement.md" &&
  printf '%s\n' --- "name: ponytail" "description: d" --- "" "# Ponytail" "" "Be lazy." "" > "$c6/skills/ponytail/SKILL.md" &&
  printf '\n# ADHD\n\nBe brief.\n' > "$c6/core/i-have-adhd.md" &&
  printf "## DIY-harness's own files\n\n| File | Upstream path |\n| --- | --- |\n| \`skills/ponytail/SKILL.md\` | none |\n" \
    > "$c6/vendor/UPSTREAM.md" || exit 1
expect "$c6" nonzero "check 6: AGENTS.md" "missing"
# Sources in order, blank edge lines dropped, one blank line between; run from another directory on purpose
(cd "$tmp" && node "$c6/core/build-agents-md.mjs") > "$tmp/c6.out" || fail "build-agents-md.mjs to stdout failed"
printf '# Agreement\n\nBe equals.\n\n# Ponytail\n\nBe lazy.\n\n# ADHD\n\nBe brief.\n' | cmp -s - "$tmp/c6.out" ||
  fail "build-agents-md.mjs printed: $(cat "$tmp/c6.out")"
node "$c6/core/build-agents-md.mjs" --write && cmp -s "$tmp/c6.out" "$c6/AGENTS.md" || fail "--write did not write the build"
node "$c6/core/build-agents-md.mjs" --bogus 2>/dev/null; [ $? -eq 2 ] || fail "build-agents-md.mjs accepts an unknown flag"
expect "$c6" 0
if env PATH=/usr/bin:/bin sh -c 'command -v node' >/dev/null 2>&1; then
  echo "SKIP: node is in /usr/bin or /bin, check 6 without node not exercised"; skips=$((skips + 1))
else
  out=$(PATH=/usr/bin:/bin sh scripts/check.sh "$c6" 2>&1) && fail "check 6 passes without node on PATH"
  case $out in *"check 6: AGENTS.md: node is not on PATH"*) ;; *) fail "no check 6 node failure. Output: $out" ;; esac
fi
echo "extra line" >> "$c6/AGENTS.md"
expect "$c6" nonzero "check 6: AGENTS.md" "differs"
printf '# Ponytail\n' > "$c6/skills/ponytail/SKILL.md"
expect "$c6" nonzero "check 6: core/build-agents-md.mjs" "no leading --- frontmatter block"
rm "$c6/core/build-agents-md.mjs"
expect "$c6" nonzero "check 6: core/build-agents-md.mjs" "missing"

# No-network check (spec 07 section 9): no file under hooks/ references a network API; an absent hooks/ passes
expect "$fx/hooks-clean" 0
expect "$fx/hooks-network" nonzero "check no-network: hooks/x.mjs:1:"
# Each network form fails on its own, in a variant of hooks-clean
for hook in 'globalThis.fetch(u)' "import http from 'node:http';" 'require("https")' "import net from 'net';" \
  'require("node:dgram")' "import tls from 'tls';" 'curl -s "$u"' 'wget -q -O- "$u"' 'new WebSocket(u)' \
  'new XMLHttpRequest()' 'const u = "http://localhost:1";' 'exec 3<>/dev/tcp/localhost/1' 'require("node:dns")' \
  "import dns from 'dns/promises';" "import { request } from 'undici';" 'const f = fetch;' 'globalThis["fetch"](u)'; do
  mkvariant hooks-clean && printf '%s\n' "$hook" > "$v/hooks/y.mjs"
  before=$fails
  expect "$v" nonzero "check no-network: hooks/y.mjs:1:"
  [ "$fails" -eq "$before" ] || echo "  (hook line: $hook)"
done
# A NUL byte makes grep treat a file as binary: GNU grep then prints no match line, BSD grep no line number
mkvariant hooks-clean && printf 'x\0\nfetch(u)\n' > "$v/hooks/y.mjs"
expect "$v" nonzero "check no-network: hooks/y.mjs:2:"
# grep -r does not read through a symlink, so a linked hook or hooks folder fails instead of passing unread
mkvariant hooks-clean && mkdir "$v/hooks/sub" && ln -s ../x.mjs "$v/hooks/sub/link.mjs"
expect "$v" nonzero "check no-network: hooks/sub/link.mjs" "symlink"
mkvariant check9-pass && ln -s "$PWD/$fx/hooks-network/hooks" "$v/hooks"
expect "$v" nonzero "check no-network: hooks:" "symlink"

# Hook wiring (PLAN Q8): Claude Code loads hooks/hooks.json by itself, so plugin.json must not name it again
mkvariant manifests-pass
sed -i.bak 's|"version"|"hooks": "./hooks/hooks.json", "version"|' "$v/.claude-plugin/plugin.json" &&
  mkdir -p "$v/hooks" && echo '{"hooks": {}}' > "$v/hooks/hooks.json"
expect "$v" nonzero "check hooks-wiring: .claude-plugin/plugin.json"
mkvariant manifests-pass
sed -i.bak 's|"version"|"hooks": ["./hooks/hooks.json"], "version"|' "$v/.claude-plugin/plugin.json" &&
  mkdir -p "$v/hooks" && echo '{"hooks": {}}' > "$v/hooks/hooks.json"
expect "$v" nonzero "check hooks-wiring: .claude-plugin/plugin.json"

# Budget (doc 05 section 2, PLAN Q7): AGENTS.md at most about 4,000 tokens (bytes / 4), and each part the hook
# prints within Claude Code's 10,000-character cap. Built at run time around copies of the real builder and hook.
b7="$tmp/budget"
budget_fixture() {  # <bytes of i-have-adhd text>
  rm -rf "$b7" && mkdir -p "$b7/core" "$b7/hooks" "$b7/skills/ponytail" && cp -R "$fx/check9-pass/." "$b7/" &&
    cp core/build-agents-md.mjs "$b7/core/" && cp hooks/session-start.mjs hooks/hooks.json "$b7/hooks/" &&
    printf '# Agreement\n\nBe equals.\n' > "$b7/core/agreement.md" &&
    printf '%s\n' --- "name: ponytail" "description: d" --- "" "# Ponytail" "" "Be lazy." > "$b7/skills/ponytail/SKILL.md" &&
    { echo "# ADHD"; awk -v n="$1" 'BEGIN { while (n > 0) { print "Be brief, be brief, be brief, be brief, be brief."; n -= 50 } }'; } \
      > "$b7/core/i-have-adhd.md" &&
    printf "## DIY-harness's own files\n\n| File | Upstream path |\n| --- | --- |\n| \`skills/ponytail/SKILL.md\` | none |\n" \
      > "$b7/vendor/UPSTREAM.md" && node "$b7/core/build-agents-md.mjs" --write || exit 1
}
budget_fixture 2000
expect "$b7" 0
# A session-start hook with no hooks/hooks.json never runs: the layer would vanish with every other check green
rm "$b7/hooks/hooks.json"
expect "$b7" nonzero "check hooks-wiring: hooks/hooks.json" "missing"
# The hook runs the builder in every session, so the no-network scan covers it too
budget_fixture 2000
# Never called, so the test itself makes no request
printf '%s\n' 'function unused(u) { return fetch(u); }' >> "$b7/core/build-agents-md.mjs"
expect "$b7" nonzero "check no-network: core/build-agents-md.mjs:"
# With no hooks/ folder the builder is the only file scanned; the report must still name it
rm -rf "$b7/hooks"
expect "$b7" nonzero "check no-network: core/build-agents-md.mjs:"
budget_fixture 2000
mv "$b7/core/build-agents-md.mjs" "$b7/core/real.mjs" && ln -s real.mjs "$b7/core/build-agents-md.mjs"
expect "$b7" nonzero "check no-network: core/build-agents-md.mjs" "symlink"
budget_fixture 11000
expect "$b7" nonzero "check budget: hooks/session-start.mjs adhd" "10,000"
refute "check budget: AGENTS.md"
budget_fixture 17000
expect "$b7" nonzero "check budget: AGENTS.md" "4,000"

# The real repo
expect . 0
grep -rq setup-matt-pocock-skills skills && fail "skills/ still mentions setup-matt-pocock-skills"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json \
  skills/diy-harness/SKILL.md skills/diy-harness/agents/openai.yaml \
  AGENTS.md core/agreement.md core/build-agents-md.mjs README.md; do
  [ -f "$f" ] || fail "$f missing"
done
[ "$(readlink CLAUDE.md)" = AGENTS.md ] || fail "CLAUDE.md is not a symlink to AGENTS.md"
# AGENTS.md is the agreement, then the ponytail body, then i-have-adhd: each without blank edge lines, a blank line
# between. Rebuilt here in shell, independently of core/build-agents-md.mjs.
trim() { awk 'NF && !s { s = NR } { a[NR] = $0 } NF { e = NR } END { for (i = s; s && i <= e; i++) print a[i] }'; }
nofm() { awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } !fm' "$1"; }
{ trim < core/agreement.md; echo; nofm skills/ponytail/SKILL.md | trim; echo; trim < core/i-have-adhd.md; } |
  cmp -s - AGENTS.md || fail "AGENTS.md is not agreement, then ponytail, then i-have-adhd"

# The always-on hook (ticket 07): one run per rule set, a header line, then exactly that part
grep -q '"hooks"' .claude-plugin/plugin.json && fail ".claude-plugin/plugin.json names a hooks file (PLAN Q8)"
grep -q '"owner": { "name": "aakashkavuru101" }' .claude-plugin/marketplace.json || fail "marketplace owner is not aakashkavuru101 (D11)"
h_agreement="diy-harness always-on: the working agreement."
h_ponytail='diy-harness always-on: ponytail rules. "stop ponytail" or "normal mode" switches them off.'
h_adhd='diy-harness always-on: i-have-adhd rules. "stop adhd mode" or "normal mode" switches them off.'
expected_part() {  # <part>: header line, a blank line, the part, as the hook should print it
  eval "printf '%s\n\n' \"\$h_$1\""
  case $1 in agreement) trim < core/agreement.md ;; ponytail) nofm skills/ponytail/SKILL.md | trim ;; adhd) trim < core/i-have-adhd.md ;; esac
}
for p in agreement ponytail adhd; do
  expected_part "$p" > "$tmp/want.$p"
  node hooks/session-start.mjs SessionStart "$p" < /dev/null > "$tmp/got.$p"; c=$?
  [ "$c" -eq 0 ] && cmp -s "$tmp/want.$p" "$tmp/got.$p" || fail "SessionStart $p: exit $c, output differs from header + part"
  # Stdin that is not JSON changes nothing
  printf 'not json' | node hooks/session-start.mjs SessionStart "$p" > "$tmp/got.$p"; c=$?
  [ "$c" -eq 0 ] && cmp -s "$tmp/want.$p" "$tmp/got.$p" || fail "SessionStart $p: garbled stdin gave exit $c or other output"
done
# A subagent gets ponytail and i-have-adhd as JSON additionalContext, and never the agreement
for p in ponytail adhd; do
  node hooks/session-start.mjs SubagentStart "$p" < /dev/null | node -e '
    const fs = require("fs"); const o = JSON.parse(fs.readFileSync(0, "utf8")).hookSpecificOutput || {};
    process.exit(o.hookEventName === "SubagentStart" && o.additionalContext === fs.readFileSync(process.argv[1], "utf8") ? 0 : 1)' \
    "$tmp/want.$p" || fail "SubagentStart $p: not JSON additionalContext of header + part"
done
[ -z "$(node hooks/session-start.mjs SubagentStart agreement < /dev/null)" ] || fail "SubagentStart agreement printed something"
[ -z "$(node hooks/session-start.mjs Bogus ponytail < /dev/null)$(node hooks/session-start.mjs SessionStart bogus < /dev/null)" ] ||
  fail "an unknown event or part printed something"
# hooks.json: SessionStart (startup, resume, clear, compact) runs all three parts, SubagentStart only two, each with a timeout
node -e 'import("./core/build-agents-md.mjs").then(({ PARTS }) => {
  const h = JSON.parse(require("fs").readFileSync("hooks/hooks.json", "utf8")).hooks;
  const runs = (ev) => (h[ev] || []).flatMap((g) => g.hooks.map((x) => ({ m: g.matcher, t: x.timeout, c: x.command })));
  const parts = (ev) => runs(ev).map((r) => (r.c.match(new RegExp("session-start\\.mjs\" " + ev + " (\\w+)$")) || [])[1]).join(",");
  const ok = parts("SessionStart") === PARTS.join(",") && parts("SubagentStart") === "ponytail,adhd" &&
    runs("SessionStart").every((r) => r.m === "startup|resume|clear|compact") &&
    [...runs("SessionStart"), ...runs("SubagentStart")].every((r) => Number.isInteger(r.t) && r.t > 0 && r.t <= 30);
  process.exit(ok ? 0 : 1) })' || fail "hooks/hooks.json does not wire the parts as ticket 07 says"
# Stdin that never closes cannot hold the hook up
node -e '
  const p = require("child_process").spawn(process.execPath, ["hooks/session-start.mjs", "SessionStart", "ponytail"], { stdio: ["pipe", "pipe", "inherit"] });
  let out = ""; p.stdout.on("data", (d) => (out += d));
  const t = setTimeout(() => { p.kill(); process.exit(1); }, 2000);
  const want = require("fs").readFileSync(process.argv[1], "utf8");
  p.on("close", (c) => { clearTimeout(t); process.exit(c === 0 && out === want ? 0 : 1); });' "$tmp/want.ponytail" ||
  fail "SessionStart ponytail did not finish within 2 seconds with stdin left open"
# A missing source silences only its own part; the hook still exits 0
hk="$tmp/hookcopy"
mkdir -p "$hk/core" "$hk/hooks" "$hk/skills/ponytail" && cp core/build-agents-md.mjs core/agreement.md "$hk/core/" &&
  cp hooks/session-start.mjs "$hk/hooks/" && cp skills/ponytail/SKILL.md "$hk/skills/ponytail/" || exit 1
out=$(node "$hk/hooks/session-start.mjs" SessionStart adhd < /dev/null 2>&1); c=$?
[ "$c" -eq 0 ] && [ -z "$out" ] || fail "SessionStart adhd with core/i-have-adhd.md missing: exit $c, output '$out'"
node "$hk/hooks/session-start.mjs" SessionStart ponytail < /dev/null | cmp -s "$tmp/want.ponytail" - ||
  fail "SessionStart ponytail stopped working when core/i-have-adhd.md went missing"
rm "$hk/core/build-agents-md.mjs"
out=$(node "$hk/hooks/session-start.mjs" SessionStart ponytail < /dev/null 2>&1); c=$?
[ "$c" -eq 0 ] && [ -z "$out" ] || fail "hook with core/build-agents-md.mjs missing: exit $c, output '$out'"
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
  echo "SKIP: upstream/ absent, licence and skill identity not checked"; skips=$((skips + 1))
fi

[ "$fails" -eq 0 ] && echo "PASS ($skips skipped)" || { echo "$fails failed"; exit 1; }
