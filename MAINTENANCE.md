# MAINTENANCE — omo-skills 长期维护手册

> 面向：用户本人 / Agent / 团队成员。按手册逐节执行即可，无需额外约定。

---

## §1. 仓库拓扑（前置必读）

```
omo-skills/
├── mattpocock-skills/   ← 独立 git 仓库 @ omo 分支（本地微调）
├── README.md            ← 人读概览
├── INSTALL.md           ← Agent 询问后安装指引
├── MAINTENANCE.md       ← 本文件（维护手册）
└── .omo/                ← 工作状态（不入版本控制）
```

- `mattpocock-skills/` 是一个独立 git 仓库，跟踪上游 `mattpocock/skills`，本地分支为 `omo`。
- `mattpocock-skills/` 内部 `git log omo ^origin/main -- skills/engineering/ skills/productivity/` 应只有 2 个本地 commit：
  - `feat(skills): prefix user-invoked guard on 14 skill descriptions`
  - `refactor(skills): route temp artifacts (.scratch/.out-of-scope) into .omo/`
- **不 push 到任何远程**（本地 fork，演进靠 `rebase`）。
- **不要把 `mattpocock-skills/` 加为 submodule**（plan 已禁止，保持独立仓库 + `.gitignore` 排除）。

---

## §2. 监控信号（什么时候要维护）

| 信号 | 检测命令 | 触发维护场景 |
|---|---|---|
| 上游有新 commit | `git -C mattpocock-skills fetch origin && git -C mattpocock-skills log --oneline origin/main ^omo` | 上游有未合入提交 |
| 守卫失效 | 触发某 skill 后模型没识别 user-invoked | 守卫被覆盖 |
| INSTALL.md 漏 Agent | 新 Agent 上线但 INSTALL.md 未加章节 | 能力缺口 |
| 路径残留 | `grep -rn '\.scratch/\|\.out-of-scope/' mattpocock-skills/skills/*/SKILL.md \| grep -v '.omo/'` 非空 | 路径未统一 |

---

## §3. 上游同步 Playbook（每周/双周）

```bash
cd /home/ljh2923/opencode-project/omo-skills/mattpocock-skills
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

## §4. rebase 后必跑验证（关键 — 不跑就别继续）

```bash
cd /home/ljh2923/opencode-project/omo-skills

# 断言 1: 25 个 SKILL.md YAML 解析
python3 -c "
import glob, yaml, sys
files = sorted(glob.glob('mattpocock-skills/skills/engineering/*/SKILL.md')) + sorted(glob.glob('mattpocock-skills/skills/productivity/*/SKILL.md'))
errs = []
for f in files:
    try:
        fm = open(f).read().split('---',2)[1]
        d = yaml.safe_load(fm)
        if not d.get('name') or not d.get('description'): errs.append(f)
    except Exception as e: errs.append(f'{f}: {e}')
sys.exit(1 if errs else 0)
"

# 断言 2: 14 个守卫 + 字段保留
for f in mattpocock-skills/skills/engineering/{grill-with-docs,implement,improve-codebase-architecture,setup-matt-pocock-skills,to-spec,to-tickets,triage,wayfinder,ask-matt}/SKILL.md mattpocock-skills/skills/productivity/{grill-me,teach,to-questionnaire,wait-what,handoff}/SKILL.md; do
  grep -q 'User-invoked only — do not invoke automatically' "$f" || echo "FAIL_GUARD $f"
  grep -q 'disable-model-invocation: true' "$f" || echo "FAIL_FIELD $f"
done

# 断言 3: 11 个 model-invoked 零守卫
for f in mattpocock-skills/skills/engineering/{codebase-design,domain-modeling,tdd,resolving-merge-conflicts,wizard,prototype,code-review,diagnosing-bugs,research}/SKILL.md mattpocock-skills/skills/productivity/{grilling,writing-for-agents}/SKILL.md; do
  grep -q 'User-invoked only' "$f" && echo "FAIL_EXTRA $f"
done

# 断言 4: 5 个路径文件
grep -E '\.omo/scratch|\.omo/out-of-scope' mattpocock-skills/skills/engineering/{ask-matt,code-review,setup-matt-pocock-skills,to-tickets,triage}/SKILL.md
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

### Step 1. 拉最新

在 `mattpocock-skills/omo` 分支 `git merge origin/main`（上游新增场景）。

### Step 2. 应用守卫与路径

`ls mattpocock-skills/skills/<bucket>/<新skill>/SKILL.md`，按 §9 讨论结果执行：

- user-invoked（前缀 `User-invoked only — do not invoke automatically. `，保留 `disable-model-invocation: true` 字段）
- model-invoked（不动 description）
- 含 `.scratch/.out-of-scope` 字面量 → 替换为 `.omo/` 前缀

### Step 3. 提交

`git commit -m "feat(skills): add <新 skill> with guard/path fixes"`（按 Step 0 讨论结果可能多 commit）。

### Step 4. 更新外层文档

