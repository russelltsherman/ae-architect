---
name: prd-authoring
description: >-
  Standard and structure for authoring a master-grade Product Requirements Document (PRD) — the
  problem, goals and explicit non-goals, users and journeys, functional requirements, non-functional
  requirements, success metrics, constraints, assumptions, risks, and open questions. Read this when
  writing or reviewing a PRD so it captures the right problem at the right altitude before any design
  begins. Primarily read by the requirements-analyst and principal-reviewer subagents in the
  ae-architect plugin.
---

# Authoring a master-grade PRD

A PRD's job is to make everyone agree on **the problem and what success looks like** *before*
anyone argues about the solution. The most common failure is jumping to features and skipping the
problem — a master-grade PRD is ruthless about staying at the "what and why," and defers the "how"
to the architecture phase.

Two principles drive quality:

1. **Problem before solution.** If the PRD reads like a spec for a solution someone already
   decided on, it's failing. Lead with the problem and the evidence it's real.
2. **Falsifiable success.** Every goal must have a metric that could later prove the project
   failed. Vague goals ("improve the experience") are how projects avoid accountability.

## Output structure

Use this structure. Adapt section depth to the size of the effort, but don't silently drop a
section — if something is genuinely N/A, say so and why.

```
# PRD: <Title>

## Metadata
Author · Date · Status (Draft/Review/Approved) · Stakeholders · Related docs

## 1. Problem statement
What problem, for whom, and the evidence it's real and worth solving. The cost of NOT solving it.

## 2. Goals & non-goals
- Goals: the outcomes this delivers (outcomes, not features).
- Non-goals: what is explicitly OUT of scope, so scope creep has something to bounce off.

## 3. Users & use cases
Personas/segments and the key user journeys (as user stories or scenarios). The primary journey
called out as primary.

## 4. Functional requirements
What the system must do, prioritized (e.g. MoSCoW: Must/Should/Could/Won't). Each requirement
testable and unambiguous. User stories with acceptance criteria where it helps.

## 5. Non-functional requirements
Performance, scale, availability, security, compliance, etc. — with measurable targets. See the
nfr-checklists skill; pull in the attributes that dominate THIS system and give each a number.

## 6. Success metrics
How we'll know it worked. SMART (Specific, Measurable, Achievable, Relevant, Time-bound). Include
the baseline and the target. Distinguish leading from lagging indicators.

## 7. Constraints & assumptions
Hard constraints (budget, deadline, tech mandates, regulatory). Assumptions being made — each one
a risk if wrong, so state them so they can be challenged.

## 8. Risks & open questions
Known risks with likelihood/impact and any mitigation. Open questions that must be resolved, with
an owner where possible.

## 9. Out of scope / future
Explicitly deferred items, so "later" is recorded rather than forgotten or silently dropped.
```

## What separates master-grade from mediocre

- **Outcomes over features.** "Reduce checkout abandonment" is a goal; "add a progress bar" is a
  proposed solution masquerading as a goal.
- **Explicit non-goals.** The willingness to write down what you're *not* doing is a strong signal
  of senior thinking — it's what prevents scope creep later.
- **Measurable everything.** Replace "fast," "scalable," "secure," "intuitive" with numbers or
  defined criteria. If you can't measure it, you can't tell if you delivered it.
- **Assumptions surfaced, not buried.** Every "we assume…" is a future incident if it's wrong.
  Listing them invites the cheap challenge now instead of the expensive surprise later.
- **Honest risks.** A PRD with no risks is hiding them. Name the things that could sink this.
- **Right altitude.** No premature architecture. The PRD says *what* and *why*; `/ae-architect:design` owns
  the *how*. If the PRD is dictating database choices, it's too low.

## Interview the requester

A PRD is only as good as its inputs. Before/while drafting, probe the gaps a senior PM/architect
would: Who exactly is the user and what do they do today instead? How do we measure success, and
what's the baseline? What's explicitly out of scope? What's the hard deadline or budget? What
happens if we do nothing? Which assumptions are we betting on? Surface these rather than inventing
answers — an invented requirement is worse than an open question.
