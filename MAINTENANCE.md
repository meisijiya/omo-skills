# MAINTENANCE — omo-skills 长期维护手册

> 面向：用户本人 / Agent / 团队成员。按手册逐节执行即可，无需额外约定。

---

## §1. 仓库拓扑（前置必读）

```
omo-skills/
├── skills/                 ← 微调后的 13 个 skill（产物，push 到 GitHub，INSTALL.md 安装源）
├── mattpocock-skills/      ← 本地 fork（已脱离上游，仅历史参考，不入远端）
├── README.md               ← 人读概览
├── INSTALL.md              ← Agent 询问后安装指引
├── MAINTENANCE.md          ← 本文件（维护手册）
└── .omo/                   ← 工作状态（不入版本控制）
```

- **`skills/`（产物）**：微调后可直接 `cp -r` 给 Agent 安装的 skill 目录。push 到 GitHub。
- **`mattpocock-skills/`（开发源）**：本地 fork，独立 git 仓库，跟踪上游 `mattpocock/skills`，本地分支为 `omo`。**不入 GitHub**，在 `.gitignore` 排除。**已脱离上游**，仅历史参考，不参与同步。
- **同步关系**：新 skill 直接在 `skills/<bucket>/<name>/` 下新建，按 §10 流程维护。
- **`mattpocock-skills/`** 内部 `git log omo ^origin/main -- skills/engineering/ skills/productivity/` 应只有 2 个本地 commit：
  - `feat(skills): prefix user-invoked guard on 14 skill descriptions`
  - `refactor(skills): route temp artifacts (.scratch/.out-of-scope) into .omo/`
- **不要把 `mattpocock-skills/` 加为 submodule**（plan 已禁止，保持独立仓库 + `.gitignore` 排除）。

---

## §2. 监控信号（什么时候要维护）

| 信号 | 检测命令 | 触发维护场景 |
|---|---|---|
| 上游有新 commit | `git -C mattpocock-skills fetch origin && git -C mattpocock-skills log --oneline origin/main ^omo` | 上游有未合入提交 |
| 上游有 breaking PR | `gh pr list --repo mattpocock/skills --state open --json number,title \| jq -r '.[] \| select(.title \| test("flatt\|flatten\|rename\|break\|major\|agent plugins"; "i")) \| "\(.number) \(.title)"'` | 上游结构/约定变更（如 PR #807 Flatten + Agent Plugins 1.0、PR #876 CONTEXT→GLOSSARY 重命名）→ 触发 §10 Step0 深度讨论 |
| 守卫失效 | 触发某 skill 后模型没识别 user-invoked | 守卫被覆盖 |
| INSTALL.md 漏 Agent | 新 Agent 上线但 INSTALL.md 未加章节 | 能力缺口 |
| 路径残留 | `grep -rn '\.scratch/\|\.out-of-scope/' mattpocock-skills/skills/*/SKILL.md \| grep -v '.omo/'` 非空 | 路径未统一 |

---

## §3. 上游同步 Playbook（已脱离上游，仅历史参考，不需执行）

> **本节已废弃**。仓库已脱离 `mattpocock-skills/` 上游 fork（见 §10），不再有 fetch / rebase / merge 上游流程。保留本节仅为历史参考。如需了解过去如何从上游同步，请按以下流程「了解思路」即可，**不要执行**。

```bash
cd mattpocock-skills      # 假设外层 omo-skills/ 已 clone 到当前工作目录
git fetch origin
git rebase origin/main

# 冲突处理（按文件类型）
# A. description 冲突：保留我们的守卫前缀 + 上游新 description
#    conflict block 形如:
#    <<<<<<<< HEAD (上游新 description)
#    description: 新的 description...
#    ========
#    description: User-invoked only — do not invoke automatically. <旧 description>
#    >>>>>>>> feat(skills): prefix user-invoked guard on 14 skill descriptions
#    → 取 HEAD 行的值，在最前加守卫前缀
#
# B. 路径冲突：保留我们的 .omo/ 前缀
#    <<<<<<<< HEAD (上游新路径)
#    mkdir -p docs/adr/...
#    ========
#    mkdir -p .omo/scratch/adr/...
#    >>>>>>> refactor(skills): route temp artifacts...
#    → 保留 HEAD 新路径，加 .omo/ 前缀
#
# C. 其它冲突（正文 / frontmatter 其它字段）：上游优先，我们没动过

git add <冲突文件>
git rebase --continue
```

> **push 后增量**：本仓库已 push 到 `https://github.com/meisijiya/omo-skills.git`，`mattpocock-skills/omo` 分支 rebase 后需 `git push --force-with-lease` 同步远端。`--force-with-lease` 比 `--force` 安全（只在远端没有新提交时才强推）。

