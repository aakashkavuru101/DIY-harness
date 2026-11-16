// The always-on hook (docs/spec/05 section 2). hooks/hooks.json runs it once per rule set, because Claude Code
// caps one hook's output at 10,000 characters (PLAN.md Q7).
// Usage: node hooks/session-start.mjs <SessionStart|SubagentStart> <agreement|ponytail|adhd>
// It prints a header line and the part: plain text for SessionStart, JSON additionalContext for SubagentStart.
// A subagent never gets the agreement. It does not read stdin. On any error it prints nothing, and it always
// exits 0, so a session always starts.
const HEADERS = {
  agreement: "diy-harness always-on: the working agreement.",
  ponytail: 'diy-harness always-on: ponytail rules. "stop ponytail" or "normal mode" switches them off.',
  adhd: 'diy-harness always-on: i-have-adhd rules. "stop adhd mode" or "normal mode" switches them off.',
};
const FOR_SUBAGENTS = ["ponytail", "adhd"];

try {
  const [event, name] = process.argv.slice(2);
  const wanted = Object.hasOwn(HEADERS, name) &&
    (event === "SessionStart" || (event === "SubagentStart" && FOR_SUBAGENTS.includes(name)));
  if (wanted) {
    // Imported here, not at the top, so a missing builder is caught like any other error
    const { part } = await import("../core/build-agents-md.mjs");
    const text = `${HEADERS[name]}\n\n${part(name)}\n`;
    process.stdout.write(event === "SessionStart" ? text
      : JSON.stringify({ hookSpecificOutput: { hookEventName: event, additionalContext: text } }) + "\n");
  }
} catch {
  // A missing or unreadable source: print nothing for this part
}
process.exitCode = 0;
