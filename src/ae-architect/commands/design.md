---
description: Design the system architecture, then adversarially review and revise it until it passes.
argument-hint: [system/feature to design]
---

# /ae-architect:design — Architecture design

Design the architecture for: **$ARGUMENTS**

(If no target was given, infer it from the most recent PRD under `docs/prd/`, or ask the user.)

Orchestrate the **draft → adversarial review → revise** loop using subagents so drafting and review
stay independent. Do not design in the main thread.

## Steps

1. **Resolve scope & path.** Derive a short kebab-case `<slug>` (reuse the PRD's slug if designing
   from one). Target file: `docs/architecture/<slug>.md`. Read the relevant PRD under `docs/prd/`
   if it exists — the design must satisfy it.

2. **Ground brownfield work.** Determine greenfield vs brownfield. If there's an existing codebase:
   - If `docs/architecture/current-state.md` exists, the design will cite it.
   - If it's missing and the codebase is non-trivial, **offer to run `/ae-architect:analyze` first** so the
     design extends the real system instead of inventing structure. Proceed without it only if the
     user declines or it's genuinely greenfield.

3. **Draft.** Spawn the `system-architect` subagent with: the target ($ARGUMENTS), the output path
   `docs/architecture/<slug>.md`, the PRD path (if any), and greenfield/brownfield context. It
   writes the architecture doc and lists ADR candidates.

4. **Review.** Spawn the `principal-reviewer` subagent with the path to the drafted design. It
   returns PASS/REVISE with blocking and advisory findings, checking that the design actually
   satisfies the PRD and is grounded in current-state for brownfield.

5. **Revise loop.** On REVISE, spawn `system-architect` again with the blocking findings to revise
   in place, then re-review. Repeat until PASS or **3 rounds**.

6. **Report.** Tell the user where the design is, the final verdict, residual findings, the riskiest
   assumptions, and the **ADR candidates** — suggest `/ae-architect:adr` to record the significant ones.