---

## §4. 变更后必跑验证（关键 — 不跑就别继续）

```bash
cd omo-skills/      # 产物仓库根

# 断言 1: 13 个 SKILL.md YAML 解析（engineering 11 + productivity 2）
python3 -c "
import glob, yaml, sys
files = sorted(glob.glob('skills/engineering/*/SKILL.md')) + sorted(glob.glob('skills/productivity/*/SKILL.md'))
if len(files) != 13:
    print(f'FAIL: expected 13 SKILL.md, got {len(files)}')
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

# 断言 2: 2 个 user-invoked 守卫 + 字段保留
for f in skills/engineering/{improve-codebase-architecture,setup-meisijiya-skills}/SKILL.md; do
  grep -q 'User-invoked only — do not invoke automatically' "$f" || echo "FAIL_GUARD $f"
  grep -q 'disable-model-invocation: true' "$f" || echo "FAIL_FIELD $f"
done

# 断言 3: 11 个 model-invoked 零守卫
for f in skills/engineering/{codebase-design,domain-modeling,tdd,resolving-merge-conflicts,wizard,prototype,code-review,diagnosing-bugs,slice-work}/SKILL.md skills/productivity/{grilling,writing-for-agents}/SKILL.md; do
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
   - 是否要新建 scratch 笔记？写到 `.omo/scratch/`
2. **路径分类**：对照 §9 把每份文档归到「提交类」或「临时态」
3. **冲突检查**：与现有 skill 的 description 是否撞车？路径是否复用？
4. **联动更新**：INSTALL.md 能力对照表 / README.md 清单是否要改？

### Step 1. 新建 skill 目录

新 skill 直接在 `skills/<bucket>/<name>/` 下新建（`mkdir -p skills/<bucket>/<name>/agents`），无需从 `mattpocock-skills/` 拉取（已脱离上游，见 §10）。

### Step 2. 应用守卫与路径

检查 `skills/<bucket>/<新skill>/SKILL.md`，按 §9 讨论结果执行：

- user-invoked（前缀 `User-invoked only — do not invoke automatically. `，保留 `disable-model-invocation: true` 字段）
- model-invoked（不动 description）
- 含 `.scratch/.out-of-scope` 字面量 → 替换为工作区根直接子目录 `.scratch/` / `.out-of-scope/`（无 `.omo/` 前缀）

### Step 3. 提交

`git commit -m "feat(skills): add <新 skill> with guard/path fixes"`（按 Step 0 讨论结果可能多 commit）。

### Step 4. 更新外层文档

按 Step 0 讨论结果更新 INSTALL.md / README.md。

### Step 5. 验证

跑 §4 的 3 个断言。

---

## §6. 添加新 Agent Playbook（INSTALL.md）

1. 在 INSTALL.md 现有 `## Xiaomi mimocode` 章节后加 `## <新 Agent>`
2. 加目录映射（必须先现场 `ls` 检测或问用户，不硬编码！）
3. 在"询问装到哪个 Agent"流程中加选项
4. 在能力对照表"装到 X 时默认 Y"行加一行
5. 在 INSTALL.md 末尾"已验证装机清单"表里补一行
6. 跑 INSTALL.md 字符串断言（见 Todo 4 acceptance criteria）
7. `git commit -m "docs(install): add <新 Agent> install chapter"`

---

## §7. 退役/废弃 Playbook

1. 确认退役：与用户讨论退役理由（已脱离上游，无 `mattpocock-skills fetch` 检测步骤）
2. 从 INSTALL.md 能力对照表删除该行
3. 从 README.md 清单删除该行（无论采纳还是备用）
4. `git commit -m "docs: retire <skill>"`
5. **不删**本地 SKILL.md（保留历史；但 INSTALL.md 不再推荐）

---

## §8. 故障排查速查

| 现象 | 可能原因 | 检查命令 |
|---|---|---|
| Skill 未被 Agent 发现 | 守卫未生效 / disable-model-invocation 字段丢失 | `grep 'User-invoked only' <SKILL>` + `grep 'disable-model-invocation' <SKILL>` |
| Skill 触发噪音 | 守卫描述太弱 / model-invoked skill 描述里有 user-invoked 词 | `grep -E 'When\|Use when'` |
| INSTALL.md 装错目录 | 询问流程被跳过 | INSTALL.md §4 流程是否被 Agent 跳过 |
| rebase 失败 | 上游改了同一 description 行 | 看 conflict block 类型 A |

## §9. 文档落地路径分类（讨论参考，非自动化）

