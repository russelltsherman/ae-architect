---
description: Map an existing codebase's current-state architecture to ground brownfield design.
argument-hint: [optional path or area to focus on]
---

# /ae-architect:analyze — Current-state architecture map

Map the existing system so later design extends reality instead of inventing it. Focus area (if
given): **$ARGUMENTS** — otherwise map the whole repository.

## Steps

1. **Spawn the `codebase-cartographer` subagent.** Give it the repo root (the current working
   directory), the focus area if one was provided, and the output path
   `docs/architecture/current-state.md`. It is read-only and produces a cited, factual map —
   components, data flows, external dependencies, conventions/constraints, extension seams, and an
   explicit "unknowns" section. It describes what *is*; it does not propose changes.

2. **(Optional) Sanity-review.** For a large or critical codebase, you may spawn the
   `principal-reviewer` on the map to check it isn't hand-waving or making unsupported claims.
   Skip for small repos.

3. **Report.** Summarize the system in a few sentences, point to `docs/architecture/current-state.md`,
   and list the most important unknowns. Suggest `/ae-architect:design` as the next step — the design will
   cite this map.
