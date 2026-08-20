---
layout: default
title: "omo-skills — Matt Pocock 工程 skill 仓库"
description: >-
  omo 适配的 Matt Pocock 工程 skill 仓库在线指南 —— 12 个采纳 skill、
  三 Agent 接力工作流、4 步安装与维护手册。
---

<section class="hero">
  <p class="eyebrow mono">omo · 工程 skill 仓库</p>
  <h1 class="mono">Matt Pocock 的工程 skill，<br><span style="color: var(--accent);">为 omo 量身筛选。</span></h1>
  <p class="hero-subtitle" style="color: var(--muted);">12 个工程 / 产出 skill · 三 Agent 接力工作流 · 4 步安装即用 · 长期维护手册。</p>
  <div class="ctas">
    <a class="btn btn-primary mono" href="{{ '/skills/' | relative_url }}">→ 浏览 12 skill</a>
    <a class="btn btn-ghost mono" href="{{ '/install/' | relative_url }}">4 步安装</a>
  </div>
</section>

<section class="skills-snapshot">
  <header class="section-head">
    <h2 class="mono">skills · 12 采纳</h2>
    {% assign eng_count = site.data.skills | where: "category", "engineering" | size %}
    {% assign prod_count = site.data.skills | where: "category", "productivity" | size %}
    <span class="count mono">{{ eng_count }} engineering · {{ prod_count }} productivity</span>
  </header>
  <div class="grid-skills">
    {% for skill in site.data.skills %}
      {% include skill-card.html
          name=skill.name
          tag=skill.tag
          desc=skill.desc
          category=skill.category
          file=skill.file %}
    {% endfor %}
  </div>
</section>

<section class="relay">
  <header class="section-head">
    <h2 class="mono">三 Agent 接力</h2>
    <span class="count mono">用户 → Sisyphus → Prometheus → Atlas</span>
  </header>
  <div class="grid-relay">
    <article class="relay-card">
      <div class="num mono">01 <small>sisyphus</small></div>
      <h4 class="mono">主脑 / 主编排</h4>
      <p style="color: var(--muted);">意图判定 + 委派路由。每次对话默认入口。</p>
    </article>
    <article class="relay-card">
      <div class="num mono">02 <small>prometheus</small></div>
      <h4 class="mono">规划专员（只读）</h4>
      <p style="color: var(--muted);"><code>/ulw-plan</code> 写决策完备计划到 <code>.omo/plans/</code>。</p>
    </article>
    <article class="relay-card">
      <div class="num mono">03 <small>atlas</small></div>
      <h4 class="mono">执行编排者</h4>
      <p style="color: var(--muted);"><code>/start-work</code> 逐 checkbox 委派 worker，证据台账。</p>
    </article>
  </div>
</section>

<section class="install-intro">
  <header class="section-head">
    <h2 class="mono">4 步安装 · 1 行融合</h2>
    <a class="count mono" href="{{ '/install/' | relative_url }}">→ 完整指南</a>
  </header>
  <div class="terminal">
    <div class="term-head">
      <span class="term-head__dots"><i></i><i></i><i></i></span>
      <span class="mono" style="color: var(--muted);">~/omo-skills</span>
    </div>
<pre class="term-body mono"><span class="c"># 1. 选目录</span>
<span class="cmd">$</span> ls ~/.config/opencode/skills/
<span class="ok">→</span> 12 skill dir created
<span class="c"># 2-4. cp -r × 12 + merge prompt_append</span>
<span class="cmd">$</span> bash scripts/install-prompt-append.mjs
<span class="ok">✓ 3 agent prompt_append merged</span></pre>
  </div>
</section>