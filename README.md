# omo-skills

Matt Pocock 的 [`mattpocock/skills`](https://github.com/mattpocock/skills) 在 [OhMyOpenCode](https://github.com/code-yeongyu/oh-my-opencode) (omo) 环境下的精选适配与分发仓库。

omo 内置 skill 体系与 Matt 上游 skill 在描述惯例、触发词、引用路径上不完全一致 —— 本仓库对 25 个上游 skill 做了挑选与微调，让它们能在 omo 风格下稳定触发并被 Agent 正确路由。

## 仓库布局

```
omo-skills/
├── README.md                 ← 本文件（人读概览）
├── INSTALL.md                ← 安装 / 部署指南（面向 Agent 与人）
├── MAINTENANCE.md            ← 长期维护手册（rebase / 新 skill / 新 Agent / 故障排查）
├── .gitignore                ← 排除 mattpocock-skills/ 与 .omo/
├── mattpocock-skills/        ← 完整 clone（独立子仓库，独立管理）
│   └── skills/
│       ├── engineering/      ← 18 个工程 skill
│       └── productivity/     ← 7 个产出/写作 skill
└── .omo/                     ← Boulder 计划状态、证据与 notepads（不入版本控制）
```

`mattpocock-skills/` 是一个独立 Git 仓库（拥有自己的 `.git/`），与外层 `omo-skills` 仓库解耦。它的升级方式见 [`INSTALL.md`](INSTALL.md)。

## 挑选清单

上游共 25 个 skill，按本计划「omo 默认安装 / 适配后是否纳入」分类如下：

### ✅ 默认采纳（20 个）

| Skill | 类别 | 一句话用途 |
|---|---|---|
| `grill-with-docs` | engineering | 让 Agent 在编造事实前用文档质询自身 |
| `domain-modeling` | engineering | 用领域模型梳理业务实体与边界 |
| `codebase-design` | engineering | 从代码库现状反推其设计意图 |
| `tdd` | engineering | 严格 TDD 节奏（红→绿→重构） |
| `improve-codebase-architecture` | engineering | 渐进式架构改良 |
| `to-spec` | engineering | 把模糊想法转为结构化规格 |
| `to-tickets` | engineering | 把规格拆成可执行工单 |
| `triage` | engineering | 给工单/Issue 排优先级 |
| `wayfinder` | engineering | 在大型代码库中找路 |
| `implement` | engineering | 按工单实现具体改动 |
| `resolving-merge-conflicts` | engineering | 解决 merge 冲突（含 rebase） |
| `wizard` | engineering | 复杂流程的多步向导 |
| `prototype` | engineering | 快速原型与可行性验证 |
| `teach` | productivity | 把领域知识讲清楚 |
| `to-questionnaire` | productivity | 构造问卷收集需求 |
| `setup-matt-pocock-skills` | productivity | 初始化本套 skill（自举） |
| `grill-me` | productivity | 让 Agent 反向质询用户 |
| `grilling` | productivity | 严格交叉质询流程 |
| `wait-what` | productivity | 在偏离主题时强制暂停重述 |
| `writing-for-agents` | productivity | 写让 Agent 看得懂的文档 |

### 🟡 备用（5 个，按需安装）

| Skill | 类别 | 不默认纳入的原因 |
|---|---|---|
| `ask-matt` | engineering | 路由型 skill，omo 无内置对应；仅供其他 Agent 直接下载 |
| `diagnosing-bugs` | engineering | 与 omo 自带 debug 工作流重叠度高 |
| `code-review` | engineering | 与 omo 内置 review 流程重叠 |
| `research` | engineering | 范围过大，触发噪音明显 |
| `handoff` | productivity | 与 omo `task()` 多 Agent 委派机制重叠 |

> 备用项的安装方式、是否启用、何时启用，见 [`INSTALL.md`](INSTALL.md)。

## 微调策略

为了让 20 个采纳 skill 在 omo 风格下稳定触发，本仓库对上游 SKILL.md 做了两类微调（最小侵入、保持上游原意）：

- **14 个 description 守卫**：在 frontmatter `description` 中加入 omo 风格触发词与去歧义短语，避免与 omo 内置 skill 撞车，同时让 Agent 知道何时**不应**调用本 skill。
- **8 个路径统一**：把 SKILL.md 正文里对兄弟 skill、相对路径、仓库根的硬编码引用统一为「通过 omo 解析的相对路径」或「安装后实际路径」，不再依赖具体 clone 位置。

完整 diff 与逐 skill 调整记录见 Wave 2 Todo 2 / Todo 3 的产出物。

## 安装与升级

👉 看 [`INSTALL.md`](INSTALL.md)

它覆盖：
- 把采纳 skill 装入 omo 的步骤
- 把采纳 + 备用 skill 装入 pi / senpi / mcode / mimocode 的步骤
- 升级 `mattpocock-skills/` 子仓库的方法
- 卸载 / 禁用方式
- 故障排查（触发不灵、与 omo 内置 skill 撞车等）

## 上游同步

`mattpocock-skills/` 保留完整 Git 历史，可在本地用其内置的 `git` 工作流升级：

```bash
cd mattpocock-skills
git fetch origin
git rebase origin/main      # 在 omo 分支上 rebase 上游 main
```

rebase 后如有冲突，回到外层仓库重新跑 Wave 2 微调脚本。

## 许可

本仓库（`omo-skills/`，不含 `mattpocock-skills/` 子目录）下的微调与文档以仓库作者偏好为准。
各 skill 本身的许可证见 `mattpocock-skills/` 内对应目录 —— 上游为 MIT。

## 长期维护

如果你将来要同步上游 Matt 的新提交、添加新 skill、新 Agent、或排查触发问题，看 [`MAINTENANCE.md`](MAINTENANCE.md)。

它覆盖：
- 仓库拓扑与边界（mattpocock-skills/ 是独立子仓库）
- 监控信号（什么时候该维护）
- 上游同步 `git rebase` 工作流（含冲突处理 playbook）
- rebase 后必跑的 4 个断言
- 添加新 skill / 新 Agent / 退役 skill 的流程
- 故障排查速查表