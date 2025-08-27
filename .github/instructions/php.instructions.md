---
description: 'Comprehensive PHP + DDD/Hexagonal project guidelines (coding, architecture, testing, security, performance, tooling)'
applyTo: '**/*.php'
---

# PHP Project Instructions

These instructions govern all PHP contributions. They extend general engineering principles with domain + architectural guardrails specific to this codebase (Hexagonal + DDD, Ports & Adapters, CQRS-lite, Observability-first).

## 1. Core Principles
- Protect the Domain: Keep business rules isolated from frameworks & IO concerns.
- Ports Before Implementations: Always define/extend an interface before adding a new adapter.
- One Action per Use Case: Avoid multi-purpose services.
- Events Over Chains: Prefer domain events to implicit cascading calls.
- Immutability by Default: Use `readonly` entities/value objects; no public setters.
- Evolutionary Simplicity: Defer microservice / full CQRS / event sourcing until justified by metrics.
- Observability is a Feature: Emit structured telemetry at start + outcome of each use case & listener.

## 2. Language & Coding Standards
- Strict types: Always declare `declare(strict_types=1);` for new files.
- Namespaces: Follow PSR-4 directory alignment; domain stays under `Core/Domain`, application under `Core/Application`, infra under `Infrastructure`.
- Visibility: Explicit (`private`, `protected`, `public`); no implicit defaults.
- Final Classes: Default to `final` unless inheritance is an intentional extension seam.
- Interfaces: Name by capability (`*RepositoryInterface`, `*NotifierInterface`), not technology.
- Generics / Collections: Prefer typed domain collections (wrap arrays) when passing grouped domain objects.
- Avoid Static State: Static methods only for pure, stateless helpers (rare); prefer injected collaborators.
- Constants: Domain constants become Value Objects when behavior emerges.

## 3. Domain Modeling
- Value Objects: Introduce for Email, Identifier, Hours, DateRange, MonetaryAmount, EstimateThreshold before duplicating validation.
- Entities: Contain identity + invariants. Prohibit direct persistence or IO awareness.
- Factories: Use when creation requires invariants, decisions, or multiple dependencies.
- Domain Events: Name in past tense fact form (e.g., `EstimateThresholdReachedEvent`). Payload should be minimal & meaningful.
- Policies / Specifications: Use to isolate complex approval or estimation rules instead of bloating use cases.

## 4. Application Layer (Use Cases & Listeners)
- Use Case Contract: `execute()` or intention-revealing method; return void or a dedicated response DTO (avoid associative arrays).
- Logging / Telemetry: Log intent (`action=start`, key identifiers) and completion (`action=completed`, outcome, latency if available).
- Orchestration Only: No DTO construction or low-level IO; delegate outward to ports.
- Idempotency: Webhook & import-related use cases must be safe to retry (ensure repository guards or natural keys).

## 5. Ports & Adapters
- Repository Interfaces: Reside in `Core/Domain/Repositories`; expose domain intent (e.g., `findPendingApprovals()`) not CRUD leakage.
- Outbound Adapters: Implement interfaces in `Infrastructure/Persistence` or `Infrastructure/Notifications` etc.; wire via DI.
- Inbound Adapters: Controllers (HTTP), CLI commands, scheduled runners—thin glue only.
- Mapping Layer: Use mappers to convert ORM entities → domain; domain objects must never expose ORM internals.

## 6. Validation & DTOs
- Validation Funnel: Transport (Controller/CLI) → DTO Factory w/ field validation → Use Case → Domain.
- Exceptions: Throw `MissingFieldException`, `InvalidFieldException`, or domain-specific exception; never generic `Exception`.
- Avoid Primitive Obsession: Escalate repeating (≥3) primitive validation patterns to Value Objects.

## 7. Error Handling Strategy
- Domain Errors: Custom domain exceptions; caught at boundary (controller/command) -> canonical error response.
- Infrastructure Failures: Wrap low-level library exceptions into domain or application exceptions early.
- Logging: Log failures once at boundary; avoid duplicate stack traces.
- Retry Semantics: External API transient failures—decorate repositories/clients with retry (exponential backoff) when validated by telemetry.

