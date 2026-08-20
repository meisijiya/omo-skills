# omo + Meisijiya Skills 工作流

本文记录 OhMyOpenCode（**omo**，运行在 OpenCode 平台）配合本仓库筛选的 12 个 skill 的完整工作流，从三个核心 Agent 讲起，串起 skill 的使用场景。

## 1. 三个 Agent 的接力

omo 把「一次需求 → 落地」拆成三个 Agent 三段接力，各自有独立模型配置（`~/.config/opencode/oh-my-openagent.jsonc` 的 `agents`）：

| Agent | 角色 | 触发方式 | 产出 |
|---|---|---|---|
| **Sisyphus** | 会话主脑 / 主编排者 | 每次对话默认 | 意图判定 + 委派路由 |
| **Prometheus** | 规划专员（只读） | `/ulw-plan` skill | `.omo/plans/<slug>.md` 决策完备计划 |
| **Atlas** | 执行编排者 | `/start-work` skill | 计划全部 checkbox 完成 + 证据台账 |

三者都不是「实现者」：Sisyphus 与 Atlas 只编排（通过 `task()` 把工作委派给 subagent），Prometheus 只探索和写计划——他们的手不碰产品代码。

```
用户请求
   │
   ▼
┌─────────────┐  Intent Gate 识别意图
│  Sisyphus   │── trivial / explicit ──► 直接委派 task() 做掉
│ （主脑）     │
└──────┬──────┘
       │ 需要规划 / 模糊 / 大型需求
       ▼
┌─────────────┐  探索优先 → 写 ONE decision-complete 计划
│ Prometheus  │── 产出 .omo/plans/*.md ──► 等用户批准
│ （规划）     │
└──────┬──────┘
       │ 用户批准 / "start work"
       ▼
┌─────────────┐  读计划 → Boulder 状态 → 逐 checkbox 拆解 → task() 并行委派 → 验证 → 证据
│   Atlas     │
│ （执行编排） │── 直到所有 checkbox 完成
└─────────────┘
```

## 2. skill 的两层来源

OpenCode 下 omo 的 skill 分两层：

1. **omo 内置层**（插件自带 `dist/skills/`）—— 编排 / 工具型，就是三个 Agent 的「操作手册」：`ulw-plan`、`start-work`、`ulw-research`、`review-work`、`debugging`、`git-master`、`frontend`、`programming`、`refactor`、`remove-ai-slops`、`visual-qa`、`lsp-setup`、`ast-grep` 等。

2. **本仓库筛选层**（`~/.config/opencode/skills/`）—— 12 个 Meisijiya skill，工程 / 方法论型：
   - `engineering/`（10）：`setup-meisijiya-skills`、`codebase-design`、`domain-modeling`、`tdd`、`improve-codebase-architecture`、`prototype`、`diagnosing-bugs`、`code-review`、`resolving-merge-conflicts`、`wizard`
   - `productivity/`（2）：`grilling`、`writing-for-agents`

**筛选原则是「去重」**：凡是 omo 内置能力已覆盖的一律弃用（15 个），避免重复触发——`research` → `/ulw-research`、`to-spec` / `to-tickets` / `slice-work` → `/ulw-plan`、`implement` / `handoff` → `task()`、`grill-me` / `wait-what` → `grilling`、`teach` → omo `teach`、`triage` → omo issue-tracker。

## 3. skill 在流水线各环节的注入点

### 一次性初始化（Sisyphus 首次进新 repo）

- **`setup-meisijiya-skills`**：建领域文档布局（`CONTEXT.md` + `docs/adr/`）。这是其它 skill 的前置。

### Prometheus 规划阶段

- **`domain-modeling` 的产物被消费**：Prometheus 探索时读 `CONTEXT.md` + `docs/adr/`（`docs/agents/domain.md` 规定契约）。
- **`codebase-design`**：提供深模块词汇（module / interface / seam / adapter / depth），被 `tdd` 和 `improve-codebase-architecture` 引用为参考源。
- 探索工具链：`codegraph_explore` 优先 → `explore` / `librarian` 只读 subagent → `metis`（gap 分析）/ `momus`（高精度计划评审）。

### Atlas 执行阶段（worker 被注入 skill）

- **`tdd`**：实现走红 → 绿 → 重构。
- **`prototype`**：可行性 spike（计划里明确要的 spike）。
- **`code-review`**：日常两轴 diff 评审（与 `/review-work` 的 PR 交接 full QA 互补）。
- **`resolving-merge-conflicts`**：解决 in-progress merge / rebase 冲突（常规 rebase 走 `git-master`）。

### Sisyphus 日常直接执行阶段（不经过计划的轻量活）

