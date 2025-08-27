---
description: 'Principal Architect'
applyTo: '**/*'
---

Principal Architect Instruction Set
==================================

Concise, technology‑agnostic guardrails for building evolvable, observable, secure, high‑quality systems. Treat every rule as the default. Any material deviation MUST be justified by an Architecture Decision Record (ADR) that states reason, risk, mitigation, and revisit trigger.

Quick Navigation
----------------

1. Core Principles
2. Layering Contract
3. Design Guardrails
4. Telemetry & Metrics Contract
5. Error & Failure Strategy
6. Security & Privacy Baseline
7. Performance & Scalability
8. Concurrency & Idempotency
9. Evolution & Migration
10. Documentation & ADR Rules
11. Code Review Checklist
12. Anti‑Patterns (Always Refactor)
13. AI / Automation Guardrails
14. Minimal Use Case Template
15. Quality Gates (CI)
16. Pre‑Merge Readiness
17. Deviation Protocol
18. Core Pattern Capsules
19. Architect Ethos

---

Core Principles (Non‑Negotiable)
--------------------------------

| Principle | Summary | Failure Smell |
|-----------|---------|---------------|
| Domain Isolation | Business logic free of frameworks / transport / persistence concerns | Domain imports HTTP / ORM / logger directly |
| Ports First | Define an interface before introducing / replacing external capability | Adapter coded directly against vendor SDK |
| Single‑Intention Use Cases | Each use case = one business verb phrase | God use case branching across unrelated flows |
| Event ≠ Everything | Emit domain events only for cross‑aggregate / cross‑context value | Dozens of granular events with 0 consumers |
| Immutability Bias | Value Objects & DTOs immutable; mutate only inside aggregate invariants | Setters everywhere / shared mutable state |
| Built‑In Observability | Start + finish logs + outcome + duration + metrics | No correlation id or duration visibility |
| Evolutionary Simplicity | Complexity introduced only after measured constraint | Premature CQRS / microservices w/out metrics |
| Security & Privacy by Design | Least privilege, mask sensitive data, externalize secrets | Secrets in repo / PII in logs |
| Additive Versioning | Extend first, deprecate later with plan | Breaking change merged without compatibility path |

---

Layering Contract
-----------------

| Layer | Responsibility | MUST NOT |
|-------|----------------|----------|
| Domain | Entities, value objects, invariants, policies, domain events | Framework & transport calls, DB APIs, logging APIs |
| Application | Orchestrate use cases, coordinate ports, emit events + telemetry | Embed core business rules or validation logic |
| Ports | Abstract external capabilities (persistence, messaging, remote services) | Leak vendor names (e.g. Kafka*, MySql*) |
| Adapters | Concrete IO (DB, HTTP, MQ, CLI, UI) implementing ports | Decide domain branching |
| Inbound (Controller / Handler) | Input mapping, authN/Z, validation, call use case | Perform orchestration logic |

Bounded Context = cohesive domain language boundary. Cross boundary → prefer domain events or Anti‑Corruption Layer (ACL).

---

Design Guardrails
-----------------

| Concern | Guideline | Reject If |
|---------|----------|-----------|
| Repeated Primitive Validation | Elevate to Value Object ≥3 occurrences OR domain rule encoded | Duplication persists |
| Repository Surface | Express intent (e.g. `findPendingApprovals`) | Generic CRUD leak to app layer |
| Constructors | Keep trivial; use factory for multi‑step invariants | Constructor doing branching / heavy IO |
| Policies / Specs | Isolate complex decision logic | Use case full of nested conditionals |
| Composition > Inheritance | Only explicit extension points (document) | Deep inheritance chain |
| Port Versioning | Add new interface v2 → migrate → deprecate timeline | In‑place breaking changes |

---

Telemetry & Metrics Contract
----------------------------

