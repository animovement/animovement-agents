# animovement — Agent Skills

Agent [Skills](https://code.claude.com/docs/en/skills) for working with the
[animovement](https://github.com/animovement) R stack. The content is plain
markdown, so it can be consumed by Claude Code, [goose](https://block.github.io/goose/),
and any other agent that supports the generic Agent Skills / Open Plugin format.

The **animovement** skill gives a coding agent a durable map of the stack — which
package owns what (`aniframe`, `aniread`, `aniprocess`, `animetric`, `anivis`,
`anicheck`, `anispace`), the aniframe data model, and the naming conventions — so
it can locate functions and **verify their signatures in the source** rather than
guessing. It loads only when a task actually involves animovement (progressive
disclosure via the skill `description`), so it costs nothing on unrelated work.

## Install

### Claude Code

```
/plugin marketplace add animovement/animovement-agents
/plugin install animovement@animovement
```

The first command registers this marketplace; the second installs the `animovement`
plugin (which bundles the skill). Choose the `user` scope to make it available
across all your projects. Update later with `/plugin marketplace update animovement`.

### goose and other Agent Skills-compatible agents

```sh
goose plugin install https://github.com/animovement/animovement-agents.git
```

This uses the Open Plugin manifest at the repository root. Update later with
`goose plugin update`.

### Manual alternative

If you'd rather not use a plugin system, copy the skill straight into your personal
skills directory:

```sh
# Claude Code
mkdir -p ~/.claude/skills
cp -r skills/animovement ~/.claude/skills/animovement

# goose
mkdir -p ~/.config/goose/skills
cp -r skills/animovement ~/.config/goose/skills/animovement
```

## What's inside

```
skills/animovement/
  SKILL.md                    # package map, data model summary, conventions
  reference/
    packages.md               # key exported functions per package
    aniframe-model.md         # the aniframe data contract in detail
```

The skill deliberately points the agent at the local animovement source
(`.../animovement/<package>/R/`) to confirm signatures, so it stays correct as the
API evolves — keep the reference files as a map, not a frozen copy of the API.

The canonical skill content lives under `skills/animovement/`. The
`plugins/animovement/` directory wraps it for the Claude Code plugin marketplace
and is kept in sync via a symlink, so the prose is never duplicated.

## Contributing

- Edit the skill under `skills/animovement/`.
- **Bump `version`** in `plugin.json` and
  `plugins/animovement/.claude-plugin/plugin.json` on every release — installs only
  pick up updates when these change.
- Validate before pushing:
  - `claude plugin validate .` for Claude Code
  - `goose plugin validate .` for goose, if available

## License

MIT — see [LICENSE](LICENSE).
