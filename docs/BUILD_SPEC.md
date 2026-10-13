# TicketForge approved build specification

## Problem Statement
Customers must reserve scarce event tickets during extreme flash-sale traffic without losing money or receiving conflicting seat rights.
The complete backend must preserve all original requirements and D-001 through D-104. One million concurrent users, zero overselling, hold p99 below 200 ms and 99.9% availability remain acceptance targets.
The user approved the full package on 2026-10-13. This spec synthesizes it for the Matt Pocock workflow; it does not reopen requirements.

## Solution
Deliver eight independently deployable Go services: API Gateway, Auth, Event/Venue, Inventory, Booking, Payment, Waiting Room and Notification.
Use PostgreSQL, Redis, Kafka and Elasticsearch with Docker, Kubernetes, Terraform, GitHub Actions, Prometheus, Grafana, OpenTelemetry, Jaeger and k6.
Preserve guarded owner transactions, Saga, Outbox/Inbox, idempotency, bounded work, certified CQRS reads and independently protected recovery control.
Implement the complete system within the requested 48 active hours. Run focused checks while coding; full local deployment, integration/load/failure campaigns follow Day 2. OCI deployment later depends on actual free eligibility and safety evidence.

## User Stories — identity and catalog
1. As a customer, I want verified signup and secure login, so my ticket ownership has a stable identity.
2. As a customer, I want strict refresh and revocation, so old sessions cannot regain authority.
3. As a customer, I want WebAuthn/TOTP and saved recovery codes, so recovery preserves enrolled assurance.
4. As a customer, I want safe contact changes and notifications, so money and credentials do not reach an unverified mailbox.
5. As a customer, I want catalog browsing and Elasticsearch search, so I can discover Event Occurrences.
6. As a customer, I want current certified availability, so stale reads cannot masquerade as a reservation.
7. As an organizer, I want conflict-safe venue scheduling and immutable commercial manifests, so activation cannot duplicate physical seats.
8. As an organizer, I want sale windows and cancellation fences, so changes cannot silently invalidate purchase terms.

## User Stories — scarce seats and money
9. As a customer, I want durable FIFO waiting-room membership, so reconnecting does not reset my position.
10. As an operator, I want bounded admission with retained unknown slots, so traffic does not bypass capacity accounting.
11. As a customer, I want an atomic Seat Bundle and Purchase Quota, so success never means a partial reservation.
12. As a customer, I want a two-minute Active Hold, so my original deadline is clear and retries cannot extend it.
13. As a customer, I want conversion to a fixed five-minute Payment Reservation, so checkout has a bounded lifetime.
14. As a customer, I want idempotent checkout and original command history, so a lost response cannot create another order.
15. As a customer, I want Bangladesh SSLCOMMERZ sandbox payment, so payment behavior can be tested without live money.
16. As a customer, I want verified charge matching before confirmation, so redirects and forged callbacks cannot grant seats.

## User Stories — compensation and tickets
17. As an operator, I want late/extra/risky/wrong money retained and reconciled, so uncertainty does not trigger blind retries.
18. As a customer, I want guarded cancellation and refunds, so compensation never refunds more than verified money.
19. As a customer, I want private current Order Observations, so retries and eventual consistency remain understandable.
20. As a customer, I want stable per-seat tickets and bounded QR/PNG/PDF delivery, so confirmed entitlement can be used safely.
21. As a customer, I want controlled credential reissue, so old versions cannot regain admission rights.
22. As gate staff, I want signed online first-use and passage reporting, so a used credential cannot admit twice.
23. As a supervisor, I want ambiguous lane outcomes retained, so recovery never resets irreversible ticket use.
24. As a customer, I want durable in-app and email confirmation, so notification failures do not change booking truth.

## User Stories — reliability and operations
25. As an operator, I want causal Kafka facts and crash-safe Inbox/Outbox handling, so duplicates do not duplicate effects.
26. As an operator, I want complete source cuts and original-age proofs, so read availability never substitutes for correctness.
27. As an operator, I want strict PostgreSQL HA and physical fencing, so a previous writer cannot overlap a promoted writer.
28. As an operator, I want exact remote WAL/storage coverage, so acknowledged critical work survives the accepted regional fault.
29. As an operator, I want prepared recovery journals and guarded survivor recovery, so infrastructure ambiguity stays visible.
30. As an operator, I want isolated encrypted PITR and reconciliation, so restore cannot resurrect payments or credentials.
31. As a maintainer, I want complete local/cloud/reference manifests, so reproducible deployment keeps the same architecture.
32. As a maintainer, I want metrics, traces, migration/rollback runbooks and CI, so failures can be diagnosed and repaired.

