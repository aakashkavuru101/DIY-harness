// Builds the always-on layer (docs/spec/05 section 2): core/agreement.md, then the body of
// skills/ponytail/SKILL.md, then core/i-have-adhd.md, in the precedence order of docs/spec/03 section 4.
// Usage: node core/build-agents-md.mjs [--write]   Prints to stdout; --write writes AGENTS.md instead.
// Paths are relative to this repo, not the current directory. Node only, no dependencies.
// hooks/session-start.mjs imports part() so the hook and AGENTS.md cannot differ.
import { readFileSync, realpathSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = new URL("../", import.meta.url);
const read = (path) => readFileSync(new URL(path, root), "utf8");

// The text after the leading --- frontmatter block. A file without one is an error, so frontmatter
// can never leak into the layer.
function body(path) {
  const lines = read(path).split("\n");
  const end = lines[0] === "---" ? lines.indexOf("---", 1) : -1;
  if (end < 0) throw new Error(`${path}: no leading --- frontmatter block`);
  return lines.slice(end + 1).join("\n");
}

// Blank lines at either end are dropped, so the parts are joined by exactly one blank line.
const trim = (text) => text.replace(/^([ \t]*\n)+/, "").replace(/(\n[ \t]*)+$/, "");

const SOURCES = {
  agreement: () => read("core/agreement.md"),
  ponytail: () => body("skills/ponytail/SKILL.md"),
  adhd: () => read("core/i-have-adhd.md"),
};
export const PARTS = Object.keys(SOURCES);

// One part of the layer, trimmed. Reads only that part's source; throws if it is missing.
export function part(name) {
  if (!Object.hasOwn(SOURCES, name)) throw new Error(`unknown part: ${name}`);
  return trim(SOURCES[name]());
}

function main() {
  const args = process.argv.slice(2);
  if (args.length > 1 || (args.length === 1 && args[0] !== "--write")) {
    console.error("usage: node core/build-agents-md.mjs [--write]");
    process.exit(2);
  }
  let text;
  try {
    text = PARTS.map(part).join("\n\n") + "\n";
  } catch (e) {
    console.error(`build-agents-md: ${e.message}`);
    process.exit(1);
  }
  if (args[0] === "--write") writeFileSync(new URL("AGENTS.md", root), text);
  else process.stdout.write(text);
}

// Run only as a script, not when imported by the hook
if (process.argv[1] && realpathSync(process.argv[1]) === realpathSync(fileURLToPath(import.meta.url))) main();
