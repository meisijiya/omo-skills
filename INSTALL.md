# INSTALL — mattpocock-skills 多 Agent 安装指南

本指南面向能执行 shell 的 Agent（omo / pi / senpi / Mavis / Xiaomi mimocode）。Agent 读完本指南后，按流程逐节执行即可，无需再回头询问用户目录。

## 0. 通用约定

- **不写「自动执行破坏性操作」**：本指南每一步都要求 Agent 先 `ls` 现状、对比能力缺口、再向用户确认目标，再 `cp -r`。
- **不把 skill 硬编码装到使用目录**：安装位置由用户在「询问装到哪个 Agent」步骤明确指定；Agent 不得自行决定。
- **「minicode」 / 「mcode」归因**：在 MiniMax 体系内，`mcode` 是 **Mavis**（MiniMax 出品的代码 Agent）的 CLI 别名；不在 MiniMax 体系内时，"minicode" 通常指 Xiaomi mimocode。Agent 在确认目标 Agent 前必须先与用户确认名字归属，再进入对应章节。
- **目录扫描触发**：所有 Agent 都通过启动时扫描 skill 目录自动发现 skill；`cp -r` 完成后下次启动即生效，无需任何额外注册命令（Mavis / mimocode 见各自章节）。

---

## 1. 目标 Agent → skill 目录映射

| Agent | 目标 skill 目录 | 备注 |
| --- | --- | --- |
| omo (OpenCode) | `~/.config/opencode/skills/` 与 `~/.agents/skills/` | omo 主目录 + Agent 通用目录 |
| pi | `~/.pi/agent/skills/` 与 `~/.agents/skills/` | 注意：`agent` 单数，目录名只有一个 segment；常见错拼会带额外 s，需避坑 |
| senpi | `~/.senpi/agent/skills/` 与 `~/.agents/skills/` | senpi 主目录 + Agent 通用目录 |
| Mavis（MiniMax mcode） | `~/.minimax/agents/mavis/skills/` | 官方文档化且固定的路径；CLI 别名 `mcode` |
| Xiaomi mimocode | 官方未文档化 | 现场检测（见下文 `## Xiaomi mimocode`） |

> 凡标「官方未文档化」者，下方对应章节给出**现场检测**方法；Agent 必须先 `ls` 现状、列可能路径、与用户确认真实目录后才能复制。

---

## 2. 能力对照表

本节把 13 个采纳 skill 与 omo 内置的对应能力并列对照，方便选型。

| Skill | omo 内置对应 | 备注 |
|---|---|---|
| `setup-meisijiya-skills` | — | 仓库初始化（首次使用前跑一次） |
| `slice-work` | — | 垂直切片拆解 |
| `codebase-design` | — | 设计意图词典 |
| `domain-modeling` | — | 领域模型 / ADR |
| `tdd` | `tdd` skill | 与 omo 内置同名一致 |
| `improve-codebase-architecture` | — | user-invoked |
| `prototype` | `prototype` skill | 与 omo 内置同名一致 |
| `diagnosing-bugs` | `/debugging` | 互补：build feedback loop 在先 |
| `code-review` | `/review-work` | 互补：日常 review vs PR 交接 |
| `resolving-merge-conflicts` | — | rebase conflict playbooks |
| `wizard` | — | 多步人工向导 |
| `grilling` | — | 严格交叉质询 |
| `writing-for-agents` | — | AGENTS.md / SKILL.md 写作 |

---

## 3. 内置覆盖表（哪些 skill 跳过）

omo / Mavis 已内置同名或同等能力的 skill，跳过避免重复触发。

