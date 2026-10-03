#!/usr/bin/env bash
# Validate the packaging: the Claude Code manifests, that the Open Plugins manifest at the
# root agrees with them, and that a change to the skills comes with a version bump. Two
# manifests wrapping the skills is the only duplication in this repository, and the version
# is what makes installs pick a change up, so those are the things worth asserting.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail=0
note() { echo "✗ $*" >&2; fail=1; }

found=0
for dir in skills/*/; do
  dir="${dir%/}"
  name="$(basename "$dir")"
  found=$((found + 1))
  if [ ! -f "$dir/SKILL.md" ]; then
    note "$dir has no SKILL.md"
    continue
  fi
  # The frontmatter name is what an agent installs the skill as, so a mismatch
  # with the directory is confusing rather than harmless.
  declared=$(sed -n 's/^name: *//p' "$dir/SKILL.md" | head -1)
  [ "$declared" = "$name" ] || note "$dir/SKILL.md declares name '$declared', expected '$name'"
  grep -q '^description:' "$dir/SKILL.md" || note "$dir/SKILL.md has no description — it will never trigger"
done
[ "$found" -gt 0 ] || note "no skills found under skills/"

# The vendored copies of animovement/.github's documents are generated. A missing
# provenance header means someone hand-wrote or hand-edited one, and the next sync
# will silently overwrite it.
for f in skills/animovement-dev/reference/contributing.md \
         skills/animovement-dev/reference/ai-policy.md \
         skills/animovement-dev/reference/release-checklist.md \
         skills/animovement-dev/reference/pull-request-template.md \
         skills/animovement-dev/reference/issue-templates.md; do
  if [ ! -f "$f" ]; then
    note "$f is missing — run the Sync agent docs workflow in animovement/.github"
  elif ! head -12 "$f" | grep -q '^  Commit: [0-9a-f]\{40\}$'; then
    note "$f has no provenance header — it must be generated, not edited by hand"
  fi
done

field() { python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2],""))' "$1" "$2"; }

for key in name version description license; do
  open=$(field plugin.json "$key")
  claude_=$(field .claude-plugin/plugin.json "$key")
  if [ "$open" != "$claude_" ]; then
    note "$key differs: plugin.json='$open' .claude-plugin/plugin.json='$claude_'"
  fi
done

# Installs only pick up a change when the version moves, so a change under skills/ without
# a bump ships to nobody (the docs refresh before 0.6.0 did exactly that). Compared against
# where this branch left origin/main; skipped, not failed, where that cannot be worked out.
base_ref="${CHECK_BASE_REF:-origin/main}"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "! not a git checkout — skipped the version-bump check" >&2
elif ! git rev-parse --verify --quiet "$base_ref^{commit}" >/dev/null; then
  echo "! $base_ref not available (git fetch origin, or a full-depth checkout) — skipped the version-bump check" >&2
elif ! base=$(git merge-base "$base_ref" HEAD 2>/dev/null); then
  echo "! no common ancestor with $base_ref — skipped the version-bump check" >&2
elif ! git diff --quiet "$base" -- skills/; then
  base_version=$(git show "$base:plugin.json" 2>/dev/null \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("version",""))' 2>/dev/null || true)
  head_version=$(field plugin.json version)
  if [ -z "$base_version" ]; then
    echo "! could not read the version on $base_ref — skipped the version-bump check" >&2
  elif [ "$base_version" = "$head_version" ]; then
    note "skills/ changed since $base_ref but the version is still $head_version — bump it in plugin.json and .claude-plugin/plugin.json"
  fi
fi

if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict
else
  echo "! claude CLI not found — skipped manifest validation" >&2
fi

[ "$fail" -eq 0 ] && echo "✔ packaging consistent"
exit "$fail"
