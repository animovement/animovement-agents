#!/usr/bin/env bash
# Validate the packaging: the Claude Code manifests, and that the Open Plugins manifest at
# the root agrees with them. Two manifests wrapping one skill is the only duplication in
# this repository, so it is the one thing worth asserting.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

fail=0
note() { echo "✗ $*" >&2; fail=1; }

[ -f skills/animovement/SKILL.md ] || note "skills/animovement/SKILL.md is missing"

field() { python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2],""))' "$1" "$2"; }

for key in name version description license; do
  open=$(field plugin.json "$key")
  claude_=$(field .claude-plugin/plugin.json "$key")
  if [ "$open" != "$claude_" ]; then
    note "$key differs: plugin.json='$open' .claude-plugin/plugin.json='$claude_'"
  fi
done

if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict
else
  echo "! claude CLI not found — skipped manifest validation" >&2
fi

[ "$fail" -eq 0 ] && echo "✔ packaging consistent"
exit "$fail"
