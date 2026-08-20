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

## §5. 添加新 skill Playbook

1. 在 `mattpocock-skills/omo` 分支 `git merge origin/main`（拉最新）
2. `ls mattpocock-skills/skills/<bucket>/<新skill>/SKILL.md`
3. 看 frontmatter 含 `disable-model-invocation: true`：
   - 是 → 加守卫前缀 `User-invoked only — do not invoke automatically. `（保留原引号风格）
   - 否 → 不动 description
4. `grep '\.scratch/\|\.out-of-scope/' SKILL.md`，有则路径替换为 `.omo/scratch` / `.omo/out-of-scope`
5. `git commit -m "feat(skills): add <新 skill> with guard/path fixes"`
6. 更新 INSTALL.md 能力对照表（加一行）
7. 更新 README.md 采纳清单（如纳入）
8. 跑 §4 的 4 个断言

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