Log format: JSON line (preferred). Required fields: `action`, `phase (start|finish)`, `correlation_id`, `outcome (success|failure [finish])`, `duration_ms (finish)`, optional: `entity`, `entity_id`, `error_type`.

Example:

```json
{"action":"notify_inactive_users","phase":"start","correlation_id":"..."}
{"action":"notify_inactive_users","phase":"finish","outcome":"success","duration_ms":123}
```

Correlation: Accept `request-id` then `x-correlation-id`; generate UUIDv4 if absent; propagate.

Metrics (RED minimum):

| Metric | Type | Example Name |
|--------|------|--------------|
| Throughput | Counter | `user_marked_inactive_total` |
| Latency | Histogram | `notify_inactive_users_duration_ms` |
| Errors by Class | Counter | `notify_inactive_users_errors_total{error_type=timeout}` |
| Backlog / Queue | Gauge | `email_dispatch_backlog` |

Rules:

1. One start + one finish log per use case.
2. No multi‑line stack traces in primary log (attach structured field or trace system).
3. High‑cardinality labels strictly controlled.

---

Error & Failure Strategy
------------------------

Taxonomy: `validation | domain_invariant | external_io | timeout | auth | permission | conflict | unexpected`.

| Scenario | Action |
|----------|--------|
| Domain invariant breach | Throw specific domain exception → map to stable boundary code |
| Transient external IO | Retry (exponential + jitter) ONLY if idempotent |
| Logging | Log once at boundary; inner layers enrich / rethrow only |
| Conflicts | Use optimistic concurrency (version / ETag) |
| User Messages | Sanitize; sensitive detail only in secure logs |

---

Security & Privacy Baseline
---------------------------

| Area | Requirement | Reject If |
|------|------------|-----------|
| Input Validation | Normalize & validate at boundary | Raw unvalidated input reaches domain |
| Persistence | Parameterized queries only | String concatenated SQL |
| Secrets | Externalized (env / secret store) | Checked‑in credentials |
| Logging | Mask tokens (first 4 + last 2), partial email | Full secrets / PII logged |
| Outbound URLs | Allow‑list + deny internal IPs (SSRF) | Direct user URL fetch w/out validation |
| PII | Minimum necessary + hashing when feasible | Excess personal data stored/logged |
| Config Objects | Immutable after bootstrap | Runtime mutation of global config |

---

Performance & Scalability
-------------------------

1. Detect & test for N+1 (integration tests count queries / calls).
2. Caching via explicit decorator only (document TTL, invalidation trigger + metrics).
3. Prefer streaming / cursor pagination over full materialization.
4. Batch + parallel safe external calls within rate limits using shared policy.
5. Introduce async only after metrics prove sync bottleneck.

---

Concurrency & Idempotency
-------------------------

Idempotency Techniques: natural key uniqueness, idempotency key store (key→hash/outcome), dedupe TTL table, optimistic locking.

| Rule | Rationale |
|------|-----------|
| External retriable trigger MUST be idempotent | Safe client retries |
| No global mutable state | Predictable concurrency |
| Ordering only if required by business observability | Avoid unnecessary coupling |

Composition Order (outer→inner): Idempotency → Caching → Retry → Metrics → Core.

---

Evolution & Migration
---------------------

| Change | Pattern | Success Signal |
|--------|--------|----------------|
| Extract bounded context | Publish contracts → carve adapters → migrate persistence | Independent deployment + stable SLA |
| Replace external system | Dual‑write / shadow read behind flag | Parity metrics & error budget met |
| Introduce async | Keep sync fallback until async p95 + failure improved | Async < baseline p95; error rate within budget |
| Add cache | Baseline → decorator → validate correctness + hit ratio | Target hit ratio w/out stale bugs |
| Port change | Add v2 interface → migrate → deprecate v1 | All callers off v1 before removal |

---

Documentation & ADR Rules
-------------------------

ADR Required For: new bounded context, data store, cross‑cutting framework, breaking API, security model shift.

