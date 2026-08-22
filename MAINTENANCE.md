# MAINTENANCE — omo-skills 长期维护手册

> 📖 在线指南：[meisijiya.github.io/omo-skills/](https://meisijiya.github.io/omo-skills/)

> 面向：用户本人 / Agent / 团队成员。按手册逐节执行即可，无需额外约定。

本仓库专为 [OhMyOpenCode](https://github.com/code-yeongyu/oh-my-opencode)（omo）服务，已脱离任何上游 fork；`skills/` 是唯一来源。本手册的所有流程都基于此前提。

---

## §1. 仓库拓扑（前置必读）

```
omo-skills/
├── skills/                 ← 微调后的 16 个 skill（产物，push 到 GitHub，INSTALL.md 安装源）
│   ├── engineering/        ← 12 个工程 skill
│   └── productivity/       ← 4 个产出/写作 skill
├── README.md               ← 人读概览
├── INSTALL.md              ← Agent 询问后安装指引
├── MAINTENANCE.md          ← 本文件（维护手册）
└── .omo/                   ← 工作状态（不入版本控制）
```

- **`skills/`（产物）**：微调后可直接 `cp -r` 给 omo 安装的 skill 目录。push 到 GitHub。
- **同步关系**：新 skill 直接在 `skills/<bucket>/<name>/` 下新建，按 §5 流程维护。
- **`mattpocock-skills/` 已删除**：仓库早期 fork 自 `mattpocock/mattpocock-skills`，但本仓库早已脱离上游同步（不再 fetch / rebase），fork 目录也不再保留。所有 skill 改动都直接在 `skills/` 下进行。

---

## §2. 监控信号（什么时候要维护）

| 信号 | 检测命令 | 触发维护场景 |
|---|---|---|
| 守卫失效 | 触发某 skill 后模型没识别 user-invoked | 守卫被覆盖 |
| INSTALL.md 漏目录 | 新安装环境但 INSTALL.md §1 未列 | 能力缺口 |
| 路径残留 | `grep -rn '\.scratch/\|\.out-of-scope/' skills/*/SKILL.md` 非空且路径未在 §9.1 提交类清单中 | 路径未统一 |

> 早期监控信号包含的 `mattpocock-skills fetch` / `rebase 冲突` / `path 同步` 已全部废止——仓库不依赖上游。

---

## §3. （已废止）

> 原 §3 为 "上游同步 Playbook"。仓库已脱离 `mattpocock-skills/` 上游 fork，本节内容全部废止。如需了解历史，请参见本仓库 `git log -- skills/` 与早期 commit。

---

## §4. 变更后必跑验证（关键 — 不跑就别继续）

```bash
cd omo-skills/      # 产物仓库根

# 断言 1: 16 个 SKILL.md YAML 解析（engineering 12 + productivity 4）
python3 -c "
import glob, yaml, sys
files = sorted(glob.glob('skills/engineering/*/SKILL.md')) + sorted(glob.glob('skills/productivity/*/SKILL.md'))
if len(files) != 16:
    print(f'FAIL: expected 16 SKILL.md, got {len(files)}')
    sys.exit(1)
errs = []
for f in files:
    try:
        fm = open(f).read().split('---',2)[1]
        d = yaml.safe_load(fm)
        if not d.get('name') or not d.get('description'): errs.append(f)
    except Exception as e: errs.append(f'{f}: {e}')
sys.exit(1 if errs else 0)
"

# 断言 2: 4 个 user-invoked 守卫 + 字段保留
for f in skills/engineering/{improve-codebase-architecture,setup-meisijiya-skills}/SKILL.md skills/productivity/{teach,to-questionnaire}/SKILL.md; do
  grep -q 'User-invoked only — do not invoke automatically' "$f" || echo "FAIL_GUARD $f"
  grep -q 'disable-model-invocation: true' "$f" || echo "FAIL_FIELD $f"
done

# 断言 3: 12 个 model-invoked 零守卫（slice-work 已弃用，从列表移除；新增 architecture-decision-records / api-and-interface-design）
for f in skills/engineering/{codebase-design,domain-modeling,tdd,resolving-merge-conflicts,wizard,prototype,code-review,diagnosing-bugs,architecture-decision-records,api-and-interface-design}/SKILL.md skills/productivity/{grilling,writing-for-agents}/SKILL.md; do
  grep -q 'User-invoked only' "$f" && echo "FAIL_EXTRA $f"
done
```

任何 `FAIL` 立即停下来调查。

---

## §5. Skill 引入规则（讨论流程）

> **核心原则**：新引入 skill 时，**先讨论、再决定、最后执行**。不靠自动化分配路径，靠人/Agent 对照 §9 把每份新文档摊开讨论归类。

### Step 0. 讨论（必走 — 不跳过）

与用户讨论以下议题，把决策写到 `.omo/notepads/<plan>/decisions.md`（同当前 plan 流程）：

1. **文档产出清单**：这个新 skill 会涉及哪些文档？
   - `SKILL.md`（必有）
   - `references/*.md`（CONTEXT.md / CONTEXT-MAP.md / issue-tracker-local.md 等）
   - 是否要新建 ADR？写到 `docs/adr/`
   - 是否要新建 Agent 角色定义？写到 `docs/agents/`
   - 是否要新建 scratch 笔记？写到 `.scratch/`
2. **路径分类**：对照 §9 把每份文档归到「提交类」或「临时态」
3. **冲突检查**：与现有 skill 的 description 是否撞车？与 omo 内置 skill（`ulw-plan` / `/debugging` / `/review-work` / `task()` / `codegraph_*` 等）是否撞车？路径是否复用？
4. **联动更新**：INSTALL.md 能力对照表 / README.md 清单是否要改？

### Step 1. 新建 skill 目录

新 skill 直接在 `skills/<bucket>/<name>/` 下新建（`mkdir -p skills/<bucket>/<name>/agents`），无需 fork 任何上游。

### Step 2. 应用守卫与路径

检查 `skills/<bucket>/<新skill>/SKILL.md`，按 §9 讨论结果执行：

- user-invoked（前缀 `User-invoked only — do not invoke automatically. `，保留 `disable-model-invocation: true` 字段）
- model-invoked（不动 description；若与 omo 内置撞触发词，加去歧义短语）
- 含 `.scratch/.out-of-scope` 字面量 → 替换为工作区根直接子目录 `.scratch/` / `.out-of-scope/`（无 `.omo/` 前缀）

### Step 3. 提交

`git commit -m "feat(skills): add <新 skill> with guard/path fixes"`（按 Step 0 讨论结果可能多 commit）。

### Step 4. 更新外层文档

按 Step 0 讨论结果更新 INSTALL.md / README.md。

### Step 5. 验证

跑 §4 的 3 个断言。

---

## §6. （已废止）

> 原 §6 为 "添加新 Agent Playbook（INSTALL.md）"。本仓库已不再支持 pi / senpi / mimocode 等其他 Agent 的安装指引；专门服务 omo。新 Agent 支持流程仅在 `INSTALL.md §1` 增加 omo 安装目录变体时使用。

---

## §7. 退役/废弃 Playbook

1. 确认退役：与用户讨论退役理由
2. 从 INSTALL.md 能力对照表删除该行
3. 从 README.md 清单删除该行（无论采纳还是备用）
4. `git commit -m "docs: retire <skill>"`
5. **删除**本地 SKILL.md（保留弃用表作为历史决策可查）
6. 更新 MAINTENANCE.md §4 断言列表（去掉退役 skill 的引用）

---

## §8. 故障排查速查

| 现象 | 可能原因 | 检查命令 |
|---|---|---|
| Skill 未被 Agent 发现 | 守卫未生效 / disable-model-invocation 字段丢失 | `grep 'User-invoked only' <SKILL>` + `grep 'disable-model-invocation' <SKILL>` |
| Skill 触发噪音 | 守卫描述太弱 / model-invoked skill 描述里有 user-invoked 词 / 与 omo 内置撞车 | `grep -E 'When\|Use when'` + 比对 omo `dist/skills/` 内置 description |
| INSTALL.md 装错目录 | 询问流程被跳过 | INSTALL.md §4 流程是否被 Agent 跳过 |

---

## §9. 文档落地路径分类（讨论参考，非自动化）

> **核心立场**：这份分类是**讨论的脚手架**，**不是自动执行规则**。新引入 skill 时拿这份表对照，逐份文档讨论归类，而不是让脚本替我们判断。
>
> 自动化可不靠谱 —— Agent 与人一起讨论出来的归类才能长期维护。

### §9.1 两类路径

**A. 提交类（final / 保留 / decision）** —— 上游原路径，**禁止改动**：

| 路径 | 含义 | 权威源 |
|---|---|---|
| `docs/adr/` | Architecture Decision Records（目录 bootstrap 权威 = 创建布局；运行时写入权威 = `architecture-decision-records/SKILL.md`） | `setup-meisijiya-skills/SKILL.md`（bootstrap） + `architecture-decision-records/SKILL.md`（写入） |
| `CONTEXT.md` | 项目主上下文（仓库根级） | `setup-meisijiya-skills/SKILL.md` |
| `CONTEXT-MAP.md` | 上下文导航图（仓库根级） | `setup-meisijiya-skills/SKILL.md` |
| `docs/agents/` | Agent 角色定义 | 各 skill 引用的元数据 |
| `DESIGN.md` | UI 设计规范（仓库根级，与 `CONTEXT.md` 平级） | 由 omo 内置 `/frontend` 写入 |

**B. 临时态（working / scratch / out-of-scope）** —— 上游原路径，工作区根直接子目录（与 omo / 上游双方一致）：

| 路径 | 含义 | 替换关系 |
|---|---|---|
| `.scratch/` | 工作草稿 | 工作区根直接子目录（无 `.omo/` 前缀） |
| `.out-of-scope/` | 范围外工作笔记 | 工作区根直接子目录（无 `.omo/` 前缀） |

### §9.2 讨论时的判定问题

新引入文档时，逐份对照以下问题决定归类：

| 判定问题 | → 提交类 | → 临时态 |
|---|---|---|
| 内容是 final 决策吗？ | ✅ `docs/adr/` | ❌ `.scratch/` |
| 是项目级上下文吗？ | ✅ `CONTEXT.md` / `CONTEXT-MAP.md` | ❌ |
| 是 Agent 角色定义吗？ | ✅ `docs/agents/` | ❌ |
| 是工作笔记/草稿吗？ | ❌ | ✅ `.scratch/` |
| 是范围外备查吗？ | ❌ | ✅ `.out-of-scope/` |

### §9.3 边界争议处理（讨论时参考）

如果一份文档跨两类（如既记录记录决策又含工作笔记）：

1. **优先拆为两份**：决策摘要 → `docs/adr/`；详细笔记 → `.scratch/xxx.md`，并在 ADR 中引用
2. **次选**：在 `docs/adr/` 中加 `## working notes` 段引用 `.scratch/xxx`
3. **最次选**：保留在原 SKILL.md 正文里（同文件内多 section），但加路径前缀

---

## §10. skill 同步与新建流程（仓库已脱离上游 fork）

**状态**：本仓库已脱离任何上游 fork，`skills/` 是唯一来源。新 skill 在 `skills/<bucket>/<name>/` 下新建，按 §5 Step 0 讨论后再决定是否纳入。

### Step 0. 讨论

新 skill 引入必须先讨论（见 §5）。讨论通过后再执行 Step 1-3。

### Step 1. 新建 skill 目录

```bash
mkdir -p skills/engineering/<new-skill>/agents
# 写 SKILL.md（带 frontmatter）+ agents/openai.yaml
```

### Step 2. 跑断言

参见 §4 的 3 条断言（每个目录都含 SKILL.md / user-invoked 守卫 / model-invoked 零守卫）。

### Step 3. 更新文档

更新 `README.md` 采纳表、`INSTALL.md §2 与 §5 复制命令`、`MAINTENANCE.md §4` 断言列表。

### 已废止：上游同步

仓库不再依赖任何上游 fork。无 `fetch` / `rebase` / `merge` 流程。`mattpocock-skills/` 目录已删除。

---

## §11. agent overrides 双轨维护（新增 / 废弃 skill 时的强制检查项）

> **核心约束**：每新增或废弃一个 skill，**两条轨道都必须更新**，遗漏任意一条都会导致部分 agent 看不到 / 误触发。

### §11.1 双轨定义

| 轨道 | 配置字段 | 适用 agent | 触发逻辑 |
|---|---|---|---|
| **A. 主代理 prompt_append** | `agents.<name>.prompt_append: string` | sisyphus / prometheus / atlas | omo 默认通过 skill 工具**advertise** skill 描述（不注入正文），模型按需调用 skill 工具加载全文；prompt_append 描述 **触发词 / 工作流 / 编排规则**，让模型在合适时机主动调用 |
| **B. 子代理 skills[]** | `agents.<name>.skills: string[]` | oracle / metis / momus 等 | 子代理默认不 advertise user skill；`skills: []` 显式列出 skill 名，omo 把这些 skill 的**正文强制前置注入**进 system prompt（schema 语义：`Skill names to inject into the agent prompt`） |

### §11.2 新增 skill 时的双轨检查

```text
对每个新 skill（按 MAINTENANCE.md §5 Step 0 通过讨论纳入）回答：
  1. 主代理 prompt_append 是否要更新？
     □ 是 → 把 trigger phrase 加进 sisyphus.prompt_append
            或在 atlas.prompt_append 字符串里的 worker 映射表追加新条目
            （例：atlas 的 `tdd (impl) | prototype (spike) | ...`）
     □ 否 → 仅 README/INSTALL 文档登记，prompt_append 不动

  2. 子代理 skills[] 是否要更新？
     □ 是 → 判断该 skill 是否被某个子代理长期依赖
            - oracle（架构咨询）→ 通常加 codebase-design 类
            - metis（gap 分析）→ 通常加 domain-modeling 类
            - momus（plan review）→ 通常加 codebase-design 类
            - 其他子代理按职责判断
            然后在 fragment 加 `agents.<xxx>.skills: ["<新 skill>"]`
     □ 否 → 子代理不装配，per-task 用 `task(load_skills=[...])` 临时注入

  3. 跑 §4 的 3 条断言
  4. 跑 `node scripts/install-prompt-append.mjs` 验证幂等
  5. grep 确认 `~/.omo/omo.jsonc` 已写入
```

### §11.3 废弃 skill 时的双轨检查

```text
对每个废弃 skill：
  1. 从 sisyphus.prompt_append / atlas.prompt_append 移除 trigger phrase 与 worker 映射项
  2. 从相关子代理的 skills[] 移除（如果之前装配过）
  3. 更新 README 弃用表 + INSTALL.md §3 跳过表
  4. 删除本地 SKILL.md 目录（保留弃用表作为历史决策可查）
  5. 跑 §4 断言更新（去掉退役 skill 的引用）+ 跑 install 脚本验证
```

### §11.4 维护位置（事实来源）

- **fragment 文件**：`config/oh-my-openagent.prompt-append.jsonc`（仓库内唯一事实来源）
- **合并目标**：`~/.omo/omo.jsonc` 的 `[opencode].agents.*`（运行 install 脚本写入）
- **merge 脚本**：`scripts/install-prompt-append.mjs`（浅比对 + fragment 字段覆盖，不动用户字段）

### §11.4.1 文档同步契约

仓库文档有三层事实来源：

| 来源 | 跟踪 | 同步时机 |
|---|---|---|
| `INSTALL.md` / `MAINTENANCE.md` / `config/*.jsonc` | git | 每次改 §5.1 / §11 必同步 |
| `docs/*.md`（Jekyll 站点镜像） | 手工 | 不强制每次同步；按 §2 监控信号 `docs/ drift` 触发批量对齐 |
| `~/.omo/omo.jsonc` | 运行时 | 跑 `install-prompt-append.mjs` 自动写入 |

### §11.5 不装配的子代理（避免越界）

| 子代理 | 不装配的原因 |
|---|---|
| `explore` / `librarian` / `multimodal-looker` | 本职是裸跑（grep / 文档搜索 / 视觉解析），加 skill 干扰本职 |
| `sisyphus-junior` | 由 `task(load_skills=[...])` per-task 注入更灵活；预设会污染 task 调度灵活性 |
| `hephaestus` | GPT-native agent，先保守不加；如未来需要工程纪律再补 `["tdd", "diagnosing-bugs"]` |

> **未来扩展 skill 时的最低动作清单**：每加 1 个 skill，至少检查 §11.2 的 5 个 checkbox 与 §11.3 的 5 个 checkbox。