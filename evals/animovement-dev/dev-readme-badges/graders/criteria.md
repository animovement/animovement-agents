---
type: llm
---

PASS if the response says to fix README.qmd's YAML header by setting `default-image-extension: ""` (under `format: gfm:`), and then to re-render README.md from README.qmd.

FAIL if the only fix it gives is editing README.md by hand (such as deleting ".png" from the badge URLs), or if it doesn't identify the ".png" appended to the badge URLs as the cause.
