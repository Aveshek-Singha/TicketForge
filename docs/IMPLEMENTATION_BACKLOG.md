# Complete implementation work order

## Status and timeline
Approved full backlog as D-104. The review created no runnable code. Implementation is now tracked in [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md), with the GitHub PRD and 24 native dependency-linked tickets.
T0 starts after the final architecture/implementation authorization. The target remains a full 48-hour implementation, followed by the requested local integration/load/failure validation and later conditional OCI deployment.
All required features stay in this backlog. The time estimates are work-order targets; unfinished required tasks are reported rather than removed or relabelled complete.
Use the existing public [Aveshek-Singha/TicketForge](https://github.com/Aveshek-Singha/TicketForge) repository and the repo's GitHub issue guidance after authorization.

## Day 1 execution windows
| Window from T0 | Work | Completion evidence |
| --- | --- | --- |
| 0–4 h | BK-001–BK-003: toolchain/Linux engine, Git/contracts/runtime/native fixture | Reproducible builds and relevant native guarded-commit checks. |
| 4–8 h | BK-004–BK-005: initial identity and prepared event/venue model | Owner-scoped commands, immutable manifest and basic verified customer flow. |
| 8–14 h | BK-006–BK-008: Inventory and durable Waiting Room | Bundle/quota/time invariants and original admission/closure handoff. |
| 14–19 h | BK-009–BK-010: Booking/Payment vertical workflow | Real adapter code, isolated double, Saga and compensation/unknown paths. |
| 19–24 h | BK-011–BK-012: reliable facts and certified read planes | Source completeness, Inbox/Outbox and actual readback contracts. |

## Day 2 execution windows
| Window from T0 | Work | Completion evidence |
| --- | --- | --- |
| 24–30 h | BK-013–BK-016: complete Auth, tickets/gates/artifacts/notifications | All accepted user/security/channel/use flows and bounded workers. |
| 30–36 h | BK-017–BK-019: native HA/remote coverage/journal/recovery | Fenced control, exact captures/receipts, retained unknown work and adapters. |
| 36–42 h | BK-020–BK-022: Docker/Kubernetes/Terraform/observability/CI | Full profiles, renders, metrics, dashboards, build and deployment workflow. |
| 42–48 h | BK-023–BK-024: harnesses/docs/full code-completeness audit | Every requirement mapped to code, checks and actual readiness status. |
No full-system capacity or physical-recovery claim follows merely from reaching hour 48.

## Dependency order and vertical development
Bootstrap contracts and guarded runtime first. Build each owner with its constraints, migrations, handlers, worker phases and meaningful focused tests together; do not create eight unconnected HTTP skeletons and call them services.
Hold/checkout/provider initiation depends on verified Auth, prepared occurrence, Inventory allocation and WR claim history; confirmation depends on verified Payment and Inventory facts.
Private/public/source views depend on exact owner writer coverage. Notifications/artifacts/gates depend on owner-confirmed entitlements and current security guards, never fabricated SQL fixtures.
Wire real local/native controls early, then enforce the same interfaces in production-reference adapters. Any unproved required real capability stays blocked; a simulator cannot impersonate it.

## Planned repository — applications
One Go module initially pins a common toolchain/dependency set; all eight executables remain separately deployable services.
Use cmd/{api-gateway,auth,event-venue,inventory,booking,payment,waiting-room,notification} for process entry points.
Use internal/{gateway,auth,eventvenue,inventory,booking,payment,waitingroom,notification} for owner domain/application/adapters/migrations.
Use internal/platform for small non-domain clock, identity, SQL, Redis/Kafka, telemetry, limits and transport primitives; contracts never expose another owner's ORM/repository.
Enforce import/dependency checks: one owner cannot import another owner's persistence/domain internals. No business data or generic cross-service transaction helper enters a shared package.

## Planned repository — contracts and platform
api/openapi contains public endpoints and errors; api/proto contains internal RPC schemas; api/events contains versioned owner fact envelopes.
internal/control and cmd/control-* contain attested receiver, independent journal, fence/root and readiness agents; these are platform subsystems, not replacements for the eight core services.
deploy/{compose,kubernetes,postgres,redis,kafka,search,identity,observability} contains complete profile wiring and safety controls.
infra/terraform/{oci,reference} contains free eligibility, placement and independent infrastructure definitions; production-only resources cannot leak into the OCI-free plan.
test/{contract,component,integration,fault,k6,oracle}, scripts, .github/workflows and docs contain reproducible checks, safe automation and operating evidence.

## BK-001: Workspace and reproducibility
Depends on final user authorization. Preserve review files, inspect remote refs, initialize the local checkout and connect the existing repository without force-overwriting history.
Select Go 1.27.2 and a verified Linux Docker environment. Resolve exact dependency/action/image/provider digests into a committed manifest; install missing tools without paid products.
Generate issue/task bodies from this backlog, PR template, contribution/security guidance, environment samples with placeholders and secret exclusions.
Acceptance: Clean fresh-checkout build preparation and explicit observed Docker/WSL/storage readiness; no real secret staged or external account/resource created by accident.

## BK-002–BK-003: Contracts and guarded platform
Create versioned public OpenAPI, gRPC/Protobuf and Kafka owner envelopes with idempotency, scope, revisions, exact evidence and original deadline fields.
Implement finite work/SQL/resource shares, clock bounds, object authorization, secure lifecycle, telemetry, worker ownership and phase/receipt persistence.
Implement native logged commit/notice/unknown handling and the bounded same-backend capture lane; ordinary transaction pooling retains its rules.
Acceptance: Incompatible schemas fail checks, cancelled/lost commit cannot become success, no unbounded goroutine/queue or cross-owner SQL/import path exists.

## BK-004–BK-005: Initial Auth and Event/Venue
Create scoped account/contact/session/attempt records, password/verified signup and original-authority plumbing; finish the full MFA/recovery set in BK-013.
Create catalog/venue/occurrence, native occupancy exclusion, immutable commercial/entry manifests, prepared owner activation and cancellation fences.
Implement public catalog/search sources and material-change cancellation/replacement rules; original sale opening/FIFO policies remain fixed.
Acceptance: Only verified customer/occurrence state grants queue/hold eligibility, and conflicting occupancy or stale manifest cannot activate inventory.

## BK-006–BK-008: Inventory and Waiting Room
Implement atomic seat bundle/quota/quote/command records, two-minute holds, five-minute conversion, confirmation/closure/revocation, source stripes and guarded due-work.
Implement durable FIFO acceptance/batching, presence sequences, admission slots/claims, exact handoff/retirement, fixed selection/attempt limits and measured controller inputs.
Wire same-slot Redis gates and ownership-token operations while keeping PostgreSQL authoritative and refusing unknown required gates.
Acceptance: Native concurrent bundle/quota/closure tests pass; lost hold/claim responses or Redis failover never create late allocation, duplicate capacity or renewed deadlines.

## BK-009–BK-010: Booking and Payment
Implement checkout acceptance, durable Saga phases, owner evidence matching, original attempts, callback receipts, verified charge binding and unknown/recovery states.
Implement actual SSL sandbox adapter, fixed egress/merchant identity, parameter-safe validation/query/refund calls and a completely isolated high-load double.
Implement extra/late/risky/wrong money cases, guarded refund ledgers, order cancellation and conditional compensation.
Acceptance: No callback/redirect-only confirmation, blind financial retry, refund-over-charge or provider call after unsafe reservation/actor history.

## BK-011–BK-012: Reliable facts and certified reads
Implement owner Outbox/Inbox, stable semantic IDs, causal/offset handling, bounded poison isolation, schema compatibility and guarded replay.
Implement complete owner source cuts, baseline/dirty manifests, actual publication readback, immutable section/private dictionaries and audited search PITs.
Implement original-age Auth/WR/order/notice/seat views, minima, expiry and no unsafe hot primary fallback; implement safe bounded referenced-object maintenance.
Acceptance: Missing/extra/torn data or delayed old evidence cannot certify a current useful view; duplicates and producer/consumer crash windows retain obligations.

## BK-013: Complete identity and recovery
Implement exact email comparison/claims/retirement, saved kit disclosure/ack, strict refresh lineage, WebAuthn/TOTP, enrolled-factor recovery, contact changes and session/key revocation.
Implement pre-work attempt allowances, physical KDF/signing/execution grants and current source dictionaries with all security writer coverage.
Implement privileged operator/staff ceremonies and the independent recovery realm, with real-device/two-person capabilities separately unverified until tested.
Provide the minimal browser ceremony/test client needed to execute WebAuthn and strict session flows; virtual fixtures and real authenticator evidence remain separate.
Acceptance: No lost response reuses a consumed code/refresh or grants fresh credentials; mailbox-only reset cannot bypass enrolled assurance.

## BK-014–BK-016: Tickets, entry and notifications
Implement stable per-seat ticket metadata/enrollment, purpose-encrypted delivery, private QR/PNG/PDF rendering and guarded reissue.
Implement signed scanner sessions, first-use/window/entitlement guards, passage report and lane/supervisor recovery with irreversible use/occupancy history.
Include the bounded online staff/browser signing and passage-journal client; the backend APIs alone cannot prove the user's persisted original green cycle.
Implement durable business/security notices, recipient grants, in-app feed, Mailpit capture fixture and bounded SMTP retries/uncertainty.
Acceptance: Used/revoked old credentials never admit again; cancellation obeys all-unused/event rules; renders/email cannot mutate booking truth or expose secrets to another subject.

## BK-017–BK-019: HA, region and recovery control
Implement Patroni/native etcd control, pre-promote physical-fence adapters, current primary routing, strict follower probes and quarantined rejoin.
Implement exact WAL capture/receiver proof, full base/timeline/storage evidence and coalesced bounded remote gates for protected phases/results/certification.
Implement independent journal conditional append/fsync/receipts, operator plans, original unknown phases and D-102 survivor recovery; implement encrypted pgBackRest chain and isolated restore/reconciliation.
Acceptance: No simulator, unsigned/stale root, unknown infrastructure effect or cancelled COMMIT bypasses protected production guards; each required real proof has an adapter and a failure gate.

## BK-020–BK-022: Complete deployment and operations
Provide full Docker Compose/Kubernetes/Terraform profiles, resource/cost/placement manifests, native identity/TLS/network policies, volumes and controlled rollout.
Provide Prometheus metrics, Grafana dashboards, OpenTelemetry propagation/collector and Jaeger traces with safe labels/data and bounded resource shares.
Provide GitHub Actions unit/contract/native/render/build/release workflows and signed digest/SBOM/report artifacts under verified free account/resource limits.
Acceptance: Profiles contain all technologies; YAML/IaC renders and focused checks pass, secrets stay out of source/state outputs, and unsupported free capabilities are visibly blocked.

## BK-023–BK-024: Validation and completion audit
Build every invariant, native fault, sandbox/double, original workload and independent-oracle harness in [VALIDATION_MATRIX.md](VALIDATION_MATRIX.md).
Publish capability evidence, benchmark commands and results, operational/cancellation/refund/trust/restore runbooks, migration/rollback steps and an end-to-end demonstration script.
Update DECISIONS/CONCEPTS/LEARNING_LOG/QUESTIONS/MISTAKES/ARCHITECTURE and, after each completed feature, add the required three INTERVIEW questions/answers. RUNBOOK commands must be actually verified.
Acceptance: Each required flow has code and focused checks; every missing system-wide/physical/free-capacity proof remains explicitly NOT RUN/UNVERIFIED/FAILED. No partial feature set or unexecuted campaign is called full validation.

## Git and issue workflow
Use short issue-linked feat/BK-* or fix/BK-* branches from main, small meaningful Conventional Commits and PRs with concrete behavior, validation and risk. No long-lived development branch is needed.
Use GitHub issues per docs/agents/issue-tracker.md; preserve review IDs and acceptance links. Stage only intended source/docs/config, scan for secrets and keep runtime data, TF state, credentials and dependencies ignored.
Require relevant CI checks and reviewer-visible diffs before ordinary squash merge. A sole maintainer can review his own branch, but must not claim independent production two-person recovery approval.
Attach created PRs to the task using the app tool. Never force-push shared main, reset user work, change repository visibility or invent another remote repository.

## CI/CD and release gates
PR CI: formatting/vet/race/unit, guarded-owner import checks, schema lint/breaking checks, native component jobs, secret/dependency scans, manifests and IaC validation.
Trusted branch/tag CI: reproducible amd64/arm64 images, image/SBOM scans, digest/provenance and release metadata. Pin third-party actions to exact reviewed SHAs; fork PRs get no production/provider secrets or privileged runner.
Use standard hosted runners for the existing public repository, limited artifact/cache retention and no paid larger runners. Local/self-hosted tests use only actually available resources and are isolated from untrusted contributions.
CD stages render/plan, explicit target capability checks, namespace-limited rollout, safe expand/contract migrations and verify/rollback. Cloud apply waits for a concrete free-eligible plan; no automatic provider/cloud effect occurs from a PR.

## Versioning and definition of done
Version public/internal/event contracts explicitly and support accepted mixed-reader/replay windows. Release changes with schema/build/config/image digests and migration compatibility records.
A v0.1 release candidate may mean complete code/fixtures/deployment artifacts; label its actual conformance evidence. A production-ready label additionally requires all applicable physical, capacity, transport and SLO proofs.
Do not use automatic down migrations, historical database restore or money/identity reset as release rollback. Rollback is an earlier compatible image/schema combination; otherwise use controlled forward repair.
Record actual blockers and their smallest affected scope. Fix them as engineering tasks without restarting the completed upfront interview or reducing the target system.
