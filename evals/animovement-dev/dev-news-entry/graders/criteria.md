---
type: llm
---

PASS if the response puts a bullet for the fix in the `# aniprocess (development version)` section of NEWS.md under a `## Fixed` heading (creating that heading, after `## Changed`, is correct, since the section has none yet), and the bullet names `filter_kalman()`, says that it now keeps the frame's metadata (or its sampling rate and units), and cites #112.

FAIL if the entry goes under `# aniprocess 0.5.0`, or under any heading other than `## Fixed` (such as `## Bug fixes` or `## Changed`), or if the bullet tells the story of how the bug was found or what was tried rather than what changed for users.
