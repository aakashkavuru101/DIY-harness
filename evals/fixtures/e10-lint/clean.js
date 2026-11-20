// Drop blank rows from CSV text on stdin and trim every cell.
import { readFileSync } from "node:fs";

export function clean(text) {
  return text
    .split("\n")
    .map((line) => line.split(",").map((cell) => cell.trim()))
    .filter((cells) => cells.some((cell) => cell !== ""))
    .map((cells) => cells.join(","))
    .join("\n");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  process.stdout.write(clean(readFileSync(0, "utf8")) + "\n");
}
