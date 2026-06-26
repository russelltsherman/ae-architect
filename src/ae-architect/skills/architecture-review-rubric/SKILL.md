---
name: architecture-review-rubric
description: >-
  The adversarial review rubric used to red-team a PRD, architecture document, or ADR — the
  dimensions a principal architect scores against (completeness, grounding, NFR coverage, trade-off
  rigor, failure modes, internal consistency, feasibility, cost/scale realism) and the blocking vs
  advisory severity model. Read this when reviewing or critiquing a design artifact, or when you
  want a design to survive expert scrutiny before it ships. Primarily read by the principal-reviewer
  subagent in the ae-architect plugin.
---

# Architecture review rubric (adversarial)

Your posture as reviewer is **skeptical by default**. You are not here to validate the draft — you
are here to find what a master architect would catch and what would embarrass the team in
production or in front of an auditor. Assume the draft is incomplete until proven otherwise. A
review that rubber-stamps a flawed artifact is a failure of the review, not a success of the draft.

But be fair and specific: every finding must be **actionable** and **grounded** — point at the
exact gap and say what would resolve it. Vague disapproval is as useless as vague design.

## Severity model

- **Blocking** — the artifact is not done until this is addressed. Missing or hand-waved coverage
  of a dimension that matters for this system; a decision with no justification; an internal
  contradiction; a design that doesn't actually satisfy a stated requirement.
- **Advisory** — worth improving but not a gate. Stylistic gaps, nice-to-have depth, minor
  unstated assumptions on low-risk attributes.

Report blocking findings first, each with: the dimension, what's wrong, why it matters, and what
would fix it. Then advisory findings. End with an explicit verdict: **pass** (no blocking findings)
or **revise** (one or more blocking findings).

## The dimensions

### 1. Completeness — no hand-waving
Are all the sections that matter present and substantive? Watch for filler that *looks* like
content but says nothing ("the system will be scalable and secure"). Empty NFR sections, missing
non-goals, absent success metrics, and "TBD"s on load-bearing decisions are blocking.

### 2. Grounding — claims tied to reality
Are claims backed? For a PRD, is the problem evidenced rather than asserted? For an architecture
doc on an existing codebase, does it cite the current-state map (`docs/architecture/current-state.md`)
and extend real components — or does it invent a system that doesn't match what's there? Designs
divorced from reality are blocking.

### 3. NFR coverage
Does the artifact deliberately address the quality attributes that dominate this system, *with
measurable targets*? Cross-check against the nfr-checklists skill. The dominant attributes for the
system's domain (e.g. consistency for payments, latency for trading, availability for infra) must
be present and quantified. Missing a dominant attribute is blocking; missing a minor one is
advisory.

### 4. Trade-off rigor
For each significant decision: are real alternatives named, are the decision drivers concrete, and
does the choice visibly follow from the drivers? A decision presented with no alternatives, or
justified only by assertion/fashion, is blocking. "We used X because it's modern/popular" is a
finding.

### 5. Failure modes & risks named
Does the design say what happens when things break — a dependency is slow or down, a node dies,
the queue backs up, the deploy is bad? Are single points of failure and blast radius identified?
Are risks listed honestly? A design that only describes the happy path is blocking for anything
non-trivial.

### 6. Internal consistency
Does the architecture actually satisfy the PRD's functional and non-functional requirements? Do
the components, data flows, and chosen tech align with each other and with the stated targets? A
99.99% availability requirement with a single-instance database is a contradiction — and a
blocking finding.

### 7. Feasibility & operability
Can this team actually build and *operate* this with their size and maturity? Is the operational
burden (services to run, on-call load, deployment complexity) proportional to the team? Premature
microservices for a three-person team is a feasibility finding.

### 8. Cost & scale realism
Are scale assumptions realistic (not fantasy hockey-sticks, not naive under-provisioning)? Is
there an order-of-magnitude sense of cost and its drivers? Does the design over-engineer for scale
that won't arrive, or under-engineer for scale that will? Both are findings.

## Calibration

- Match scrutiny to stakes: a throwaway internal tool and a payments platform get different bars.
  Say which bar you're applying.
- Don't invent requirements the artifact never claimed — review against its stated scope and the
  attributes genuinely relevant to its domain, not a maximalist checklist.
- Distinguish "missing because out of scope (and said so)" from "missing because overlooked." The
  former is fine; the latter is a finding.
- Credit what's done well briefly, so the author can tell signal from noise — but lead with the
  gaps. The goal is an artifact that survives a principal architect's scrutiny.
