# ae-architect marketplace

A Claude Code **plugin marketplace** for software design, architecture, and planning.

## Add the marketplace

```
/plugin marketplace add russelltsherman/ae-architect
```

Then install a plugin from it:

```
/plugin install ae-architect@ae-architect
```

## Plugins

| Plugin | Source | Description |
|---|---|---|
| [`ae-architect`](src/ae-architect) | `./src/ae-architect` | Master-level software design & planning toolkit: turn an idea into a PRD, architecture doc, and ADRs, each adversarially reviewed before it is considered done. |

## Repository layout

```
.
├── .claude-plugin/
│   └── marketplace.json    # marketplace manifest listing the plugins below
└── src/
    └── ae-architect/       # the ae-architect plugin
        ├── .claude-plugin/
        │   └── plugin.json
        ├── agents/
        ├── commands/
        ├── hooks/
        ├── skills/
        └── README.md
```

Each plugin lives under `src/<plugin-name>/` with its own `.claude-plugin/plugin.json`. See each
plugin's own `README.md` for usage details.
