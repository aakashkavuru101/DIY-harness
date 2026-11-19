// Drop blank rows and trim every cell.
export function clean(rows) {
  return rows.map((row) => row.map((cell) => cell.trim())).filter((row) => row.some((cell) => cell !== ""));
}
