---
type: llm
---

PASS if the response says that `smooth_heading` has to be added to the reference index in `_pkgdown.yml` (for example under "Smooth and filter signals"), or be marked `@keywords internal`, because otherwise the pkgdown build fails.

FAIL if it doesn't mention `_pkgdown.yml`, or presents adding it as optional.