ADR Template: Context → Options → Decision → Consequences (short/long) → Migration/Sunset → Owner → Review Date.

Deviation (no ADR yet): PR must state Reason / Risk / Mitigation / Revisit Trigger / Owner.

Each new domain concept: short rationale (docblock or local README) describing purpose + invariants.

---

Code Review Checklist (Architect Focus)
--------------------------------------

| Check | Pass? |
|-------|-------|
| Domain purity (no framework leakage) |  |
| Intent‑based repositories (no CRUD leak) |  |
| Value Objects extracted (or rationale documented) |  |
| Ports defined before adapters |  |
| Telemetry (start, finish, correlation, outcome, duration) |  |
| Meaningful events only (no noise) |  |
| Specific exceptions mapped; no broad swallow |  |
| Secrets / PII masked |  |
| Performance watchpoints addressed (N+1, caching, batching) |  |
| Test coverage ≥ 80% changed lines |  |
| Idempotency strategy in place (where needed) |  |
| ADR(s) added/updated for architectural deltas |  |

---

Anti‑Patterns (Immediate Refactor)
---------------------------------

Fat controllers/handlers; generic Helper/Manager/Utils buckets; passing untyped maps; silent or broad catch; hidden side effects; premature microservices / async; event spam.

---

AI / Automation Guardrails
--------------------------

1. Reject code violating dependency direction.
2. Prefer Value Object extraction over duplicated validation logic.
3. Add tests + start/finish telemetry for any new port or adapter.
4. Classify errors with taxonomy; no blanket catches.
5. Ask for domain language clarification when ambiguous.

---

Minimal Use Case Template
-------------------------

```text
use_case NotifyInactiveUsers
  log {action: notify_inactive_users, phase: start, correlation_id}
  // domain orchestration
  log {action: notify_inactive_users, phase: finish, outcome: success, duration_ms}
end
```

---

Quality Gates (CI Baseline)
--------------------------

1. Static analysis: no new violations
2. Unit tests (domain + application) fast
3. Integration tests (adapters)
4. End‑to‑end smoke (critical path)
5. Security / dependency scan (fail high severity)
6. Coverage ≥ 80% changed lines (non‑decreasing overall)
7. Performance watch: key latency p95 within SLO

---

Pre‑Merge Readiness
-------------------

| Item | Status |
|------|--------|
| Quality gates green |  |
| Telemetry complete (start/finish) |  |
| Error taxonomy applied |  |
| Idempotency validated (where needed) |  |
| Performance risks reviewed |  |
| Cache invalidation + metrics (if added) |  |
| Secrets externalized |  |
| Docs / API spec / CHANGELOG updated |  |
| ADR(s) created/updated |  |
| Deprecations communicated |  |

---

Deviation Protocol
------------------

If a rule must be broken create or reference an ADR OR add PR deviation note:

`Reason → Accepted Risk → Mitigation / Monitoring → Revisit Trigger (metric/date) → Owner`.

Add TODO + issue link if remediation deferred. Maintain optional deviation index for periodic review.

---

Core Pattern Capsules (Condensed)
---------------------------------

| Pattern | Use When | Key Rules | Smells |
|---------|----------|-----------|--------|
| Caching Decorator | Latency / rate limit + tolerable staleness | TTL, invalidation, hit/miss metrics | No invalidation; negative cache w/out TTL |
| Retry Decorator | Transient idempotent ops | Exponential + jitter, cap, classify | Retrying non‑idempotent mutation |
| Idempotency Guard | External retriable mutation | Atomic key store, hash consistency | No TTL (unbounded growth) |
| Metrics Wrapper | Critical path or external call | Start/finish, outcome, error_type | Missing error labels |
| Circuit Breaker | Flaky / spiking dependency | Threshold → open → half‑open probe | Breaker on non‑idempotent ops |
| Outbox | Reliable event emission | PENDING → publish → DISPATCHED | No index(status, created_at) |
| Cursor Iterator | Large ordered traversal | Opaque cursor, max page size | Resort after fetch |
| ACL (Anti‑Corruption Layer) | Isolate legacy / external model | Translate vocabulary inbound/outbound | Domain leaking external types |

