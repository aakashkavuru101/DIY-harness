// UserPromptSubmit hook (ticket 08): a prompt that is exactly "stop ponytail", "stop adhd mode" or "normal mode"
// (ignoring case, surrounding space and trailing punctuation) switches that rule set off for this session.
// It writes only a flag naming the rule sets, never the prompt. It always exits 0 and never blocks a prompt.
const PHRASES = { "stop ponytail": ["ponytail"], "stop adhd mode": ["adhd"], "normal mode": ["ponytail", "adhd"] };
const LABEL = { ponytail: "ponytail", adhd: "i-have-adhd" };

try {
  // Imported here, not at the top, so a missing file is caught and the hook still exits 0
  const { addFlags, readInput } = await import("./flags.mjs");
  const input = await readInput();
  const said = String(input.prompt ?? "").trim().toLowerCase().replace(/[.!?\s]+$/, "");
  const names = Object.hasOwn(PHRASES, said) ? PHRASES[said] : null;
  if (names && addFlags(input.session_id, names)) {
    const what = names.map((n) => LABEL[n]).join(" and ");
    process.stdout.write(`diy-harness: ${what} rules are now off for this session. They stay off when this session is ` +
      `resumed or compacted; /clear or a new session brings them back.\n`);
  }
} catch {
  // Never block a prompt
}
process.exitCode = 0;
