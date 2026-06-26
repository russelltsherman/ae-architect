---
description: Draft a master-grade PRD from an idea, then adversarially review and revise it until it passes.
argument-hint: [idea or feature request]
---

# /ae-architect:prd — Product Requirements Document

Produce a master-grade PRD for: **$ARGUMENTS**

(If no idea was given above, ask the user what they want a PRD for before proceeding.)

Orchestrate the **draft → adversarial review → revise** loop. Do not write the PRD yourself in the
main thread — use the subagents so the drafting and the review are independent.

## Steps

1. **Resolve scope & path.** Derive a short kebab-case `<slug>` from the idea. Target file:
   `docs/prd/<slug>.md`. If a PRD already exists there, read it — this is a refinement, not a
   fresh start. Detect greenfield vs brownfield (is there an existing codebase?); if brownfield and
   `docs/architecture/current-state.md` is missing, mention that `/ae-architect:analyze` would strengthen
   grounding, but don't block the PRD on it.

2. **Draft.** Spawn the `requirements-analyst` subagent. Give it: the idea/$ARGUMENTS, the target
   path `docs/prd/<slug>.md`, any existing PRD content, and whether it's greenfield/brownfield.
   It writes the PRD.

3. **Review.** Spawn the `principal-reviewer` subagent. Give it the path to the drafted PRD. It
   returns a verdict (PASS/REVISE) with blocking and advisory findings.

4. **Revise loop.** If the verdict is REVISE, spawn `requirements-analyst` again with the blocking
   findings and have it revise the PRD in place, then re-review. Repeat until PASS or **3 rounds**
   have elapsed — whichever comes first.

5. **Report.** Tell the user where the PRD is, the final verdict, and:
   - any residual findings (advisory, or blocking ones still open if you hit the 3-round cap),
   - the key open questions and assumptions the PRD surfaced — the things most likely to be wrong.
   Suggest `/ae-architect:design` as the natural next step.

Keep the loop honest: surface remaining gaps rather than declaring success prematurely.
