---
type: llm
---

PASS if the description follows the animovement pull request template: it has sections for the kind of change (a bug fix), why it is needed, what it does, references with `Fixes #61` (or `Closes #61` or `Resolves #61`), how it was tested, whether it is a breaking change, whether documentation needs updating, and a checklist. Headings may be worded slightly differently, and a checklist item left unticked is fine.

FAIL if the description is free-form prose or a short summary without these sections, or does not link #61 with a closing keyword.
