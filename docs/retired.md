---
layout: default
title: "Retired Skills"
---

<section class="page-head">
  <p class="eyebrow mono">归档 · 已弃用</p>
  <h1 class="mono">15 个 retired skill</h1>
  <p class="muted">合并 / 由 omo 内置替代 / 触发噪音，已从 `skills/` 删除。</p>
</section>

| name | category | 弃用原因 | replacement |
|---|---|---|---|
| `setup-matt-pocock-skills` | engineering | 重命名为 `setup-meisijiya-skills`（去掉上游词汇） | `setup-meisijiya-skills` |
| `ask-matt` | engineering | 路由型 skill，omo 无内置对应 | — |
| `grill-with-docs` | engineering | 与 `grilling` + `domain-modeling` 工作流重叠 | `grilling` + `domain-modeling` |
| `implement` | engineering | 与 omo `task()` 多 Agent 委派机制重叠 | omo `task()` |
| `research` | engineering | 范围过大，触发噪音明显；omo `/ulw-research` 已覆盖 | omo `/ulw-research` |
| `to-spec` | engineering | 由 omo `/ulw-plan` 承接 | omo `/ulw-plan` |
| `to-tickets` | engineering | 由 omo `/ulw-plan` 承接 | omo `/ulw-plan` |
| `triage` | engineering | omo `issue-tracker` workflow 内置类似流程 | omo `issue-tracker` |
| `wayfinder` | engineering | 仅大型 monorepo 需要，触发噪音明显 | — |
| `grill-me` | productivity | 由 `grilling` 合并 | `grilling` |
| `handoff` | productivity | 与 omo `task()` 多 Agent 委派机制重叠 | omo `task()` |
| `teach` | productivity | omo 内置 `teach` skill | omo `teach` |
| `to-questionnaire` | productivity | 与 `grilling` 工作流重叠 | `grilling` |
| `wait-what` | productivity | 由 `grilling` 承接 | `grilling` |
| `slice-work` | engineering | 与 omo `/ulw-plan` 触发面重叠、缺任务行语法约束；omo `prometheus.prompt_append` 已内化垂直切片纪律 | omo `/ulw-plan` + `prometheus.prompt_append` |

## 分类小结

### 重命名 / 合并 {#renamed}

- `setup-matt-pocock-skills` → `setup-meisijiya-skills`
- `grill-me` → `grilling`
- `to-questionnaire` → `grilling`

### omo 内置替代 {#omo-builtin}

- `implement` → omo `task()`
- `handoff` → omo `task()`
- `teach` → omo `teach`
- `research` → omo `/ulw-research`
- `to-spec` → omo `/ulw-plan`
- `to-tickets` → omo `/ulw-plan`
- `slice-work` → omo `prompt_append`
- `triage` → omo `issue-tracker`

### 触发噪音去除 {#noise}

- `ask-matt` / `wayfinder` / `wait-what`