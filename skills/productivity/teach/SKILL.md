---
name: teach
description: User-invoked only — do not invoke automatically. Teach the user (教学) a concept (概念) or an OSS repo / library / framework (仓库), producing interactive lessons inside the user's project. Use on `/teach`, "teach", 概念学习, or 仓库学习.
disable-model-invocation: true
---

The user has asked you to teach them something. This is a stateful request - they intend to learn the topic over multiple sessions.

## Workspace

The teaching workspace lives at **`docs/teach/{concept,repo}/` inside the user's project root** (NOT cwd, NOT inside omo-skills). Each invocation carves one subworkspace:

- `/teach <concept>` → `docs/teach/concept/<slug>/`
- `/teach <repo>` → `docs/teach/repo/<repo-slug>/`

The trailing `<slug>` is the dash-cased topic (e.g. `react-hooks`, `tanstack-query`). If `docs/teach/{concept,repo}/` does not yet exist, create the directory tree before writing any file there. This skill is **independent of `to-questionnaire`**: that one writes to cwd, this one writes to the project-root workspace. Do not reuse the `to-questionnaire-<slug>.md` filename or cwd location.

## Concept vs repo

Pick the subworkspace from the user's phrasing:

- **OSS repo / library / framework / 仓库** → `docs/teach/repo/<repo-slug>/`. The primary source is the codebase itself. Lessons are vocabulary-, idiom-, and seam-driven; cross-reference ## Reference: codebase-to-course for the philosophy.
- **Concept / "what is X" / "how does Y work" / 概念** → `docs/teach/concept/<slug>/`. The primary source is external references (docs, papers, glossaries), not a codebase.

If ambiguous (e.g. "React hooks" could be either), ask one focused question before scaffolding the workspace. Do not guess - the wrong subworkspace pollutes both `concept/` and `repo/` trees and the shared glossary.

## Teaching Workspace

Treat `docs/teach/{concept,repo}/<slug>/` as a teaching workspace. The state of their learning is captured in this directory in several files:

