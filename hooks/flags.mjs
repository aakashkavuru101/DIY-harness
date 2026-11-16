// Session off-switch flags shared by prompt-tracker.mjs and session-start.mjs (ticket 08, PLAN.md D5 table).
// A flag is <config>/diy-harness/sessions/<session_id>, holding only the names of the rule sets that are off.
// Flags are never read or written through a symlink, and a session ID must be a plain token.
import { lstatSync, lutimesSync, mkdirSync, readdirSync, readFileSync, renameSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { isAbsolute, join } from "node:path";

const ID = /^[A-Za-z0-9_-]{1,128}$/;
const WEEK_MS = 7 * 24 * 60 * 60 * 1000;
export const RULE_SETS = ["ponytail", "adhd"];

// The sessions folder, or null. A relative CLAUDE_CONFIG_DIR or HOME is not used: the hook runs in the user's project.
export function sessionsDir() {
  const base = process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude");
  return isAbsolute(base) ? join(base, "diy-harness", "sessions") : null;
}

export const validId = (id) => typeof id === "string" && ID.test(id);

// Hook input from stdin, parsed, or {} when it is missing, not JSON or never closes (fallback timer, 800 ms).
export function readInput() {
  return new Promise((resolve) => {
    let data = "";
    const finish = () => {
      clearTimeout(timer);
      process.stdin.destroy();
      try { resolve(JSON.parse(data) || {}); } catch { resolve({}); }
    };
    const timer = setTimeout(finish, 800);
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => { data += chunk; if (data.length > 1_000_000) finish(); });
    process.stdin.on("end", finish);
    process.stdin.on("error", finish);
  });
}

const isFile = (p) => { try { return lstatSync(p).isFile(); } catch { return false; } };
const isLink = (p) => { try { return lstatSync(p).isSymbolicLink(); } catch { return false; } };

// The rule sets switched off for a session. Any doubt (no flag, a symlink, unreadable, removed meanwhile) gives an
// empty set, so the rules stay on: failing open.
export function readFlags(id) {
  try {
    const dir = sessionsDir();
    if (!dir || !validId(id) || isLink(dir) || !isFile(join(dir, id))) return new Set();
    const names = readFileSync(join(dir, id), "utf8").split("\n");
    return new Set(names.filter((n) => RULE_SETS.includes(n)));
  } catch {
    return new Set();
  }
}

// Add rule sets to a session's flag, through a temp file and a rename, so an existing symlink is replaced, not followed
export function addFlags(id, names) {
  const dir = sessionsDir();
  if (!dir || !validId(id)) return false;
  mkdirSync(dir, { recursive: true, mode: 0o700 });
  if (lstatSync(dir).isSymbolicLink()) return false;
  const all = new Set([...readFlags(id), ...names]);
  const tmp = join(dir, `.${id}.${process.pid}.tmp`);
  writeFileSync(tmp, RULE_SETS.filter((n) => all.has(n)).join("\n") + "\n", { flag: "wx", mode: 0o600 });
  try {
    renameSync(tmp, join(dir, id));
  } catch (e) {
    try { unlinkSync(tmp); } catch {} // prune never removes a temp name, so clean it up here
    throw e;
  }
  return true;
}

// At a session start: refresh the starting session's own flag, so a session in use keeps its switch, then delete
// flags not refreshed for 7 days. Only regular files named like a flag; symlinks and other files are left alone.
export function pruneFlags(currentId) {
  const dir = sessionsDir();
  if (!dir || isLink(dir)) return;
  const now = new Date();
  let names = [];
  try { names = readdirSync(dir); } catch { return; }
  for (const name of names) {
    try {
      const p = join(dir, name);
      const st = lstatSync(p);
      if (!validId(name) || !st.isFile()) continue;
      if (name === currentId) lutimesSync(p, now, now);
      else if (now - st.mtimeMs > WEEK_MS) unlinkSync(p);
    } catch {
      // Removed meanwhile, or not ours to touch: skip it
    }
  }
}
