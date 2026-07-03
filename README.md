# animovement — Claude Code skills

Agent [Skills](https://code.claude.com/docs/en/skills) for working with the
[animovement](https://github.com/animovement) R stack, distributed as a Claude Code
plugin marketplace.

The **animovement** skill gives a coding agent a durable map of the stack — which package
owns what (`aniframe`, `aniread`, `aniprocess`, `animetric`, `anivis`, `anicheck`,
`anispace`), the aniframe data model, and the naming conventions — so it can locate
functions and **verify their signatures in the source** rather than guessing. It loads only
when a task actually involves animovement (progressive disclosure via the skill
`description`), so it costs nothing on unrelated work.

## Install

In Claude Code:

```
/plugin marketplace add animovement/claude-skills
/plugin install animovement@animovement
```

The first command registers this marketplace; the second installs the `animovement` plugin
(which bundles the skill). Choose the `user` scope to make it available across all your
projects. Update later with `/plugin marketplace update animovement`.

### Manual alternative

If you'd rather not use the plugin system, copy the skill straight into your personal
skills directory:

```
cp -r plugins/animovement/skills/animovement ~/.claude/skills/animovement
```

## What's inside

```
plugins/animovement/skills/animovement/
  SKILL.md                    # package map, data model summary, conventions
  reference/
    packages.md               # key exported functions per package
    aniframe-model.md         # the aniframe data contract in detail
```

The skill deliberately points the agent at the local animovement source
(`.../animovement/<package>/R/`) to confirm signatures, so it stays correct as the API
evolves — keep the reference files as a map, not a frozen copy of the API.

## Contributing

- Edit the skill under `plugins/animovement/skills/animovement/`.
- **Bump `version`** in `plugins/animovement/.claude-plugin/plugin.json` on every release —
  installs only pick up updates when this changes.
- Validate before pushing: `claude plugin validate .`

## License

MIT — see [LICENSE](LICENSE).