---

Architect Ethos
---------------

Default to the simplest design that is: **Correct → Observable → Secure → Evolvable**. Complexity must “pay rent” via measurable value (latency, resilience, autonomy, cost).

---

Opinionated guardrails to keep architecture lean, testable, observable, secure, and evolvable. Treat them as the default contract. Any material deviation REQUIRES an ADR with rationale + mitigation + revisit trigger. Optimize for clarity and measured need (not novelty).

---

## 0. Quick Reference (TL;DR)

| Area | Rule (Essence) | If Violated → Do This |
|------|----------------|-----------------------|
| Domain Purity | No framework / IO leakage | Refactor behind port / mapper |
| Ports First | Introduce interface before adapter | Write interface, add tests, then impl |
| Use Cases | Single intent + orchestration only | Extract policy/value object / spec |
| Events | Only for cross-aggregate/context value | Collapse noise; inline trivial logic |
| Immutability | DTOs & value objects are immutable | Replace setters with factories |
| Telemetry | Log start + finish (+ outcome/duration) | Add paired logs + histogram metric |
| Security | Secrets external; validate inputs | Add boundary validation & secret ref |
| Versioning | Additive-first; deprecate w/ timeline | Add v2 port + ADR + CHANGELOG entry |
| Caching | Decorator w/ invalidation + metrics | Add TTL + hit/miss counters + ADR |
| Idempotency | All retried external triggers safe | Add key store / natural unique guard |

---

## 1. Core Principles (Non‑Negotiable)

1. Domain Isolation – Business rules know nothing about transport, persistence, frameworks, UI.
2. Ports Before Adapters – Define capabilities as interfaces first; implementations can churn safely after.
3. Single‑Intention Use Cases – One verb phrase. Orchestrate; delegate decision logic to policies/specs.
4. Events Over Chains (Selective) – Emit only when another aggregate/context benefits; avoid event spam.
5. Immutability Bias – Value objects / DTOs immutable; mutation limited to aggregate methods enforcing invariants.
6. Built‑In Observability – Start + finish logs (JSON) plus latency histogram + success/error counters.
7. Evolutionary Simplicity – Introduce complexity (microservices/CQRS/event sourcing) only after metric‑proven constraint.
8. Security & Privacy First – Least privilege, secrets external, PII minimized + masked in telemetry.
9. Additive Versioning – Backwards compatible extensions preferred; explicit deprecation path.

---

## 2. Layer Responsibilities & Boundaries

| Layer | Responsibility | Forbidden |
|-------|----------------|-----------|
| Domain | Entities, value objects, invariants, domain events | Framework / DB / HTTP / logging APIs |
| Application | Use case orchestration, port coordination, emitting events + telemetry | Core business rule branching |
| Ports (Interfaces) | Abstract external capabilities (storage, messaging, services) | Technology‑specific naming |
| Adapters | Concrete IO (DB, HTTP, MQ, CLI, UI) fulfilling ports | Business orchestration |
| Inbound (Controllers / Handlers) | Input mapping, authN/Z, validation, trigger use case | Cross‑aggregate logic |

Bounded Context: Coherent domain language boundary. Cross-context integration favors events or ACL (anti‑corruption layer).

---

## 3. Design Guardrails

| Concern | Guideline | Rationale |
|---------|-----------|-----------|
| Repeated Primitive Validation | Promote to Value Object after ≥3 occurrences | Reduces drift + duplication |
| Repository Surface | Intent methods (e.g., `findPendingApprovals`) not CRUD leaks | Express domain language |
| Constructors | Keep trivial; use factories for multi-step invariants | Prevent constructor bloat |
| Policies / Specs | Encapsulate branching rules outside use case | Keeps orchestrators lean |
| Composition > Inheritance | Only inherit at explicit extension points (document) | Predictable evolution |
| Port Changes | Add new interface version; migrate; deprecate | Safe incremental evolution |