## User Stories — objective evidence
33. As a reviewer, I want independent invariants and native fault tests, so implementation cannot certify itself.
34. As a reviewer, I want staged load measurements and capacity models, so the one-million target remains evidence-based.
35. As a maintainer, I want dependency-linked issues and reviewed Conventional Commits, so another engineer can continue the build.
36. As a maintainer, I want documented free-tier gaps, so missing physical capacity cannot be hidden as production readiness.

## Implementation Decisions — ownership and consistency
Use Go 1.27.2, one module, eight separate processes and owner-scoped PostgreSQL databases/roles. No cross-owner SQL or internal persistence imports.
Inventory owns seat entitlement; Booking owns workflow; Payment owns money; Waiting Room owns admission capacity. Each uses local guarded commit and reliable facts.
PostgreSQL remains authoritative. Redis atomic operations coordinate bounded gates and caches; Redis expiration never releases authoritative entitlement.
Retain original command IDs, quotes, deadlines, revisions, actor incarnations and unknown outcomes. No missing row, lost reply or provider NotFound substitutes for safe closure.
Implement the whole D-001 through D-104 contract set, including native/remote durability, independent journal/root, source completeness, browser ceremonies and protected gate passage.

## Implementation Decisions — bounded interfaces and delivery
Public OpenAPI, internal Protobuf/RPC and versioned owner event contracts carry idempotency, subject/scope, revisions, evidence and original deadlines.
Use finite resource shares, workers, SQL pools and purpose bulkheads. Unknown unsafe history fails closed and counts against unchanged SLOs.
Real SSLCOMMERZ traffic is sandbox-only, one request/second and one live HTTP request. A separate isolated provider double supplies high-load validation.
Local simulations explicitly identify co-location and virtual roots. OCI-free and production-reference keep all stack components; missing capacity blocks the affected capability.
Resolve immutable module, image, action and provider pins with source/license/checksum evidence. Never ship mutable latest or publish secrets.

## Testing Decisions — approved seams
The accepted validation matrix specifies Gateway/public operations, owner command interfaces and explicit adapter/fault boundaries. These are the pre-agreed test seams.
Test externally visible behavior and independent accepted-history invariants. Avoid private-method mocks or implementation-derived expectations.
Use one red-green behavior slice at a time. Native PostgreSQL/Redis/Kafka tests are required for native correctness; a unit double cannot prove durability or distributed concurrency.
Capture original acknowledged/unknown outcomes outside the implementation. Check whole bundles, quotas, payment evidence, retries, expiration, outbox delivery and recovery using that independent history.
There is no existing runnable-code test prior art. Full integration/load/fault harnesses must implement the accepted profiles without relaxing acceptance rates or windows.

## Testing Decisions — results and release
Focused build, race, contract, component and fault checks accompany each relevant ticket. Full system campaigns follow Day 2 as requested.
Record PASSED, FAILED, NOT RUN, UNVERIFIED and explicitly SIMULATED states with actual topology, versions, offered/useful rates and failure timelines.
The original SLOs include eligible refusals and uncertainty. An unexecuted harness, model or signed configuration is never a passed physical/1M test.
Complete-code release candidates and production readiness are separate evidence states. Missing required work remains open.

## Out of Scope
No original service, technology, feature, target or accepted correctness requirement is excluded.
Paid resources, live financial transactions, current cloud apply and messages to third parties are outside this authorization.
A presale lottery is not an accepted product requirement. Durable FIFO waiting-room admission is required.

## Further Notes
Canonical contract details: [delivery package](DELIVERY_PACKAGE.md), [validation matrix](VALIDATION_MATRIX.md), [operations plan](OPERATIONS_PLAN.md), [dependency baseline](DEPENDENCY_BASELINE.md), [work order](IMPLEMENTATION_BACKLOG.md) and all accepted ADRs.
The root domain glossary is the terminology authority. This synthesis adds no replacement guarantee.
Use to-tickets, then implement dependency-ready tickets with TDD and separate Standards/Spec review. Do not restart the completed grill.
