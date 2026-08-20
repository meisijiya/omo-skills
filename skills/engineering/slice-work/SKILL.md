---
name: slice-work
description: "Decompose a plan or request into vertical tracer-bullet slices, each cutting a complete path through every layer and declaring its blocking edges. Use when a plan or spec needs breaking into independently-completable work items with explicit dependencies."
---

# Slice Work

Break a plan, spec, or current conversation into **vertical tracer-bullet slices**: each one a narrow but complete cut through every layer, with explicit blocking edges.

## 1. Vertical slice rules

Every slice must:

- Cut a narrow but **complete** path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- Be **independently demoable or verifiable** on its own — the user can see it work before the next slice starts
- Fit in a **single fresh context window** — if it won't, the slice is too wide
- Have **prefactoring done first** as its own slices (so implementation slices stay clean)

Wide mechanical refactors are the exception. A single edit whose blast radius fans across the whole codebase breaks thousands of call sites at once; no vertical slice can land green. Use **expand–contract** instead:

1. **Expand**: add the new form beside the old so nothing breaks
2. **Migrate**: move call sites over in batches sized by blast radius (per package, per directory), each batch its own slice blocked by the expand, keeping CI green batch to batch because the old form still exists
3. **Contract**: delete the old form once no caller remains, in a slice blocked by every migrate batch

When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify slice; green is promised only there.

## 2. Blocked by dependency edges

Every slice declares the other slices that **block** it. A slice with no blockers can start immediately; a slice whose blockers are all done is the next frontier.

Edges go **one direction only** (blocker → blocked). Never write bidirectional or implied edges. If A and B genuinely need each other, the design is wrong; merge them into one slice.

## 3. Output location

Where the slices land depends on the caller:

- For a Prometheus work plan: write them as `## Todos` checkboxes under `.omo/plans/<plan-name>.md`, with `Blocked by:` in each entry's body
- For a real issue tracker: publish one issue per slice to wherever the repo tracks work
- For inline conversation: emit the slice list as a numbered list in chat

The slices themselves are the same in every case; only the publishing shape changes. The caller decides.
