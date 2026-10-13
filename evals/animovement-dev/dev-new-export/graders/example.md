---
type: llm
---

PASS if the response flags the example's `example_aniframe()` call: it is not namespaced, so it fails under R CMD check where only aniprocess is attached, or it is deprecated in favour of `anicore::example_anipoint()`. Either point is a PASS.

FAIL if it leaves the example's `example_aniframe()` call as it is.
