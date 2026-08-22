---
name: resolving-merge-conflicts
description: "Resolve git merge / rebase conflicts by intent. 按意图解决 git merge / rebase 冲突. Use when: merge/rebase stops on conflict / pull fails with conflicts / rebase needs hunk-by-hunk decision / user says 'help me resolve this conflict' / 'git is fighting me' / git 冲突了 / 帮我解冲突 / rebase 卡住了 / 这冲突什么意思 / git 在跟我打架 / pull 失败. Process: see current state → read primary sources (commits/PRs/issues) → resolve each hunk preserving both intents → run automated checks → finish. Not for routine rebase/squash/git-history (use omo's git-master). Always resolve; never --abort unless asked."
---

1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. Always resolve; never `--abort`.

4. Discover the project's **automated checks** and run them, typically typecheck, then tests, then format. Fix anything the merge broke.

5. **Finish the merge/rebase.** Stage everything and commit. If rebasing, continue the rebase process until all commits are rebased.
