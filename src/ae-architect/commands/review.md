---
description: Adversarially review an existing design artifact (PRD, architecture doc, or ADR) on demand.
argument-hint: <path to artifact>
---

# /ae-architect:review — Adversarial review of a design artifact

Run a principal-architect review against an existing artifact: **$ARGUMENTS**

(If no path was given, ask the user which artifact to review, or offer the most recent one under
`docs/prd/`, `docs/architecture/`, or `docs/adr/`.)

## Steps

1. **Locate the artifact** at the given path and confirm its type (PRD / architecture doc / ADR)
   from its location and content.

2. **Spawn the `principal-reviewer` subagent** with the artifact path. It reads the
   `architecture-review-rubric` and `nfr-checklists` skills, plus any grounding it needs (the PRD
   for a design review, `docs/architecture/current-state.md` for a brownfield design), and returns
   a PASS/REVISE verdict with blocking and advisory findings.

3. **Report the review verbatim-faithfully** to the user — verdict, blocking findings (each with
   why it matters and what would fix it), advisory findings, and what's done well. Do **not** edit
   the artifact unless the user asks; this command reviews, it doesn't revise. If they want it
   fixed, point them at the matching drafting command (`/ae-architect:prd`, `/ae-architect:design`, `/ae-architect:adr`), which
   runs the full revise loop.