| Skill | 状态 | 原因 |
|---|---|---|
| `tdd` | 装 | 与 omo `tdd` skill 内容一致，作为对外承诺保留 |
| `prototype` | 装 | 同上 |
| `diagnosing-bugs` | 装 | 互补 `omo /debugging`：diagnosis loop 聚焦先建 feedback loop，再做假设；不重叠 |
| `code-review` | 装 | 互补 `omo /review-work`：日常 diff review vs PR 交接 full QA；不重叠 |
| `research` | skip | 范围过大，触发噪音明显；omo 的 `/ulw-research` 已覆盖 |
| `handoff` | skip | 与 omo `task()` 多 Agent 委派机制重叠 |
| `ask-matt` | skip | 路由型 skill，omo 无内置对应；上游分发即可 |
| `grill-with-docs` | skip | 与 `grilling` + `domain-modeling` 工作流重叠 |
| `implement` | skip | 与 omo `task()` 多 Agent 委派机制重叠 |
| `to-spec` | skip | 由 `slice-work` 承接 |
| `to-tickets` | skip | 由 `slice-work` 承接 |
| `triage` | skip | omo `issue-tracker` workflow 内置类似流程 |
| `wayfinder` | skip | 仅大型 monorepo 需要，触发噪音明显 |
| `grill-me` | skip | 由 `grilling` 合并 |
| `teach` | skip | omo 内置 `teach` skill |
| `to-questionnaire` | skip | 与 `grilling` 工作流重叠 |
| `wait-what` | skip | 由 `grilling` 承接 |
| `setup-matt-pocock-skills` | skip | 重命名为 `setup-meisijiya-skills` |

---

## 4. 安装流程（先问，再检测，再复制，再汇报）

**步骤 0：先问「装到哪个 Agent」。**

进入对话后第一句话必须包含以下要点（不写「自动执行破坏性操作」措辞）：

> 「请问本次要把 Matt 这 25 个 skill 装到哪个 Agent？可选：omo / pi / senpi / Mavis / Xiaomi mimocode。装到 omo 时默认 20 个采纳 skill（按 §3.1 skip 5 个内置覆盖的）；装到 Mavis 时 25 全量 + 3 个加 `mattpocock-` 前缀避让；装到其它 Agent 时 25 个全量可选，由你逐项确认。」

收到明确答复（必须是 5 个之一）后才进入步骤 1；未明确前不复制任何文件。

> **Mavis 快速通道**：用户答「Mavis / mcode」且明确"走快路"时，可跳过 §4 步骤 1–2，直接走 §5「## Mavis」章节的复制命令（已包含 3 个 `mattpocock-` 前缀避让）。

**步骤 1：现场检测目标 Agent 的现状。**

按 §1 映射表执行 `ls`，记录：

- 目标目录是否存在
- 已存在哪些同名 skill 目录（避免覆盖）
- 是否需要先 `mkdir -p` 创建目录

命令示例（omo）：

```bash
ls -1 ~/.config/opencode/skills/ 2>/dev/null
ls -1 ~/.agents/skills/ 2>/dev/null
```

**步骤 2：列能力缺口。**

对照 §2 能力对照表，逐项打标：

- 目标 Agent 中已存在的 skill → skip
- 目标 Agent 中缺失但 omo 内置覆盖的（仅 omo）→ 标「omo 内置覆盖，按 §3 skip」
- 目标 Agent 中缺失且未覆盖的 → 列入待复制清单

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
- `<目标skill目录>` 是 §1 表里该 Agent 的目录字面值。
- 同一目标目录多次复制不同 skill 时，每次 `cp -r` 独立执行；不要写 `cp -r ... skills/* <dir>/` 这种一把梭的写法——会顺带把 bucket 下的 `README.md` 复制进去，污染目标目录。

**步骤 4：汇报。**

汇报模板：

```
已为 <Agent> 复制 <N> 个 skill 到 <目录>：
  - engineering/<name1> → 追问对齐（带文档背景）
  - productivity/<name2> → 追问对齐（开放反问）
跳过 <M> 个：
  - engineering/ask-matt（omo 无内置路由对应，按 §3.1 暂不入 omo；其它 Agent 时已询问用户决定）
  - engineering/diagnosing-bugs（omo 内置 /debugging 覆盖，按 §3.1 skip）
  - engineering/code-review（omo 内置 /review-work 覆盖，按 §3.1 skip；Mavis 装机时改名 mattpocock-code-review 共存）
  - engineering/research（omo 内置 /ulw-research 覆盖，按 §3.1 skip；Mavis 装机时改名 mattpocock-research 共存）
  - productivity/handoff（omo 内置 /handoff 覆盖，按 §3.1 skip；Mavis 装机时改名 mattpocock-handoff 共存）
```

