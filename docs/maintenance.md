---
layout: default
title: "Maintenance"
---

<section class="page-head">
  <p class="eyebrow mono">长期维护</p>
  <h1 class="mono">何时维护 + 如何引入新 skill</h1>
  <p class="muted">面向：用户本人 / Agent / 团队成员。按手册逐节执行即可，无需额外约定。本仓库专为 OhMyOpenCode（omo）服务，已脱离任何上游 fork；<code>skills/</code> 是唯一来源。</p>
</section>

## 仓库拓扑 {#topology}

```
omo-skills/
├── skills/                 ← 微调后的 16 个 skill（产物，push 到 GitHub，INSTALL.md 安装源）
│   ├── engineering/        ← 12 个工程 skill
│   └── productivity/       ← 4 个产出/写作 skill
├── README.md               ← 人读概览
├── INSTALL.md              ← Agent 询问后安装指引
├── MAINTENANCE.md          ← 维护手册源文件（本页为其 web 版）
└── .omo/                   ← 工作状态（不入版本控制）
```

- **`skills/`（产物）**：微调后可直接 `cp -r` 给 omo 安装的 skill 目录。push 到 GitHub。
- **同步关系**：新 skill 直接在 `skills/<bucket>/<name>/` 下新建，按 §5 流程维护。
- **`mattpocock-skills/` 已删除**：仓库早期 fork 自 `mattpocock/mattpocock-skills`，但早已脱离上游同步（**不再 fetch / rebase**），fork 目录也不再保留。所有 skill 改动都直接在 `skills/` 下进行。

## 监控信号（什么时候要维护） {#monitoring}

| 信号 | 检测命令 | 触发维护场景 |
|---|---|---|
| 守卫失效 | 触发某 skill 后模型没识别 user-invoked | 守卫被覆盖 |
| INSTALL.md 漏目录 | 新安装环境但 INSTALL.md §1 未列 | 能力缺口 |
| 路径残留 | `grep -rn '\.scratch/\|\.out-of-scope/' skills/*/SKILL.md` 非空且路径未在 §9.1 提交类清单中 | 路径未统一 |

> 早期监控信号包含的 `mattpocock-skills fetch` / `rebase 冲突` / `path 同步` 已全部废止——仓库不依赖上游。

## 变更后必跑验证（3 个断言） {#assertions}

任何 `FAIL` 立即停下来调查。

**断言 1：16 个 SKILL.md YAML 解析（engineering 12 + productivity 4）**

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
```

**断言 2：4 个 user-invoked 守卫 + 字段保留**

```bash
# 断言 2: 4 个 user-invoked 守卫 + 字段保留
for f in skills/engineering/{improve-codebase-architecture,setup-meisijiya-skills}/SKILL.md skills/productivity/{teach,to-questionnaire}/SKILL.md; do
  grep -q 'User-invoked only — do not invoke automatically' "$f" || echo "FAIL_GUARD $f"
  grep -q 'disable-model-invocation: true' "$f" || echo "FAIL_FIELD $f"
done
```

**断言 3：12 个 model-invoked 零守卫（slice-work 已弃用，从列表移除；新增 architecture-decision-records / api-and-interface-design）**

```bash
# 断言 3: 12 个 model-invoked 零守卫（slice-work 已弃用，从列表移除；新增 architecture-decision-records / api-and-interface-design）
for f in skills/engineering/{codebase-design,domain-modeling,tdd,resolving-merge-conflicts,wizard,prototype,code-review,diagnosing-bugs,architecture-decision-records,api-and-interface-design}/SKILL.md skills/productivity/{grilling,writing-for-agents}/SKILL.md; do
  grep -q 'User-invoked only' "$f" && echo "FAIL_EXTRA $f"
done
```

## 文档落地路径分类（讨论参考，非自动化） {#paths}

> **核心立场**：这份分类是**讨论的脚手架**，**不是自动执行规则**。新引入 skill 时拿这份表对照，逐份文档讨论归类，而不是让脚本替我们判断。自动化可不靠谱——Agent 与人一起讨论出来的归类才能长期维护。

**A. 提交类（final / 保留 / decision）** —— 上游原路径，**禁止改动**：

| 路径 | 含义 | 权威源 |
|---|---|---|
| `docs/adr/` | Architecture Decision Records（目录 bootstrap 权威 = 创建布局；运行时写入权威 = `architecture-decision-records/SKILL.md`） | `setup-meisijiya-skills/SKILL.md`（bootstrap） + `architecture-decision-records/SKILL.md`（写入） |
| `CONTEXT.md` | 项目主上下文（仓库根级） | `setup-meisijiya-skills/SKILL.md` |
| `CONTEXT-MAP.md` | 上下文导航图（仓库根级） | `setup-meisijiya-skills/SKILL.md` |
| `docs/agents/` | Agent 角色定义 | 各 skill 引用的元数据 |
| `DESIGN.md` | UI 设计规范（仓库根级，与 `CONTEXT.md` 平级） | 由 omo 内置 `/frontend` 写入 |

**B. 临时态（working / scratch / out-of-scope）** —— 工作区根直接子目录（与 omo / 上游双方一致）：

| 路径 | 含义 | 替换关系 |
|---|---|---|
| `.scratch/` | 工作草稿 | 工作区根直接子目录（无 `.omo/` 前缀） |
| `.out-of-scope/` | 范围外工作笔记 | 工作区根直接子目录（无 `.omo/` 前缀） |

**判定问题**：内容是 final 决策吗？→ `docs/adr/`；是项目级上下文吗？→ `CONTEXT.md` / `CONTEXT-MAP.md`；是 Agent 角色定义吗？→ `docs/agents/`；是工作笔记/草稿吗？→ `.scratch/`；是范围外备查吗？→ `.out-of-scope/`。

**边界争议**：跨两类文档 → 优先拆为两份（决策摘要 → `docs/adr/`，详细笔记 → `.scratch/xxx.md` 并在 ADR 中引用）；次选在 ADR 中加 `## working notes` 段引用；最次选保留在 SKILL.md 正文并加路径前缀。

