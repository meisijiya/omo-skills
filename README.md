# omo-skills

Matt Pocock [`mattpocock/skills`](https://github.com/mattpocock/skills) 的 **omo 适配仓库**。

本仓库专为 [OhMyOpenCode](https://github.com/code-yeongyu/oh-my-opencode)（omo）服务，吸收其 skill 工具栈约定，让上游 Matt Pocock 的工程 skill 在 omo 下稳定触发。其它 Agent（pi / senpi / Xiaomi mimocode 等）不在本仓库服务边界内。

本仓库对 12 个采纳 skill 做了挑选与微调（含去歧义描述、user-invoked 守卫、路径约定），让它们在 omo 风格下稳定触发并被 Agent 正确路由。

## 仓库布局

```
omo-skills/
├── README.md                 ← 本文件（人读概览）
├── INSTALL.md                ← 安装 / 部署指南（专门面向 omo）
├── MAINTENANCE.md            ← 长期维护手册（新增 skill / 退役 / 路径分类）
├── .gitignore                ← 排除 .omo/（Boulder 工作目录）
├── skills/                   ← 微调后的 12 个 skill（产物，INSTALL.md 安装源）
│   ├── engineering/          ← 10 个工程 skill
│   └── productivity/         ← 2 个产出/写作 skill
└── .omo/                     ← Boulder 计划状态、证据与 notepads（不入版本控制）
```

`skills/` 是唯一来源（已脱离上游 fork，不依赖任何本地 fork）。新 skill 在 `skills/` 下新建，详见 `MAINTENANCE.md §5 / §10`。

## 挑选清单

仓库自有 12 个 skill，按「保留 / 弃用」分类如下：

### ✅ 采纳（12 个）

| Skill | 类别 | 一句话用途 |
|---|---|---|
| `setup-meisijiya-skills` | engineering | 初始化领域文档布局（首次使用前跑一次） |
| `codebase-design` | engineering | 深模块设计词汇与原则（被 tdd / improve-codebase-architecture 引用为参考源） |
| `domain-modeling` | engineering | 用领域模型梳理业务实体与边界（更新 CONTEXT.md / 写 ADR） |
| `tdd` | engineering | 严格 TDD 节奏（红→绿→重构） |
| `improve-codebase-architecture` | engineering | 渐进式架构改良（user-invoked） |
| `prototype` | engineering | 快速原型与可行性验证 |
| `diagnosing-bugs` | engineering | 硬 bug / 性能回退的诊断循环（与 `/debugging` 互补，崩溃 / hang 走 omo `/debugging`） |
| `code-review` | engineering | 两轴差异评审（Standards vs Spec）/review-work 走 PR 交接 |
| `resolving-merge-conflicts` | engineering | 解决 in-progress merge / rebase 冲突（非常规 rebase 走 omo `git-master`） |
| `wizard` | engineering | 复杂流程的多步向导 |
| `grilling` | productivity | 严格交叉质询流程 |
| `writing-for-agents` | productivity | 写让 Agent 看得懂的文档（SKILL.md / AGENTS.md；opencode 配置走 `customize-opencode`） |

### ❌ 弃用（15 个，已从 `skills/` 删除）

| Skill | 类别 | 弃用原因 |
|---|---|---|
| `setup-matt-pocock-skills` | engineering | 重命名为 `setup-meisijiya-skills`（去掉上游词汇） |
| `ask-matt` | engineering | 路由型 skill，omo 无内置对应 |
| `grill-with-docs` | engineering | 与 `grilling` + `domain-modeling` 工作流重叠 |
| `implement` | engineering | 与 omo `task()` 多 Agent 委派机制重叠 |
| `research` | engineering | 范围过大，触发噪音明显；omo `/ulw-research` 已覆盖 |
| `to-spec` | engineering | 由 omo `/ulw-plan` 承接 |
| `to-tickets` | engineering | 由 omo `/ulw-plan` 承接 |
| `triage` | engineering | omo `issue-tracker` workflow 内置类似流程 |
| `wayfinder` | engineering | 仅大型 monorepo 需要，触发噪音明显 |
| `grill-me` | productivity | 由 `grilling` 合并 |
| `handoff` | productivity | 与 omo `task()` 多 Agent 委派机制重叠 |
| `teach` | productivity | omo 内置 `teach` skill |
| `to-questionnaire` | productivity | 与 `grilling` 工作流重叠 |
| `wait-what` | productivity | 由 `grilling` 承接 |
| `slice-work` | engineering | 与 omo `/ulw-plan` 触发面重叠、缺任务行语法约束；omo `prometheus.prompt_append`（见 INSTALL.md §5.1）已内化垂直切片纪律 |

## 微调策略

为了让 12 个采纳 skill 在 omo 风格下稳定触发，本仓库对 SKILL.md 的 frontmatter `description` 做了最小侵入优化（仅改 description 字段，不动正文逻辑）：

- **2 个 user-invoked 守卫**：`improve-codebase-architecture` 与 `setup-meisijiya-skills` 显式标注 `User-invoked only`，避免 Agent 在不合适时机自动调用。
- **5 个 omo 触发词 / 去歧义更新**：
  - `domain-modeling`：保留 setup 依赖句，补回 "writing or editing a CONTEXT.md, or recording or editing an ADR" 具体动作锚点
  - `resolving-merge-conflicts`：加 "NOT for routine rebase/squash/git-history investigation (that's omo's git-master)" 反向指引
  - `diagnosing-bugs`：加 "For crashes / hangs / attach-debugger / runtime inspection / sourcemap issues, use omo's built-in /debugging instead" 反向指引
  - `code-review`：加 "Use /review-work instead for pre-PR handoff full QA" 反向指引
  - `grilling`：保留 'grill' trigger phrase + plan/design challenged 措辞
- **1 个 stale 引用修正**：`code-review/SKILL.md` 第 13 行从 `setup-matt-pocock-skills` 改为 `setup-meisijiya-skills`；`writing-for-agents/SKILL.md` 第 3 行删 `CLAUDE.md`（omo 不使用），加 customize-opencode 去歧义

仓库已脱离上游 fork，`skills/` 是唯一来源——不再依赖任何 `mattpocock-skills/` 同步流程。

## 安装与升级

👉 看 [`INSTALL.md`](INSTALL.md)

它覆盖：

- 把采纳 skill 装入 omo 的步骤（专门服务 omo）
- `oh-my-openagent.jsonc` 中 `agents.prometheus.prompt_append` 的垂直切片内化配置
- 升级 skill（添加新 skill / 修改现有 skill）的方法
- 卸载 / 禁用方式
- 故障排查（触发不灵、与 omo 内置 skill 撞车等）

## 历史（已脱离上游）

仓库早期 fork 自 `mattpocock/mattpocock-skills`，但早已脱离上游同步（不再 fetch / rebase），fork 目录已删除。本仓库 `skills/` 是唯一来源。

新 skill 直接在 `skills/<bucket>/<name>/` 下新建，按 `MAINTENANCE.md §5` Step 0 讨论通过后纳入。

## 许可

本仓库 `omo-skills/` 下的微调（`skills/` + `INSTALL.md` / `README.md` / `MAINTENANCE.md`）以仓库作者偏好为准。

各 skill 本身的许可证见 `skills/<bucket>/<name>/` 内对应目录（上游为 MIT，源自 `mattpocock/skills`）。

## 长期维护

如果你将来要添加新 skill、退役 skill、或排查触发问题，看 [`MAINTENANCE.md`](MAINTENANCE.md)。

它覆盖：

- 仓库拓扑与边界（`skills/` 唯一来源）
- 监控信号（什么时候该维护）
- §3 已废止（上游同步 playbook）
- 变更后必跑的 3 个断言
- **§5 Skill 引入规则（讨论流程）**：先讨论再决定，不靠自动化
- **§9 文档落地路径分类**：提交类（`docs/adr/` `CONTEXT.md` `CONTEXT-MAP.md` `docs/agents/`）vs 临时态（`.scratch/` `.out-of-scope/`）的判定标准（讨论参考，非自动化）
- **§10 skill 新建流程**（已脱离上游，按 §5 Step 0 讨论后再决定是否纳入）
- 退役 skill 的流程
- 故障排查速查表