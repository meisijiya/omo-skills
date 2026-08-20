# INSTALL — mattpocock-skills 多 Agent 安装指南

本指南面向能执行 shell 的 Agent（omo / pi / senpi / MiniMax mcode / Xiaomi mimocode）。Agent 读完本指南后，按流程逐节执行即可，无需再回头询问用户目录。

## 0. 通用约定

- **不写「自动执行破坏性操作」**：本指南每一步都要求 Agent 先 `ls` 现状、对比能力缺口、再向用户确认目标，再 `cp -r`。
- **不把 skill 硬编码装到使用目录**：安装位置由用户在「询问装到哪个 Agent」步骤明确指定；Agent 不得自行决定。
- **本机未装开源 MiniCode**：本指南不为它写独立章节。用户口中的「minicode」一律指 Xiaomi mimocode。
- **目录扫描触发**：所有 Agent 都通过启动时扫描 skill 目录自动发现 skill；`cp -r` 完成后下次启动即生效，无需任何额外注册命令（mcode/mimocode 见各自章节）。

---

## 1. 目标 Agent → skill 目录映射

| Agent | 目标 skill 目录 | 备注 |
| --- | --- | --- |
| omo (OpenCode) | `~/.config/opencode/skills/` 与 `~/.agents/skills/` | omo 主目录 + Agent 通用目录 |
| pi | `~/.pi/agent/skills/` 与 `~/.agents/skills/` | 注意：`agent` 单数，目录名只有一个 segment；常见错拼会带额外 s，需避坑 |
| senpi | `~/.senpi/agent/skills/` 与 `~/.agents/skills/` | senpi 主目录 + Agent 通用目录 |
| MiniMax mcode | 官方未文档化 | 现场检测（见下文 `## MiniMax mcode`） |
| Xiaomi mimocode | 官方未文档化 | 现场检测（见下文 `## Xiaomi mimocode`） |

> 凡标「官方未文档化」者，下方对应章节给出**现场检测**方法；Agent 必须先 `ls` 现状、列可能路径、与用户确认真实目录后才能复制。

---

## 2. 能力对照表（25 个 skill）

下表列出本仓库 `mattpocock-skills/skills/` 下的全部 25 个 skill（engineering/ 18 + productivity/ 7）及其能力归属。装机前先读这一节，圈出目标 Agent 真正缺的能力，再决定装哪些。

| skill | 能力标签 | bucket |
| --- | --- | --- |
| `grill-with-docs` | 追问对齐（带文档背景） | engineering |
| `grill-me` | 追问对齐（开放反问） | productivity |
| `grilling` | 追问对齐（持续追问） | productivity |
| `domain-modeling` | 领域建模 | engineering |
| `codebase-design` | 深模块设计 | engineering |
| `tdd` | 测试驱动 | engineering |
| `improve-codebase-architecture` | 架构扫描 | engineering |
| `to-spec` | spec 合成 | engineering |
| `to-tickets` | 工单拆分 | engineering |
| `triage` | issue 分类 | engineering |
| `wayfinder` | 多会话规划 | engineering |
| `implement` | 实现调度 | engineering |
| `resolving-merge-conflicts` | 冲突解析 | engineering |
| `wizard` | 交互向导 | engineering |
| `prototype` | 原型 | engineering |
| `teach` | 教学 | productivity |
| `to-questionnaire` | 问卷 | productivity |
| `setup-matt-pocock-skills` | 一次性配置（装其它 skill 的引导） | engineering |
| `wait-what` | 纠错 | productivity |
| `writing-for-agents` | 写作规范 | productivity |
| `ask-matt` | 路由（指引到正确 skill） | engineering |
| `diagnosing-bugs` | 调试 | engineering |
| `code-review` | 审查 | engineering |
| `research` | 研究 | engineering |
| `handoff` | 交接 | productivity |

**关于 5 个备用的说明**：`ask-matt` / `diagnosing-bugs` / `code-review` / `research` / `handoff` 这 5 个 skill 与 omo 已内置能力重叠，详见 §3「omo 内置覆盖」。

---

## 3. omo Agent 内置覆盖（影响装机清单）

omo 内置命令/工具已覆盖部分能力。下面四条映射决定**装到 omo 时默认不装这 5 个对应 skill**（它们在 omo 上是冗余）；装到 pi / senpi / mcode / mimocode 时因覆盖与否需现场检测，默认 25 个全量可选。

| Matt skill | omo 内置对应 | 装机策略 |
| --- | --- | --- |
| `diagnosing-bugs` | `/debugging`（内置调试工作流） | 装 omo → 不装；装其它 Agent → 可选 |
| `code-review` | `/review-work`（内置评审编排） | 装 omo → 不装；装其它 Agent → 可选 |
| `research` | `/ulw-research`（内置深度研究） | 装 omo → 不装；装其它 Agent → 可选 |
| `handoff` | `/handoff`（内置交接摘要） | 装 omo → 不装；装其它 Agent → 可选 |
| `ask-matt` | （omo 无内置路由对应） | 装 omo → 不装；仅供其它 Agent 下载，按用户决定保留 |

