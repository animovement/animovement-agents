---
type: llm
---

PASS if the response says all three of: (1) bump anicore's development version in the pull request that adds signed_turn() (to 0.8.0.9009); (2) raise animetric's anicore floor in Imports to that version, `anicore (>= 0.8.0.9009)`; (3) animetric's CI installs anicore from R-universe, so it can pass only once R-universe has built the new anicore after the merge: wait, then re-run.

FAIL if any of the three is missing, or if it has animetric's CI install anicore from GitHub instead, for example with a `Remotes:` field.
