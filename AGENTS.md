# AGENTS.md

This repository is the ecosystem map for the [animovement](https://animovement.dev) suite —
the layer that tells an agent *which package owns what*, what an aniframe is, and how to
verify a function before calling it — and, for maintainers, how the packages are built,
released and distributed. The prose lives once, in two skills under [`skills/`](skills/);
every manifest here is a thin wrapper over that directory.

- Ecosystem map and agent rules — [`skills/animovement/SKILL.md`](skills/animovement/SKILL.md)
- Maintainer conventions — [`skills/animovement-dev/SKILL.md`](skills/animovement-dev/SKILL.md)
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
- **Five files in `skills/animovement-dev/reference/` are generated:** `contributing.md`,
  `ai-policy.md`, `release-checklist.md`, `pull-request-template.md` and
  `issue-templates.md`. They are vendored from `animovement/.github` by its Sync agent docs
  workflow and carry the commit they came from. Never edit them here — the change belongs in
  `animovement/.github`, and the next sync would overwrite it anyway. `scripts/check.sh`
  fails if a provenance header is missing.
- Keep the two skills separated by audience. A release or CI question must not need the user
  skill loaded, and an analysis question must not pull in maintainer conventions; that
  split is the whole reason there are two.
- Keep `reference/` a map, not a frozen copy of the API. It points at the generated docs so
  it cannot drift from the packages; do not paste signatures into it.
- Bump `version` in **both** `plugin.json` and `.claude-plugin/plugin.json` whenever
  anything under `skills/` changes; installs only pick up updates when it changes. The Sync
  agent docs workflow bumps the patch version itself for the files it vendors; anything
  else — a new or reorganised skill, a hand edit — is bumped by hand.
- Run `./scripts/check.sh` before pushing. It validates the manifests, asserts the two
  agree, and fails when `skills/` differs from `origin/main` but the version does not.
- Do not push to `main`; open a pull request, and fill in the template.