---

## 4. Telemetry & Metrics (Minimum Contract)

Logging: JSON line per event. Required fields: `action`, `phase (start|finish)`, `correlation_id`, `outcome (success|failure on finish)`, `duration_ms (finish)`, `error_type (on failure)`, optional `entity`, `entity_id`.

Example:

```
{"action":"notify_inactive_users","phase":"start","correlation_id":"..."}
{"action":"notify_inactive_users","phase":"finish","outcome":"success","duration_ms":123}
```

Correlation: Accept (`request-id`, `x-correlation-id`) precedence; generate UUIDv4 if absent; propagate.

Metrics (at minimum):

| Metric Type | When | Naming Example |
|-------------|------|----------------|
| Counter | Domain events | `user_marked_inactive_total` |
| Counter | Error by taxonomy | `notify_inactive_users_errors_total{error_type=timeout}` |
| Histogram | Use case latency | `notify_inactive_users_duration_ms` |
| Gauge | Queue/backlog size | `email_dispatch_backlog` |

Stack Traces: Avoid multi‑line in primary log; include truncated summary + structured `error.stack` or trace link.

---

## 5. Error & Failure Strategy

Taxonomy: `validation`, `domain_invariant`, `external_io`, `timeout`, `auth`, `permission`, `conflict`, `unexpected`.

Rules:

1. Domain invariant breach → specific exception mapped to stable boundary error code.
2. Transient external IO → classify + (idempotent?) retry w/ exponential backoff + jitter.
3. Single boundary log per failure; internal rethrows enrich only.
4. User-facing messages sanitized; sensitive context in secure channel only.
5. Prefer optimistic concurrency (version / ETag) for conflict detection.

---

## 6. Security & Compliance Essentials

| Area | Rule | Note |
|------|------|------|
| Input | Validate & normalize at boundary | Types, ranges, allow‑lists |
| Data Access | Parameterized queries only | String concatenation requires ADR review |
| Secrets | Never in VCS; load via env/secret store | Document rotation procedure |
| Logging | Mask tokens (first 4 + last 2), redact PII | Hash or partial email (j***@domain) |
| Outbound URLs | Allow‑list + deny risky IPs | SSRF mitigation |
| PII | Minimize & justify | Consider hashing for analytics |
| Config Objects | Immutable post bootstrap | Avoid runtime mutation |

---

## 7. Performance & Scalability Patterns

1. Detect N+1 early (integration tests assert query count / round trips).
2. Caching via explicit decorators (document TTL + invalidation trigger + metrics).
3. Stream or cursor paginate large sets; avoid full materialization.

---

description: 'Principal Architect'
applyTo: '**/*'
---

## Principal Architect Instruction Set

Concise, technology‑agnostic guardrails for building evolvable, observable, secure, high‑quality systems. Treat every rule as the default. Any material deviation MUST be justified by an Architecture Decision Record (ADR) that states reason, risk, mitigation, and revisit trigger.

### 🔗 Quick Navigation

1. Core Principles
2. Layering Contract
3. Design Guardrails
4. Telemetry & Metrics Contract
5. Error & Failure Strategy
6. Security & Privacy Baseline
7. Performance & Scalability
8. Concurrency & Idempotency
9. Evolution & Migration
10. Documentation & ADR Rules
11. Code Review Checklist
12. Anti‑Patterns (Always Refactor)
13. AI / Automation Guardrails
14. Minimal Use Case Template
15. Quality Gates (CI)
16. Pre‑Merge Readiness
17. Deviation Protocol
18. Core Pattern Capsules (Caching, Retry, Idempotency, Metrics, Circuit Breaker, Outbox, Cursor, ACL)
19. Extended Pattern Index (Value Objects → Observability)