## 8. Security (OWASP-Aligned)
- No raw SQL string concatenation—always parameterized queries via ORM or prepared statements.
- Input Sanitization: Trust nothing from HTTP / CLI; rely on DTO factories.
- Secrets: Never hardcode. Read from env or secret store (document required variable names).
- Output Encoding: In any future HTML contexts, use proper escaping; never echo raw user data.
- Logging Hygiene: Strip or hash PII where not essential (emails, tokens).
- SSRF / External Calls: Validate host & scheme for any user-supplied URLs before outbound HTTP.

## 9. Performance & Scalability
- Imports: Document rationale for destructive re-sync; add TODO referencing future delta sync if dataset grows.
- N+1 Prevention: Repositories should batch where feasible—add integration tests for expected query counts where critical.
- Caching Strategy: Introduce decorator layer (e.g., `Caching*Repository`)—never embed caching logic inside domain or base repository classes.
- Streaming / Chunking: For large exports or reports, stream to writers (CSV) instead of holding all rows in memory.

## 10. Telemetry & Observability
- Standard Log Fields: `action`, `entity`, `entity_id`, `correlation_id`, `outcome`, `duration_ms`.
- Correlation: Propagate correlation IDs from inbound layer to all logs; generate if absent.
- Metrics: Emit counters for domain events & gauges for backlog sizes (e.g., pending approvals).
- Error Classification: Tag logs with `error_type` (validation, domain_invariant, external_io, unexpected).

## 11. Testing Strategy
| Layer | Focus | Tooling |
|-------|-------|---------|
| Unit (Domain) | Entities, Value Objects, Policies | PHPUnit + pure PHP asserts |
| Unit (Use Case) | Orchestration w/ mocked ports | PHPUnit + prophecy/mock libs |
| Integration | Adapter correctness (DB, clients) | Real DB / HTTP stubs |
| Functional | End-to-end request → response | Slim/HTTP kernel test harness |
| Contract | External APIs | Mock server / recorded interactions |
| Performance | Critical flows | Bench harness / timing assertions |
| Architecture Fitness | Dependency direction, naming | Custom PHPUnit rules / static analysis |

Guidelines:
- Name tests mirroring business intent (`test_it_dispatches_monthly_invoice_event_when_cycle_starts`).
- Avoid over-mocking; prefer in-memory or lightweight fake repositories for domain tests.
- Ensure each bug fix adds a regression test.

## 12. Static Analysis & Tooling
- PHPStan / Psalm: Level should remain ≥ current baseline; do not suppress without justification.
- PHPCS / PHPMD: Fix style & complexity warnings before merging.
- Rector: Automated refactors must be reviewed for semantic drift.
- Composer Constraints: Use caret for libraries with stable semver; pin exact versions only for fragile dependencies.
- CI Gate (Minimum): Lint → Static Analysis → Unit Tests → Integration Tests.

## 13. Code Review Checklist
- [ ] Domain purity preserved (no infra classes imported into Domain).
- [ ] New endpoints delegate directly to a use case.
- [ ] DTO validation present; no raw array usage outside factories.
- [ ] Value Object introduced (or justified omission) for repeated primitive patterns.
- [ ] Telemetry logs include action + outcome.
- [ ] Events emitted for significant state changes.
- [ ] No duplication of orchestration logic (extraction suggested if found).
- [ ] Exceptions are specific and meaningful.
- [ ] Tests added/updated at appropriate layers.
- [ ] No secret leakage / credentials in code.
- [ ] Destructive operations documented with future migration path.

## 14. Migration / Evolution Guidelines
- Extracting a Context: First publish interface + event contracts; then carve adapters; lastly move persistence.
- Introducing Async Events: Add message bus adapter; keep synchronous listener until cut-over confidence.
- Replacing an External API: Provide a parallel adapter + feature flag; run dual-write or shadow mode before switchover.
- Introducing Caching: Wrap repository with decorator; add hit/miss telemetry metric.

## 15. Naming Conventions
| Artifact | Pattern |
|----------|---------|
| Entities | Singular noun (`Employee`, `Invoice`) |
| Value Objects | Concept + optional qualifier (`EmailAddress`, `EstimateThreshold`) |
| Repositories | `<Concept>RepositoryInterface` / `<Concept><Store|Api|Database>Repository` |
| Events | Past tense fact (`InvoiceSentEvent`) |
| Use Cases | Verb + Noun (`ImportProjectsUseCase`) |
| DTO Factories | `<Concept>DtoFactory` |
| Listeners | `<EventName>Listener` |
| Commands (CLI) | `<Action><Context>Command` |

