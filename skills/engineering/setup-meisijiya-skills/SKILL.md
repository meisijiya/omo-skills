---
name: setup-meisijiya-skills
description: "User-invoked only — do not invoke automatically. Configure this repo for the Meisijiya skills: domain doc layout (CONTEXT.md + docs/adr/) and the adopted-skill manifest. Run once before first use."
disable-model-invocation: true
---

# Setup Meisijiya's Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Domain docs**: where `CONTEXT.md` and ADRs live, and the consumer rules for reading them

This is a prompt-driven skill, not a deterministic script. Explore, write, confirm.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `AGENTS.md` and `CLAUDE.md` at the repo root: does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `docs/adr/` at the repo root
- `docs/agents/`: does this skill's prior output already exist?
- Monorepo signals: a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. These are present only in a genuinely large multi-package repo; their absence means single-context, which is almost every repo.

### 2. Domain docs layout

Default to **single-context** (one `CONTEXT.md` + `docs/adr/` at the repo root). This fits almost every repo; write it without asking.

Offer **multi-context** (a root `CONTEXT-MAP.md` pointing to per-context `CONTEXT.md` files) only when exploration found monorepo signals. Then confirm which layout they want.

### 3. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create; don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa); always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Then write `docs/agents/domain.md` using the seed template in this skill folder as a starting point.

### 4. Done

Tell the user the setup is complete and which engineering skills will now read from this file. Mention they can edit `docs/agents/domain.md` directly later; re-running this skill is only necessary if they want to switch layouts or restart from scratch.
