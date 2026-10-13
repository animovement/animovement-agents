---
description: A near miss. An analysis question about the animovement packages, where the maintainer skill must not load; the user skill should.
expected_outcome: >-
  Answers with R code that reads the SLEAP file with aniread and computes each
  mouse's speed with the animovement packages, using the animovement skill.
  animovement-dev is never invoked, and nothing about NEWS.md, pull requests,
  releases or CI comes up.
tags: [dev, negative]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

I have SLEAP tracking of two mice in data/session1.analysis.h5, recorded at 30 fps. How do I read it with aniread and get each mouse's speed over time? analysis.R is where I've got to.
