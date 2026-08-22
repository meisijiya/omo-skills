# omo-skills

> 📖 在线指南：[meisijiya.github.io/omo-skills/](https://meisijiya.github.io/omo-skills/)

Matt Pocock [`mattpocock/skills`](https://github.com/mattpocock/skills) 的 **omo 适配仓库**。

本仓库专为 [OhMyOpenCode](https://github.com/code-yeongyu/oh-my-opencode)（omo）服务，吸收其 skill 工具栈约定，让上游 Matt Pocock 的工程 skill 在 omo 下稳定触发。其它 Agent（pi / senpi / Xiaomi mimocode 等）不在本仓库服务边界内。

本仓库对 16 个采纳 skill 做了挑选与微调（含去歧义描述、user-invoked 守卫、路径约定），让它们在 omo 风格下稳定触发并被 Agent 正确路由。

## 仓库布局

```
omo-skills/
├── README.md                 ← 本文件（人读概览）
├── INSTALL.md                ← 安装 / 部署指南（专门面向 omo）
├── MAINTENANCE.md            ← 长期维护手册（新增 skill / 退役 / 路径分类）
├── .gitignore                ← 排除 .omo/（Boulder 工作目录）
├── config/                   ← omo system prompt 配置（prompt_append 唯一事实来源）
│   └── oh-my-openagent.prompt-append.jsonc
├── scripts/                  ← 安装脚本
│   └── install-prompt-append.mjs
├── docs/                     ← 工作流文档与 Agent 约定
│   ├── workflow.md           ← 三个 Agent + skill 使用场景工作流
│   └── agents/domain.md      ← 领域文档消费契约
├── skills/                   ← 微调后的 16 个 skill（产物，INSTALL.md 安装源）
│   ├── engineering/          ← 12 个工程 skill
│   └── productivity/         ← 4 个产出/写作 skill
└── .omo/                     ← Boulder 计划状态、证据与 notepads（不入版本控制）
```

`skills/` 是唯一来源（已脱离上游 fork，不依赖任何本地 fork）。新 skill 在 `skills/` 下新建，详见 `MAINTENANCE.md §5 / §10`。

三个 Agent（Sisyphus / Prometheus / Atlas）+ skill 使用场景的完整工作流见 [`docs/workflow.md`](docs/workflow.md)。

## 挑选清单

仓库自有 16 个 skill，按「保留 / 弃用」分类如下：

### ✅ 采纳（16 个）

| Skill | 类别 | 一句话用途 |
|---|---|---|
| `setup-meisijiya-skills` | engineering | 初始化领域文档布局（首次使用前跑一次） |
| `codebase-design` | engineering | 深模块设计词汇与原则（被 tdd / improve-codebase-architecture 引用为参考源） |
| `domain-modeling` | engineering | 用领域模型梳理业务实体与边界（更新 CONTEXT.md；架构决策路由到 architecture-decision-records） |
| `architecture-decision-records` | engineering | ADR 编写与维护（产物落 `docs/adr/`；唯一拥有 ADR 文件的 skill） |
| `api-and-interface-design` | engineering | API / 模块接口契约设计（Hyrum's Law + contract-first，重大契约写 ADR） |
| `tdd` | engineering | 严格 TDD 节奏（红→绿→重构） |
| `improve-codebase-architecture` | engineering | 渐进式架构改良（user-invoked） |
| `prototype` | engineering | 快速原型与可行性验证 |
| `diagnosing-bugs` | engineering | 硬 bug / 性能回退的诊断循环（与 `/debugging` 互补，崩溃 / hang 走 omo `/debugging`） |
| `code-review` | engineering | 两轴差异评审（Standards vs Spec）/review-work 走 PR 交接 |
| `resolving-merge-conflicts` | engineering | 解决 in-progress merge / rebase 冲突（非常规 rebase 走 omo `git-master`） |
| `wizard` | engineering | 复杂流程的多步向导 |
| `teach` | productivity | 学习概念或 OSS 仓库（生成交互式课程 + 测验，写入 `docs/teach/{concept,repo}/`） |
| `to-questionnaire` | productivity | 把不能完全回答的决定转成问卷（异步需求收集，输出到 cwd） |
| `grilling` | productivity | 严格交叉质询流程 |
| `writing-for-agents` | productivity | 写让 Agent 看得懂的文档（SKILL.md / AGENTS.md；opencode 配置走 `customize-opencode`） |


### ❌ 弃用（14 个，已从 `skills/` 删除）

| Skill | 类别 | 弃用原因 |
|---|---|---|
| `setup-matt-pocock-skills` | engineering | 重命名为 `setup-meisijiya-skills`（去掉上游词汇） |
| `ask-matt` | engineering | 路由型 skill，omo 无内置对应 |
| `grill-with-docs` | engineering | 与 `grilling` + `domain-modeling` 工作流重叠 |
| `implement` | engineering | 与 omo `task()` 多 Agent 委派机制重叠 |
| `research` | engineering | 范围过大，触发噪音明显；omo `/ulw-research` 已覆盖 |
| `to-spec` | engineering | 由 omo `/ulw-plan` 承接 |
| `to-tickets` | engineering | 由 omo `/ulw-plan` 承接 |
| `triage` | engineering | omo 内置 issue-tracker workflow 部分覆盖（github-triage subface），全 triage 工作流需自行补全 |
| `wayfinder` | engineering | 仅大型 monorepo 需要，触发噪音明显 |
| `grill-me` | productivity | 由 `grilling` 合并 |
| `handoff` | productivity | 与 omo `task()` 多 Agent 委派机制重叠 |
| `wait-what` | productivity | 由 `grilling` 承接 |
| `slice-work` | engineering | 与 omo `/ulw-plan` 触发面重叠、缺任务行语法约束；omo `prometheus.prompt_append`（见 INSTALL.md §5.1）已内化垂直切片纪律 |
| `create-design-md` | productivity | omo 内置 `/frontend` 自带 DESIGN.md 8-section schema（`design-system-architecture.md`），与本 skill 的 `@google/design.md` schema 互不兼容；user-invoked + `disable-model-invocation` 守卫不足以解决 schema 冲突，统一走 `/frontend` |

## 微调策略

为了让 16 个采纳 skill 在 omo 风格下稳定触发，本仓库对 SKILL.md 的 frontmatter `description` 做了最小侵入优化（仅改 description 字段，不动正文逻辑）：

- **2 个 user-invoked 守卫**：`improve-codebase-architecture` / `setup-meisijiya-skills` 显式标注 `User-invoked only`，避免 Agent 在不合适时机自动调用。
- **5 个 omo 触发词 / 去歧义更新**：
  - `domain-modeling`：保留 setup 依赖句；description 缩窄到 "writing or editing a CONTEXT.md"，架构决策明确路由到 `architecture-decision-records`（前者不再写 ADR）
  - `resolving-merge-conflicts`：加 "NOT for routine rebase/squash/git-history investigation (that's omo's git-master)" 反向指引
  - `diagnosing-bugs`：加 "For crashes / hangs / attach-debugger / runtime inspection / sourcemap issues, use omo's built-in /debugging instead" 反向指引
  - `code-review`：加 "Use /review-work instead for pre-PR handoff full QA" 反向指引
  - `grilling`：保留 'grill' trigger phrase + plan/design challenged 措辞
- **2 个新引入 skill 的去歧义**：
  - `architecture-decision-records`：锚定到 `docs/adr/` + `NNNN-kebab-title.md` 编号 + `Proposed → Accepted → Deprecated → Superseded` lifecycle（与 `domain-modeling` 路径约定一致）
  - `api-and-interface-design`：区分重大契约（写 ADR）vs 模块内部契约（落 `docs/agents/<module>.md`），反向指引 `codebase-design` / `architecture-decision-records`
- **1 个 stale 引用修正**：`code-review/SKILL.md` 第 13 行从 `setup-matt-pocock-skills` 改为 `setup-meisijiya-skills`；`writing-for-agents/SKILL.md` 第 3 行删 `CLAUDE.md`（omo 不使用），加 customize-opencode 去歧义
- **2 个新引入 skill 全部加 NOT-for 反向指引**：`architecture-decision-records` / `api-and-interface-design` 加 NOT-for 反向指引避免撞 `codebase-design` / `domain-modeling` 触发面

仓库已脱离上游 fork，`skills/` 是唯一来源——不再依赖任何 `mattpocock-skills/` 同步流程。

## 安装与升级

👉 看 [`INSTALL.md`](INSTALL.md)

它覆盖：

- 把采纳 skill 装入 omo 的步骤（专门服务 omo）
- `oh-my-openagent.jsonc` 中 agent overrides 的 skill 融合内化配置：
  - 三个主 Agent（`sisyphus` / `prometheus` / `atlas`）的 `prompt_append`
  - 三个子 Agent（`oracle` / `metis` / `momus`）的 `skills: []`
- 升级 skill（添加新 skill / 修改现有 skill）的方法 —— 详见 `MAINTENANCE.md §11` 双轨维护
- 卸载 / 禁用方式
- 故障排查（触发不灵、与 omo 内置 skill 撞车等）

## 历史（已脱离上游）

仓库早期 fork 自 `mattpocock/skills`，但早已脱离上游同步（不再 fetch / rebase），fork 目录已删除。本仓库 `skills/` 是唯一来源。

新 skill 直接在 `skills/<bucket>/<name>/` 下新建，按 `MAINTENANCE.md §5` Step 0 讨论通过后纳入；纳入后必须按 `MAINTENANCE.md §11` 双轨维护 prompt_append + 子代理 skills[]。

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
- **§11 agent overrides 双轨维护**（新增 / 废弃 skill 时强制：主代理 prompt_append + 子代理 skills[] 双轨更新）
- 退役 skill 的流程
- 故障排查速查表