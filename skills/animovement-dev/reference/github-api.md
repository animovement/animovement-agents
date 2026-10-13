# Issues, pull requests and commits through gh or the API

Read this before creating an issue, a pull request or a commit with `gh` or the GitHub API
rather than git and the web UI. The web UI fills in the templates and makes one commit per
change; the API does neither, and nothing warns you.

## Issues

The bug, feature and task templates are issue forms, which only the web UI renders.
`issue-templates.md` turns each into a markdown skeleton: fill in every field, and set the
type, which the form would have set:

```sh
gh issue create -R animovement/<package> --type Bug --title "…" --body-file body.md
```

File it against the package that owns the behaviour, or `animovement` when unsure. Bugs and
features opened from a form go straight onto the organisation's project board; one created
this way waits for the daily Project Sweep.

**A release checklist:** the body is `release-checklist.md` without the provenance comment at
the top.

```sh
gh issue create -R animovement/<package> --type Task \
  --title "Release <package> <version>" --body-file checklist.md
```

`--template "Release checklist"` can't do this: without a terminal, `gh` requires `--body`,
and refuses `--template` alongside it.

## Pull requests

```sh
gh pr create -R animovement/<package> --base main --head <branch> \
  --title "fix(<package>): …" --body-file pr.md
```

`pr.md` is `pull-request-template.md` with every section filled in: the kind of change, why
it is needed, what it does, `Fixes #<n>` under *References*, how it was tested, whether it
breaks anything, the documentation. Tick the checklist items that are true, and leave the last
one, a human's statement that they read and tested every change, for the human. Say that it
was AI-assisted: a note at the end, or a `Co-Authored-By:` trailer on the commits.

With a single commit, make that commit's first line the title before opening: the squash merge
keeps the commit's message, not the title.

## Commits touching several files

The contents API (`PUT /repos/{owner}/{repo}/contents/{path}`) commits each file separately, so
nine files make nine commits to squash later. Build one commit through the git data API
instead, as `agents/sync-agent-docs.sh` in animovement/.github does:

```sh
repo=animovement/<package>; branch=<new-branch>
base=$(gh api repos/$repo/git/ref/heads/main --jq .object.sha)
base_tree=$(gh api repos/$repo/git/commits/$base --jq .tree.sha)
args=()
for f in R/foo.R NEWS.md tests/testthat/test-foo.R; do
  blob=$(gh api repos/$repo/git/blobs -F content=@"$f" -f encoding=utf-8 --jq .sha)
  args+=(-f "tree[][path]=$f" -f "tree[][mode]=100644" -f "tree[][type]=blob" -f "tree[][sha]=$blob")
done
tree=$(gh api repos/$repo/git/trees -f base_tree="$base_tree" "${args[@]}" --jq .sha)
commit=$(gh api repos/$repo/git/commits -f message="fix(<package>): …" \
  -f tree="$tree" -f "parents[]=$base" --jq .sha)
gh api repos/$repo/git/refs -f ref="refs/heads/$branch" -f sha="$commit"
```

`-F` for the content, so that `@file` is read; `-f` for the tree fields, whose mode must stay a
string. To add to an existing branch, start from its head instead of `main`'s, and move it with
`gh api -X PATCH repos/$repo/git/refs/heads/$branch -f sha="$commit"`.

## Checking CI and R-universe

```sh
gh pr checks <number> -R animovement/<package>
gh run view <run-id> -R animovement/<package> --log-failed
curl -s https://animovement.r-universe.dev/api/packages/<package>   # Version, and RemoteSha: the commit built
```
