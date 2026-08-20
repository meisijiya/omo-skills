# omo-skills

Matt Pocock 的 [`mattpocock/skills`](https://github.com/mattpocock/skills) 的 **omo 适配仓库**。

本仓库专为 [OhMyOpenCode](https://github.com/code-yeongyu/oh-my-opencode)（omo）服务，吸收其 skill 工具栈约定，让上游 Matt Pocock 的工程 skill 在 omo 下稳定触发。其它 Agent（pi / senpi / Xiaomi mimocode）属历史参考，不在本仓库服务边界内。

本仓库对 13 个采纳 skill 做了挑选与微调，让它们在 omo 风格下稳定触发并被 Agent 正确路由。

## 仓库布局

```
omo-skills/
├── README.md                 ← 本文件（人读概览）
├── INSTALL.md                ← 安装 / 部署指南（面向 Agent 与人）
├── MAINTENANCE.md            ← 长期维护手册（rebase / 同步 / 新 skill / 新 Agent / 路径分类）
├── .gitignore                ← 排除 mattpocock-skills/（本地开发源）与 .omo/
├── skills/                   ← 微调后的 13 个 skill（产物，INSTALL.md 安装源）
│   ├── engineering/          ← 11 个工程 skill
│   └── productivity/         ← 2 个产出/写作 skill
├── mattpocock-skills/        ← 本地 fork（开发源，不入远端；rebase + 微调都在这里做）
│   └── skills/
│       ├── engineering/
│       └── productivity/
└── .omo/                     ← Boulder 计划状态、证据与 notepads（不入版本控制）
```

`skills/` 是产物（13 个采纳 skill，已脱离上游 fork，是唯一来源）。`mattpocock-skills/` 是历史 fork（`.gitignore` 已排除，不参与同步）。新 skill 在 `skills/` 下新建，详见 `MAINTENANCE.md §10`。

## 挑选清单

仓库自有 13 个 skill，按「保留 / 弃用」分类如下：

### ✅ 采纳（13 个）

| Skill | 类别 | 一句话用途 |
|---|---|---|
| `setup-meisijiya-skills` | engineering | 初始化领域文档布局（首次使用前跑一次） |
| `slice-work` | engineering | 把规格拆成可独立交付的垂直切片 |
| `codebase-design` | engineering | 从代码库现状反推其设计意图 |
| `domain-modeling` | engineering | 用领域模型梳理业务实体与边界 |
| `tdd` | engineering | 严格 TDD 节奏（红→绿→重构） |
| `improve-codebase-architecture` | engineering | 渐进式架构改良（user-invoked） |
| `prototype` | engineering | 快速原型与可行性验证 |
| `diagnosing-bugs` | engineering | 硬 bug / 性能回退的诊断循环（与 /debugging 互补） |
| `code-review` | engineering | 两轴差异评审（Standards vs Spec）/review-work 走 PR 交接 |
| `resolving-merge-conflicts` | engineering | 解决 merge / rebase 冲突 |
| `wizard` | engineering | 复杂流程的多步向导 |
| `grilling` | productivity | 严格交叉质询流程 |
| `writing-for-agents` | productivity | 写让 Agent 看得懂的文档 |

### ❌ 弃用（14 个，已从 `skills/` 删除）

| Skill | 类别 | 弃用原因 |
|---|---|---|
| `setup-matt-pocock-skills` | engineering | 重命名为 `setup-meisijiya-skills`（去掉上游词汇） |
| `ask-matt` | engineering | 路由型 skill，omo 无内置对应 |
| `grill-with-docs` | engineering | 与 `grilling` + `domain-modeling` 工作流重叠 |
| `implement` | engineering | 与 omo `task()` 多 Agent 委派机制重叠 |
| `research` | engineering | 范围过大，触发噪音明显 |
| `to-spec` | engineering | 由 `slice-work` 承接 |
| `to-tickets` | engineering | 由 `slice-work` 承接 |
| `triage` | engineering | omo `issue-tracker` workflow 内置类似流程 |
| `wayfinder` | engineering | 仅大型 monorepo 需要，触发噪音明显 |
| `grill-me` | productivity | 由 `grilling` 合并 |
| `handoff` | productivity | 与 omo `task()` 多 Agent 委派机制重叠 |
| `teach` | productivity | omo 内置 `teach` skill |
| `to-questionnaire` | productivity | 与 `grilling` 工作流重叠 |
| `wait-what` | productivity | 由 `grilling` 承接 |

## 微调策略

为了让 13 个采纳 skill 在 omo 风格下稳定触发，本仓库对 SKILL.md 的 frontmatter `description` 做了最小侵入优化（仅改 description 字段，不动正文逻辑）：

- **2 个 user-invoked 守卫**：`improve-codebase-architecture` 与 `setup-meisijiya-skills` 显式标注 `User-invoked only`，避免 Agent 在不合适时机自动调用。
- **5 个 omo 触发词 / 去歧义更新**：`domain-modeling`、`resolving-merge-conflicts`、`diagnosing-bugs`、`code-review`、`grilling` 在 description 中加入 omo 风格触发词与去歧义短语。
- **1 个 stale 引用修正**：`code-review/SKILL.md` 第 13 行从 `setup-matt-pocock-skills` 改为 `setup-meisijiya-skills`，避免旧 skill 已删后引用悬空。

仓库已脱离上游 fork，`skills/` 是唯一来源——不再依赖 `mattpocock-skills/` 同步流程（保留作历史参考，`.gitignore` 已排除）。

## 安装与升级

👉 看 [`INSTALL.md`](INSTALL.md)

它覆盖：
- 把采纳 skill 装入 omo 的步骤
- 把 13 个采纳 skill 装入 pi / senpi / Xiaomi mimocode 的步骤（历史参考）
- 升级 skill（添加新 skill / 修改现有 skill）的方法
- 卸载 / 禁用方式
- 故障排查（触发不灵、与目标 Agent 内置 skill 撞车等）

## 历史（已脱离上游）

仓库原 fork 自 `mattpocock/mattpocock-skills`，本地 fork 在 `mattpocock-skills/`（保留完整 Git 历史，已 `.gitignore`）。本仓库 `skills/` 是产物（已脱离上游 fork，是唯一来源）。

新 skill 直接在 `skills/<bucket>/<name>/` 下新建，按 `MAINTENANCE.md §5` Step 0 讨论通过后纳入。不再有 `mattpocock-skills/` rebase + 同步流程；该目录仅作历史参考。

## 许可

本仓库 `omo-skills/` 下的微调（`skills/` + `INSTALL.md` / `README.md` / `MAINTENANCE.md`）以仓库作者偏好为准。
各 skill 本身的许可证见 `skills/<bucket>/<name>/` 内对应目录（同步自 mattpocock/skills） —— 上游为 MIT。
`mattpocock-skills/` 子目录为开发源，不入远端，遵循上游许可证。

## 长期维护

如果你将来要同步上游 Matt 的新提交、添加新 skill、新 Agent、或排查触发问题，看 [`MAINTENANCE.md`](MAINTENANCE.md)。

它覆盖：
- 仓库拓扑与边界（`skills/` 产物 vs `mattpocock-skills/` 开发源）
- 监控信号（什么时候该维护）
- 上游同步历史 playbook（§3，已脱离上游，仅参考）
- 变更后必跑的 3 个断言（断言 4 路径断言已删）
- **§5 Skill 引入规则（讨论流程）**：先讨论再决定，不靠自动化
- **§9 文档落地路径分类**：提交类（`docs/adr/` `CONTEXT.md` `CONTEXT-MAP.md` `docs/agents/`）vs 临时态（`.omo/scratch/` `.omo/out-of-scope/`）的判定标准（讨论参考，非自动化）
- **§10 skill 同步与新建流程（已脱离上游）**：按 §5 Step 0 讨论后再决定是否纳入，详见 §10
- 添加新 Agent / 退役 skill 的流程
- 故障排查速查表