**结论**：

- **装到 omo → 默认只装 20 个采纳 skill**（§2 表里除上述 5 行外的全部）。`setup-matt-pocock-skills` 这一项属于「一次性配置」类，已内置的 5 个被显式 skip。
- **装到 pi / senpi / mcode / mimocode → 默认 25 个全量可选**。这些 Agent 的内置覆盖未在本机验证（pi/senpi 同源 omo 的内置子集可能不同；mcode/mimocode 完全未文档化），所以不预设 skip，由 §6 流程逐项询问用户。

---

## 4. 安装流程（先问，再检测，再复制，再汇报）

**步骤 0：先问「装到哪个 Agent」。**

进入对话后第一句话必须包含以下要点（不写「自动执行破坏性操作」措辞）：

> 「请问本次要把 Matt 这 25 个 skill 装到哪个 Agent？可选：omo / pi / senpi / MiniMax mcode / Xiaomi mimocode。装到 omo 时我会默认跳过 5 个与内置重叠的；装到其它 Agent 时 25 个全量可选。」

收到明确答复（必须是 5 个之一）后才进入步骤 1；未明确前不复制任何文件。

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
cp -r mattpocock-skills/skills/engineering/<name> <目标skill目录>/

# 复制单个 skill（productivity bucket）
cp -r mattpocock-skills/skills/<bucket>/<name> <目标skill目录>/
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
  - ...
跳过 <M> 个：
  - engineering/ask-matt（omo 内置无对应，按 §3 暂不入 omo；其它 Agent 时已询问用户决定）
  - engineering/diagnosing-bugs（omo 内置 /debugging 覆盖，按 §3 skip）
  - engineering/code-review（omo 内置 /review-work 覆盖，按 §3 skip）
  - engineering/research（omo 内置 /ulw-research 覆盖，按 §3 skip）
  - productivity/handoff（omo 内置 /handoff 覆盖，按 §3 skip）
```

汇报完即可结束；不需要重启 Agent——下次启动会自动扫描到新 skill。

---

## 5. 各 Agent 章节

下面 5 个章节分别给出 omo / pi / senpi / MiniMax mcode / Xiaomi mimocode 五个 Agent 的目录、装机策略与复制命令示例。每个 Agent 一节，标题均为二级 `##`，便于 grep 与跳转。

为方便别名 grep（`^## mcode`、`^## mimocode` 等模式），下两行作为锚点跳转目标：

## mcode

见下文 `## MiniMax mcode`（MiniMax 出品的代码 Agent，skill 目录官方未文档化）。

## mimocode

见下文 `## Xiaomi mimocode`（Xiaomi 出品的代码 Agent，skill 目录官方未文档化）。

## omo (OpenCode)

**目录**：`~/.config/opencode/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.config/opencode/skills/`）。

**装机策略**：默认只装 20 个采纳 skill，跳过 §3 表中 5 个 omo 内置覆盖的。

**复制示例**（一次性复制 20 个）：

```bash
TARGET=~/.config/opencode/skills/

# 17 个 engineering 采纳（不含 ask-matt / diagnosing-bugs / code-review / research）
for s in \
  codebase-design domain-modeling grill-with-docs \
  implement improve-codebase-architecture \
  prototype resolving-merge-conflicts \
  setup-matt-pocock-skills tdd to-spec to-tickets triage \
  wayfinder wizard; do
  cp -r mattpocock-skills/skills/engineering/$s "$TARGET/"
done

# 7 个 productivity 采纳（不含 handoff）
for s in \
  grill-me grilling teach to-questionnaire \
  wait-what writing-for-agents; do
  cp -r mattpocock-skills/skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 ~/.config/opencode/skills/ | wc -l   # 期望 ≥ 20（取决于已存在的 skill 数）
```

**omo 内置覆盖的 5 个 skill 不复制**：见 §3。

---

## pi

**目录**：`~/.pi/agent/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.pi/agent/skills/`）。

**装机策略**：默认 25 个全量可选（pi 内置覆盖未在本机验证，按 §3 不预设 skip；§4 步骤 2 现场对比能力表逐项询问用户后决定）。

**复制示例**（25 个全量）：

```bash
TARGET=~/.pi/agent/skills/

# engineering 18 个（含 ask-matt / diagnosing-bugs / code-review / research）
for s in \
  ask-matt code-review codebase-design diagnosing-bugs \
  domain-modeling grill-with-docs implement \
  improve-codebase-architecture prototype research \
  resolving-merge-conflicts setup-matt-pocock-skills tdd \
  to-spec to-tickets triage wayfinder wizard; do
  cp -r mattpocock-skills/skills/engineering/$s "$TARGET/"
done

# productivity 7 个（含 handoff）
for s in \
  grill-me grilling handoff teach to-questionnaire \
  wait-what writing-for-agents; do
  cp -r mattpocock-skills/skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 ~/.pi/agent/skills/ | wc -l   # 期望 ≥ 25
```

> 注意：`agent` 为单数。错拼成 `agents`（额外 s）的目录不会被任何已知 Agent 扫描。

