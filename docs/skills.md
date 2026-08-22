---
layout: default
title: "Skills 索引"
---

<section class="page-head">
  <p class="eyebrow mono">14 skills · 采纳清单</p>
  <h1 class="mono">所有 skill 一览</h1>
  <p class="muted">10 个 engineering skill + 4 个 productivity skill，按 phase 分组。</p>
</section>

{% assign engineering_skills = site.data.skills | where: "category", "engineering" %}
{% assign productivity_skills = site.data.skills | where: "category", "productivity" %}

<section class="skills-group">
  <header class="section-head">
    <h2 class="mono">engineering · 10</h2>
    <span class="count mono">init · planning · execution · daily · user-invoked</span>
  </header>

  <div class="skills-expanded">
    {% for skill in engineering_skills %}
    <article class="skill-expanded" id="skill-{{ skill.name }}">
      <header class="skill-expanded-head">
        <span class="tag mono">{{ skill.tag }}</span>
        <span class="phase mono muted">phase: {{ skill.phase }}</span>
      </header>
      <h3 class="mono">{{ skill.name }}</h3>
      <p class="skill-expanded-desc">{{ skill.desc }}</p>
      <a class="skill-expanded-link mono" href="{{ skill.file }}" target="_blank" rel="noopener">查看 SKILL.md →</a>
    </article>
    {% endfor %}
  </div>
</section>

<section class="skills-group">
  <header class="section-head">
    <h2 class="mono">productivity · 4</h2>
    <span class="count mono">writing · grilling · teaching · eliciting</span>
  </header>

  <div class="skills-expanded">
    {% for skill in productivity_skills %}
    <article class="skill-expanded" id="skill-{{ skill.name }}">
      <header class="skill-expanded-head">
        <span class="tag mono">{{ skill.tag }}</span>
        <span class="phase mono muted">phase: {{ skill.phase }}</span>
      </header>
      <h3 class="mono">{{ skill.name }}</h3>
      <p class="skill-expanded-desc">{{ skill.desc }}</p>
      <a class="skill-expanded-link mono" href="{{ skill.file }}" target="_blank" rel="noopener">查看 SKILL.md →</a>
    </article>
    {% endfor %}
  </div>
</section>
