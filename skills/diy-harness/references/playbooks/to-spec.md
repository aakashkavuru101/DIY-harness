
This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.

The issue tracker is local: the spec is `.harness/SPEC.md` and the tickets are files in `.harness/tickets/`.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Read [the template](../templates/SPEC.md) and write the spec to `.harness/SPEC.md` from it. Keep its headings and field names, fill in every field, and leave out its comments.