> **核心立场**：这份分类是**讨论的脚手架**，**不是自动执行规则**。新引入 skill 时拿这份表对照，逐份文档讨论归类，而不是让脚本替我们判断。
>
> 自动化可不靠谱 —— Agent 与人一起讨论出来的归类才能长期维护。
>
> **历史说明**：早期 omo 专属微调曾用 `.omo/scratch/` / `.omo/out-of-scope/` 前缀（与 omo 的 `.omo/` 工作目录一致）。为还原上游原路径，已在 2026-08 issue #1 中将临时态路径恢复为工作区根直接子目录 `.scratch/` / `.out-of-scope/`。

### §9.1 两类路径

**A. 提交类（final / 保留 / decision）** —— 上游原路径，**禁止改动**：

| 路径 | 含义 | 权威源 |
|---|---|---|
| `docs/adr/` | Architecture Decision Records | `setup-meisijiya-skills/SKILL.md` |
| `CONTEXT.md` | 项目主上下文（仓库根级） | `setup-meisijiya-skills/SKILL.md` |
| `CONTEXT-MAP.md` | 上下文导航图（仓库根级） | `setup-meisijiya-skills/SKILL.md` |
| `docs/agents/` | Agent 角色定义 | 各 skill 引用的元数据 |

**B. 临时态（working / scratch / out-of-scope）** —— 上游原路径，工作区根直接子目录（与 omo / 上游双方一致）：

| 路径 | 含义 | 替换关系 |
|---|---|---|
| `.scratch/` | 工作草稿 | 上游原路径，**未加前缀** |
| `.out-of-scope/` | 范围外工作笔记 | 上游原路径，**未加前缀** |

### §9.2 讨论时的判定问题

新引入文档时，逐份对照以下问题决定归类：

| 判定问题 | → 提交类 | → 临时态 |
|---|---|---|
| 内容是 final 决策吗？ | ✅ `docs/adr/` | ❌ `.scratch/` |
| 是项目级上下文吗？ | ✅ `CONTEXT.md` / `CONTEXT-MAP.md` | ❌ |
| 是 Agent 角色定义吗？ | ✅ `docs/agents/` | ❌ |
| 是工作笔记/草稿吗？ | ❌ | ✅ `.scratch/` |
| 是范围外备查吗？ | ❌ | ✅ `.out-of-scope/` |

### §9.3 上游原路径的"权威源"

- 提交类主权威：`skills/engineering/setup-meisijiya-skills/SKILL.md`
- 临时态细则：`mattpocock-skills/skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md`（**仅 mattpocock-skills/ 历史参考**）
- 临时态范围外细则：`mattpocock-skills/skills/engineering/triage/OUT-OF-SCOPE.md`（**仅 mattpocock-skills/ 历史参考**）

### §9.4 边界争议处理（讨论时参考）

如果一份文档跨两类（如既记录决策又含工作笔记）：

1. **优先拆为两份**：决策摘要 → `docs/adr/`；详细笔记 → `.scratch/xxx.md`，并在 ADR 中引用
2. **次选**：在 `docs/adr/` 中加 `## working notes` 段引用 `.scratch/xxx`
3. **最次选**：保留在原 SKILL.md 正文里（同文件内多 section），但加路径前缀

### §9.5 已知裸路径（历史参考 — 仅 mattpocock-skills/）

| 文件 | 命中数 | 状态 |
|---|---|---|
| `setup-matt-pocock-skills/issue-tracker-local.md` | 多处 `.scratch/` | **仅 mattpocock-skills/ 历史参考**（无前缀 = 工作区根直接子目录） |
| `triage/OUT-OF-SCOPE.md` | 多处 `.out-of-scope/` | **仅 mattpocock-skills/ 历史参考**（无前缀） |
| `triage/AGENT-BRIEF.md` | 多处 `.out-of-scope/` | **仅 mattpocock-skills/ 历史参考**（不在迁移范围） |

> 已脱离上游：`skills/` 为唯一来源，以上条目仅指向 `mattpocock-skills/` 历史目录，不参与同步，无监控脚本。

---

## §10 skill 同步与新建流程（已脱离上游）

**状态**：本仓库已脱离 `mattpocock-skills` 上游 fork，`skills/` 是唯一来源。新 skill 在 `skills/<bucket>/<name>/` 下新建，按 §5 Step 0 讨论后再决定是否纳入。

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

更新 `README.md` 采纳表、`INSTALL.md` §2 与 §5 复制命令、`MAINTENANCE.md` §4 断言列表。

### 不再有 mattpocock-skills fetch

仓库已脱离上游 fork。不再有 `mattpocock-skills fetch origin` + `rebase` 同步流程。`mattpocock-skills/` 本地目录保留作历史参考，`.gitignore` 已排除。
