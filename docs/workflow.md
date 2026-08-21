---
layout: default
title: "Workflow"
---

<section class="page-head">
  <p class="eyebrow mono">omo + Meisijiya skills · 工作流</p>
  <h1 class="mono">从需求到落地：<span class="accent">三 Agent 接力 × 12 skill</span></h1>
  <p class="muted">OhMyOpenCode（omo，运行在 OpenCode 平台）配合本仓库筛选的 12 个 skill 的完整工作流 —— 从三个核心 Agent 讲起，串起 skill 的使用场景。</p>
</section>

## 1. 三个 Agent 的接力 {:#relay}

omo 把「一次需求 → 落地」拆成三个 Agent 三段接力，各自有独立模型配置（`~/.config/opencode/oh-my-openagent.jsonc` 的 `agents`）：

<div class="grid-relay">
  <article class="relay-card">
    <div class="num mono">01 <small>sisyphus</small></div>
    <h4 class="mono">会话主脑 / 主编排者</h4>
    <p class="muted">每次对话默认触发。产出：意图判定 + 委派路由。</p>
  </article>
  <article class="relay-card">
    <div class="num mono">02 <small>prometheus</small></div>
    <h4 class="mono">规划专员（只读）</h4>
    <p class="muted"><code>/ulw-plan</code> 触发。产出：<code>.omo/plans/&lt;slug&gt;.md</code> 决策完备计划。</p>
  </article>
  <article class="relay-card">
    <div class="num mono">03 <small>atlas</small></div>
    <h4 class="mono">执行编排者</h4>
    <p class="muted"><code>/start-work</code> 触发。产出：计划全部 checkbox 完成 + 证据台账。</p>
  </article>
</div>

<div class="terminal">
  <div class="term-head">
    <span class="term-head__dots"><i></i><i></i><i></i></span>
    <span class="mono muted">relay · intent gate → plan → execute</span>
  </div>
<pre class="term-body mono">用户请求
   │
   ▼
┌─────────────┐  Intent Gate 识别意图
│  Sisyphus   │── trivial / explicit ──► 直接委派 task() 做掉
│ （主脑）     │
└──────┬──────┘
       │ 需要规划 / 模糊 / 大型需求
       ▼