按 Step 0 讨论结果更新 INSTALL.md / README.md。

### Step 5. 验证

跑 §4 的 4 个断言。

---

## §6. 添加新 Agent Playbook（INSTALL.md）

1. 在 INSTALL.md 现有 `## MiniMax mcode` 章节后加 `## <新 Agent>`
2. 加目录映射（必须先现场 `ls` 检测或问用户，不硬编码！）
3. 在"询问装到哪个 Agent"流程中加选项
4. 在能力对照表"装到 X 时默认 Y"行加一行
5. 跑 INSTALL.md 字符串断言（见 Todo 4 acceptance criteria）
6. `git commit -m "docs(install): add <新 Agent> install chapter"`

---

## §7. 退役/废弃 Playbook

1. 上游删除某 skill：`git -C mattpocock-skills fetch && git -C mattpocock-skills log --diff-filter=D --name-only --pretty=format: origin/main ^omo`
2. 从 INSTALL.md 能力对照表删除该行
3. 从 README.md 清单删除该行（无论采纳还是备用）
4. `git commit -m "docs: retire <skill> (deleted upstream)"`
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

### §9.1 两类路径

**A. 提交类（final / 保留 / decision）** —— 上游原路径，**禁止改动**：

| 路径 | 含义 | 权威源 |
|---|---|---|
| `docs/adr/` | Architecture Decision Records | `setup-matt-pocock-skills/SKILL.md` |
| `CONTEXT.md` | 项目主上下文（仓库根级） | `setup-matt-pocock-skills/SKILL.md` |
| `CONTEXT-MAP.md` | 上下文导航图（仓库根级） | `setup-matt-pocock-skills/SKILL.md` |
| `docs/agents/` | Agent 角色定义 | 各 skill 引用的元数据 |

**B. 临时态（working / scratch / out-of-scope）** —— 上游原路径有 `.scratch/` / `.out-of-scope/`，plan 已统一前缀为 `.omo/`：

| 路径 | 含义 | 替换关系 |
|---|---|---|
| `.omo/scratch/` | 工作草稿 | 原 `.scratch/` → `.omo/scratch/` |
| `.omo/out-of-scope/` | 范围外工作笔记 | 原 `.out-of-scope/` → `.omo/out-of-scope/` |

### §9.2 讨论时的判定问题

新引入文档时，逐份对照以下问题决定归类：

| 判定问题 | → 提交类 | → 临时态 |
|---|---|---|
| 内容是 final 决策吗？ | ✅ `docs/adr/` | ❌ `.omo/scratch/` |
| 是项目级上下文吗？ | ✅ `CONTEXT.md` / `CONTEXT-MAP.md` | ❌ |
| 是 Agent 角色定义吗？ | ✅ `docs/agents/` | ❌ |
| 是工作笔记/草稿吗？ | ❌ | ✅ `.omo/scratch/` |
| 是范围外备查吗？ | ❌ | ✅ `.omo/out-of-scope/` |

### §9.3 上游原路径的"权威源"

- 提交类主权威：`mattpocock-skills/skills/engineering/setup-matt-pocock-skills/SKILL.md`
- 临时态细则：`mattpocock-skills/skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md`
- 临时态范围外细则：`mattpocock-skills/skills/engineering/triage/OUT-OF-SCOPE.md`

### §9.4 边界争议处理（讨论时参考）

如果一份文档跨两类（如既记录决策又含工作笔记）：

1. **优先拆为两份**：决策摘要 → `docs/adr/`；详细笔记 → `.omo/scratch/xxx.md`，并在 ADR 中引用
2. **次选**：在 `docs/adr/` 中加 `## working notes` 段引用 `.omo/scratch/xxx`
3. **最次选**：保留在原 SKILL.md 正文里（同文件内多 section），但加路径前缀

### §9.5 已知裸路径（一次性迁移清单）

| 文件 | 命中数 | 状态 |
|---|---|---|
| `setup-matt-pocock-skills/issue-tracker-local.md` | 8 处 `.scratch/` | 待迁移（`sed 's\|\.scratch/\|.omo/scratch/\|g'`） |
| `triage/OUT-OF-SCOPE.md` | 9 处 `.out-of-scope/` | 待迁移（`sed 's\|\.out-of-scope/\|.omo/out-of-scope/\|g'`） |
| `triage/AGENT-BRIEF.md` | 8 处 `.out-of-scope/` | **历史快照豁免**（不在迁移范围） |

迁移命令（一次性）：
```bash
cd mattpocock-skills
sed -i 's|\.scratch/|\.omo/scratch/|g' skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md
sed -i 's|\.out-of-scope/|\.omo/out-of-scope/|g' skills/engineering/triage/OUT-OF-SCOPE.md
git add skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md skills/engineering/triage/OUT-OF-SCOPE.md
git commit -m "refactor(docs): migrate remaining scratch/out-of-scope refs into .omo/"
```

迁移后跑 §4 验证，零 FAIL 才算迁移完成。