---

## senpi

**目录**：`~/.senpi/agent/skills/` 与 `~/.agents/skills/`（任选其一即可，建议主目录 `~/.senpi/agent/skills/`）。

**装机策略**：默认 25 个全量可选（senpi 内置覆盖未在本机验证，按 §3 不预设 skip；§4 步骤 2 现场对比能力表逐项询问用户后决定）。

**复制示例**（25 个全量，与 pi 同；目标目录替换为 `~/.senpi/agent/skills/`）：

```bash
TARGET=~/.senpi/agent/skills/

for s in \
  ask-matt code-review codebase-design diagnosing-bugs \
  domain-modeling grill-with-docs implement \
  improve-codebase-architecture prototype research \
  resolving-merge-conflicts setup-matt-pocock-skills tdd \
  to-spec to-tickets triage wayfinder wizard; do
  cp -r mattpocock-skills/skills/engineering/$s "$TARGET/"
done

for s in \
  grill-me grilling handoff teach to-questionnaire \
  wait-what writing-for-agents; do
  cp -r mattpocock-skills/skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 ~/.senpi/agent/skills/ | wc -l   # 期望 ≥ 25
```

---

## MiniMax mcode

**目录**：**官方未文档化**。本指南不为其硬编码路径。

**现场检测方法**（必须执行，不可跳过）：

1. `ls -1 ~/.MiniMax/skills/ 2>/dev/null`、`ls -1 ~/.MiniMax/mcode/skills/ 2>/dev/null`、`ls -1 ~/.mcode/skills/ 2>/dev/null`、`ls -1 ~/.MiniMax/agent/skills/ 2>/dev/null`、`ls -1 ~/.config/mcode/skills/ 2>/dev/null` 之类的常见模式。
2. 询问用户：「mcode 的 skill 目录实际放在哪个路径？我用 `ls` 没命中常见位置，需要你确认。」
3. 拿到确认路径后，再走 §4 步骤 2–4。

**装机策略**：默认 25 个全量可选（mcode 内置覆盖未验证，按 §3 不预设 skip）。

**复制命令模板**（路径由用户确认后填入 `<USER_CONFIRMED_DIR>`）：

```bash
TARGET=<USER_CONFIRMED_DIR>   # 现场检测后由用户给定

for s in \
  ask-matt code-review codebase-design diagnosing-bugs \
  domain-modeling grill-with-docs implement \
  improve-codebase-architecture prototype research \
  resolving-merge-conflicts setup-matt-pocock-skills tdd \
  to-spec to-tickets triage wayfinder wizard; do
  cp -r mattpocock-skills/skills/engineering/$s "$TARGET/"
done

for s in \
  grill-me grilling handoff teach to-questionnaire \
  wait-what writing-for-agents; do
  cp -r mattpocock-skills/skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 <USER_CONFIRMED_DIR> | wc -l   # 期望 ≥ 25
```

> **不写「自动执行破坏性操作」**：mcode 路径未定前，**不**直接 `mkdir -p` 任何路径、不 `cp` 到任何目录；先 `ls`、再询问用户。

---

## Xiaomi mimocode

**目录**：**官方未文档化**。本指南不为其硬编码路径。

**现场检测方法**（必须执行，不可跳过）：

1. 同样执行 `ls` 探查 `~/.mimocode/skills/`、`~/.xiaomi/mimocode/skills/`、`~/.config/mimocode/skills/`、`~/.config/xiaomi/skills/` 等常见模式——但本指南**不为它硬编码**任何一条具体路径，逐项试完后未命中即询问用户。
2. 询问用户：「mimocode 的 skill 目录实际放在哪个路径？本机常见的几个位置我用 `ls` 没命中，需要你确认。」
3. 拿到确认路径后，再走 §4 步骤 2–4。

**装机策略**：默认 25 个全量可选（mimocode 内置覆盖未验证，按 §3 不预设 skip）。

**复制命令模板**（路径由用户确认后填入 `<USER_CONFIRMED_DIR>`）：

```bash
TARGET=<USER_CONFIRMED_DIR>   # 现场检测后由用户给定

for s in \
  ask-matt code-review codebase-design diagnosing-bugs \
  domain-modeling grill-with-docs implement \
  improve-codebase-architecture prototype research \
  resolving-merge-conflicts setup-matt-pocock-skills tdd \
  to-spec to-tickets triage wayfinder wizard; do
  cp -r mattpocock-skills/skills/engineering/$s "$TARGET/"
done

for s in \
  grill-me grilling handoff teach to-questionnaire \
  wait-what writing-for-agents; do
  cp -r mattpocock-skills/skills/productivity/$s "$TARGET/"
done
```

**复制完成标志**：

```bash
ls -1 <USER_CONFIRMED_DIR> | wc -l   # 期望 ≥ 25
```

> **不写「自动执行破坏性操作」**：mimocode 路径未定前，**不**直接 `mkdir -p` 任何路径、不 `cp` 到任何目录；先 `ls`、再询问用户。

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