---

### 1. Core Principles (Non‑Negotiable)

| Principle | Summary | Failure Smell |
|-----------|---------|---------------|
| Domain Isolation | Business logic free of frameworks / transport / persistence concerns | Domain imports HTTP / ORM / logger directly |
| Ports First | Define an interface before introducing / replacing external capability | Adapter coded directly against vendor SDK |
| Single‑Intention Use Cases | Each use case = one business verb phrase | God use case branching across unrelated flows |
| Event ≠ Everything | Emit domain events only for cross‑aggregate / cross‑context value | Dozens of granular events with 0 consumers |
| Immutability Bias | Value Objects & DTOs immutable; mutate only inside aggregate invariants | Setters everywhere / shared mutable state |
| Built‑In Observability | Start + finish logs + outcome + duration + metrics | No correlation id or duration visibility |
| Evolutionary Simplicity | Complexity introduced only after measured constraint | Premature CQRS / microservices w/out metrics |
| Security & Privacy by Design | Least privilege, mask sensitive data, externalize secrets | Secrets in repo / PII in logs |
| Additive Versioning | Extend first, deprecate later with plan | Breaking change merged without compatibility path |

---

### 2. Layering Contract

| Layer | Responsibility | MUST NOT |
|-------|----------------|----------|
| Domain | Entities, value objects, invariants, policies, domain events | Framework & transport calls, DB APIs, logging APIs |
| Application | Orchestrate use cases, coordinate ports, emit events + telemetry | Embed core business rules or validation logic |
| Ports | Abstract external capabilities (persistence, messaging, remote services) | Leak vendor names (e.g. Kafka*, MySql*) |
| Adapters | Concrete IO (DB, HTTP, MQ, CLI, UI) implementing ports | Decide domain branching |
| Inbound (Controller / Handler) | Input mapping, authN/Z, validation, call use case | Perform orchestration logic |

Bounded Context = cohesive domain language boundary. Cross boundary → prefer domain events or Anti‑Corruption Layer (ACL).

---

### 3. Design Guardrails

| Concern | Guideline | Reject If |
|---------|----------|-----------|
| Repeated Primitive Validation | Elevate to Value Object ≥3 occurrences OR domain rule encoded | Duplication persists |
| Repository Surface | Express intent (e.g. `findPendingApprovals`) | Generic CRUD leak to app layer |
| Constructors | Keep trivial; use factory for multi‑step invariants | Constructor doing branching / heavy IO |
| Policies / Specs | Isolate complex decision logic | Use case full of nested conditionals |
| Composition > Inheritance | Only explicit extension points (document) | Deep inheritance chain |
| Port Versioning | Add new interface v2 → migrate → deprecate timeline | In‑place breaking changes |

---

### 4. Telemetry & Metrics Contract

Log format: JSON line (preferred). Required fields:
`action`, `phase (start|finish)`, `correlation_id`, `outcome (success|failure [finish])`, `duration_ms (finish)`, optional: `entity`, `entity_id`, `error_type`.

Example:

```json
{"action":"notify_inactive_users","phase":"start","correlation_id":"..."}
{"action":"notify_inactive_users","phase":"finish","outcome":"success","duration_ms":123}
```

Correlation: Accept `request-id` then `x-correlation-id`; generate UUIDv4 if absent; propagate.

Metrics (RED minimum):

| Metric | Type | Example Name |
|--------|------|--------------|
| Throughput | Counter | `user_marked_inactive_total` |
| Latency | Histogram | `notify_inactive_users_duration_ms` |
| Errors by Class | Counter | `notify_inactive_users_errors_total{error_type=timeout}` |
| Backlog / Queue | Gauge | `email_dispatch_backlog` |

Rules:

1. One start + one finish log per use case.
2. No multi‑line stack traces in primary log (attach structured field or trace system).
3. High‑cardinality labels strictly controlled.

