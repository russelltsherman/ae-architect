---
description: Record a significant architectural decision as a MADR-format ADR, reviewed before it lands.
argument-hint: [the decision to record]
---

# /ae-architect:adr — Architecture Decision Record

Record the architectural decision: **$ARGUMENTS**

(If no decision was given, ask the user which decision to record — or offer the ADR candidates from
the most recent `/ae-architect:design` run.)

Produce a MADR 4.0 ADR via the **draft → review → revise** loop. Use subagents.

## Steps

1. **Resolve number & path.** List `docs/adr/` and find the highest existing `NNNN`. The new ADR is
   the next number, zero-padded to 4 digits. Derive a kebab-case title; target file:
   `docs/adr/NNNN-<title>.md`. (Note: if two ADRs are created at once the numbers can collide —
   check before writing.)

2. **Draft.** Spawn the `system-architect` subagent with: the decision ($ARGUMENTS), the target
   path, and pointers to the PRD/architecture doc for context. Instruct it to consult the
   `adr-authoring` skill and produce a complete MADR record — **at least two real options**,
   concrete decision drivers, a decision outcome that follows from the drivers, and honest
   consequences (including the accepted cost).

3. **Review.** Spawn the `principal-reviewer` subagent on the drafted ADR. The key blocking checks:
   are there genuine alternatives, are drivers concrete (not "performance" but a number/criterion),
   and are the downsides stated honestly? Returns PASS/REVISE.

4. **Revise loop.** On REVISE, revise via `system-architect` with the findings, re-review. Up to
   **3 rounds**.

5. **Report.** Tell the user the ADR path, its status (default `Accepted` unless they indicated
   it's still proposed), and the verdict. If this decision supersedes a prior ADR, update the old
   one's status to `Superseded by [ADR-NNNN]`.
