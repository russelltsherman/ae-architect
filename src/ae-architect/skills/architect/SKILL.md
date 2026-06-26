---
name: architect
description: >-
  Master-level software design and planning toolkit. Use this whenever the user wants to design,
  architect, plan, or scope a software application, service, system, or significant feature — from
  a rough idea through requirements, system architecture, and decision records. Trigger on phrases
  like "design a system for…", "how should I architect…", "plan out this app", "write a PRD",
  "what's the architecture for…", "help me think through the design of…", "I'm building X, where do
  I start", or any request to evaluate technical trade-offs, choose between architectural
  approaches, or produce a PRD / architecture document / ADR. Trigger even when the user describes
  the system they want to build without explicitly saying "design" or "architecture" — if the
  underlying need is to figure out how to build something, route them here. Do NOT use this for
  implementing or writing the actual application code (that is downstream), for one-off code
  questions, or for pure project-management scheduling.
---

# architect: software design & planning toolkit

This skill routes a software design effort to the right tool and explains how the toolkit works.
The plugin produces **master-level** design artifacts — the kind a seasoned principal architect
would sign their name to — by pairing a drafting specialist with an independent adversarial
reviewer for every artifact.

## The mental model

Design flows **idea → requirements → architecture → decisions**, but the toolkit is *flexible*:
invoke whichever command fits where the user actually is. Don't force a linear march.

Every artifact is produced the same way, and this is the source of the quality bar:

1. A **drafting subagent** (requirements-analyst or system-architect) writes the artifact,
   grounded in the relevant knowledge skill and — for existing codebases — the current-state map.
2. An independent **principal-reviewer subagent** adversarially red-teams it: hunting missing
   non-functional requirements, weak or absent trade-off analysis, unjustified decisions,
   unnamed failure modes, and internal inconsistency.
3. The draft is revised against blocking findings and re-reviewed, up to ~3 rounds, until it
   passes. Residual non-blocking findings are surfaced, not buried.

This draft→review loop is why the output should read like a master's work rather than a first
draft: nothing ships without surviving an expert critique.

## The commands

| Command | Produces | Use when |
|---|---|---|
| `/ae-architect:prd [idea]` | `docs/prd/<slug>.md` | Turning an idea or feature request into a Product Requirements Document. |
| `/ae-architect:design [target]` | `docs/architecture/<slug>.md` | Designing the system/architecture (consumes the PRD if one exists). |
| `/ae-architect:adr [decision]` | `docs/adr/NNNN-<title>.md` | Recording a significant architectural decision (MADR format). |
| `/ae-architect:analyze` | `docs/architecture/current-state.md` | Brownfield: mapping an existing codebase before designing into it. |
| `/ae-architect:review <path>` | review report | Adversarially reviewing any existing design artifact on its own. |

## Greenfield vs brownfield

- **Greenfield** (no relevant existing code): design is grounded in the PRD and the user's intent.
- **Brownfield** (designing into an existing codebase): run `/ae-architect:analyze` first so the design
  extends *what is actually there* — real components, data flows, conventions, and seams — instead
  of inventing a system that doesn't match reality. The design must cite `current-state.md`.

## Routing guidance

- "I have an idea for an app / feature" → start with `/ae-architect:prd`.
- "How should I structure / architect this?" → `/ae-architect:design` (offer `/ae-architect:prd` first if no PRD).
- "Should we use X or Y? / why did we choose…" → `/ae-architect:adr`.
- "Here's an existing repo, I want to add / change…" → `/ae-architect:analyze`, then `/ae-architect:design`.
- "Is this design any good? / poke holes in this" → `/ae-architect:review`.

When the user's request spans several of these, name the sequence you recommend and let them pick
the entry point — the toolkit is theirs to drive.

## The knowledge behind the rigor

The drafting and review subagents read these sibling skills; you generally don't invoke them
directly, but know they exist so you can point the user at the underlying standards:

- `prd-authoring` — what a complete, master-grade PRD contains.
- `architecture-patterns` — patterns framed as trade-offs (not recommendations).
- `nfr-checklists` — the quality-attribute taxonomy a senior architect carries in their head.
- `adr-authoring` — MADR 4.0 decision-record format and what makes an ADR good.
- `architecture-review-rubric` — the dimensions the principal-reviewer scores against.
