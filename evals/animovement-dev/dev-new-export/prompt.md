---
description: What else changes when aniprocess gains an exported function, whose example calls example_aniframe() unqualified.
expected_outcome: >-
  devtools::document() for NAMESPACE and man/; smooth_heading added to the
  reference index in _pkgdown.yml (pkgdown errors on an unlisted topic, after
  R CMD check has passed); the example rewritten with
  anicore::example_anipoint(), since an unqualified call fails under R CMD
  check and example_aniframe() is deprecated; tests; a NEWS.md bullet under
  `## Added`; a `feat(aniprocess): add smooth_heading()` title. Ideally also the
  padded description, the undocumented default and a @return that names what
  changed.
tags: [dev, export]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

I've written smooth_heading() for aniprocess, in R/smooth_heading.R, and exported it. What else has to change before I open the pull request?