## Skill 引入规则（讨论流程） {#intro}

> **核心原则**：新引入 skill 时，**先讨论、再决定、最后执行**。不靠自动化分配路径，靠人/Agent 对照 §9 把每份新文档摊开讨论归类。

<aside class="mono accent">
  <strong>Step 0. 讨论（必走 — 不跳过）</strong><br>
  与用户讨论以下议题，把决策写到 <code>.omo/notepads/&lt;plan&gt;/decisions.md</code>（同当前 plan 流程）：
  <ol>
    <li><strong>文档产出清单</strong>：这个新 skill 会涉及哪些文档？<code>SKILL.md</code>（必有）、<code>references/*.md</code>、是否新建 ADR（<code>docs/adr/</code>）、是否新建 Agent 角色（<code>docs/agents/</code>）、是否新建 scratch 笔记（<code>.scratch/</code>）</li>
    <li><strong>路径分类</strong>：对照 §9 把每份文档归到「提交类」或「临时态」</li>
    <li><strong>冲突检查</strong>：与现有 skill 的 description 是否撞车？与 omo 内置 skill（<code>ulw-plan</code> / <code>/debugging</code> / <code>/review-work</code> / <code>task()</code> / <code>codegraph_*</code> 等）是否撞车？路径是否复用？</li>
    <li><strong>联动更新</strong>：INSTALL.md 能力对照表 / README.md 清单是否要改？</li>
  </ol>
</aside>

**Step 1. 新建 skill 目录**：直接在 `skills/<bucket>/<name>/` 下新建（`mkdir -p skills/<bucket>/<name>/agents`），无需 fork 任何上游。

**Step 2. 应用守卫与路径**：user-invoked → 前缀 `User-invoked only — do not invoke automatically. `，保留 `disable-model-invocation: true` 字段；model-invoked → 不动 description，若与 omo 内置撞触发词加去歧义短语；含 `.scratch/.out-of-scope` 字面量 → 替换为工作区根直接子目录（无 `.omo/` 前缀）。

**Step 3. 提交**：`git commit -m "feat(skills): add <新 skill> with guard/path fixes"`（按 Step 0 讨论结果可能多 commit）。

**Step 4. 更新外层文档**：按 Step 0 讨论结果更新 INSTALL.md / README.md。

**Step 5. 验证**：跑 §4 的 3 个断言。

## skill 新建流程（已脱离上游 fork） {#new-skill}

**状态**：本仓库已脱离任何上游 fork，`skills/` 是唯一来源。新 skill 在 `skills/<bucket>/<name>/` 下新建，按 §5 Step 0 讨论后再决定是否纳入。

1. **Step 0. 讨论**：新 skill 引入必须先讨论（见 §5）。讨论通过后再执行 Step 1-3。
2. **Step 1. 新建 skill 目录**：

```bash
mkdir -p skills/engineering/<new-skill>/agents
# 写 SKILL.md（带 frontmatter）+ agents/openai.yaml
```

3. **Step 2. 跑断言**：参见 §4 的 3 条断言（每个目录都含 SKILL.md / user-invoked 守卫 / model-invoked 零守卫）。
4. **Step 3. 更新文档**：更新 `README.md` 采纳表、`INSTALL.md §2 与 §5 复制命令`、`MAINTENANCE.md §4` 断言列表。

> **已废止：上游同步**。仓库不再依赖任何上游 fork。无 `fetch` / `rebase` / `merge` 流程。`mattpocock-skills/` 目录已删除。

## 退役 / 废弃流程 {#retire}

1. **确认退役**：与用户讨论退役理由
2. 从 INSTALL.md 能力对照表删除该行
3. 从 README.md 清单删除该行（无论采纳还是备用）
4. `git commit -m "docs: retire <skill>"`
5. **删除**本地 SKILL.md（保留弃用表作为历史决策可查）
6. 更新 MAINTENANCE.md §4 断言列表（去掉退役 skill 的引用）

## 故障排查速查 {#troubleshooting}

| 现象 | 可能原因 | 检查命令 |
|---|---|---|
| Skill 未被 Agent 发现 | 守卫未生效 / `disable-model-invocation` 字段丢失 | `grep 'User-invoked only' <SKILL>` + `grep 'disable-model-invocation' <SKILL>` |
| Skill 触发噪音 | 守卫描述太弱 / model-invoked skill 描述里有 user-invoked 词 / 与 omo 内置撞车 | `grep -E 'When\|Use when'` + 比对 omo `dist/skills/` 内置 description |
| INSTALL.md 装错目录 | 询问流程被跳过 | INSTALL.md §4 流程是否被 Agent 跳过 |