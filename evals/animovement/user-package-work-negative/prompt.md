---
description: A near miss on the other side. Work on an animovement package itself (formatting, a pull request title) is the animovement-dev skill's; the user skill shouldn't load, even though the checkout is aniprocess.
expected_outcome: >-
  Formats with air (air format ., or the /style comment that members can run)
  rather than styler, and titles the pull request as a Conventional Commit,
  feat(aniprocess): add filter_median3(). The animovement skill isn't invoked;
  animovement-dev is.
tags: [negative]
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

I've added filter_median3() to aniprocess on a branch and opened a pull request. The format-suggest check fails and leaves dozens of suggestions on my PR. How do I fix that, and what should the pull request title be?
