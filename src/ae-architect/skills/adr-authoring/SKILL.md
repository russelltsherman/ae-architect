---
name: adr-authoring
description: >-
  How to author an Architecture Decision Record (ADR) in MADR 4.0 format — capturing a single
  significant technical decision, the options considered, the decision drivers, the outcome, and the
  consequences (good and bad). Read this when recording an architectural decision, documenting why a
  technology or design approach was chosen over alternatives, or superseding a prior decision.
  Primarily read by the system-architect and principal-reviewer subagents in the ae-architect
  plugin.
---

# Authoring an ADR (MADR 4.0)

An ADR captures **one** architecturally significant decision and — crucially — the *reasoning* and
the *alternatives*, so a future engineer (often you, in a year) understands not just what was
decided but why, and what was given up. A decision recorded without its rejected alternatives is
nearly worthless: the value is in the trade-off, not the conclusion.

Record a decision as an ADR when it is **significant**: hard or expensive to reverse, affects
structure or cross-cutting concerns, or where someone will later ask "why on earth did we do it
this way?" Don't ADR trivial or easily-reversible choices — that's noise.

## File and numbering

- Location: `docs/adr/`
- Filename: `NNNN-short-kebab-title.md`, e.g. `0007-use-postgres-for-primary-store.md`
- `NNNN` is a zero-padded sequence number; use the next one above the highest existing ADR.

## MADR 4.0 template

```markdown
# <short title of the decision>

## Status
Proposed | Accepted | Rejected | Deprecated | Superseded by [ADR-NNNN](NNNN-....md)

## Context and Problem Statement
The forces at play and the question being decided, in 2–3 sentences. What's the situation that
makes this decision necessary? Link the PRD or architecture doc if relevant.

## Decision Drivers
- <driver 1 — e.g. must sustain 5k writes/sec>
- <driver 2 — e.g. team already operates Postgres>
- <driver 3 — e.g. strong consistency required for ledger data>

## Considered Options
- Option A
- Option B
- Option C

## Decision Outcome
Chosen option: "<Option X>", because <the deciding rationale tied back to the drivers>.

### Consequences
- Good: <what improves>
- Bad / accepted cost: <what we give up or take on>
- Neutral / follow-up: <new work or risk this introduces>

## Pros and Cons of the Options

### Option A
- Good: <…>
- Bad: <…>

### Option B
- Good: <…>
- Bad: <…>

## More Information (optional)
Links, benchmarks, splikes, related ADRs, and any conditions under which this should be revisited.
```

## What makes an ADR good

- **At least two real options.** A single-option ADR is a decision with the alternatives hidden.
  Even "do nothing" or "keep the status quo" is a legitimate option worth stating.
- **Drivers are concrete.** "Performance" is not a driver; "p99 < 200ms at 5k RPS" is. The decision
  should visibly follow from the drivers.
- **Honest consequences.** Every real decision has downsides. An ADR that lists only upsides isn't
  trustworthy. Name the accepted cost — that's the senior move.
- **Immutable once accepted.** Don't rewrite history. If the decision changes, write a *new* ADR
  and set the old one's status to `Superseded by [ADR-NNNN]`. This preserves the reasoning trail.
- **Scoped to one decision.** If you're tempted to put two decisions in one ADR, split them.

## Example (abbreviated)

**Input:** "We need to pick the primary datastore for the orders service."

**Output:** `0007-use-postgres-for-primary-store.md` with Status: Accepted; drivers naming the
consistency requirement for order/ledger data, the team's existing Postgres operational
experience, and the moderate (not extreme) write volume; Considered Options of Postgres, DynamoDB,
and MongoDB; Decision Outcome choosing Postgres because strong transactional consistency and
existing ops experience outweighed DynamoDB's superior write scaling at a volume the service won't
reach for years; Consequences naming the future sharding work as the accepted cost if volume
eventually exceeds a single primary.