若用户在 §4 步骤 2 显式排除某些 skill，则一并写入"跳过 <M> 个"段。

汇报完即可结束；不需要重启 Agent——下次启动会自动扫描到新 skill。

---

## 5. 各 Agent 章节

下面 5 个章节分别给出 omo / pi / senpi / Mavis / Xiaomi mimocode 五个 Agent 的目录、装机策略与复制命令示例。每个 Agent 一节，标题均为二级 `##`，便于 grep 与跳转。

为方便别名 grep（`^## Mavis`、`^## mimocode` 等模式），下两行作为锚点跳转目标：

## Mavis / mcode

见下文 `## Mavis`（MiniMax 出品的代码 Agent，CLI 别名 `mcode`，skill 目录官方文档化为 `~/.minimax/agents/mavis/skills/`）。

## mimocode

见下文 `## Xiaomi mimocode`（Xiaomi 出品的代码 Agent，skill 目录官方未文档化）。

## omo (OpenCode)

**目录**：`~/.config/opencode/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.config/opencode/skills/`）。

**装机策略**：默认 13 个 skill 全量。

### omo / Atlas 安装

```bash
# 把 13 个 skill 复制到 omo skills 目录
SKILLS=(
  setup-meisijiya-skills slice-work codebase-design domain-modeling
  tdd improve-codebase-architecture prototype
  diagnosing-bugs code-review resolving-merge-conflicts wizard
  grilling writing-for-agents
)

for s in "${SKILLS[@]}"; do
  cp -r "skills/engineering/$s" ~/.config/opencode/skills/engineering/ 2>/dev/null || \
  cp -r "skills/productivity/$s" ~/.config/opencode/skills/productivity/ 2>/dev/null
done
```

更精确的命令（直接同步到 omo 期望目录）：

```bash
ENGINEERING=(
  setup-meisijiya-skills slice-work codebase-design domain-modeling
  tdd improve-codebase-architecture prototype
  diagnosing-bugs code-review resolving-merge-conflicts wizard
)
PRODUCTIVITY=(grilling writing-for-agents)

mkdir -p ~/.config/opencode/skills/engineering ~/.config/opencode/skills/productivity
for s in "${ENGINEERING[@]}"; do cp -r "skills/engineering/$s" ~/.config/opencode/skills/engineering/; done
for s in "${PRODUCTIVITY[@]}"; do cp -r "skills/productivity/$s" ~/.config/opencode/skills/productivity/; done
```

## 5.1 prompt_append 配置（Prometheus 垂直切片内化）

为了让 Prometheus（omo 计划 agent）在生成 `## Todos` 时自动按垂直切片拆解，**不要在每次 prompt 里重复说**，把规则内化到 `~/.config/opencode/oh-my-openagent.jsonc` 的 `agents.prometheus.prompt_append` 字段：

```jsonc
{
  "agents": {
    "prometheus": {
      "model": "<your model>",
      "variant": "high",
      "prompt_append": "When decomposing work into ## Todos, use vertical tracer-bullet slices: each slice cuts a narrow but complete path through every layer (schema/API/UI/tests), is independently demoable, and fits one context window. Give each task its blocking edges — tasks with no blockers can start immediately. Wide mechanical refactors use expand-contract (add the new form beside the old, migrate call sites in batches, then contract).",
      "fallback_models": []
    }
  }
}
```

加入后，Prometheus 生成的 `## Todos` 会自然按垂直切片形式产出，不再依赖 `slice-work` skill 的显式调用。`slice-work` skill 仍保留用于计划已写好之后做进一步拆分。

---

## pi

**目录**：`~/.pi/agent/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.pi/agent/skills/`）。