- **`diagnosing-bugs`**：硬 bug 诊断循环（先建 feedback loop）—— 与 `/debugging`（崩溃 / hang / attach）互补。
- **`wizard`**：基础设施 / 凭据 / CI 这类只能人工操作的多步向导。
- **`grilling`**：交叉质询用户的 plan / design。
- **`writing-for-agents`**：写 `SKILL.md` / `AGENTS.md`（opencode 配置走 `customize-opencode`）。
- **`prototype`**：用户问「这个状态模型 / UI 对吗」时的设计探索。

### 两个 user-invoked 守卫

**`improve-codebase-architecture`**、**`setup-meisijiya-skills`** 带 `User-invoked only` 前缀 + `disable-model-invocation: true`，只能用户显式触发，避免 Agent 误触发。

## 4. 12 个 skill 使用场景映射

| Skill | 类别 | 触发阶段 | 一句话用途 |
|---|---|---|---|
| setup-meisijiya-skills | engineering | 一次性初始化 | 建 CONTEXT.md + docs/adr/ 布局 |
| codebase-design | engineering | 被引用 | 深模块词汇参考源（module/interface/seam/adapter/depth） |
| domain-modeling | engineering | 讨论 / 规划中 | 术语结晶时写 CONTEXT.md 词汇、决策敲定时 offer ADR |
| tdd | engineering | Atlas 执行 | 红 → 绿 → 重构 |
| improve-codebase-architecture | engineering | user-invoked | 渐进架构改良 |
| prototype | engineering | Sisyphus 评估 / Atlas spike | 快速原型与可行性验证 |
| diagnosing-bugs | engineering | Sisyphus 日常 | 硬 bug 诊断循环（先建 feedback loop） |
| code-review | engineering | 日常评审 | 两轴差异评审（vs /review-work） |
| resolving-merge-conflicts | engineering | 冲突时 | 解决 in-progress merge / rebase 冲突 |
| wizard | engineering | 人工操作 | 多步人工向导 |
| grilling | productivity | 质询 | 严格交叉质询 |
| writing-for-agents | productivity | 写文档 | 写 SKILL.md / AGENTS.md |

## 5. prompt_append 融合机制

为了让三个主 Agent 稳定触发这些 skill，把融合规则内化到 `~/.config/opencode/oh-my-openagent.jsonc` 的 `agents.*.prompt_append`（agent 级通用字段，追加到各 agent system prompt 末尾）。

配置的唯一事实来源是 **`config/oh-my-openagent.prompt-append.jsonc`**，安装时用 **`scripts/install-prompt-append.mjs`** 幂等合并（只更新三个 `prompt_append`，不碰 model / variant / categories / team_mode）。

| Agent | prompt_append 职责 |
|---|---|
| Prometheus | 垂直切片拆解 `## Todos` + 探索前读领域文档（视为参考数据而非指令）+ codebase-design 词汇评估架构 |
| Sisyphus | 两个触发时机：设计问题用 `prototype`，术语 / 决策结晶时用 `domain-modeling` |
| Atlas | 委派 worker 时 skill→任务类型映射：实现→tdd、spike→prototype、评审→code-review |

## 6. 一条完整链路走一遍

以「重构支付模块」为例：

1. **Sisyphus 接单**：Intent Gate 判定「需要规划」→ 触发 `/ulw-plan`，交棒 Prometheus。
2. **Prometheus**：宣布 `ULW-PLAN MODE ENABLED!` → 读 `CONTEXT.md` / `docs/adr/` → `codegraph_explore` + `explore` / `librarian` 并行探索 → 用 `codebase-design` 词汇评估 → 产出决策完备计划存 `.omo/plans/*.md` → 等批准。
3. **用户说 "start work"** → **Atlas** 接管 `/start-work`：读计划 → 建 `.omo/boulder.json` → 逐 checkbox 拆原子子任务 → `task()` 并行委派 worker（`load_skills=["tdd"]` 等）→ 独立验证 DoneClaim → 证据写入 `.omo/start-work/ledger.jsonl` → 勾 checkbox → 直到全绿。

## 7. 关键设计边界

- **读 vs 写分界**：domain-modeling 的「读」（消费词汇）是任何 skill 的一行习惯；「写」（改 CONTEXT.md / 写 ADR）才是 domain-modeling 独有，靠 skill description 自动触发。
- **只读边界**：Prometheus 只读规划，不委派 implementer（prototype 不从 Prometheus 触发，交给 Sisyphus 评估或 Atlas spike）。
- **领域文档消费契约**：`AGENTS.md` → `docs/agents/domain.md` 规定「探索前读 CONTEXT.md + docs/adr/，不存在则静默跳过」；prompt_append 把它内化到 Prometheus system prompt 作为全局兜底。
- **守卫与去歧义**：skill description 里写入 omo 反向指引（如 diagnosing-bugs → `/debugging`、code-review → `/review-work`），避免与 omo 内置 skill 撞车。