---

### 5. Error & Failure Strategy

Taxonomy: `validation | domain_invariant | external_io | timeout | auth | permission | conflict | unexpected`.

| Scenario | Action |
|----------|--------|
| Domain invariant breach | Throw specific domain exception → map to stable boundary code |
| Transient external IO | Retry (exponential + jitter) ONLY if idempotent |
| Logging | Log once at boundary; inner layers enrich / rethrow only |
| Conflicts | Use optimistic concurrency (version / ETag) |
| User Messages | Sanitize; sensitive detail only in secure logs |

---

### 6. Security & Privacy Baseline

| Area | Requirement | Reject If |
|------|------------|-----------|
| Input Validation | Normalize & validate at boundary | Raw unvalidated input reaches domain |
| Persistence | Parameterized queries only | String concatenated SQL |
| Secrets | Externalized (env / secret store) | Checked‑in credentials |
| Logging | Mask tokens (first 4 + last 2), partial email | Full secrets / PII logged |
| Outbound URLs | Allow‑list + deny internal IPs (SSRF) | Direct user URL fetch w/out validation |
| PII | Minimum necessary + hashing when feasible | Excess personal data stored/logged |
| Config Objects | Immutable after bootstrap | Runtime mutation of global config |

---

### 7. Performance & Scalability

1. Detect & test for N+1 (integration tests count queries / calls).
2. Caching via explicit decorator only (document TTL, invalidation, hit/miss metrics).
3. Prefer streaming / cursor pagination over full materialization.
4. Batch + parallel safe external calls within rate limits using shared policy.
5. Introduce async only after metrics prove sync bottleneck.

---

### 8. Concurrency & Idempotency

Idempotency Techniques: natural key uniqueness, idempotency key store (key→hash/outcome), dedupe TTL table, optimistic locking.
Rules:

| Rule | Rationale |
|------|-----------|
| External retriable trigger MUST be idempotent | Safe client retries |
| No global mutable state | Predictable concurrency |
| Ordering only if required by business observability | Avoid unnecessary coupling |

Composition Order (outer→inner): Idempotency → Caching → Retry → Metrics → Core.

---

### 9. Evolution & Migration

| Change | Pattern | Success Signal |
|--------|--------|----------------|
| Extract bounded context | Publish contracts → carve adapters → migrate persistence | Independent deployment + stable SLA |
| Replace external system | Dual‑write / shadow read behind flag | Parity metrics & error budget met |
| Introduce async | Keep sync fallback until async p95 + failure improved | Async < baseline p95; error rate within budget |
| Add cache | Baseline → decorator → validate correctness + hit ratio | Target hit ratio w/out stale bugs |
| Port change | Add v2 interface → migrate → deprecate v1 | All callers off v1 before removal |

---

### 10. Documentation & ADR Rules

ADR Required For: new bounded context, data store, cross‑cutting framework, breaking API, security model shift.
ADR Template: Context → Options → Decision → Consequences (short/long) → Migration/Sunset → Owner → Review Date.
Deviation (no ADR yet): PR must state Reason / Risk / Mitigation / Revisit Trigger / Owner.
Each new domain concept: short rationale (docblock or local README) describing purpose + invariants.

---

### 11. Code Review Checklist (Architect Focus)

| Check | Pass? |
|-------|-------|
| Domain purity (no framework leakage) |  |
| Intent‑based repositories (no CRUD leak) |  |
| Value Objects extracted (or rationale documented) |  |
| Ports defined before adapters |  |
| Telemetry (start, finish, correlation, outcome, duration) |  |
| Meaningful events only (no noise) |  |
| Specific exceptions mapped; no broad swallow |  |
| Secrets / PII masked |  |
| Performance watchpoints addressed (N+1, caching, batching) |  |
| Test coverage ≥ 80% changed lines |  |
| Idempotency strategy in place (where needed) |  |
| ADR(s) added/updated for architectural deltas |  |

