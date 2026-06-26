---
name: nfr-checklists
description: >-
  Quality-attribute (non-functional requirement) taxonomy and prompting checklists used when
  authoring or reviewing a PRD, architecture document, or ADR. Read this when you need to make sure
  a design deliberately accounts for performance, scalability, availability, security, cost,
  operability, observability, compliance, and the other "-ilities" — the considerations a senior
  architect raises before anyone writes code. Primarily read by the requirements-analyst,
  system-architect, and principal-reviewer subagents in the ae-architect plugin.
---

# Non-functional requirements: the architect's checklist

Functional requirements say *what the system does*. The difference between a competent design and
a master's design is almost always in the **non-functional** requirements — the qualities that
decide whether the system survives contact with real traffic, real failures, real budgets, and
real auditors. A senior architect treats these as first-class, not an afterthought.

Use this as a prompting tool: for the system in question, walk each attribute and ask "does the
design have a deliberate, *justified* position on this — with a number where a number belongs?"
A non-answer ("it should be fast") is a finding, not a requirement.

## How to use this

1. Not every attribute matters equally for every system — a batch ETL job and a payments API have
   very different profiles. **Explicitly rank** which attributes are dominant for *this* system and
   say why. Naming the ones that *don't* matter much is itself a sign of rigor.
2. For each dominant attribute, capture a **measurable target** (a number, a percentile, a budget)
   and the **scenario** it applies to. "p99 read latency < 200ms at 5k RPS" beats "low latency."
3. Tie each target back to a **business or user driver** — performance and availability cost money;
   over-engineering them is as much a failure as under-engineering them.

## The quality attributes

### Performance
Latency (p50/p95/p99), throughput, and the load level each is measured at. What's the expected
request rate, and the peak-to-average ratio? Where are the hot paths? What's the acceptable
response time from the *user's* perspective vs. the internal budget per hop?

### Scalability
Expected growth in users, data, and request volume over 1–3 years. Does the system scale
horizontally or is something inherently single-instance? Where's the first bottleneck as load
grows (usually the database or a shared lock)? Stateless vs. stateful components, and how state
is partitioned/sharded.

### Availability & reliability
Target (e.g. 99.9% vs 99.99% — know the downtime budget each implies). Single points of failure.
Blast radius of any one component failing. Redundancy, failover, and how long failover takes.
Degraded-mode behavior: what *still works* when a dependency is down? Retry/timeout/circuit-breaker
posture. RTO/RPO for disaster recovery.

### Data integrity & consistency
Consistency model (strong vs eventual) and whether the use case actually tolerates eventual
consistency. Transaction boundaries. Idempotency of writes and of message handlers. How
duplicate/out-of-order events are handled. Backup, restore, and the last time restore was tested.

### Security
AuthN and AuthZ model. Data classification — what's sensitive, and is it encrypted in transit and
at rest? Secrets management. The trust boundaries and the attack surface at each. Input validation
and injection risks. Audit logging of security-relevant events. Principle of least privilege for
every component and credential.

### Privacy & compliance
Regulatory regimes in scope (GDPR, HIPAA, PCI-DSS, SOC 2, etc.). PII inventory and data-residency
constraints. Retention and deletion (right-to-be-forgotten). Consent and data-processing records.

### Observability
Logs, metrics, and traces — what's emitted and is it enough to debug a 2am incident? The key SLIs
and how they map to SLOs. Alerting on symptoms (user-facing) vs causes. Correlation IDs across
service boundaries. Can you answer "is it the app, the DB, or the network?" from the dashboards?

### Operability & maintainability
Deployment model and rollback story. Zero-downtime deploys? Config vs. code. Feature-flagging.
Runbooks for known failure modes. On-call burden. How a new engineer onboards to the codebase.
Coupling and cohesion of modules; how change-resistant the design is.

### Cost
Infra cost at expected and peak scale — order of magnitude, not to the penny. The cost drivers
(egress, storage, compute, managed-service premiums). Cost-vs-performance trade-offs made
explicit. Build-vs-buy for each major capability.

### Portability & interoperability
Cloud/vendor lock-in and whether that's an accepted trade-off. Standards/protocols at integration
points. API versioning and backward-compatibility strategy.

### Usability & accessibility (where user-facing)
The critical user journeys and their performance/reliability budgets. Accessibility requirements
(e.g. WCAG) if there's a UI.

## The "have you considered…" prompts

A master architect reflexively asks these. Use them to pressure-test any design:

- What happens at 10× the expected load? At 100×?
- What's the single worst component to lose, and what's the blast radius?
- Where does this lose data, and is that acceptable?
- What does this look like when a downstream dependency is slow (not down — *slow*)?
- How do we know it's broken before a user tells us?
- How do we roll this back if the deploy is bad?
- Who can access this data, and how would we know if someone exfiltrated it?
- What's the most expensive thing here, and is it worth it?
- What's the migration path from the current state (brownfield), and how do we do it without a
  flag day?
- What did we deliberately *not* build, and why is that the right call for now?
