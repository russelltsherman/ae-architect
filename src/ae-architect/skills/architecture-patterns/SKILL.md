---
name: architecture-patterns
description: >-
  Catalog of software architecture and system-design patterns framed as trade-offs rather than
  recommendations — application structure (monolith, modular monolith, microservices,
  event-driven, serverless), data storage and consistency, communication (sync vs async),
  scaling, caching, and resilience. Read this when designing a system's architecture or weighing
  one structural approach against another, so choices are made on decision drivers and consequences
  instead of fashion. Primarily read by the system-architect and principal-reviewer subagents in
  the ae-architect plugin.
---

# Architecture patterns as trade-offs

Patterns are not goals. A master architect doesn't "use microservices" — they choose a structure
because its trade-offs fit the forces acting on *this* system (team size, scale, change rate,
operational maturity, latency budget). The job of this skill is to keep the reasoning honest:
**name the alternatives, name the decision drivers, name what you give up.**

The default bias for most systems is the *simplest structure that meets the requirements*.
Complexity must be earned by a concrete force, not adopted speculatively. "We might need to scale"
is not a force; "we will exceed single-node write throughput within 12 months" is.

## Application structure

### Monolith (single deployable)
- **Strengths:** simplest to build, test, deploy, and reason about; no network between modules; easy
  transactions; lowest operational burden. The right default for most new systems and small teams.
- **Costs:** scales as one unit; a bad deploy affects everything; can rot into a big ball of mud
  without internal discipline.
- **Choose when:** team is small, domain is not yet well understood, scale is moderate, you value
  speed of iteration.

### Modular monolith
- A monolith with enforced internal module boundaries (clear interfaces, no reaching across).
- **Strengths:** most of the monolith's simplicity, but boundaries are explicit, so it can later be
  split with far less pain. Often the *correct* answer when people reach for microservices.
- **Costs:** discipline required; boundaries are convention unless tooling enforces them.

### Microservices
- **Strengths:** independent deploy/scale/ownership per service; fault isolation; tech heterogeneity;
  scales org *and* system.
- **Costs:** distributed-systems tax — network failure, partial failure, eventual consistency,
  distributed tracing, deployment/orchestration complexity, data spread across stores. Expensive
  to operate; punishing for small teams.
- **Choose when:** multiple teams need independent delivery cadence, parts have genuinely different
  scaling profiles, and you have the operational maturity (CI/CD, observability, on-call) to pay
  the tax. Splitting a poorly-understood domain too early is a classic, costly mistake.

### Event-driven / message-based
- Components communicate via events on a broker (Kafka, SQS, etc.) rather than direct calls.
- **Strengths:** loose coupling, natural buffering and backpressure, easy fan-out, resilience to
  consumer downtime, audit trail.
- **Costs:** eventual consistency, harder to follow end-to-end flow, ordering/duplicate handling,
  debugging is non-linear, broker becomes critical infra.
- **Choose when:** workloads are asynchronous by nature, producers and consumers scale
  independently, or you need to decouple a fan-out.

### Serverless / FaaS
- **Strengths:** no server management, scale-to-zero, pay-per-use, fast to ship small pieces.
- **Costs:** cold starts, execution limits, vendor lock-in, local testing friction, cost surprises
  at sustained high volume, statelessness forces state elsewhere.
- **Choose when:** spiky/low-baseline workloads, glue logic, event handlers; not for sustained
  high-throughput compute.

## Data & storage

- **Relational (Postgres/MySQL):** strong consistency, transactions, flexible queries, mature. The
  right default until a specific access pattern proves it wrong.
- **Document (Mongo, DynamoDB):** flexible schema, horizontal scale, fast key/document access; weak
  cross-document transactions and ad-hoc queries.
- **Key-value (Redis, DynamoDB):** fastest point access, caching, sessions; limited query model.
- **Wide-column (Cassandra):** massive write throughput, tunable consistency; query patterns must be
  designed up front.
- **Search (Elasticsearch/OpenSearch):** full-text and aggregation; not a system of record.
- **Graph (Neo4j):** relationship-heavy traversal; niche.
- **Decision drivers:** access patterns first (read/write ratio, query shapes), then consistency
  needs, then scale. Polyglot persistence is legitimate but every extra store is operational cost.
- **Consistency:** prefer strong consistency until a requirement (latency, availability,
  partition tolerance, scale) forces eventual — and when it does, state explicitly *where* the
  system is eventually consistent and *why that's acceptable* for that data.

## Communication

- **Synchronous (REST/gRPC):** simple mental model, immediate response, easy to debug; but couples
  caller availability/latency to callee, and risks cascading failure.
- **Asynchronous (queue/event):** decoupling, buffering, resilience; but eventual consistency and
  harder flow tracing.
- **Rule of thumb:** synchronous for request/response a user is waiting on; asynchronous for work
  that can happen later or fan out. Guard every sync call with timeouts, retries (with backoff +
  jitter), and circuit breakers.

## Scaling & resilience building blocks

- **Stateless services + horizontal scale:** the workhorse; push state to data stores/caches.
- **Caching:** huge wins, but invalidation is hard — be explicit about TTLs, staleness tolerance,
  and the cache-stampede story. Cache only what's worth it.
- **Load balancing & autoscaling:** on which signal, with what min/max, and what's the scale-up lag?
- **Database scaling:** read replicas (read scaling, replica lag), then partitioning/sharding (write
  scaling, big complexity jump — defer until a real ceiling is in sight).
- **Resilience patterns:** timeouts, retries with backoff+jitter, circuit breakers, bulkheads, rate
  limiting, graceful degradation, idempotency keys. Name which ones the design relies on.

## Cross-cutting structure

- **Layering / hexagonal / ports-and-adapters:** isolate domain logic from I/O so the core is
  testable and infrastructure is swappable. Worth it as systems grow.
- **CQRS:** separate read and write models when their shapes/scale diverge sharply. Powerful but
  adds complexity and often eventual consistency — don't reach for it by default.
- **API gateway / BFF:** centralize cross-cutting concerns (auth, rate limiting, routing) at the
  edge; backend-for-frontend tailors APIs per client.

## Using this well

For each significant structural decision, produce a short trade-off record: the **options
considered**, the **decision drivers** that matter for this system, the **choice**, and the
**consequences** (what improves, what you accept as a cost, what risks it introduces). That record
is exactly what becomes an ADR — see `adr-authoring`.
