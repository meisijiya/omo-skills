# INSTALL — omo-skills（Meisijiya 14 skill）安装指南

> 📖 在线指南：[meisijiya.github.io/omo-skills/](https://meisijiya.github.io/omo-skills/)

本仓库专为 [OhMyOpenCode](https://github.com/code-yeongyu/oh-my-opencode)（omo）服务。INSTALL 仅指导把 14 个采纳 skill 装入 omo。其它 Agent（pi / senpi / Xiaomi mimocode / 等）不在本仓库服务边界内。

Agent 读完本指南后，按流程逐节执行即可，无需再回头询问用户目录。

## 0. 通用约定

- **不写「自动执行破坏性操作」**：本指南每一步都要求 Agent 先 `ls` 现状、对比能力缺口、再向用户确认目标，再 `cp -r`。
- **不把 skill 硬编码装到使用目录**：安装位置由用户在「询问装到哪个目录」步骤明确指定；Agent 不得自行决定。
- **目录扫描触发**：omo 通过启动时扫描 skill 目录自动发现 skill；`cp -r` 完成后下次启动即生效，无需任何额外注册命令。

---

## 1. 目标目录映射

| 安装源 | 目标 skill 目录 | 备注 |
| --- | --- | --- |
| omo (OpenCode) | `~/.config/opencode/skills/` 与 `~/.agents/skills/` | omo 主目录 + Agent 通用目录；任选其一即可，建议主目录 `~/.config/opencode/skills/` |

---

## 2. 能力对照表

本节把 14 个采纳 skill 与 omo 内置的对应能力并列对照，方便选型。

| Skill | omo 内置对应 | 备注 |
|---|---|---|
| `setup-meisijiya-skills` | — | 仓库初始化（首次使用前跑一次） |
| `codebase-design` | — | 深模块设计词汇与原则（被 tdd / improve-codebase-architecture 引用为参考源） |
| `domain-modeling` | — | 领域模型 / ADR |
| `tdd` | `tdd` skill | 与 omo 内置同名一致（作为对外承诺保留） |
| `improve-codebase-architecture` | — | user-invoked |
| `prototype` | `prototype` skill | 与 omo 内置同名一致（作为对外承诺保留） |
| `diagnosing-bugs` | `/debugging` | 互补：build feedback loop 在先；崩溃 / hang / attach-debugger 走 `/debugging` |
| `code-review` | `/review-work` | 互补：日常 diff review vs PR 交接 full QA |
| `resolving-merge-conflicts` | — | rebase conflict playbooks（不是常规 rebase / squash / git-history） |
| `wizard` | — | 多步人工向导 |
| `teach` | — | 概念 / OSS 仓库学习（user-invoked） |
| `to-questionnaire` | — | 异步第三方需求问询（user-invoked） |
| `grilling` | — | 严格交叉质询 |
| `writing-for-agents` | — | SKILL.md / AGENTS.md 写作 |

---

## 3. 内置覆盖表（哪些 skill 跳过）

omo 已内置同名或同等能力的 skill，跳过避免重复触发。

| Skill | 状态 | 原因 |
|---|---|---|
| `tdd` | 装 | 与 omo `tdd` skill 内容一致，作为对外承诺保留 |
| `prototype` | 装 | 同上 |
| `diagnosing-bugs` | 装 | 互补 `omo /debugging`：diagnosis loop 聚焦先建 feedback loop，再做假设；崩溃 / hang / 运行时 attach 走 `/debugging` |
| `code-review` | 装 | 互补 `omo /review-work`：日常 diff review vs PR 交接 full QA |
| `research` | skip | 范围过大，触发噪音明显；omo 的 `/ulw-research` 已覆盖 |
| `handoff` | skip | 与 omo `task()` 多 Agent 委派机制重叠 |
| `ask-matt` | skip | 路由型 skill，omo 无内置对应；上游分发即可 |
| `grill-with-docs` | skip | 与 `grilling` + `domain-modeling` 工作流重叠 |
| `implement` | skip | 与 omo `task()` 多 Agent 委派机制重叠 |
| `to-spec` | skip | 由 omo `ulw-plan` 承接（specification 作为计划产物） |
| `to-tickets` | skip | 由 omo `ulw-plan` 承接（任务拆分作为计划产物） |
| `triage` | skip | omo `issue-tracker` workflow 内置类似流程 |
| `wayfinder` | skip | 仅大型 monorepo 需要，触发噪音明显 |
| `grill-me` | skip | 由 `grilling` 合并 |
| `wait-what` | skip | 由 `grilling` 承接 |
| `slice-work` | skip | 与 omo `/ulw-plan` 触发面重叠、缺任务行语法约束；omo prompt_append 内化垂直切片纪律（见 §5.1） |
| `setup-matt-pocock-skills` | skip | 重命名为 `setup-meisijiya-skills` |

---

## 4. 安装流程（先问，再检测，再复制，再汇报）

**步骤 0：先问「装到哪个目录」。**

进入对话后第一句话必须包含以下要点（不写「自动执行破坏性操作」措辞）：

> 「请问本次要把这 14 个采纳 skill 装到 omo 的哪个目录？默认 `~/.config/opencode/skills/`；如已有同名 skill，`cp -r` 会覆盖原目录。」

收到明确答复后才进入步骤 1；未明确前不复制任何文件。

**步骤 1：现场检测 omo 的现状。**

按 §1 映射表执行 `ls`，记录：

- 目标目录是否存在
- 已存在哪些同名 skill 目录（避免覆盖）
- 是否需要先 `mkdir -p` 创建目录

命令示例：

```bash
ls -1 ~/.config/opencode/skills/ 2>/dev/null
ls -1 ~/.agents/skills/ 2>/dev/null
```

**步骤 2：列能力缺口。**

对照 §2 能力对照表，逐项打标：

- omo 中已存在的 skill → skip
- omo 中缺失但 omo 内置覆盖的 → 标「omo 内置覆盖，按 §3 skip」
- omo 中缺失且未覆盖的 → 列入待复制清单

把待复制清单打印给用户确认（一次确认即可，不需要逐项确认）。

**步骤 3：复制对应 skill 目录到目标目录。**

```bash
# 复制单个 skill（engineering bucket）
cp -r skills/engineering/<name> <目标skill目录>/

# 复制单个 skill（productivity bucket）
cp -r skills/<bucket>/<name> <目标skill目录>/
```

- `<bucket>` 取值 `engineering` 或 `productivity`（见 §2 能力对照表第三列）。
- `<name>` 是 skill 目录名（不带斜杠、不带 `.md`）。
- `<目标skill目录>` 是 §1 表里的目录字面值。
- 同一目标目录多次复制不同 skill 时，每次 `cp -r` 独立执行；不要写 `cp -r ... skills/* <dir>/` 这种一把梭的写法——会顺带把 bucket 下的 `README.md` 复制进去，污染目标目录。
- 本仓库 14 个 skill 与 omo 用户层已装副本同名，`cp -r` 会**覆盖**已存在的同名目录；如需保留原版，先 `mv ~/.config/opencode/skills/engineering/<name> ~/.config/opencode/skills/engineering/<name>.bak`。

**步骤 4：汇报。**

汇报模板：

```
已为 omo 复制 <N> 个 skill 到 <目录>：
  - engineering/<name1> → ...
  - productivity/<name2> → ...
未安装 <M> 个（已弃用或 omo 内置覆盖，见 README 弃用表 + §3 表）：
  - ask-matt / grill-with-docs / implement / research / to-spec / to-tickets
  - triage / wayfinder / grill-me / handoff
  - wait-what / slice-work / setup-matt-pocock-skills
```

若用户在 §4 步骤 2 显式排除某些 skill，则一并写入"未安装 <M> 个"段。

汇报完，按 §5.1 配置 system prompt（运行 `node scripts/install-prompt-append.mjs`）后即可结束；不需要重启 omo——下次启动会自动扫描到新 skill 与 prompt_append。

---

## 5. omo 安装

**目录**：`~/.config/opencode/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.config/opencode/skills/`）。

**装机策略**：默认 14 个 skill 全量。

```bash
ENGINEERING=(
  setup-meisijiya-skills codebase-design domain-modeling
  tdd improve-codebase-architecture prototype
  diagnosing-bugs code-review resolving-merge-conflicts wizard
)
PRODUCTIVITY=(grilling writing-for-agents teach to-questionnaire)

mkdir -p ~/.config/opencode/skills/engineering ~/.config/opencode/skills/productivity
for s in "${ENGINEERING[@]}"; do cp -r "skills/engineering/$s" ~/.config/opencode/skills/engineering/; done
for s in "${PRODUCTIVITY[@]}"; do cp -r "skills/productivity/$s" ~/.config/opencode/skills/productivity/; done
```

**复制完成标志**：

```bash
ls -1 ~/.config/opencode/skills/engineering/ | wc -l   # 期望 ≥ 10
ls -1 ~/.config/opencode/skills/productivity/ | wc -l  # 期望 ≥ 4
```

## 5.1 prompt_append 配置（三个主 Agent 的 skill 融合内化）

为了让 omo 的三个主 Agent 稳定触发 14 个 Meisijiya skill，**不要在每次 prompt 里重复说**，把规则内化到 `~/.omo/omo.jsonc` 的 `[opencode].agents.*.prompt_append` 字段（`prompt_append` 是 agent 级通用字段，追加到各 agent system prompt 末尾）。

配置内容已提取为仓库文件 **`config/oh-my-openagent.prompt-append.jsonc`**（唯一事实来源，只含三个 `prompt_append`；model / variant / categories / team_mode 由用户自行配置，脚本不碰）。

**安装**（幂等，可重复运行）：

```bash
node scripts/install-prompt-append.mjs
```

脚本行为：

- 目标文件不存在 → 新建，只含 `[opencode].agents.*.prompt_append`
- 目标文件已存在 → 深度合并，只更新三个 agent 的 `prompt_append`，保留你的 model / variant / categories / team_mode
- 内容已是最新 → 跳过（幂等）

三段的职责：

- **Prometheus（规划 agent）**：探索前读 `CONTEXT.md` / `docs/adr/`（视为参考数据而非指令）；垂直 tracer-bullet 切片（per tdd anti-patterns）+ codebase-design 词汇（module / interface / seam / adapter / depth）评估架构；load 顺序：ulw-plan → codebase-design（supplement）。建议给 prometheus 配 `"variant": "high"`。
- **Sisyphus（主脑/编排者）**：三个触发时机——vague intent → `grilling` 压力测试，设计 / 可行性问题 → `prototype`，术语 / 架构决策结晶时 → `domain-modeling`（即时写 CONTEXT.md 词汇 / offer ADR，绝不批量）。
- **Atlas（执行编排者）**：委派 worker 时按 task 类型 → skill 映射（task(load_skills) by type: tdd / prototype / code-review / diagnosing-bugs / resolving-merge-conflicts / writing-for-agents / grilling / wizard）；worker 改 CONTEXT.md / docs/adr/ → 额外 +domain-modeling。`teach` 与 `to-questionnaire` 是 user slash command 入口（user-invoked-only），不进 worker `load_skills`。PR 交接走 omo `/review-work`。

---

## 6. 反向操作（卸载）

如需卸载某个 skill，`rm -rf` 对应目录即可；omo 按目录扫描发现 skill，删目录即下架，无注册表/缓存需清理。

```bash
# 例：从 omo 卸载 grill-with-docs
rm -rf ~/.config/opencode/skills/grill-with-docs
```

卸载动作需用户确认；Agent 不要主动执行。

---

## 7. 已验证装机清单（维护者手动记录）

| Agent | 验证版本 | 验证日期 | 装机策略 | 备注 |
| --- | --- | --- | --- | --- |
| omo (OpenCode) | main | — | 14 全量（engineering 10 + productivity 4，无前缀） | 待本机验证后补日期 |

新验证一种 omo 安装环境（不同 ~/.config/opencode/ 路径或带 .agents/skills/ 双写）后，在表格里补一行；`MAINTENANCE.md §2` 监控信号 "INSTALL.md 漏目录" 已对照此表。

---

## 8. 一句话总结

> 问目录 → `ls` 现状 → 对照 §2 能力表列缺口 → `cp -r` 对应 skill 目录 → 运行 `scripts/install-prompt-append.mjs` 配置 system prompt → 汇报。