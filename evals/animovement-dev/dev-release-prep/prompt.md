---
description: Preparing anicheck 0.4.0, whose DESCRIPTION still requires development versions of anicore and anivis.
expected_outcome: >-
  Version 0.4.0 in DESCRIPTION, version and date-released in CITATION.cff, the
  NEWS.md heading renamed to `# anicheck 0.4.0 (<date>)`; inst/CITATION left
  alone (it reads meta$Version) and no README re-render (only animovement's
  embeds versions). Flags the floors on anicore 0.8.0.9003 and anivis 0.2.1.9003
  as development versions: anicore and anivis are released first and the floors
  moved to those releases. Release checklist issue, tag v0.4.0, release named
  `v0.4.0 — <subtitle>`, then 0.4.0.9000 and a fresh development heading.
tags: [dev, release]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

I'd like to release anicheck 0.4.0 this week. What do I need to bump, and where? Walk me through it.
