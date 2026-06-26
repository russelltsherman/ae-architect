# ae-architect

A Claude Code plugin that assists in **designing and planning software applications** — from a
rough idea through requirements, system architecture, and decision records. Its design goal is
that the output be **indistinguishable from a master of system architecture and design**: every
decision justified with explicit trade-offs and alternatives, non-functional requirements
addressed deliberately, failure modes named, and designs grounded in reality.

## How it works

ae-architect is a **flexible toolkit** — invoke whichever command fits where you are; there's no
forced order. The quality bar comes from a **draft → adversarial review → revise** loop behind
every artifact:

1. A **drafting specialist** subagent (requirements analyst or system architect) writes the
   artifact, grounded in embedded architectural knowledge and — for existing codebases — a
   current-state map of the real system.
2. An independent **principal reviewer** subagent red-teams it against a rubric: missing NFRs,
   weak trade-off analysis, unjustified decisions, unnamed failure modes, internal inconsistency.
3. The draft is revised against blocking findings and re-reviewed (up to 3 rounds) until it
   passes. Residual gaps are surfaced, not buried.

## Commands

| Command | Produces | Use when |
|---|---|---|
| `/ae-architect:prd [idea]` | `docs/prd/<slug>.md` | Turning an idea or feature request into a PRD. |
| `/ae-architect:design [target]` | `docs/architecture/<slug>.md` | Designing the system/architecture (uses the PRD if present). |
| `/ae-architect:adr [decision]` | `docs/adr/NNNN-<title>.md` | Recording a significant decision (MADR 4.0). |
| `/ae-architect:analyze` | `docs/architecture/current-state.md` | Brownfield: mapping an existing codebase before designing. |
| `/ae-architect:review <path>` | review report | Adversarially reviewing any existing artifact on demand. |

## Artifacts and the `docs/` tree

All output lands in a conventional, version-controlled `docs/` tree:

```
docs/
├── prd/<slug>.md                    # Product Requirements Documents
├── architecture/
│   ├── current-state.md             # brownfield map of the existing system
│   └── <slug>.md                    # architecture / system designs
└── adr/NNNN-<title>.md              # Architecture Decision Records (MADR 4.0)
```

## Greenfield vs brownfield

- **Greenfield** (no existing code): design is grounded in the PRD and your intent.
- **Brownfield** (designing into an existing codebase): run `/ae-architect:analyze` first. A read-only
  cartographer maps the real components, data flows, conventions, and seams into
  `current-state.md`, and the design must cite it — so you extend the system that exists rather
  than one that doesn't.

## A typical flow

```
/ae-architect:prd      "a service that lets teams schedule and run data-quality checks"
/ae-architect:design                      # consumes the PRD, produces the architecture doc + ADR candidates
/ae-architect:adr      "use Postgres as the primary store"
```

For an existing repo:

```
/ae-architect:analyze                     # map current state
/ae-architect:design   "add a webhook delivery subsystem"   # design cites current-state.md
```

## Components

- **Skills** (`skills/`) — the embedded rigor the subagents read: `nfr-checklists`,
  `architecture-patterns`, `prd-authoring`, `adr-authoring`, `architecture-review-rubric`, and the
  `architect` routing skill that auto-triggers on design/planning requests.
- **Subagents** (`agents/`) — `requirements-analyst`, `system-architect`, `codebase-cartographer`
  (read-only), and `principal-reviewer` (the adversarial gate).
- **Hooks** (`hooks/`) — a non-blocking PostToolUse hook that warns when a written artifact is
  missing expected sections. It nudges completeness without enforcing phase order.

## Hook behavior

When you (or a subagent) write a file under `docs/prd/`, `docs/adr/`, or `docs/architecture/`, the
hook checks for the structural sections that artifact type should contain (e.g. an ADR needs
Status / Context / Decision Drivers / Considered Options / Decision Outcome / Consequences) and
prints a warning listing anything missing. It **never blocks** the edit. The cartographer's
`current-state.md` is exempt because it has a different shape.

## Development

```bash
hooks/test-validate-artifact.sh     # run the hook's fixture tests
shellcheck hooks/*.sh               # lint (aim for zero warnings)
```
