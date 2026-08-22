---
name: domain-modeling
description: "Write or edit the project's domain vocabulary in CONTEXT.md. Use when: a term crystallises / writing or editing a CONTEXT.md / 术语结晶 / 决策敲定. For architecture-level decisions (technical stack, cross-context boundaries, hard-to-reverse choices), offer routing to `architecture-decision-records` — that skill is the ONLY owner of `docs/adr/` (templates, numbering, lifecycle, index). Requires the domain doc layout (run setup-meisijiya-skills first if missing). NOT for SKILL.md or AGENTS.md (use writing-for-agents), for deep-module design vocabulary (use codebase-design), or for writing ADRs (use architecture-decision-records)."
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline: challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise. (Merely *reading* `CONTEXT.md` for vocabulary is not this skill: that's a one-line habit any skill can do. This skill is for when you're changing the model, not just consuming it.)

## File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily: only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. The `docs/adr/` directory is owned by `architecture-decision-records` — this skill no longer creates it.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account': do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up: capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer to route architecture-level decisions to architecture-decision-records

This skill owns `CONTEXT.md` only. When a decision crystallises in conversation, first judge whether it's **vocabulary** (terminology, definitions, glossary entries) or **architecture** (technical stack, cross-context boundaries, hard-to-reverse choices):

- **Vocabulary** → update `CONTEXT.md` right there (see "Update CONTEXT.md inline" above).
- **Architecture** → if all three are true, offer to route it to `architecture-decision-records`:

  1. **Hard to reverse**: the cost of changing your mind later is meaningful
  2. **Surprising without context**: a future reader will wonder "why did they do it this way?"
  3. **The result of a real trade-off**: there were genuine alternatives and you picked one for specific reasons

  If any of the three is missing, skip the ADR — record it in `CONTEXT.md` if it stays a term, or just write the code if it's reversible.

`architecture-decision-records` owns the full ADR workflow: templates (MADR / Lightweight / Y-Statement / Deprecation / RFC), `NNNN-kebab-title.md` numbering, `Proposed → Accepted → Deprecated → Superseded` lifecycle, `docs/adr/README.md` index, and review checklist. Do **not** write ADR files directly from this skill.
