import assert from "node:assert/strict";
import { test } from "node:test";
import { clean } from "./clean.js";

test("drops blank rows and trims cells", () => {
  assert.deepEqual(clean([[" a ", "b"], ["", " "]]), [["a", "b"]]);
});