**装机策略**：默认 13 个全量（pi 与 omo / Mavis 内置覆盖是否一致未在本机验证；§4 步骤 2 现场对比能力表后由用户决定是否加 `mattpocock-` 前缀避让）。

**复制示例**（13 个全量，无前缀；如需避让见命令后注释）：

```bash
TARGET=~/.pi/agent/skills/

# engineering 11 个
for s in \
  setup-meisijiya-skills slice-work codebase-design \
  domain-modeling tdd improve-codebase-architecture \
  prototype diagnosing-bugs code-review \
  resolving-merge-conflicts wizard; do
  cp -r skills/engineering/$s "$TARGET/"
done

# productivity 2 个
for s in \
  grilling writing-for-agents; do
  cp -r skills/productivity/$s "$TARGET/"
done

# 如 pi 内置撞名 code-review，cp 后改名为 mattpocock-code-review
```

**复制完成标志**：

```bash
ls -1 ~/.pi/agent/skills/ | wc -l   # 期望 ≥ 13
```

> 注意：`agent` 为单数。错拼成 `agents`（额外 s）的目录不会被任何已知 Agent 扫描。

---

## senpi

**目录**：`~/.senpi/agent/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.senpi/agent/skills/`）。

**装机策略**：默认 13 个全量（senpi 与 omo / Mavis 内置覆盖是否一致未在本机验证；§4 步骤 2 现场对比能力表后由用户决定是否加 `mattpocock-` 前缀避让）。

**复制示例**（13 个全量，与 pi 同；目标目录替换为 `~/.senpi/agent/skills/`）：

```bash
TARGET=~/.senpi/agent/skills/

for s in \
  setup-meisijiya-skills slice-work codebase-design \
  domain-modeling tdd improve-codebase-architecture \
  prototype diagnosing-bugs code-review \
  resolving-merge-conflicts wizard; do
  cp -r skills/engineering/$s "$TARGET/"
done

for s in \
  grilling writing-for-agents; do
  cp -r skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 ~/.senpi/agent/skills/ | wc -l   # 期望 ≥ 13
```

---

## Mavis (MiniMax mcode)

> Mavis 是 MiniMax 出品的代码 Agent，CLI 别名 `mcode`，是 OhMyOpenCode (`omo`) 的同源姊妹项目（路径、覆盖判断、风格与 omo 一致）。

**目录**：`~/.minimax/agents/mavis/skills/`（**官方文档化且固定**，无需现场检测）。

> 若用户的 Mavis 安装使用了非默认路径（少数自部署 / 容器场景），按 §4 步骤 1 的 `ls` 探查代替。

**装机策略**：默认 25 个全量 + 3 个加 `mattpocock-` 前缀避让（Mavis 仍装上游版：上游 25 个从 `mattpocock-skills/` 本地 fork 复制，本仓库 `skills/` 已精简为 13 个）。

**复制示例**（一次性复制 25 个，3 个加前缀）：

```bash
TARGET=~/.minimax/agents/mavis/skills/

# 上游 fork 不存在时先克隆：git clone https://github.com/mattpocock/skills mattpocock-skills
SRC=mattpocock-skills/skills

# 16 个 engineering 原名（含 ask-matt / diagnosing-bugs）
for s in \
  ask-matt codebase-design diagnosing-bugs domain-modeling \
  grill-with-docs implement improve-codebase-architecture \
  prototype resolving-merge-conflicts \
  setup-matt-pocock-skills tdd to-spec to-tickets triage \
  wayfinder wizard; do
  cp -r "$SRC/engineering/$s" "$TARGET/"
done

# 2 个 engineering 加 mattpocock- 前缀（与 Mavis 内置 code-review / research 撞名）
for src in code-review research; do
  cp -r "$SRC/engineering/$src" "$TARGET/mattpocock-$src"
done

# 6 个 productivity 原名
for s in \
  grill-me grilling teach to-questionnaire \
  wait-what writing-for-agents; do
  cp -r "$SRC/productivity/$s" "$TARGET/"
done

# 1 个 productivity 加 mattpocock- 前缀（与 Mavis 内置 handoff 撞名）
cp -r "$SRC/productivity/handoff" "$TARGET/mattpocock-handoff"
```

