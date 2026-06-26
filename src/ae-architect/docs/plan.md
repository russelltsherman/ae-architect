# Plan: `ae-architect` — a Claude Code plugin for master-level software design & planning

## Context

The repo `ae-architect` is greenfield (first commit, empty). The goal is to build a Claude Code
plugin that assists in **designing and planning software applications**, covering the arc from a
rough **idea → requirements (PRD) → architecture → decision records (ADRs)**. It stops *before*
task breakdown and implementation.

The defining constraint: **the output must be indistinguishable from a master of system
architecture and design.** This is treated as a first-class engineering requirement, not a tone
goal. Master-level output means: every decision is justified with explicit trade-offs and
alternatives-considered; non-functional requirements (scale, availability, security, cost,
operability, observability, compliance) are addressed deliberately; failure modes and risks are
named; designs are grounded in reality (the PRD for greenfield, the actual codebase for
brownfield) rather than hand-waved.

### Decisions locked with the user
- **Scope:** idea → architecture (PRD, architecture doc, ADRs). No implementation/task planning.
- **Components:** all four — skills, slash commands, subagents, hooks.
- **Artifacts:** PRD, ADRs, architecture doc — written to a conventional `docs/` tree.
- **Target:** both greenfield and brownfield.
- **Workflow style:** flexible toolkit (commands invoked in any order; hooks validate artifacts,
  they do **not** enforce phase order).
- **Quality enforcement:** adversarial review loop (independent "principal reviewer" red-teams
  each artifact and it is revised until it passes).
- **Source of rigor:** embedded architectural knowledge **+** process scaffolding.
- **Brownfield grounding:** a dedicated codebase-analysis subagent maps current state first;
  designs must cite it.

## Plugin shape

A **flexible toolkit**: each phase is a slash command you invoke when you want it. Each command
orchestrates an isolated-context **drafting subagent** to produce the artifact, then an
independent **principal-reviewer subagent** to adversarially critique it, looping revise→re-review
until the reviewer signs off (cap the loop, e.g. 3 rounds, then surface remaining gaps). The
rigor each subagent applies is supplied by **knowledge skills** they read. **Hooks** validate the
structural completeness of artifacts on write. Brownfield work is grounded by a
**codebase-cartographer** subagent.

## Directory structure

```
ae-architect/
├── .claude-plugin/
│   └── plugin.json                 # manifest (name, version, description, author)
├── commands/
│   ├── prd.md                   # /ae-architect:prd [idea] → docs/prd/<slug>.md
│   ├── design.md                # /ae-architect:design [target] → docs/architecture/<slug>.md
│   ├── adr.md                   # /ae-architect:adr [decision] → docs/adr/NNNN-*.md (MADR)
│   ├── analyze.md               # /ae-architect:analyze → docs/architecture/current-state.md (brownfield)
│   └── review.md                # /ae-architect:review <path> → run reviewer against an existing artifact
├── agents/
│   ├── requirements-analyst.md     # drafts/refines the PRD
│   ├── system-architect.md         # drafts the architecture doc + ADR candidates
│   ├── codebase-cartographer.md    # brownfield current-state map (read-only)
│   └── principal-reviewer.md       # adversarial reviewer for ALL artifacts
├── skills/
│   ├── architect/SKILL.md       # primary triggering skill: routes to the toolkit
│   ├── nfr-checklists/SKILL.md     # quality-attribute taxonomy + "have you considered" prompts
│   ├── architecture-patterns/SKILL.md  # pattern catalog + trade-off frameworks
│   ├── prd-authoring/SKILL.md      # PRD structure + standards
│   ├── adr-authoring/SKILL.md      # MADR format + good-ADR criteria
│   └── architecture-review-rubric/SKILL.md  # the adversarial review rubric
├── hooks/
│   ├── hooks.json
│   └── validate-artifact.sh        # PostToolUse: structural validation of docs/ artifacts
└── README.md
```

Auto-discovery picks up `commands/`, `agents/`, `skills/`, and `hooks/hooks.json` automatically;
only `.claude-plugin/plugin.json` is required to declare the plugin.

## Components in detail

### Slash commands (the toolkit)
Each command markdown instructs the main agent to orchestrate the draft→review loop. Pattern,
written once and reused across commands:
1. Resolve a slug + target docs path; detect greenfield vs brownfield.
2. (Brownfield, design/PRD only) ensure `docs/architecture/current-state.md` exists; if not,
   offer to run `/ae-architect:analyze` (cartographer) first so the design is grounded.
3. Spawn the **drafting subagent** (analyst / architect) to write the artifact.
4. Spawn **principal-reviewer** to red-team it against the rubric → structured findings.
5. If findings block, feed them back to the drafting subagent to revise; re-review. Loop ≤3.
6. Write the final artifact to the `docs/` tree; report residual non-blocking findings.

- `/ae-architect:prd [idea]` → `docs/prd/<slug>.md`
- `/ae-architect:design [target]` → `docs/architecture/<slug>.md` (consumes the PRD if present)
- `/ae-architect:adr [decision]` → next `docs/adr/NNNN-<title>.md`
- `/ae-architect:analyze` → `docs/architecture/current-state.md` (brownfield grounding)
- `/ae-architect:review <path>` → reviewer-only pass on any existing artifact