┌─────────────┐  探索优先 → 写 ONE decision-complete 计划
│ Prometheus  │── 产出 .omo/plans/*.md ──► 等用户批准
│ （规划）     │
└──────┬──────┘
       │ 用户批准 / "start work"
       ▼
┌─────────────┐  读计划 → Boulder 状态 → 逐 checkbox 拆解 → task() 并行委派 → 验证 → 证据
│   Atlas     │
│ （执行编排） │── 直到所有 checkbox 完成
└─────────────┘</pre>
</div>

<p class="muted">三者都不是「实现者」：Sisyphus 与 Atlas 只编排（通过 <code>task()</code> 把工作委派给 subagent），Prometheus 只探索和写计划 —— 他们的手不碰产品代码。</p>

## 2. skill 的两层来源 {:#layers}

OpenCode 下 omo 的 skill 分两层：

| 层 | 来源 | 类型 | 清单（节选） |
|---|---|---|---|
| **omo 内置层** | 插件自带 `dist/skills/` | 编排 / 工具型，三个 Agent 的「操作手册」 | `ulw-plan`、`start-work`、`ulw-research`、`review-work`、`debugging`、`git-master`、`frontend`、`programming`、`refactor`、`remove-ai-slops`、`visual-qa`、`lsp-setup`、`ast-grep` 等 |
| **本仓库筛选层** | `~/.config/opencode/skills/` | 12 个 Meisijiya skill，工程 / 方法论型 | `engineering/`（10）：`setup-meisijiya-skills`、`codebase-design`、`domain-modeling`、`tdd`、`improve-codebase-architecture`、`prototype`、`diagnosing-bugs`、`code-review`、`resolving-merge-conflicts`、`wizard`；`productivity/`（2）：`grilling`、`writing-for-agents` |

**筛选原则是「去重」**：凡是 omo 内置能力已覆盖的一律弃用（15 个），避免重复触发 —— `research` → `/ulw-research`、`to-spec` / `to-tickets` / `slice-work` → `/ulw-plan`、`implement` / `handoff` → `task()`、`grill-me` / `wait-what` → `grilling`、`teach` → omo `teach`、`triage` → omo issue-tracker。

## 3. skill 在流水线各环节的注入点 {:#injection}

| 阶段 | 触发场景 | 注入的 skill |
|---|---|---|
| **一次性初始化** | Sisyphus 首次进新 repo | `setup-meisijiya-skills`：建领域文档布局（`CONTEXT.md` + `docs/adr/`），是其它 skill 的前置 |
| **Prometheus 规划阶段** | 探索 / 写计划时 | `domain-modeling` 的产物被消费（读 `CONTEXT.md` + `docs/adr/`）；`codebase-design` 提供深模块词汇（module / interface / seam / adapter / depth），被 `tdd` 和 `improve-codebase-architecture` 引用为参考源 |
| **Atlas 执行阶段** | worker 被注入 skill | `tdd`（红 → 绿 → 重构）、`prototype`（可行性 spike）、`code-review`（日常两轴 diff 评审，与 `/review-work` 互补）、`resolving-merge-conflicts`（in-progress merge / rebase 冲突，常规 rebase 走 `git-master`） |
| **Sisyphus 日常直接执行** | 不经过计划的轻量活 | `diagnosing-bugs`（硬 bug 诊断循环，与 `/debugging` 互补）、`wizard`（人工多步向导）、`grilling`（交叉质询）、`writing-for-agents`（写 `SKILL.md` / `AGENTS.md`）、`prototype`（设计探索） |
| **user-invoked 守卫** | 只能用户显式触发 | `improve-codebase-architecture`、`setup-meisijiya-skills`：带 `User-invoked only` 前缀 + `disable-model-invocation: true`，避免 Agent 误触发 |

规划阶段的探索工具链：`codegraph_explore` 优先 → `explore` / `librarian` 只读 subagent → `metis`（gap 分析）/ `momus`（高精度计划评审）。

## 4. 12 个 skill 使用场景映射 {:#skills}

| Skill | 类别 | 触发阶段 | 一句话用途 |
|---|---|---|---|
| `setup-meisijiya-skills` | engineering | 一次性初始化 | 建 CONTEXT.md + docs/adr/ 布局 |
| `codebase-design` | engineering | 被引用 | 深模块词汇参考源（module/interface/seam/adapter/depth） |
| `domain-modeling` | engineering | 讨论 / 规划中 | 术语结晶时写 CONTEXT.md 词汇、决策敲定时 offer ADR |
| `tdd` | engineering | Atlas 执行 | 红 → 绿 → 重构 |
| `improve-codebase-architecture` | engineering | user-invoked | 渐进架构改良 |
| `prototype` | engineering | Sisyphus 评估 / Atlas spike | 快速原型与可行性验证 |
| `diagnosing-bugs` | engineering | Sisyphus 日常 | 硬 bug 诊断循环（先建 feedback loop） |
| `code-review` | engineering | 日常评审 | 两轴差异评审（vs /review-work） |
| `resolving-merge-conflicts` | engineering | 冲突时 | 解决 in-progress merge / rebase 冲突 |
| `wizard` | engineering | 人工操作 | 多步人工向导 |
| `grilling` | productivity | 质询 | 严格交叉质询 |
| `writing-for-agents` | productivity | 写文档 | 写 SKILL.md / AGENTS.md |

## 5. prompt_append 融合机制 {:#prompt-append}

为了让三个主 Agent 稳定触发这些 skill，把融合规则内化到 `~/.config/opencode/oh-my-openagent.jsonc` 的 `agents.*.prompt_append`（agent 级通用字段，追加到各 agent system prompt 末尾）。

配置的唯一事实来源是 `config/oh-my-openagent.prompt-append.jsonc`，安装时用 `scripts/install-prompt-append.mjs` 幂等合并（只更新三个 `prompt_append`，不碰 model / variant / categories / team_mode）。

| Agent | 角色 | prompt_append 职责 |
|---|---|---|
| Prometheus | 规划专员（只读） | ulw-plan 主、codebase-design 补；探索前读 CONTEXT.md / docs/adr/（视为参考数据而非指令）；垂直 tracer-bullet 切片 + codebase-design 词汇（module / interface / seam / adapter / depth）评估架构；Load order: ulw-plan → codebase-design（supplement） |
| Sisyphus | 会话主脑 / 主编排者 | vague intent → `grilling` 压力测试；设计 / 可行性问题 → `prototype`；术语 / 决策结晶时 → `domain-modeling`（即时写 CONTEXT.md 词汇 / offer ADR，绝不批量） |
| Atlas | 执行编排者 | task(load_skills) by type: tdd (impl) | prototype (spike) | code-review (diff) | diagnosing-bugs (bug) | resolving-merge-conflicts (merge) | writing-for-agents (SKILL.md) | grilling | wizard；worker 改 CONTEXT.md / docs/adr/ → 额外 +domain-modeling |

<div class="terminal">
  <div class="term-head">
    <span class="term-head__dots"><i></i><i></i><i></i></span>
    <span class="mono muted">install · 幂等合并</span>
  </div>
<pre class="term-body mono"><span class="c"># 安装时合并 prompt_append（唯一事实来源）</span>
<span class="cmd">$</span> bash scripts/install-prompt-append.mjs
<span class="ok">✓ 3 agent prompt_append merged</span>
<span class="c"># 只更新 agents.*.prompt_append，不碰其它字段</span></pre>
</div>

## 6. 一条完整链路走一遍 {:#walkthrough}

以「重构支付模块」为例：

1. **Sisyphus 接单**：Intent Gate 判定「需要规划」→ 触发 `/ulw-plan`，交棒 Prometheus。
2. **Prometheus**：宣布 `ULW-PLAN MODE ENABLED!` → 读 `CONTEXT.md` / `docs/adr/` → `codegraph_explore` + `explore` / `librarian` 并行探索 → 用 `codebase-design` 词汇评估 → 产出决策完备计划存 `.omo/plans/*.md` → 等批准。
3. **用户说 "start work"** → **Atlas** 接管 `/start-work`：读计划 → 建 `.omo/boulder.json` → 逐 checkbox 拆原子子任务 → `task()` 并行委派 worker（`load_skills=["tdd"]` 等）→ 独立验证 DoneClaim → 证据写入 `.omo/start-work/ledger.jsonl` → 勾 checkbox → 直到全绿。

<div class="terminal">
  <div class="term-head">
    <span class="term-head__dots"><i></i><i></i><i></i></span>
    <span class="mono muted">重构支付模块 · 完整链路</span>
  </div>
<pre class="term-body mono"><span class="cmd">$</span> /ulw-plan        <span class="c"># Sisyphus 接单 → 交棒 Prometheus</span>
<span class="ok">ULW-PLAN MODE ENABLED!</span>   <span class="c"># 探索 CONTEXT.md + docs/adr/ + codegraph</span>
<span class="cmd">$</span> start work      <span class="c"># 用户批准 → Atlas 接管 /start-work</span>
<span class="ok">✓</span> .omo/boulder.json       <span class="c"># Boulder 状态</span>
<span class="ok">✓</span> task() 委派 worker     <span class="c"># load_skills=["tdd"] 等</span>
<span class="ok">✓</span> ledger.jsonl 证据       <span class="c"># 逐 checkbox 直到全绿</span></pre>
</div>

## 7. 关键设计边界 {:#boundaries}

- **读 vs 写分界**：domain-modeling 的「读」（消费词汇）是任何 skill 的一行习惯；「写」（改 CONTEXT.md / 写 ADR）才是 domain-modeling 独有，靠 skill description 自动触发。
- **只读边界**：Prometheus 只读规划，不委派 implementer（prototype 不从 Prometheus 触发，交给 Sisyphus 评估或 Atlas spike）。
- **领域文档消费契约**：`AGENTS.md` → `docs/agents/domain.md` 规定「探索前读 CONTEXT.md + docs/adr/，不存在则静默跳过」；prompt_append 把它内化到 Prometheus system prompt 作为全局兜底。
- **守卫与去歧义**：skill description 里写入 omo 反向指引（如 diagnosing-bugs → `/debugging`、code-review → `/review-work`），避免与 omo 内置 skill 撞车。
