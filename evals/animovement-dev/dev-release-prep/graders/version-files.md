---
type: llm
---

PASS if the response says to set the version to 0.4.0 in DESCRIPTION (dropping the .9004 suffix), to update CITATION.cff (its version and its date-released), and to turn the `# anicheck (development version)` heading in NEWS.md into `# anicheck 0.4.0` followed by the release date in parentheses.

FAIL if any of those three is missing, or if it tells the user to write the version into inst/CITATION, which reads it from DESCRIPTION through `meta$Version`.
