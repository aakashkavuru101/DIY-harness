// Prints the always-on layer from a local file. Words like network or prefetch() are not network calls.
import { readFileSync } from "node:fs";

const netCount = 0;
function prefetch() {}
prefetch();
process.stdout.write(readFileSync(new URL("../AGENTS.md", import.meta.url), "utf8") + netCount);