- `MISSION.md`: A document capturing the _reason_ the user is interested in the topic. This should be used to ground all teaching. Use the format in [MISSION-FORMAT.md](./MISSION-FORMAT.md).
- `./reference/*.html`: A directory of reference materials. These are the compressed learnings from the lessons - cheat sheets, reference algorithms, syntax, yoga poses, glossaries. They are the raw units of learning. They should be beautiful documents which print out well, and are designed for quick reference.
- `RESOURCES.md`: A list of resources which can be explored to ground your teaching in contextual knowledge, or to acquire knowledge and wisdom. Use the format in [RESOURCES-FORMAT.md](./RESOURCES-FORMAT.md).
- `./learning-records/*.md`: A directory of learning records, which capture what the user has learned. These are loosely equivalent to architectural decision records in software development - they capture non-obvious lessons and key insights that may need to be revised later, or drive future sessions. These should be used to calculate the zone of proximal development. They are titled `0001-<dash-case-name>.md`, where the number increments each time. Use the format in [LEARNING-RECORD-FORMAT.md](./LEARNING-RECORD-FORMAT.md).
- `./lessons/*.html`: A directory of lessons. A **lesson** is a single, self-contained HTML output that teaches one tightly-scoped thing tied to the mission. This is the primary unit of teaching in this workspace.
- `./assets/*`: Reusable **components** shared across lessons. See [Assets](#assets).
- `NOTES.md`: A scratchpad for you to jot down user preferences, or working notes.

## Philosophy

To learn at a deep level, the user needs three things:

- **Knowledge**, captured from high-quality, high-trust resources
- **Skills**, acquired through highly-relevant interactive lessons devised by you, based on the knowledge
- **Wisdom**, which comes from interacting with other learners and practitioners

Before the `RESOURCES.md` is well-populated, your focus should be to find high-quality resources which will help the user acquire knowledge. Never trust your parametric knowledge.

Some topics may require more skills than knowledge. Learning more about theoretical physics might be more knowledge-based. For yoga, more skills-based.

### Fluency vs Storage Strength

You should be careful to split between two types of learning:

- **Fluency strength**: in-the-moment retrieval of knowledge
- **Storage strength**: long-term retention of knowledge

Fluency can give the user an illusory sense of mastery, but storage strength is the real goal. Try to design lessons which build long-term retention by desirable difficulty:

- Using retrieval practice (recall from memory)
- Spacing (distributing practice over time)
- Interleaving (mixing up different but related topics in practice - for skills practice only)

## Lessons

A lesson is the main thing you produce: the unit in which knowledge and skills reach the user. Each lesson is one self-contained HTML file, saved to `./lessons/` and titled `0001-<dash-case-name>.html` where the number increments each time.

A lesson should be **beautiful**, with clean, readable typography and layout, since the user will return to these later to review. Think Tufte.

The lesson should be short, and completable very quickly. Learners' working memory is very small, and we need to stay within it. But each lesson should give the user a single tangible win that they can build on. It should be directly tied to the mission, and should be in the user's zone of proximal development.

If possible, open the lesson file for the user by running a CLI command.

Each lesson should link via HTML anchors to other lessons and reference documents.

Each lesson should recommend a primary source for the user to read or watch. This should be the most high-quality, high-trust resource you found on the topic.

Each lesson should contain a reminder to ask followup questions to the agent. The agent is their teacher, and can assist with anything that's unclear.

## Assets

Lessons are built from reusable **components**, stored in `./assets/`: stylesheets, quiz widgets, simulators, diagram helpers, and anything else a second lesson could reuse.

Reuse is the default, not the exception. Before authoring a lesson, read `./assets/` and build from the components already there. When a lesson needs something new and reusable, write it as a component in `./assets/` and link to it; never inline code a future lesson would duplicate.

A shared stylesheet is the first component every workspace earns: every lesson links it, so the lessons look like one consistent course rather than a pile of one-offs. As the workspace grows, so should the component library.

## The Mission

Every lesson should be tied into the mission - the reason that the user is interested in learning about the topic.

If the user is unclear about the mission, or the `MISSION.md` is not populated, your first job should be to question the user on why they want to learn this.

Failing to understand the mission will mean knowledge acquisition is not grounded in real-world goals. Lessons will feel too abstract. You will have no way of judging what the user should do next.

Missions may change as the user develops more skills and knowledge. This is normal - make sure to update the `MISSION.md` and add a learning record to capture the change. Confirm with the user before changing the mission.

## Zone Of Proximal Development

Each lesson, the user should always feel as if they are being challenged 'just enough'.

The user may specify an exact thing they want to learn. If they don't, figure out their zone of proximal development by:

- Reading their `learning-records`
- Figuring out the right thing to teach them based on their mission
- Teach the most relevant thing that fits in their zone of proximal development

## Knowledge

Lessons should be designed around a skill the user is going to learn. The knowledge in the lesson should be only what's required to acquire that skill. You teach the knowledge first, then get the user to practice the skills via an interactive feedback loop.

Knowledge should first be gathered from trusted resources. Use `RESOURCES.md` to keep track of them. Lessons should be littered with citations - links to external resources to back up any claim made. This increases the trustworthiness of the lesson.

For acquiring knowledge, difficulty is the enemy. It eats working memory you need for understanding.

## Skills

If knowledge is all about acquisition, skills are about durability and flexibility. Make the knowledge stick.

For skill acquisition, difficulty is the tool. Effortful retrieval is what builds storage strength. Skills should be taught through interactive lessons. There are several tools at your disposal:

- Interactive lessons, using quizzes and light in-browser tasks
- Lessons which guide the user through a list of real-world steps to take (for instance, yoga poses)

Each of these should be based on a **feedback loop**, where the user receives feedback on their performance. This feedback loop should be as tight as possible, giving feedback immediately - and ideally automatically.

For quizzes, each answer should be exactly the same number of words (and characters, if possible). Don't give the user any clues about the answer through formatting.

## Acquiring Wisdom

Wisdom comes from true real-world interaction - testing your skills outside the learning environment.

When the user asks a question that appears to require wisdom, your default posture should be to attempt to answer - but to ultimately delegate to a **community**.

A community is a place (online or offline) where the user can test their skills in the real world. This might be a forum, a subreddit, a real-world class (budget permitting) or a local interest group.

You should attempt to find high-reputation communities the user can join. If the user expresses a preference that they don't want to join a community, respect it.

## Reference Documents

While creating lessons, you should also create reference documents. Lessons can reference these documents - they are useful for tracking raw units of knowledge useful across lessons.

Lessons will rarely be revisited later - reference documents will be. They should be the compressed essence of the lesson, in a format designed for quick reference.

Some learning topics lend themselves to reference:

- Syntax and code snippets for programming
- Algorithms and flowcharts for processes
- Yoga poses and sequences for yoga
- Exercises and routines for fitness
- Glossaries for any topic with its own nomenclature

Glossaries, in particular, are an essential reference. Once one is created, it should be adhered to in every lesson.

## `NOTES.md`

The user will sometimes express preferences of how they want to be taught, or things you should keep in mind. This is the place to record those preferences, so you can refer back to them when designing lessons or working with the user.

## Reference: codebase-to-course

For OSS-repo subworkspaces, follow the philosophy of [zarazhangrui/codebase-to-course](https://github.com/zarazhangrui/codebase-to-course). Four principles, verbatim:

- **Build first understand later** - invert CS education: build, then experience, then understand. Don't lecture first.
- **Show don't tell** - every screen is at least 50% visual. Max 2-3 sentences per text block. If something can be a diagram, animation, or interactive element, it shouldn't be a paragraph.
- **Quizzes test doing not knowing** - no "What does API stand for?" Instead: a real scenario that requires using what was learned. Quizzes test whether you can _apply_, not whether you can _recall_.
- **Original code only** - code snippets are exact copies from the real codebase, never modified or simplified. The learner should be able to open the actual file and see the same code they learned from.

## Glossary

Concept and repo subworkspaces share a common `docs/teach/GLOSSARY.md` (sibling of `concept/` and `repo/`). New terms introduced while teaching a concept are auto-available when teaching a related repo later; both subworkspace trees reference the same file.

When a lesson introduces a new term, add it to `docs/teach/GLOSSARY.md` (create lazily if absent) before referencing the term elsewhere. Subsequent lessons MUST use the term as defined in the glossary. Adherence to a stable glossary is what keeps a multi-session course cohesive.

## Flags

`--format html|markdown|md-html` - output format for each lesson (default `html`).

- `html`: rich, printable, interactive. Default for both concept and repo subworkspaces.
- `markdown`: text-only, git-diffable, IDE-friendly. Use when lessons will be read inside an editor or reviewed in PRs.
- `md-html`: Markdown body plus an HTML wrapper that embeds code blocks and quizzes - preserves diffability while keeping richer rendering.

Set per-invocation (`/teach react hooks --format markdown`). The chosen format applies to all `./lessons/*` files in that session; do not mix formats inside one workspace.
