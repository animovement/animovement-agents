---
type: llm
---

PASS if the response tells the user to change the existing commit message ("fixed polar metadata") so that its first line matches the pull request title, for example with `git commit --amend` or by editing it in the merge dialog, because a pull request with a single commit is squash-merged with that commit's message rather than the title.

FAIL if it leaves the commit message as it is, or never mentions it.