### Subagents (isolated context, defined in `agents/`)
- **requirements-analyst** — turns an idea into a master-grade PRD; asks the product questions a
  senior PM/architect would; enforces SMART success metrics, explicit non-goals, NFRs, risks,
  assumptions. Reads `prd-authoring` + `nfr-checklists`.
- **system-architect** — designs the system: C4-style context/containers/components, key data
  flows & sequences, deployment, tech-stack choices *with justification*, and a trade-off table
  (alternatives considered → decision drivers → consequences/risks). Emits ADR candidates for
  significant decisions. Reads `architecture-patterns` + `nfr-checklists`. For brownfield it must
  cite `current-state.md`.
- **codebase-cartographer** — read-only; maps existing architecture (components, data flows,
  conventions, constraints, seams) so designs extend reality instead of inventing it. Tools:
  Read/Grep/Glob only.
- **principal-reviewer** — the adversarial gate, default posture "find what's missing." Scores
  each artifact against the rubric: completeness (no hand-waving), grounding (claims cite
  PRD/codebase), NFR coverage, trade-off rigor (alternatives + rationale present), named failure
  modes/risks, internal consistency (architecture actually satisfies the PRD), feasibility, and
  cost/scale realism. Returns blocking vs advisory findings. Reads `architecture-review-rubric`.

### Skills (embedded rigor — built via skill-creator)
Skills carry the curated architectural knowledge the subagents read, plus the primary
auto-triggering entry skill. Concretely they encode:
- **nfr-checklists** — quality-attribute taxonomy (performance, scalability, availability/
  reliability, security, maintainability, observability, operability, cost, compliance/privacy,
  data integrity, portability) with prompting questions per attribute.
- **architecture-patterns** — pattern catalog (monolith/modular-monolith/microservices,
  event-driven, CQRS, layering, data-store selection, caching, sync vs async) framed as
  trade-offs, not recommendations.
- **prd-authoring**, **adr-authoring** (MADR 4.0), **architecture-review-rubric**.
- **architect** — primary skill triggering on "design a system/architecture for…",
  "plan an application", "write a PRD/ADR", routing the user to the right command.

> Per the user's standing directive, **every skill is created and tuned through the
> `skills:skill-creator` skill and its eval loop — never hand-authored.** Description triggering
> is validated via skill-creator's benchmark/variance tooling before shipping.

### Hooks (artifact validation, not order enforcement)
`hooks/hooks.json` registers a **PostToolUse** hook on `Write`/`Edit` whose script
`validate-artifact.sh` fires only for paths under `docs/prd|adr|architecture`. It checks
structural completeness for the artifact type — e.g. ADR has Status/Context/Decision Drivers/
Considered Options/Decision Outcome/Consequences; PRD has Goals/Non-Goals/Success Metrics/NFRs;
architecture doc has an NFR section and a trade-offs/alternatives section — and emits a warning
(non-blocking) listing missing sections. This nudges completeness without gating phase order,
consistent with the flexible-toolkit choice.

## Build sequence
1. `plugin.json` + skeleton dirs; confirm the plugin loads (`/plugin`, `claude plugin validate`).
2. Knowledge skills first (nfr-checklists, architecture-patterns, prd-authoring, adr-authoring,
   architecture-review-rubric) via **skill-creator** — they are the substrate everything reads.
3. Subagents (cartographer, analyst, architect, principal-reviewer), each pointed at its skills.
4. Commands wiring the draft→review loop; then the primary `architect` routing skill.
5. Hooks (`hooks.json` + `validate-artifact.sh`) last.
6. `README.md` documenting the toolkit and the docs/ conventions.

## Verification / testing
- **Structure/manifest:** `claude plugin validate` (or the `plugin-dev:plugin-validator` agent) —
  manifest valid, components discovered.
- **Skills:** run each skill's eval suite through **skill-creator** (triggering accuracy +
  content quality); do not ship a skill that fails its evals.
- **Hooks:** `validate-artifact.sh` written ShellCheck-clean (per the bash-scripts skill) with a
  small test harness feeding it complete and deliberately-incomplete fixture artifacts and
  asserting the warnings — satisfies the "no task complete without tests" directive.
- **End-to-end greenfield:** in a scratch dir, run `/ae-architect:prd "<sample idea>"` →
  `/ae-architect:design` → `/ae-architect:adr`, and confirm: artifacts land in the `docs/` tree, the reviewer loop
  actually fired and revised, and the output exhibits master-level markers (explicit trade-offs,
  NFR coverage, named risks, alternatives-considered).
- **End-to-end brownfield:** point at an existing sample repo, run `/ae-architect:analyze` then `/ae-architect:design`,
  and confirm the design cites `current-state.md` rather than inventing structure.
- **Adversarial sanity check:** feed the reviewer a deliberately weak artifact and confirm it
  produces blocking findings rather than rubber-stamping.

## Open considerations (flag, don't block)
- ADR numbering/concurrency: scan `docs/adr/` for the highest `NNNN` and increment; note the
  small race if two ADRs are created in parallel.
- Reviewer loop cost: the ≤3-round cap bounds tokens; expose the cap if it needs tuning.
- The existing `rnd` plugin already ships `writing-prds`/`writing-adr` skills; per the user's
  instruction this plugin is self-contained, but `adr-authoring` should still follow **MADR 4.0**
  for consistency.