## 16. Logging & Error Message Patterns
- Start log: `action=<verb_noun> phase=start …`
- Completion log: `action=<verb_noun> outcome=success|failure duration_ms=…`
- Avoid embedding stack traces in structured fields; rely on logger context.
- Never log raw secrets or full tokens—mask middle segments.

## 17. Dependency Management
- Prefer stable, actively maintained libraries; evaluate transitive dependency health (stars, last commit, security advisories).
- Remove unused dependencies promptly (run `composer unused` or similar tooling if available).
- Security scanning: Incorporate `symfony security:check` or `composer audit` in CI.

## 18. Performance Watchpoints
- Watch for accidental O(N^2) loops in import transformations—profile when dataset > pilot scale.
- Defer heavy allocations; stream CSV/Report generation.
- Batch external API calls; respect provider rate limits; centralize throttling.

## 19. Concurrency & Idempotency
- Ensure external-triggered use cases (webhooks) can be safely retried: use natural keys or idempotency tokens.
- Side-effect ordering reliant on events must be documented; if ordering matters, capture rationale in code comments.

## 20. Documentation Expectations
- Each new domain concept: add rationale in nearest README or ADR stub (even if WIP).
- Architectural-impacting change: create or update an ADR (title: concise decision, include context, options, outcome, consequences).
- Public-facing contract change: update OpenAPI spec + corresponding controller attributes.

## 21. AI Assistance Guardrails
- Never inline business logic into controllers for brevity.
- Offer refactor to Value Objects before duplicating validation logic.
- Refuse to generate code that violates dependency direction.
- When ambiguous, prefer adding a seam (interface) over embedding a conditional.
- Include tests and DI wiring for any new port/adapter pair.

## 22. Example Minimal Use Case Template
```php
<?php

declare(strict_types=1);

namespace WebGrip\Application\Core\Application\UseCases; 

use WebGrip\TelemetryService\Core\Domain\Services\TelemetryServiceInterface;
use WebGrip\Application\Core\Domain\Repositories\EmployeeRepositoryInterface;

final class NotifyInactiveEmployeesUseCase
{
    public function __construct(
        private TelemetryServiceInterface $telemetry,
        private EmployeeRepositoryInterface $employees,
    ) {}

    public function execute(): void
    {
        $start = microtime(true);
        $this->telemetry->logger()->info('action=notify_inactive_employees phase=start');

        foreach ($this->employees->findInactiveSinceDays(30) as $employee) {
            // Domain event or notifier trigger here
        }

        $this->telemetry->logger()->info('action=notify_inactive_employees phase=completed duration_ms=' . (int)((microtime(true)-$start)*1000));
    }
}
```

## 23. Example Repository Interface Pattern
```php
<?php

declare(strict_types=1);

namespace WebGrip\Application\Core\Domain\Repositories; 

use WebGrip\Application\Core\Domain\Entities\Employee; 

interface EmployeeRepositoryInterface
{
    /** @return iterable<Employee> */
    public function findInactiveSinceDays(int $days): iterable;
}
```

## 24. Contribution Anti-Patterns (Reject or Refactor)
- Fat controllers / commands implementing business logic.
- Generic utility classes named `Helper`, `Common`, `Manager`.
- Passing associative arrays deep into domain layer.
- Silent catch blocks swallowing exceptions.
- Adding new library without justification / alternatives comparison.
- Hardcoding timezones, locales, or currency logic.

## 25. Readiness Checklist Before Merge
- [ ] Code passes static analysis & style tools.
- [ ] Unit & integration tests green locally.
- [ ] New or changed endpoints documented (OpenAPI + README snippet if needed).
- [ ] Telemetry coverage verified (start + completion log present).
- [ ] ADR added/updated for architectural decision.
- [ ] No secrets / credentials introduced.
- [ ] Architectural guardrails (dependency direction) validated.

---
Adhere to these guidelines to preserve clarity, evolvability, and domain integrity. Deviations require explicit rationale in an ADR or code comment referencing a future remediation task.
