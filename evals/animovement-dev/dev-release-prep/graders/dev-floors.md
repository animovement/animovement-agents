---
type: llm
---

PASS if the response points out that DESCRIPTION requires development versions of other suite packages, `anicore (>= 0.8.0.9003)` or `anivis (>= 0.2.1.9003)`, and that these need resolving before the release: for example by releasing anicore (and anivis) first and raising the floors to those releases.

FAIL if it doesn't mention these floors at all.