**复制完成标志**：

```bash
ls -1 ~/.minimax/agents/mavis/skills/ | wc -l   # 期望 ≥ 25
ls -1 ~/.minimax/agents/mavis/skills/ | grep '^mattpocock-'   # 期望 3 个：mattpocock-code-review, mattpocock-research, mattpocock-handoff
```

**Mavis 启动时的 skill 调用约定**：Mavis 的 skill 工具用裸名调用 —— `skill({name: "xxx"})`，**不**用 `/xxx` 这种 slash command 形式。上游 fork 的 SKILL.md 已统一改为裸名（详见 `mattpocock-skills/skills/engineering/ask-matt/SKILL.md` 改写记录）。

---

## Xiaomi mimocode

**目录**：**官方未文档化**。本指南不为其硬编码路径。

**现场检测方法**（必须执行，不可跳过）：

1. 同样执行 `ls` 探查 `~/.mimocode/skills/`、`~/.xiaomi/mimocode/skills/`、`~/.config/mimocode/skills/`、`~/.config/xiaomi/skills/` 等常见模式——但本指南**不为它硬编码**任何一条具体路径，逐项试完后未命中即询问用户。
2. 询问用户：「mimocode 的 skill 目录实际放在哪个路径？本机常见的几个位置我用 `ls` 没命中，需要你确认。」
3. 拿到确认路径后，再走 §4 步骤 2–4。

**装机策略**：默认 13 个全量可选（mimocode 内置覆盖未验证，按 §3 不预设 skip）。

**复制命令模板**（路径由用户确认后填入 `<USER_CONFIRMED_DIR>`）：

```bash
TARGET=<USER_CONFIRMED_DIR>   # 现场检测后由用户给定

for s in \
  setup-meisijiya-skills slice-work codebase-design \
  domain-modeling tdd improve-codebase-architecture \
  prototype diagnosing-bugs code-review \
  resolving-merge-conflicts wizard; do
  cp -r skills/engineering/$s "$TARGET/"
done

for s in \
  grilling writing-for-agents; do
  cp -r skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 <USER_CONFIRMED_DIR> | wc -l   # 期望 ≥ 13
```

> **不写「自动执行破坏性操作」**：mimocode 路径未定前，**不**直接 `mkdir -p` 任何路径、不 `cp` 到任何目录；先 `ls`、再询问用户。

---

### 已验证装机清单（维护者手动记录）

| Agent | 验证版本 | 验证日期 | 装机策略 | 备注 |
| --- | --- | --- | --- | --- |
| Mavis | v0.1+ | 2026-08 | 25 全量 + 3 `mattpocock-` 前缀 | 已成功；命名冲突已避让；调用方式 `skill({name:"xxx"})` |
| omo (OpenCode) | main | — | 13 全量（engineering 11 + productivity 2，无前缀） | 与 Mavis 同源，待本机验证后补日期 |
| pi | — | — | 13 全量可选（按需加前缀） | 未在本机验证 |
| senpi | — | — | 13 全量可选（按需加前缀） | 未在本机验证 |
| Xiaomi mimocode | — | — | 13 全量可选（按需加前缀） | 路径官方未文档化 |

新验证一种 Agent 后，在表格里补一行；`MAINTENANCE.md` §2 监控信号"INSTALL.md 漏 Agent"已对照此表。

---

## 6. 反向操作（卸载）

如需卸载某个 skill，`rm -rf` 对应目录即可；所有 5 个 Agent 都按目录扫描发现 skill，删目录即下架，无注册表/缓存需清理。

```bash
# 例：从 omo 卸载 grill-with-docs
rm -rf ~/.config/opencode/skills/grill-with-docs
```

卸载动作需用户确认；Agent 不要主动执行。

---

## 7. 一句话总结

> 问 Agent → `ls` 现状 → 对照 §2 能力表列缺口 → `cp -r` 对应 skill 目录 → 汇报。