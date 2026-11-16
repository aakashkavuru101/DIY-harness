// The always-on hook (docs/spec/05 section 2). hooks/hooks.json runs it once per rule set, because Claude Code
// caps one hook's output at 10,000 characters (PLAN.md Q7).
// Usage: node hooks/session-start.mjs <SessionStart|SubagentStart> <agreement|ponytail|adhd>
// It prints a header line and the part: plain text for SessionStart, JSON additionalContext for SubagentStart.
// A subagent never gets the agreement. A rule set switched off (ticket 08) prints a one-line notice instead.
// On stdin that is missing, garbled or never closes it fails open. On any other error it prints nothing.
// It always exits 0, so a session always starts.
const HEADERS = {
  agreement: "diy-harness always-on: the working agreement.",
  ponytail: 'diy-harness always-on: ponytail rules. "stop ponytail" or "normal mode" switches them off.',
  adhd: 'diy-harness always-on: i-have-adhd rules. "stop adhd mode" or "normal mode" switches them off.',
};
const SESSION_OFF = {
  ponytail: 'diy-harness always-on: ponytail rules are off for this session ("stop ponytail" or "normal mode").',
  adhd: 'diy-harness always-on: i-have-adhd rules are off for this session ("stop adhd mode" or "normal mode").',
};
const ENV_OFF = {
  ponytail: "diy-harness always-on: ponytail rules are off (DIY_HARNESS_OFF).",
  adhd: "diy-harness always-on: i-have-adhd rules are off (DIY_HARNESS_OFF).",
};
const FOR_SUBAGENTS = ["ponytail", "adhd"];

let text = "";
let event;
try {
  const [ev, name] = process.argv.slice(2);
  event = ev;
  const wanted = Object.hasOwn(HEADERS, name) &&
    (event === "SessionStart" || (event === "SubagentStart" && FOR_SUBAGENTS.includes(name)));
  if (wanted) {
    // Imported here, not at the top, so a missing file is caught like any other error
    const flags = await import("./flags.mjs");
    const input = await flags.readInput();
    const envOff = String(process.env.DIY_HARNESS_OFF ?? "").split(",").map((s) => s.trim().toLowerCase());
    // Only ponytail and i-have-adhd can be off; the agreement never reads a switch
    const switchable = flags.RULE_SETS.includes(name);
    if (switchable && envOff.includes(name)) text = `${ENV_OFF[name]}\n`;
    else if (switchable && flags.readFlags(input.session_id).has(name)) text = `${SESSION_OFF[name]}\n`;
    else {
      const { part } = await import("../core/build-agents-md.mjs");
      text = `${HEADERS[name]}\n\n${part(name)}\n`;
    }
    // One run per real session start prunes old flags; runs without a session ID (check.sh, tests) never do
    if (event === "SessionStart" && name === "agreement" && flags.validId(input.session_id)) {
      try { flags.pruneFlags(input.session_id); } catch {} // pruning can never cost the part already built
    }
  }
} catch {
  text = ""; // A missing or unreadable source: print nothing for this part
}
const out = !text ? "" : event === "SessionStart" ? text
  : JSON.stringify({ hookSpecificOutput: { hookEventName: event, additionalContext: text } }) + "\n";
// Exit only once stdout is flushed: on macOS a pipe write can still be pending
if (out) process.stdout.write(out, () => process.exit(0));
else process.exit(0);
