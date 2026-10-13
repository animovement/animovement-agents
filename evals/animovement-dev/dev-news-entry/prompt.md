---
description: A NEWS.md entry for a bug fix in aniprocess, in the suite's Keep a Changelog sections.
expected_outcome: >-
  A bullet under a new `## Fixed` heading in the `# aniprocess (development
  version)` section, after `## Changed`: names `filter_kalman()`, says it keeps
  the frame's metadata, ends with `(#112)`. States the effect for users, not how
  the bug was found. Not a tidyverse-style `## Bug fixes` heading.
tags: [dev, news]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

I've just fixed #112 in aniprocess: `filter_kalman()` returned its result without the frame's metadata, so the sampling rate and units were lost and anything downstream that needed them errored. It keeps the metadata now. Write the NEWS.md entry for me, and tell me exactly where it goes.
