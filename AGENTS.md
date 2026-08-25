# AGENTS.md

This repository is the ecosystem map for the [animovement](https://animovement.dev) suite —
the layer that tells an agent *which package owns what*, what an aniframe is, and how to
verify a function before calling it. The prose lives once, in
[`skills/animovement/`](skills/animovement/); every manifest here is a thin wrapper over
that one directory.

- Ecosystem map and agent rules — [`skills/animovement/SKILL.md`](skills/animovement/SKILL.md)
- API reference (generated, per package) — `https://animovement.dev/<package>/llms.txt`
- How we work — [CONTRIBUTING.md](https://github.com/animovement/.github/blob/main/CONTRIBUTING.md)
- Working with AI tools — [AI.md](https://github.com/animovement/.github/blob/main/AI.md)

## What does *not* live here

The `AGENTS.md` that each of the eight package repositories carries is generated from
`agents/AGENTS.md.tmpl` and `agents/packages.tsv` in
[animovement/.github](https://github.com/animovement/.github), and rolled out by its
**Sync AGENTS.md** workflow. Do not add a second template or rollout script here — edit it
there. Likewise the human-facing conventions (contributing, releases, AI policy): link to
them, never restate them.

## Working in this repository

- Edit the skills under `skills/`: `animovement` (using the stack) and `animovement-dev`
  (working on the packages). Each is the only copy — the repository root is itself the
  plugin, so Claude Code and Open Plugins consumers both read that directory.
- Keep the two separated by audience. A release or CI question must not need the user
  skill loaded, and an analysis question must not pull in maintainer conventions; that
  split is the whole reason there are two.
- Keep `reference/` a map, not a frozen copy of the API. It points at the generated docs so
  it cannot drift from the packages; do not paste signatures into it.
- Bump `version` in **both** `plugin.json` and `.claude-plugin/plugin.json` on every
  release; installs only pick up updates when it changes.
- Run `./scripts/check.sh` before pushing. It validates the manifests and asserts the two
  agree.
- Do not push to `main`; open a pull request, and fill in the template.