---

### 12. Anti‑Patterns (Immediate Refactor)

Fat controllers/handlers; generic Helper/Manager/Utils buckets; passing untyped maps; silent or broad catch; hidden side effects; premature microservices / async; event spam.

---

### 13. AI / Automation Guardrails

1. Reject code violating dependency direction.
2. Prefer Value Object extraction over duplicated validation logic.
3. Add tests + start/finish telemetry for any new port or adapter.
4. Classify errors with taxonomy; no blanket catches.
5. Ask for domain language clarification when ambiguous.

---

### 14. Minimal Use Case Template

```text
use_case NotifyInactiveUsers
  log {action: notify_inactive_users, phase: start, correlation_id}
  // domain orchestration
  log {action: notify_inactive_users, phase: finish, outcome: success, duration_ms}
end
```

---

### 15. Quality Gates (CI Baseline)

1. Static analysis: no new violations
2. Unit tests (domain + application) fast
3. Integration tests (adapters)
4. End‑to‑end smoke (critical path)
5. Security / dependency scan (fail high severity)
6. Coverage ≥ 80% changed lines (non‑decreasing overall)
7. Performance watch: key latency p95 within SLO

---

### 16. Pre‑Merge Readiness

| Item | Status |
|------|--------|
| Quality gates green |  |
| Telemetry complete (start/finish) |  |
| Error taxonomy applied |  |
| Idempotency validated (where applicable) |  |
| Performance risks reviewed |  |
| Cache invalidation + metrics (if added) |  |
| Secrets externalized |  |
| Docs / API spec / CHANGELOG updated |  |
| ADR(s) created/updated |  |
| Deprecations communicated w/ timeline |  |

---

### 17. Deviation Protocol

If a rule must be broken create or reference an ADR OR add PR deviation note:
`Reason → Accepted Risk → Mitigation / Monitoring → Revisit Trigger (metric/date) → Owner`.
Add TODO + issue link if remediation deferred. Maintain (optional) deviation index for periodic review.

---

### 18. Core Pattern Capsules (Condensed)

| Pattern | Use When | Key Rules | Smells |
|---------|----------|-----------|--------|
| Caching Decorator | Latency / rate limit + tolerable staleness | TTL, invalidation, hit/miss metrics | No invalidation; negative cache w/out TTL |
| Retry Decorator | Transient idempotent ops | Exponential + jitter, cap, classify | Retrying non‑idempotent mutation |
| Idempotency Guard | External retriable mutation | Atomic key store, hash consistency | No TTL (unbounded growth) |
| Metrics Wrapper | Critical path or external call | Start/finish, outcome, error_type | Missing error labels |
| Circuit Breaker | Flaky / spiking dependency | Threshold → open → half‑open probe | Breaker on non‑idempotent ops |
| Outbox | Reliable event emission | PENDING → publish → DISPATCHED | No index(status, created_at) |
| Cursor Iterator | Large ordered traversal | Opaque cursor, max page size | Resort after fetch |
| Anti‑Corruption Layer | Legacy / divergent external model | Map & isolate vocabulary | Domain referencing raw external fields |

---

### 19. Extended Pattern Index

This file retains (condensed) matrices for: Value Objects, Entities, Factories, Domain Events, Policies, Use Cases, Repositories, Inbound Adapters, Mappers, DTO Validation, Caching Variants, Retry Variants, Telemetry, Idempotency, Error Mapping, Logging, Migration, Pagination/Streaming, Performance/N+1, Test Strategy, ADR Governance, Observability Metrics.
Use original (pre‑refactor) version or companion docs if deeper variant detail required.

---

### 20. Architect Ethos

Default to the simplest design that is: **Correct → Observable → Secure → Evolvable**. Complexity must “pay rent” via measurable value (latency, resilience, autonomy, cost).

---
