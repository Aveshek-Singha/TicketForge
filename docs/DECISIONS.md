# Decisions

Record confirmed decisions here. Link an ADR when the trade-off needs one.

## D-001: Protect active holds and confirmed bookings
Date: 2026-10-10
Status: Accepted
Problem: Failover can lose a successful hold and allow conflicting seat allocation.
Options: Protect confirmed bookings only; protect active holds and confirmed bookings.
Decision: Protect both. Stop affected seat allocation when exclusive ownership cannot be established.
Reason: The user accepted this safety contract during the architecture review.
Disadvantages: Failures may cause rejected or delayed requests and reduce availability.
Related concepts: Atomicity and durability; Fail-closed allocation. See [ADR-0001](adr/0001-seat-safety-contract.md).

## D-002: Inventory owns authoritative seat allocation
Date: 2026-10-10
Status: Accepted
Problem: Redis and PostgreSQL may disagree after a partial failure.
Options: Redis authority with recovery coordination; PostgreSQL authority with Redis coordination.
Decision: Inventory/Seat Service alone writes authoritative allocation records in PostgreSQL; hold success requires their durable commit.
Reason: Recover ownership from a durable record. Booking Service requests allocation changes through Inventory APIs.
Disadvantages: Successful holds require database writes; contention and commit latency need admission control and capacity validation.
Related concepts: Authoritative record. Redis retains atomic hold coordination, TTL tracking, and availability reads. See [ADR-0002](adr/0002-authoritative-seat-allocation.md).

## D-003: Preserve acknowledged allocations after one database host fails
Date: 2026-10-10
Status: Accepted
Problem: A primary-only commit may be lost when its host and storage are unavailable.
Options: Async replication with possible loss; synchronous durable replication with safe failover.
Decision: RPO zero for acknowledged allocations after one database host fails; success requires durable WAL on the primary and at least one independent synchronous standby.
Reason: Successful allocation promises must survive the covered host failure.
Disadvantages: Replication adds latency; unavailable required copies stop new allocation success.
Related concepts: RPO; Fencing. Safe promotion must preserve acknowledged writes and fence the old primary. See [ADR-0003](adr/0003-allocation-durability-under-host-failure.md).

## D-004: Bound payment reservations and compensate late success
Date: 2026-10-10
Status: Accepted
Problem: Hold expiry may release a seat while its payment is still processing.
Options: Keep the original deadline; wait indefinitely; use a separate bounded payment reservation.
Decision: Before provider contact, atomically convert the user's valid hold into an exclusive payment reservation with a fixed deadline; retries cannot extend it.
Reason: Protect checkout while bounding seat retention; confirmation and expiry use guarded authoritative transitions with only one winning outcome.
Disadvantages: Payment may succeed without a ticket; closed allocations require durable, retried refund or authorization-void compensation.
Related concepts: Unknown payment outcome; Payment Reservation. At deadline, close unconfirmed allocation and release when safe; late success cannot revive it. See [ADR-0004](adr/0004-bounded-payment-reservations.md).

## D-005: Use SSLCOMMERZ sandbox for a Bangladesh merchant
Date: 2026-10-10
Status: Accepted
Problem: Payment integration needs a merchant country, provider, and test/live boundary.
Options: Eligible live gateway integration with fees; actual provider sandbox without real-money transactions.
Decision: Target a Bangladesh merchant and integrate SSLCOMMERZ in sandbox mode only for this delivery.
Reason: The user explicitly selected Bangladesh and SSLCOMMERZ sandbox-only testing.
Disadvantages: Sandbox results do not establish live onboarding, settlement, or bank-level production readiness.
Related concepts: Provider sandbox. Keep live requirements and costs documented for a future rollout; no live transactions are authorized. See [ADR-0005](adr/0005-sslcommerz-sandbox-only.md). D-069 accepts isolated supplemental provider testing without replacing sandbox integration.

## D-006: Reconcile uncertain payment initiation instead of blind retry
Date: 2026-10-10
Status: Accepted
Problem: An initiation timeout can hide a provider session that already exists.
Options: Retry initiation blindly; stop new initiation while its previous result is unknown and reconcile.
Decision: Persist initiation identity before dispatch, serialize concurrent initiation per order, replay known results, and block new initiation during an unknown outcome.
Reason: Application idempotency alone cannot guarantee provider-side exactly-once execution; not-found alone does not prove non-execution.
Disadvantages: Some checkouts stay pending instead of receiving a replacement session immediately.
Related concepts: Application and provider idempotency; Payment Attempt. Inventory deadlines remain bounded; reconciliation and extra-charge compensation continue after closure. See [ADR-0006](adr/0006-uncertain-payment-initiation.md).

## D-007: Booking owns durable Saga orchestration
Date: 2026-10-10
Status: Accepted
Problem: A crash can separate verified payment, confirmed inventory, and completed order state.
Options: Distributed event choreography; explicit durable orchestration in Booking Service.
Decision: Booking owns durable Saga progress and recovery; Payment owns payment evidence and compensation execution; Inventory owns allocation transitions.
Reason: Reconcile uncertain outcomes using stable identities before retry or compensation; order confirmation requires verified payment and matching durable allocation.
Disadvantages: The orchestrator adds durable coordination state, recovery logic, and a dependency on Booking availability.
Related concepts: Durable Saga orchestration; Outbox. Services transact locally with outbound Outbox work and consumer deduplication, without cross-service database writes or blind provider retries. See [ADR-0007](adr/0007-booking-saga-orchestration.md).

## D-008: One event occurrence per atomic seat bundle and order
Date: 2026-10-10
Status: Accepted
Problem: Partial multi-seat allocation can leave a customer with fewer seats than requested.
Options: Partial fulfillment; cross-event atomic purchase; one-event all-or-nothing seat bundles.
Decision: A reservation and order target one event occurrence; acquire, convert, and confirm the entire requested bundle atomically or not at all.
Reason: Preserve the customer's requested group through the allocation lifecycle; different events use separate orders.
Disadvantages: Any unavailable seat fails the whole bundle; overlapping bundles increase contention.
Related concepts: Event Occurrence; Seat Bundle; Order. No silent partial fulfillment or substitution; partitioning and bundle limits remain unresolved. See [ADR-0008](adr/0008-atomic-seat-bundle-boundary.md).

## D-009: Define the 1M-user workload and hold latency boundary
Date: 2026-10-10
Status: Accepted
Problem: Concurrent users, admitted checkout traffic, and hold request latency are different measurements.
Options: Unbounded direct inventory traffic; capacity-controlled admission for one million active sessions in one flash sale.
Decision: Target one million active client sessions in the same sale; Waiting Room controls checkout admission using measured safe capacity.
Reason: Preserve the user-scale target while bounding inventory work; admitted holds require Gateway-to-response p99 below 200 ms including internal queues and durable commit.
Disadvantages: Users may wait for admission; minimum useful throughput, queue wait targets, and numeric error objectives still need decisions.
Related concepts: Checkout Admission; Concurrency versus arrival rate. Report outcomes separately, test concurrency and arrival rates, and expose generator limits and extrapolation. See [ADR-0009](adr/0009-million-user-workload-contract.md).

## D-010: Enforce admission budgets with automatic queueing
Date: 2026-10-10
Status: Accepted
Problem: A late overload trigger can admit unsafe demand, and dependency slowdown can reduce capacity without more traffic.
Options: Scheduled or manual queueing only; always-enforced budgets with automatic queueing and conservative recovery.
Decision: Enforce per-event and global admission budgets continuously; queue excess demand and reduce or pause admission when safe capacity falls or is uncertain.
Reason: Protect inventory and reserve bounded capacity for existing checkout, payment evidence, expiry, reconciliation, and compensation; use resource signals, hard limits, and hysteresis.
Disadvantages: Admission may pause conservatively; budgets, signal freshness, and recovery tuning require measured evidence.
Related concepts: Admission budget; Hysteresis. Operators may tighten controls but cannot bypass safety; scheduled advance queueing is optional. See [ADR-0010](adr/0010-automatic-admission-control.md).

## D-011: Admit queued participants in server-accepted FIFO order
Date: 2026-10-10
Status: Accepted
Problem: Click times, local node clocks, duplicate requests, and queue-mode changes can produce inconsistent priority.
Options: Random admission; approximate timestamp order; stable authoritative server-accepted FIFO.
Decision: For each event occurrence, admit eligible valid entries by authoritative acceptance sequence; refresh and reconnect reuse the same valid entry and priority.
Reason: Concurrent joins need one ordering point; duplicate requests must not create extra entries for one eligible identity, and new arrivals cannot bypass earlier eligible waiting entries.
Disadvantages: Ordering a single hot event requires coordination and measured capacity; identity, durability, and expiry rules remain unresolved.
Related concepts: Queue Entry; Server acceptance order. FIFO orders admission, not payment completion or guaranteed ticket availability. See [ADR-0011](adr/0011-server-accepted-fifo-admission.md).

## D-012: Use authenticated accounts for queue and checkout identity
Date: 2026-10-10
Status: Accepted
Problem: Browser sessions and IP addresses alone cannot enforce one participant entry across tabs, devices, and shared networks.
Options: Anonymous browser identity; IP identity; authenticated account identity.
Decision: Browsing and search may be anonymous; queue entry and seat allocation require login, with one active queue/admission lifecycle and one active checkout bundle per account and event occurrence.
Reason: Reuse valid entry and allocation across tabs and devices; enforce admission ownership server-side and bind permission to account and event.
Disadvantages: Login adds friction and an authentication capacity dependency; account identity does not establish unique human identity.
Related concepts: Customer Account; Account identity versus human identity. Use IP/device signals for abuse detection without hard IP identity; quotas, verification, and farming defenses remain unresolved. See [ADR-0012](adr/0012-account-bound-queue-and-checkout.md).

## D-013: Account for admission capacity through the checkout lifecycle
Date: 2026-10-10
Status: Accepted
Problem: Credential expiry and arrival limits alone cannot prove that checkout capacity is safe to reuse.
Options: Release slots on token expiry; track capacity leases until safe workflow closure.
Decision: Bound arrival rate and active checkout slots; issue an account/event-bound lease with a bounded checkout-start window, and keep its slot counted through claims, unknown outcomes, holds, and payment reservations.
Reason: Reclaim unused leases only after proving no allocation can still consume them; release terminal slots through guarded, idempotent accounting after authoritative reconciliation.
Disadvantages: Uncertain outcomes can conservatively retain slots and reduce admission throughput until recovery.
Related concepts: Admission Lease; Arrival and in-flight limits. Retired leases cannot start new allocation; fresh purchases require fresh admission, while monetary recovery uses its reserved budget. See [ADR-0013](adr/0013-admission-capacity-lease-lifecycle.md).

## D-014: Preserve accepted queue and lease state through single-host failure
Date: 2026-10-10
Status: Accepted
Problem: Losing accepted priority or active lease counts can break FIFO and admit more checkout work than the capacity budget permits.
Options: Rebuild acknowledged state after Redis loss; persist authoritative queue and lease state durably before acknowledgment.
Decision: Waiting Room owns accepted FIFO entries and admission leases in PostgreSQL; acknowledge joins and admissions only after durable primary and independent synchronous replica commits.
Reason: Preserve acknowledged state after a covered single-host failure; fence stale writers and pause uncertain admissions until authoritative state and allocation claims are reconciled.
Disadvantages: Queue ingress requires durable write capacity, ordering coordination, replication latency, and independent hosts; free deployment must disclose any missing guarantee.
Related concepts: Durable queue acceptance. Redis remains a fast projection and atomic coordination layer; never reset slot counts or discard accepted priority on Redis loss. See [ADR-0014](adr/0014-durable-queue-and-admission-state.md).

## D-015: Claim admission durably and fence delayed allocation before slot reuse
Date: 2026-10-10
Status: Accepted
Problem: A delayed allocation command can arrive after Waiting Room expires a lease and reuses its capacity slot.
Options: Release on timeout or not-found query; durable claim followed by authoritative closure that rejects later commands.
Decision: Waiting Room durably claims the lease for one stable checkout identity before allocation; claim and unused expiry are mutually exclusive, and Inventory checks its durable claim guard in the bundle transaction.
Reason: Close claimed workflows with an Inventory barrier even when the original command has not arrived; retain the slot until matching durable closure and no active allocation remain.
Disadvantages: Coordination and durable writes add latency and recovery state; hold p99 below 200 ms must still be measured.
Related concepts: Admission Claim; Closure barrier and tombstone. Use idempotent retries and stale-generation rejection, preserve valid reservations, and keep each service's writes local. See [ADR-0015](adr/0015-durable-admission-claim-and-closure.md). D-077 narrowly clarifies slot retirement: matching terminal confirmation plus a claim fence also releases checkout capacity, while confirmed seats and consumed quota remain intact.

## D-016: Evaluate allocation deadlines at guarded Inventory transitions
Date: 2026-10-10
Status: Accepted
Problem: Lock waits, stale clocks, and delayed cleanup can incorrectly keep expired reservations eligible.
Options: Request-arrival or cleanup-based eligibility; fresh authoritative time at the guarded transition.
Decision: Inventory owns fixed UTC deadlines and checks fresh primary database time after required locks; hold conversion and payment confirmation require time strictly before the deadline.
Reason: Only committed guarded transitions count; late cleanup cannot extend eligibility, and atomic closure with generation checks protects newer reservations and confirmed allocations.
Disadvantages: Lock waits or delayed payment evidence can miss deadlines; unsafe clock or failover conditions pause affected transitions, and late verified success requires compensation.
Related concepts: Logical expiry and cleanup; Fresh time after lock acquisition. Retries never reset deadlines; D-017 resolves numeric durations, while clock error bounds remain unresolved. See [ADR-0016](adr/0016-authoritative-allocation-deadlines.md).

## D-017: Use two-minute holds and five-minute payment reservations
Date: 2026-10-10
Status: Accepted
Problem: Reservation durations must balance customer checkout time against scarce seats and active capacity.
Options: Proposed ten-minute hold and fifteen-minute payment window; user-selected two-minute hold and five-minute payment window.
Decision: Active holds last two minutes from guarded Inventory creation; payment reservations last five minutes from guarded conversion before provider initiation.
Reason: The user selected these shorter windows; initiation, customer payment, validation, and confirmation eligibility all consume the payment window without retry extensions.
Disadvantages: Slow initiation, OTP, validation, or coordination may miss the deadline and increase expired checkouts or late-payment compensation; provider session expiry remains independent.
Related concepts: Reservation policy snapshot; Provider session lifetime versus seat deadline. Store fixed deadlines and the policy version; future configuration changes affect new reservations only. See [ADR-0017](adr/0017-two-minute-holds-five-minute-payments.md).

## D-018: Bound conflict retries to one successful hold lifecycle per admission
Date: 2026-10-10
Status: Accepted
Problem: Repeated reacquisition can bypass fixed reservation windows, while treating seat conflicts as terminal wastes a customer's admission.
Options: Requeue after every conflict; unrestricted replacement holds; bounded conflict retries before one successful hold lifecycle.
Decision: Allow rate-limited seat-choice retries after known conflicts within the original bounded selection window; unknown outcomes require reconciliation or replay of the same request identity.
Reason: One admission permits at most one successful hold lifecycle; expiry, explicit cancellation, or verified terminal payment failure retires it after safe closure, and reacquisition needs fresh FIFO admission.
Disadvantages: Giving up a successful hold loses queue priority; selection time, retry budgets, quotas, and any seat-amendment workflow still need decisions.
Related concepts: Conflict retry versus reservation reacquisition. Refresh, replacement, and new idempotency keys cannot renew retired admission; browser redirects alone do not prove terminal payment failure. See [ADR-0018](adr/0018-conflict-retries-and-fresh-admission.md).

## D-019: Bound selection to sixty seconds and five allocation attempts
Date: 2026-10-10
Status: Accepted
Problem: Unsuccessful seat selection can retain admission capacity or generate excessive allocation and retry traffic.
Options: Unlimited selection and retries; a fixed selection deadline with logical attempt and rate limits.
Decision: Allow sixty seconds from durable admission issuance, at most five logical allocation attempts including the first, and at most one in flight; new choices follow known conflicts only.
Reason: Limit new attempts to one per second per account/event without burst accumulation or requeue reset; authoritative deadlines and counters cannot reset through refresh or replay.
Disadvantages: Hot-seat contention can requeue legitimate customers; deadline enforcement, request budgets, recovery traffic, and tuning require evidence.
Related concepts: Selection Window; Logical attempt budget and transport retries. Replay does not consume another logical attempt or extend deadlines; safely close exhausted admissions and retain unknown slots. See [ADR-0019](adr/0019-selection-window-and-attempt-budget.md).

## D-020: Enforce four-seat bundles and four-ticket quotas in Inventory
Date: 2026-10-10
Status: Accepted
Problem: Fresh admission can bypass per-checkout limits, and completed-order projections omit active or not-yet-projected allocations.
Options: Per-order limits only; projection-based purchase checks; atomic Inventory quota accounting with cumulative account limits.
Decision: Use configurable per-occurrence defaults of four seats per bundle and four tickets per account; confirmed plus active reserved units cannot exceed the quota, which Inventory reserves with the whole bundle in one local transaction.
Reason: Conversion preserves reserved units; confirmation moves them to consumed units once, and safe unconfirmed closure releases reserved units once without bypass through tabs, replicas, new keys, or requeue.
Disadvantages: Four-ticket defaults restrict large groups and add account-level contention; account farming needs separate controls.
Related concepts: Purchase Quota; Reserved purchase quota. Reject oversized bundles without partial allocation; refund notification alone cannot restore confirmed entitlement. Policy updates and post-confirmation restoration remain unresolved. See [ADR-0020](adr/0020-atomic-inventory-purchase-quota.md).

## D-021: Lock the checkout quote with the successful hold
Date: 2026-10-10
Status: Accepted
Problem: Price updates, client totals, and settlement deductions can produce inconsistent booking and payment amounts.
Options: Reprice at checkout; trust client totals; snapshot a server-defined quote with the successful hold.
Decision: Event and Venue defines pricing; Inventory uses an activated durable version, checks the customer's expected version, and stores bundle, currency, price breakdown, total, and version with the hold atomically.
Reason: Preserve the quote through the valid hold and payment reservation; Booking stores the matching snapshot, and Payment initiates and validates against that trusted quote.
Disadvantages: Existing valid quotes retain old prices; publication/version activation and financial mismatch recovery add coordination.
Related concepts: Checkout Quote; Immutable checkout quote. Reject stale prices for reconfirmation without silent allocation or deadline extension; verify provider identity, successful status, amount, and currency, excluding net settlement. See [ADR-0021](adr/0021-immutable-checkout-quote.md).

## D-022: Use BDT and exact integer money throughout checkout
Date: 2026-10-10
Status: Accepted
Problem: Currency conversion, rounding drift, invalid amounts, and provider bounds can break quote/payment agreement.
Options: Approximate numeric amounts or implicit currency; explicit BDT with exact integer minor units and versioned rounding.
Decision: Use BDT for this sandbox delivery with explicit currency fields and checked signed 64-bit integer paisa; parse and send provider decimal strings exactly, with exact payment equality.
Reason: Compute fractional fee/tax components exactly and round half-up once per line; sum rounded lines and snapshot the policy, rejecting fractional-paisa inputs and overflow.
Disadvantages: No foreign-exchange checkout is included in this delivery; fee/tax values, refund limits, and provider normalization still need validation.
Related concepts: Integer minor units and exact rounding; Provider transaction amount bounds. Reject payable totals outside documented BDT 10.00–500000.00 bounds before hold success; refunds retain original currency and representation. See [ADR-0022](adr/0022-bdt-and-exact-money.md).

## D-023: Recover money with a durable charge-level compensation ledger
Date: 2026-10-10
Status: Accepted
Problem: Duplicate charges, unfulfilled payments, and uncertain refund dispatch can cause lost obligations or double refunds.
Options: Order-only refund bookkeeping and blind retries; durable charge-level accounting with evidence-based recovery.
Decision: Payment owns unique verified charges and refund intents, with an independent synchronous durable copy before financial acknowledgment or refund dispatch under the covered single-host failure contract.
Reason: Target full actual-charge compensation for known-order amount mismatches, extra charges, and late success after safe closure; apply at most one eligible matching charge and reconcile unknown allocation before refunding it.
Disadvantages: Missing provider evidence can leave recovery pending; safe replay, lost-reference recovery, refund limits/fees, and recovery SLOs remain capability dependencies.
Related concepts: Provider Charge; Refund Intent; Charge-level refund accounting. Serialize intents, bound completed plus pending/unknown refunds by the original charge, verify completion, and quarantine unmatched identities. See [ADR-0023](adr/0023-charge-level-compensation-ledger.md).

## D-024: Apply Kafka events through durable idempotent local transactions
Date: 2026-10-11
Status: Accepted Pure presence projection delivery is specialized by [D-064](adr/0064-coalesced-presence-projection-and-immutable-lifecycle-events.md); critical event history remains unchanged.
Problem: Redelivery, crashes before offset commits, and cross-owner arrival order can repeat effects or break workflow state.
Options: Assume end-to-end exactly-once delivery; at-least-once events with transactional Inbox and guarded local effects.
Decision: Commit producer state and stable-identity Outbox work together; consumers atomically commit Inbox deduplication, guarded effects, and resulting Outbox work before advancing contiguous safe offsets.
Reason: Preserve owner revision order in publication, key by stable owning aggregate, and durably retain missing prerequisites with distinct received/applied states for reliable recovery.
Disadvantages: Inbox writes, ordered publication, and pending-event recovery add storage and lag; retention, poison-event handling, schemas, and transport choices remain unresolved.
Related concepts: Transactional inbox and duplicate delivery; Aggregate revision and causal prerequisites. No global/cross-topic order or provider calls inside consumer transactions; D-006 and D-023 govern monetary dispatch. See [ADR-0024](adr/0024-idempotent-kafka-consumer-effects.md).

## D-025: Preserve Kafka durability when replication becomes unavailable
Date: 2026-10-11
Status: Accepted
Problem: A successful publication can be lost with its only host; draining a backlog with weaker replication can break event reliability.
Options: Weaken acknowledgments during outages; replicated critical topics with publication pause and durable backlog recovery.
Decision: Use RF3 across independent hosts, acks=all, minimum ISR2, explicit compatible producer idempotence, and no unclean leader election; verify the chosen version's safe ELR behavior.
Reason: Production uses three KRaft controllers with separate broker/controller roles and placement that preserves the majority after one covered host failure; uncertain publications retain stable Outbox identities.
Disadvantages: Replication adds storage/network cost; publication can pause, and free/shared-host deployment cannot establish independent-host resilience without actual placement and tests.
Related concepts: Replication factor and minimum in-sync replicas; KRaft controller quorum and failure placement. Backlog thresholds reduce admission while independently safe recovery uses reserved capacity; cluster-wide disaster recovery remains separate. See [ADR-0025](adr/0025-kafka-durability-and-publication-pause.md).

## D-026: Retain critical recovery history and guard every replay
Date: 2026-10-11
Status: Accepted
Problem: Consumers can outlive Kafka retention, while old replay after deduplication cleanup can repeat irreversible effects.
Options: Depend on the retained broker log and automatic offset resets; durable owner recovery history with explicit gap recovery and business guards.
Decision: Target seven-day critical Kafka retention from broker append time and retain exact critical event envelopes in each owner's durable history for at least thirty days after acknowledged publication.
Reason: Critical consumers use auto.offset.reset=none with explicit initial checkpoints; gaps require affected-processing pause and owner reconciliation/replay preserving IDs, revisions, schemas, and provider fences.
Disadvantages: History and RF3 need measured storage budgets; missing older history requires verified snapshots/history and a rebuild plan, and free deployment may not satisfy the horizon.
Related concepts: Transport retention and durable recovery history; Replay identity and irreversible-effect guards. Unresolved work never ages out; processed Inbox IDs remain at least thirty days after latest receipt and through replay, while financial/allocation guards have no automatic purge without proven rules. See [ADR-0026](adr/0026-critical-retention-and-guarded-replay.md).

## D-027: Isolate failed events without bypassing workflow dependencies
Date: 2026-10-11
Status: Accepted
Problem: Endless retries block unrelated orders, while blind DLQ publication or offset advancement can lose a required workflow fact.
Options: Block every order in a partition or skip failures; durable quarantine with dependent-workflow blocking and separate outage handling.
Decision: Isolated transient processing failures get five total automatic attempts with durable counters and jittered delays up to 1/2/4/8 seconds; deterministic malformed/unsupported events quarantine immediately, while missing prerequisites remain pending.
Reason: Atomically persist original event bytes/metadata, failure state, trustworthy dependency blocking, and DLQ mirror Outbox work before contiguous safe offsets advance; quarantine is received, not applied.
Disadvantages: Blocked workflows need audited recovery and storage; pause the affected partition when identity/dependencies are unclear, durable quarantine is unavailable, or safe headroom is exhausted.
Related concepts: Poison event and durable quarantine; Transport progress versus workflow progress. Independent orders may continue; outages use circuit breaking/backoff, provider calls retain D-006/D-023 fences, and deadlines never extend. See [ADR-0027](adr/0027-workflow-aware-quarantine.md).

## D-028: Version Kafka contracts and gate compatible rollouts
Date: 2026-10-11
Status: Accepted
Problem: Parseable events can change business meaning, and an older binary may not understand already emitted messages or durable workflow states.
Options: Ad hoc payload changes and unrestricted image rollback; owner-controlled Protobuf contracts with structural/semantic checks and compatibility gates.
Decision: Use binary Protobuf Kafka contracts with Git-versioned owner schemas, generated types, pinned local tooling, and a validated envelope separating contract version from aggregate revision.
Reason: Preserve field tags/types/units/enum meanings and required-field presence; CI runs local Buf checks plus semantic, mixed-version, and archived replay fixtures before consumer-first rollout and producer activation.
Disadvantages: Generated tooling and retained multi-version readers add maintenance; breaking changes need a new major contract and controlled cutover rather than an in-place meaning change.
Related concepts: Wire compatibility and semantic compatibility; Consumer-first rollout and rollback floor; Local Protobuf compatibility checks. Retain archived/unresolved readers and refuse unsafe rollback; unknown critical contracts follow D-027. See [ADR-0028](adr/0028-versioned-event-contracts-and-compatible-rollouts.md).

## D-029: Migrate schemas in stages and preserve acknowledged work during recovery
Date: 2026-10-11
Status: Accepted
Problem: DDL locks, old writers, destructive rollback, or old snapshots can break allocation safety or erase accepted financial work.
Options: In-place destructive schema changes and snapshot rollback; staged compatible migrations with forward repair and separate disaster recovery.
Decision: Each owner uses one serialized scoped runner with versioned checksummed migrations; expand, migrate with guarded resumable backfills, validate/cut over, and contract only after compatibility/recovery dependencies end.
Reason: Keep old representation authoritative while old writers exist and bridge writes atomic; preserve valid safety guards, immutable quote/history meaning, deadlines, and Outbox/Inbox atomicity without provider calls from migrations.
Disadvantages: Bridge releases, retained structures, backfills, WAL/replication load, lock budgets, and mixed-version/interrupted-migration/restore tests require capacity and operational work.
Related concepts: Expand, migrate, and contract; DDL locking and partial index failure; Application rollback versus database restore. Use tested compatible application rollback or forward-fix; applied-schema down-migration and old live snapshot restore are not automatic release recovery. See [ADR-0029](adr/0029-staged-migrations-and-safe-release-recovery.md).

## D-030: Separate service database ownership and document shared deployment limits
Date: 2026-10-11
Status: Accepted
Problem: Shared SQL authority couples service workflows, while logical separation alone cannot prevent physical resource or recovery contention.
Options: Shared cross-service tables and transactions; owner-scoped logical databases with explicit physical deployment profiles.
Decision: Each state-owning service has its own logical PostgreSQL database and scoped runtime/migration identities; runtime identities are non-owner/non-superuser, unintended access is revoked and tested, and API Gateway has no domain SQL authority.
Reason: Owner-local state, Outbox/Inbox, and recovery remain atomic; cross-owner references use stable identities and authorized contracts/events, with no cross-service SQL reads/writes, foreign keys, joins, or workflow transactions.
Disadvantages: Production needs independently scalable HA deployments for critical/hot owners; local/free co-location shares CPU, disk, WAL, connections, failover, and physical-restore impact and cannot establish 1M capacity or physical isolation.
Related concepts: Logical database ownership and physical resource isolation; Connection budget and autoscaling. Preserve independent synchronous durability/fencing, bound aggregate pools including jobs/autoscaling, reserve recovery capacity, and document unverified free-deployment gaps. See [ADR-0030](adr/0030-service-database-ownership-and-deployment-isolation.md). D-073 refines occurrence-local Inventory placement and D-074 selects bounded pool enforcement without changing owner boundaries.

## D-031: Preserve safe write authority and durability through PostgreSQL failover
Date: 2026-10-11
Status: Accepted
Problem: Two data hosts can preserve acknowledged work after one fails but leave no independent copy for safe new critical success; unsafe promotion or stale connections can create competing writers.
Options: Two-node recovery with paused critical success; at least three independent production data nodes with strict durability, safe promotion, and fencing.
Decision: Production critical PostgreSQL HA groups use at least three data nodes on independent hosts with adequate surviving capacity, a tested majority-backed controller, strict synchronous behavior, and verified former-writer fencing.
Reason: Promote only a candidate preserving acknowledged history on the correct timeline; resume critical success only with safe leadership and an independent synchronous follower, invalidating stale primary routes/connections.
Disadvantages: Extra replicas, quorum control, fencing, and synchronous flush cost resources and latency; uncertain leadership/fencing/durability pauses new critical success, and limited free profiles cannot claim equivalent post-failure write availability.
Related concepts: RPO versus post-failure write availability; SQL visibility versus synchronous durability; Safe promotion and fencing. Unknown COMMIT needs reconciliation and an external-effect durability barrier; exact barrier, RTO, tooling, placement, and free-profile feasibility remain unresolved. See [ADR-0031](adr/0031-safe-postgresql-failover-and-write-capacity.md).

## D-032: Verify synchronous commits and gate recovered external effects with logged writes
Date: 2026-10-11
Status: Accepted
Problem: Locally visible records and a driver's no-error COMMIT result can hide cancelled replication waits and permit effects whose evidence is lost during failover.
Options: Trust SQL visibility or a ready flag; verify critical commit completion and use guarded logged-write barriers for replay and background dispatch.
Decision: Centralize critical COMMIT verification with synchronous_commit=on and verified strict HA/storage durability; cancellations, interrupted-wait warnings, and connection failures remain unknown rather than granting critical success or fresh side effects.
Reason: Recovery/dispatch workers revalidate owner-local records and perform a real logged persistent write in the same guarded transaction/session, then verify synchronous COMMIT; under D-031 safe history, the later flush covers earlier records needed by that action.
Disadvantages: Extra writes/waits add WAL load, contention, and latency; version/driver-specific warning, cancellation, lost-ack, concurrent-worker, and failover tests must prove the inferred barrier before production claims.
Related concepts: Later synchronous write as a WAL durability barrier; Replication cancellation warning and unknown commit outcome. Read-only/no-work/unlogged writes and visible flags are not proof; preserve identities/deadlines, D-024 deduplication, and D-006/D-023 possibly-sent financial claims. See [ADR-0032](adr/0032-verified-commits-and-logged-write-durability-barriers.md).

## D-033: Measure safe recovery and critical-operation availability separately
Date: 2026-10-11
Status: Accepted
Problem: Healthy processes, browse traffic, pending responses, or fast rejections can hide unusable checkout and unsafe recovery.
Options: Infrastructure uptime and blended request success; affected-path recovery evidence and capability-specific user-visible availability.
Decision: Target at most thirty seconds from one covered host failure to sustained safe affected-path recovery at declared design load with healthy survivors/dependencies; include detection, fencing, replay/promotion, independent synchronous readiness, routing, and worker recovery.
Reason: Measure at least 99.9 percent eligible logical-operation availability over rolling thirty days separately for waiting-room access, admitted allocation, checkout/payment orchestration, and financial callback/status handling; capacity rejection, timeout, and fail-closed interruption consume the affected budget.
Disadvantages: Requires repeatable load/fault tests, ingress identities, outcome classification, probes, and survivor headroom; free deployment gaps must be measured, and a short test cannot establish a thirty-day production SLO.
Related concepts: Recovery time objective and recovery evidence; Request availability and error budget by capability. Preserve RPO/safety/deadlines and D-009 hold p99/outcome splits; report provider failures, flash-sale/fault windows and acceptance/completion separately. See [ADR-0033](adr/0033-measurable-recovery-and-critical-operation-availability.md).

## D-034: Keep financial recovery durable with measured processing and escalation
Date: 2026-10-11
Status: Accepted
Problem: Financial uncertainty can outlive a seat reservation, disappear after retries/restarts, or be mislabeled complete when only refund initiation is known.
Options: Best-effort polling and manual discovery; owner-local durable recovery scheduling with processing targets, retained obligations, and audited escalation.
Decision: Payment owns durable recovery work for unresolved attempts/charges/refund intents, coordinated with Booking/Inventory evidence; target the first safe recovery attempt within thirty seconds of detection and correct durable booking outcome or compensation obligation within sixty seconds of sufficient verified evidence for 99.9 percent of actionable cases over rolling thirty days.
Reason: Persist recovery work with the financial transition; preserve original unresolved age across callbacks/retries/restarts, alert ambiguous/blocked cases at five minutes, and create audited operator recovery cases at fifteen minutes, with immediate safety alerts.
Disadvantages: Durable scheduling, evidence, bounded provider queries, reserved recovery capacity, and audited interventions add operational load; processing/escalation cannot guarantee provider settlement or human response times.
Related concepts: Recovery processing time versus provider settlement time; Persistent unresolved age and operator escalation. Preserve identities, deadlines, terminal allocation state, D-006/D-023 financial fences and D-032 durability; track blocked misses, verification/provider delay, and known-processing refunds separately until final evidence. See [ADR-0034](adr/0034-durable-financial-recovery-and-escalation.md).

## D-035: Gate provider initiation replay on operation-specific evidence
Date: 2026-10-11
Status: Accepted
Problem: Unique provider identity fields, not-found queries, or GET transport can appear replay-safe while delayed/stale dispatch still creates another monetary effect.
Options: Generic retries and assumed provider deduplication; operation/environment-specific evidence gates with retained uncertain obligations.
Decision: Persist immutable merchant/environment-scoped Payment Attempt-to-tran_id and Refund Intent-to-refund_trans_id mappings before dispatch, using provider-compatible opaque ASCII identities up to thirty characters; another initiation needs a validated same-identity/payload replay contract or conclusive non-execution evidence excluding delayed/in-flight requests and stale workers.
Reason: Treat initiation as side-effecting regardless of HTTP method; disable implicit SDK/client/proxy/mesh retries, redirect replay, caching, and prefetch, verify TLS/sandbox hosts, redact sensitive URL data, and use known validated references for safe local replay/status queries.
Disadvantages: Unknown dispatch can remain blocked pending provider evidence; sandbox observations cannot prove undocumented guarantees, and unsupported lookup/replay paths prevent bounded automatic-recovery readiness claims.
Related concepts: Provider identity versus validated replay guarantee; Side-effect classification independent of HTTP method. Preserve D-006/D-023/D-032/D-034 fences, compensation and features; retain lost-reference cases with audited evidence/recovery, and distinguish supplemental simulated failures from verified SSLCOMMERZ behavior. See [ADR-0035](adr/0035-evidence-gated-provider-replay-and-reference-recovery.md).

## D-036: Authorize operator recovery without overriding correctness
Date: 2026-10-11
Status: Accepted
Problem: A privileged session, stale approval, or raw status setter can bypass allocation safety or authorize an unaccountable monetary effect.
Options: Shared administrators and direct state edits; named operators with scoped owner-service commands, transaction-bound authorization, and durable audit.
Decision: Require separate named operator identities, MFA/step-up, deny-by-default owner-service checks, and typed idempotent recovery commands bound to case, evidence, resource/environment, payload, and expected state; reauthorize at execution and invalidate one-use approval on relevant changes.
Reason: Production high-risk manual finance requires a requester and independent approver who are distinct people; normal automatic Saga/recovery retains service authority. Persist append-only audit with each owner-local mutation and required durability before effects; emergency controls preserve all safety guards.
Disadvantages: Approval, scoped roles, atomic audit and separately controlled tamper-evident exports add operational work; a documented single-operator sandbox exception permits step-up/audit but cannot prove independent approval or authorize live operation.
Related concepts: Transaction-bound operator authorization; Separation of duties and a sandbox-only exception; Owner-local audit atomicity and tamper evidence. Preserve D-035 evidence gates; no force-confirm/refunded setters, revived allocations, blind financial replay, or routine cross-owner SQL. See [ADR-0036](adr/0036-guarded-operator-recovery-and-authorization.md). D-082 adds a scoped gate staff/scanner profile; original customer, operator and workload rules remain unless explicitly narrowed there. D-088 selects customer/privileged MFA and prior recovery evidence, strengthens reset/reissue assurance and narrowly defines lost-mailbox recovery; ordinary account/domain guards remain.

## D-037: Preserve customer identity through guarded authentication and recovery
Date: 2026-10-11
Status: Accepted
Problem: Mutable email identities can reset quota or transfer ownership; weak recovery can leave stolen sessions active or bypass MFA, while test email can be mistaken for real mailbox evidence.
Options: Email-based domain identity and loosely guarded recovery; immutable Account ID with verified-email authentication and purpose-bound recovery.
Decision: User/Auth owns self-hosted email/password authentication using maintained libraries; bind queue, admission, allocation, booking and quota to an immutable opaque Account ID. Require verified email before queue/allocation, preserve anonymous browsing, and enforce resource ownership in each service without email-based automatic account merging.
Reason: Use salted Argon2id and bounded authentication work, single-use expiring random recovery tokens atomically consumed with Auth mutations, session/refresh invalidation and normal login after reset; guard email changes with fresh authentication and mailbox proof, preserve MFA and all booking/financial obligations.
Disadvantages: Mailbox verification adds delivery dependencies and proves account-level access rather than a unique person; protected Mailpit only validates labeled sandbox email flows, while real SMTP delivery, lost-mailbox/MFA evidence, session propagation, Auth durability, and capacity remain to be resolved.
Related concepts: Stable account identity versus login address; Single-use recovery tokens and session invalidation; Password hashing and bounded authentication capacity; Email capture versus verified external delivery. Optional customer MFA and D-036 operator MFA remain distinct; recovery never resets ownership/quota or releases unresolved allocation. See [ADR-0037](adr/0037-stable-customer-identity-and-account-recovery.md). D-086 adds exact contact/purpose routing, fixed Auth challenges and a separate protected security-mail adapter; business notices remain secret-free and account/MFA guards remain. D-087 adds explicit mailbox comparison, verified-claim activation and retained retired-contact guards; it does not settle currently recycled mailbox recovery. D-088 selects customer/privileged MFA and prior recovery evidence, strengthens reset/reissue assurance and narrowly defines lost-mailbox recovery; ordinary account/domain guards remain.

## D-038: Bound customer revocation freshness and fail closed after expiry
Date: 2026-10-11
Status: Accepted
Problem: JWT signatures do not prove current session authority, and stale caches, delayed events or lost Auth history can revive revoked access.
Options: Signature-only access until JWT expiry; per-action current authority; short JWTs with a fixed bounded security-state proof and fail-closed expiry.
Decision: Use customer access JWTs lasting at most five minutes plus Auth-issued verifiable account/session/revision proofs valid at most thirty seconds from authoritative primary observation; owner guards recheck token, proof, ownership and time after queue/lock waits, with clock error inside that budget.
Reason: Deny new protected authorization through an old session/revision within thirty seconds of durable revocation; cache receipt/replay/refresh cannot extend proof expiry, newer known revocation wins, and Auth grants/security changes require D-031/D-032 leadership and verified independent synchronous durability.
Disadvantages: This accepts bounded stale authorization before the cutoff; Auth outages reject affected protected work after proof expiry and consume availability budgets. One million continuously active sessions impose substantial measured freshness/renewal costs; free deployment cannot silently enlarge the window.
Related concepts: Token validity versus current session authority; Bounded revocation freshness and fail-closed expiry; Customer session authority versus service recovery authority. Current checks remain required for login/refresh, credential/MFA changes and high-risk operator work; accepted Saga/provider recovery continues without undoing effects or extending allocations. See [ADR-0038](adr/0038-bounded-session-revocation-and-auth-failure.md). D-082 adds a scoped gate staff/scanner profile; original customer, operator and workload rules remain unless explicitly narrowed there.

## D-039: Rotate refresh secrets strictly and preserve domain state on reauthentication
Date: 2026-10-11
Status: Accepted
Problem: Consumed-token replay resembles a legitimate refresh retry after response loss, and concurrent tabs can accidentally repeat the same secret.
Options: Broad replay grace with successor re-delivery; strict single-use rotation with family revocation and possible reauthentication.
Decision: Store digests/lineage of opaque 256-bit-or-stronger random refresh secrets in Auth PostgreSQL; serialize security changes and atomically consume one current secret/create one successor with verified durability before credentials are released. Proven consumed-secret reuse revokes the affected family/descendants under D-038; unknown random tokens cannot revoke unrelated accounts.
Reason: Do not blindly retry unknown refresh outcomes or redeliver successors through consumed secrets; use safe reconciliation and fresh credential/MFA authentication with affected-family fencing if current credentials cannot be recovered. Coordinate browser refresh across tabs, use jitter, and preserve stable account ownership, quota and original domain deadlines.
Disadvantages: Response loss, tab races or delayed cookies can force login; thirty-minute successful-refresh inactivity and twenty-four-hour absolute family limits require server enforcement, capacity tests and clear handling without claiming human presence from background refresh.
Related concepts: Refresh token rotation and session family reuse; Lost refresh response versus credential replay; Refresh inactivity versus absolute session lifetime; HttpOnly cookies and CSRF boundaries. Use memory-only browser access JWTs, host-only Secure/HttpOnly/SameSite=Lax refresh cookies, POST/CSRF/exact-origin guards and independently validated provider callbacks; preserve payment/booking idempotency. See [ADR-0039](adr/0039-strict-refresh-rotation-and-session-lifecycle.md). D-082 adds a scoped gate staff/scanner profile; original customer, operator and workload rules remain unless explicitly narrowed there.

## D-040: Separate signing purposes and independently control key revocation
Date: 2026-10-11
Status: Accepted
Problem: Compromised keys can forge fresh credentials and self-approved key status; stale deployment or backup can resurrect revoked trust.
Options: Shared signing secrets with expiry-only containment; scoped asymmetric keys with guarded rotation and independently trusted revocation control.
Decision: Separate environment/purpose key sets for customer access, Auth proofs, operator and admission credentials; use public-only validators, explicit profiles, immutable key IDs, thirty-day initial routine rotation, pre-publication/readiness and old-issuer fencing with bounded verification overlap.
Reason: Require durable monotonic independently bootstrapped key-status evidence with absolute freshness at most thirty seconds; fail closed after expiry, reject rollback/replay of trust, and target denial of new affected owner authorization within thirty seconds of durable trusted emergency revocation without routine overlap.
Disadvantages: Control freshness adds an availability dependency; the enforcement timer does not measure theft detection. Encrypted self-hosted software keys remain extractable by privileged runtimes/hosts, and compromised control/bootstrap needs fencing and out-of-band trust restoration rather than a false containment guarantee.
Related concepts: Signing purpose separation and trust bootstrap; Routine key overlap versus emergency revocation; Key containment time versus compromise detection time; Encrypted secret storage versus runtime key extraction. Fence exposed sessions/realms, preserve domain/financial obligations, keep private material out of plaintext repositories/images/logs/Terraform state, and document free-profile isolation gaps. See [ADR-0040](adr/0040-signing-key-lifecycle-and-compromise-containment.md). D-080 narrowly distinguishes new opaque venue Entry Credentials from the asymmetric Waiting Room admission profile; existing signing and control requirements remain. D-082 adds a scoped gate staff/scanner profile; original customer, operator and workload rules remain unless explicitly narrowed there.

## D-041: Authenticate workloads and enforce authority at each owner
Date: 2026-10-11
Status: Accepted
Problem: A reachable service, valid certificate or event owner field can be mistaken for permission or verified business truth.
Options: Shared service credentials and network-only trust; attested workload identities with scoped owner authorization and broker principals.
Decision: Use self-hosted SPIFFE/SPIRE X.509 mTLS with scoped attestation and environment trust domains; each owner enforces caller/action/resource/workflow guards, matching customer or accepted Saga authority and trusted financial/allocation evidence. Use Kafka TLS with distinct scoped SASL/SCRAM-SHA-512 principals, deny-by-default ACLs, restricted owner publishers and audited original-history replay.
Reason: Authenticate who calls, then independently decide what they may do; check current policy, certificate lifetime and key trust at RPC owner guards, targeting denial within thirty seconds of durable trusted workload-policy revocation using absolute freshness and fail-closed expiry.
Disadvantages: SPIRE and policy control add capacity and recovery dependencies; native Kafka propagation needs separate measurement. Compromised owner, datastore, broker or trust root invalidates relevant truth assumptions and requires fencing and trusted recovery, with free-profile isolation and HA gaps documented.
Related concepts: Workload identity versus permission and owner truth; Kafka principal and topic provenance versus payload claims; Established connection versus current authorization; Network reachability versus business authorization. Require tested enforcing CNI/default-deny networks and owner-scoped storage credentials; no plaintext/shared-admin outage fallback. See [ADR-0041](adr/0041-workload-identity-and-owner-service-authorization.md). D-082 adds a scoped gate staff/scanner profile; original customer, operator and workload rules remain unless explicitly narrowed there.

## D-042: Use owner RPC commands with durable Saga recovery and Kafka facts
Date: 2026-10-11
Status: Accepted
Problem: A lost RPC response can hide a committed operation; in-memory orchestration and ambiguous transport fallback lose or duplicate workflow intent.
Options: Kafka-delivered mutation commands; direct owner commands with durable Saga recovery and Kafka owner events.
Decision: Use versioned public REST/JSON with OpenAPI and internal mTLS unary gRPC/Protobuf; admission/allocation transitions acknowledge verified owner durability. Booking persists Saga step identity/payload before owner RPC and recovers through scoped owner queries and guarded same-command delivery on one canonical command path.
Reason: Outbox Kafka facts drive Saga reactions, CQRS, search and notifications without placing Kafka publication on proven hold acknowledgement; Payment alone dispatches sandbox operations under existing provider uncertainty rules, Inventory requires owner evidence, and Booking requires matching durable confirmation.
Disadvantages: Synchronous dependencies and asynchronous completion both affect availability/latency; bound propagated deadlines, queues and attempts, verify mutation retry/hedging controls and reserve recovery capacity. Cancellation does not prove rollback or erase accepted workflows and original deadlines; backlog limits may pause new work.
Related concepts: RPC outcome uncertainty versus business completion; Durable Saga intent versus an in-memory RPC chain; Transport retry versus safe business replay. Preserve all services, 1M concurrency, p99 and existing safety/SLO contracts; exact routes, receipts and budgets remain under review. See [ADR-0042](adr/0042-rpc-commands-durable-saga-and-kafka-facts.md).

## D-043: Keep owner command receipts and business uniqueness across keys
Date: 2026-10-11
Status: Accepted; presence-renewal receipt history only is replaced by [D-063](adr/0063-presence-only-cumulative-receipts-and-replay-guards.md). All other scopes remain accepted.
Problem: Request deduplication can be bypassed by fresh keys, changed payloads, concurrent replicas or deletion of receipt history.
Options: Redis-only response caching; durable owner receipts with semantic payload binding and independent business guards.
Decision: Scope covered mutation keys by environment, stable authenticated actor and semantic operation; persist stable internal command identities and versioned canonical business meaning in owner PostgreSQL. Reject changed meaning, serialize duplicate receipt identities and commit local effect, terminal outcome and Outbox atomically with verified durability; multi-step acceptance retains bounded recovery intent.
Reason: Enforce one Order per hold lifecycle and allowed payment/charge/refund identities independently of keys; unknown results need same-identity owner reconciliation. Authenticate result replay, distinguish original outcome from current state, preserve deadlines and stricter provider dispatch rules, and do not relax refresh-token single use or operator approvals.
Disadvantages: Retain terminal receipt evidence for at least thirty days after completion and latest authenticated replay, unresolved work until resolution and retired identity/financial/allocation guards until safe cleanup/restore rules are proven; this adds write, storage and contention costs and requires bounded admission before receipt creation.
Related concepts: Idempotency key versus business identity; Semantic request fingerprint; Historical command outcome versus current allocation state. Expired response detail must not permit re-execution; preserve all safety, p99 and scale requirements. See [ADR-0043](adr/0043-owner-command-receipts-and-semantic-idempotency.md).

## D-044: Persist pending checkout before converting its hold
Date: 2026-10-11
Status: Accepted
Problem: Hold conversion can commit without Booking receiving its result, and a pending Order can outlive the hold's eligibility.
Options: Convert first and reconstruct Order intent later; persist a pending Order and stable Saga command before guarded conversion.
Decision: Gateway routes StartCheckout to Booking; validate the Inventory-owned hold/quote and account, durably persist one CHECKOUT_PENDING Order, exact quote and conversion intent before dispatch, and acknowledge HTTP 202 only for proven acceptance. Inventory converts the whole eligible bundle under its own locks/time into a five-minute Payment Reservation bound to the Order with receipt and Outbox.
Reason: Preserve one recoverable Order through crash/response loss; progress to PAYMENT_PENDING only from matching proven conversion and current eligible reservation evidence. Payment initiation requires those prerequisites and remaining budget; known closure blocks new dispatch while in-flight expiry retains late-charge compensation rules.
Disadvantages: Accepted Orders can fail to convert and remain pending through reconciliation; click/acceptance time gives no deadline grace, earlier snapshots do not guarantee conversion, and unknown outcomes cannot release admission capacity or trigger a fresh payment.
Related concepts: Checkout acceptance versus reservation eligibility; Owner snapshot versus guarded transition; Saga acceptance versus cross-service atomicity. Keep authorization, safe closure, original deadlines and all scale/SLO requirements. See [ADR-0044](adr/0044-durable-checkout-acceptance-and-reservation-handoff.md).

## D-045: Bind one fulfillment charge and prove allocation closure before compensation
Date: 2026-10-11
Status: Accepted
Problem: Lost confirmation responses can trigger refunds against confirmed allocations, and multiple charges can race to fund one Order.
Options: Decide fulfillment/refund from timers or Booking projections; immutable Payment charge binding with authoritative Inventory terminal proof.
Decision: Payment serializes first eligible verified quote-matching charge selection and durably binds it to one Order/allocation lifecycle. Inventory obtains matching proven Payment-owner evidence before its local transaction, then guards whole-bundle confirmation versus closure under the same original deadline/generation and atomically stores its terminal outcome, receipt and Outbox.
Reason: Selected-charge checkout-failure compensation requires matching durable Inventory closure/fencing evidence; unknown decisions reconcile, and confirmed allocation requires completion of the same Booking Order rather than stale expiry/refund. Extra/mismatched non-funding charges retain independent compensation, while Booking confirms/notifies only after matching proven allocation and payment.
Disadvantages: Binding and evidence queries add writes/RPC dependencies and delayed evidence can miss eligibility; keep database locks local, verify recovered durability, reserve recovery capacity and retain contradictory evidence rather than guessing outcomes.
Related concepts: Fulfillment charge binding versus payment success; Terminal allocation decision versus elapsed deadline; Compensation obligation versus completed refund. Preserve original deadlines and recovery targets; post-booking cancellation and provider risk/reversal policy need separate review. See [ADR-0045](adr/0045-fulfillment-charge-binding-and-closure-proven-compensation.md).

## D-046: Verify provider money separately from merchant risk eligibility
Date: 2026-10-11
Status: Accepted
Problem: Successful payment labels can hide wrong identities, missing risk, duplicate charges or contradictory later evidence.
Options: Fulfill from callbacks or provider success alone; verified sandbox evidence with explicit merchant risk eligibility.
Decision: Payment validates mapped attempts using the sandbox Order Validation API. Match trusted identities, exact BDT quote values and endpoint-specific fields. VALID/VALIDATED need these checks; only verified risk 0 permits charge selection. Risk 1 blocks fulfillment and unknown risk remains pending without deadline extension.
Reason: Money evidence and fulfillment permission are separate. Fence new binding before closure for blocked charges without a candidate. Compensation retains proven closure/non-funding guards. Preserve existing eligible bindings, confirmed allocations and contradictory observations for accountable recovery.
Disadvantages: Verification outages and unavailable fields delay outcomes. Risk changes, reversal semantics and production dispute procedures require further evidence. Actual sandbox results and isolated simulations must remain distinguishable; no evidence-bypass switch.
Related concepts: Provider validation status versus TicketForge fulfillment; Verified charge versus merchant risk eligibility; Contradictory provider evidence versus state overwrite. Preserve D-023/D-034/D-035/D-045 guards. See [ADR-0046](adr/0046-provider-verification-and-merchant-risk-eligibility.md) and Review 046.

## D-047: Store callback receipts before acknowledgement and reconcile independently
Date: 2026-10-11
Status: Accepted
Problem: Callback loss, early acknowledgement, blocked validation and forged deduplication can hide a real payment.
Options: Trust callback delivery and verify synchronously; durable receipt acknowledgement with asynchronous verification and independent queries.
Decision: Payment stores bounded known notification evidence and verification work atomically with D-032 proven durability before HTTP 200. Customer sessions and waiting-room admission are not required. Acknowledgement proves receipt only; unknown durability gets a retryable failure. Provider validation and Kafka publication are separate work.
Reason: Separate untrusted observation deduplication from verified charge guards. Durable work generations retain notifications arriving during verification. Record reconciliation intent before provider initiation and query known attempts independently; preserve unresolved work after expiry or confirmation and all D-035 dispatch restrictions.
Disadvantages: Receipt writes and polling require storage, replication and reserved recovery capacity. Actual sandbox acknowledgement, delivery, signature, query quotas and late-history visibility need evidence; provider retries and complete query history cannot be assumed.
Related concepts: Receipt acknowledgement versus verified financial outcome; Notification deduplication versus charge deduplication; Callback delivery versus owner reconciliation. Preserve D-033/D-034 targets and D-043 retention guards. See [ADR-0047](adr/0047-durable-callback-receipt-and-independent-reconciliation.md) and Review 047.

## D-048: Revoke confirmed entitlement before cancellation refund dispatch
Date: 2026-10-11
Status: Accepted
Problem: Refunding first can leave a cancelled customer's seat entitlement active. Restoring it after refund failure can conflict with resale.
Options: Treat confirmed cancellation as failed checkout; a separate forward Saga with authoritative revocation before refund dispatch.
Decision: Booking stores authorized whole-bundle cancellation intent and stable references. Payment durably reserves permitted conditional refund work against the original selected charge. Inventory atomically proves revocation of the exact confirmed lifecycle before Payment dispatches that refund. Keep owner locks local, confirmation history and immutable charge binding.
Reason: Revocation, availability and returned money are distinct outcomes. Uncertain proof reconciles the same workflow; refund failure cannot restore entitlement. Policy-permitted resale uses fresh allocation identity/generation, and stale commands cannot affect its new owner. Confirmed quota consumption does not reset automatically.
Disadvantages: Entitlement can end before refund completion. Durable recovery, audit and truthful pending status are required. Customer eligibility, refund percentages/cutoffs, event-wide cancellation and any gate/offline acceptance contract remain undecided.
Related concepts: Historical confirmation versus current entitlement; Entitlement revocation versus refund completion; Reallocation generation versus restored old booking. D-048 extends post-booking behavior without changing D-045 checkout finality or D-023/D-035 financial guards. See [ADR-0048](adr/0048-confirmed-booking-revocation-before-cancellation-refunds.md) and Review 048.

## D-049: Snapshot cancellation terms and refund the full quote for eligible revocation
Date: 2026-10-11
Status: Accepted
Problem: Mutable terms, cutoff races and overlapping refund paths can change purchased rights or refund an active entitlement twice.
Options: Apply current catalog rules at request arrival; immutable purchase terms with authoritative guarded eligibility.
Decision: Support whole-bundle customer cancellation with a twenty-four-hour pre-start default cutoff and full quoted BDT refund including quoted fees/taxes, without cancellation fees. Inventory snapshots activated policy/schedule versions, start, cutoff and refund terms with the hold. Guard new revocation strictly before cutoff using fresh time after local locks; HTTP 202 does not reserve eligibility.
Reason: Preserve purchased terms and original outcomes. Retire conditional refund reservations only with proven rejection and delayed-execution fencing; proven revocation creates the outstanding obligation. Authorized event cancellation bypasses the voluntary cutoff, while charge-level limits prevent overlapping refunds and confirmed quota consumption remains unchanged.
Disadvantages: Late purchases cannot use voluntary cancellation and must see that before checkout. Internal delays may miss eligibility and need separate measurement. Full live refunds may incur merchant fee costs; sandbox capability, event fencing, rescheduling and tax/provider rules remain readiness work.
Related concepts: Cancellation policy snapshot versus current catalog rules; Conditional refund reservation versus outstanding refund obligation; Customer-paid refund target versus merchant settlement. Preserve D-016/D-023/D-032/D-035/D-048 guards. See [ADR-0049](adr/0049-versioned-customer-cancellation-and-full-refund-policy.md) and Review 049. D-081 adds an all-unused voluntary-cancellation guard while retaining the original cutoff and full Event Cancellation refund policy.

## D-050: Prove owner fences before effective event cancellation
Date: 2026-10-11
Status: Accepted
Problem: Catalog cancellation can race stale allocation writes, new admissions and new payment authorizations. Bulk recovery can miss owner records or hide their age.
Options: Broadcast a cancellation flag and trust consumers; durable owner fences followed by bounded authoritative recovery.
Decision: Event and Venue persists authorized cancellation intent and stable commands. Inventory drains earlier guarded transitions and proves its occurrence fence; Waiting Room stops new admission/claims and Payment stops new initiation authorization. Declare cancellation effective only with matching durable proofs from every required owner/partition, while retaining partial stops and pending recovery through outages.
Reason: Already-authorized provider work can still yield money. Recover exact unconfirmed closure or confirmed revocation before refund dispatch, including unfinished Booking projections. Use resumable Inventory/Payment scans, charge guards, retained quota and explicit backlog ages; a global fence cannot replace per-bundle terminal proof or clear external uncertainty.
Disadvantages: Shared/exclusive gate choice and contention need measurement. Fence coordination and bulk recovery add availability/capacity costs. Preserve existing p99, 1M and recovery objectives; cancellation authority is critical data and restore cannot reopen cancelled allocation.
Related concepts: Cancellation request versus effective owner fences; Shared occurrence guard versus exclusive cancellation barrier; Effective event cancellation versus completed booking recovery. See [ADR-0050](adr/0050-owner-fenced-event-cancellation-and-bulk-recovery.md) and Review 050; exact lock/topology and bulk targets remain unproved.

## D-051: Prepare complete occurrence versions before guarded activation
Date: 2026-10-11
Status: Accepted
Problem: Partial imports, duplicate physical-seat mappings and mutable definitions can expose unsafe inventory or alter existing purchases.
Options: Execute catalog updates directly; complete sealed preparation with guarded owner activation and preserved purchase snapshots.
Decision: Event and Venue persists publication authority and versioned intent. Inventory stages bounded imports, validates complete unique seat mappings and immutable content, then atomically activates the sealed version under current control guards and D-032 durability. Match required owner preparation; unknown outcomes reconcile stable commands rather than bypassing prerequisites.
Reason: Freeze activated occurrence identity, physical-seat mapping, venue/layout, start and currency. New commercial versions affect future holds only and share existing seat allocation identities. Preserve original quotes and Cancellation Terms; material changes need separate workflows. Source durability, operational readiness, sales eligibility and search visibility remain distinct.
Disadvantages: Staging, validation and coordination add storage/recovery costs. Exact sales windows, material-change handling and search freshness remain undecided; no catalog/search call is added to each hold and all original scale/SLO requirements remain.
Related concepts: Catalog publication versus executable occurrence configuration; Structural occurrence identity versus commercial version; Source durability versus search visibility. See [ADR-0051](adr/0051-complete-occurrence-preparation-and-guarded-activation.md) and Review 051. Activation cannot clear D-050 cancellation fences. D-081 additionally requires approved Admission Window policy in sealed activation and purchase bindings; material changes use D-054.

## D-052: Close new sales before start without cancelling valid checkout
Date: 2026-10-11
Status: Accepted
Problem: New sales too close to start cannot preserve selected checkout durations. Normal sales closure can be mistaken for cancellation.
Options: Truncate late checkout or sell through start; close new work earlier while retaining valid existing checkout.
Decision: Configure explicit UTC opening. Close new holds seven minutes before occurrence start and new admission another sixty seconds earlier, preserving two-minute holds, five-minute Payment Reservations and the Selection Window. Validate and freeze the window before enablement; late preparation cannot reopen a closed window.
Reason: Owner guards use fresh authoritative time after required locks. Existing holds may convert after new-sales closure and reservations may confirm before original deadlines. D-050 cancellation remains separate. Eligible guarded transactions may commit/respond later; unknown or late money remains recoverable.
Disadvantages: Final-seven-minute holds and final-eight-minute admission are unavailable. These are nominal eligibility bounds, not guaranteed visible completion or settlement before start. Clock margins, physical-time evidence and emergency sales controls remain unproved.
Related concepts: New sales closure versus existing checkout eligibility; Guarded eligibility time versus visible completion time. Preserve D-016/D-017/D-019/D-032 and all scale/SLO requirements. See [ADR-0052](adr/0052-sales-cutoffs-and-preserved-checkout-deadlines.md) and Review 052.

## D-053: Bound clock uncertainty and preserve time guards across failover
Date: 2026-10-11
Status: Accepted
Problem: Fresh SQL time and a synchronized flag cannot prove safe deadlines or cross-owner evidence freshness during drift, jumps or promotion.
Options: Trust wall time and TTL; bounded current node evidence with conservative eligibility/expiry guards.
Decision: Use fresh clock_timestamp() after required local locks. Initially require estimated UTC error at most 100 ms and clock-health evidence age at most five seconds. Bind evidence to current node/boot/control identity and include source, drift and observation uncertainty. Opening uses the lower bound, eligibility the upper bound and proven expiry the lower bound of the justified UTC interval.
Reason: Preserve original two-minute/five-minute durations and closed lifecycle guards. Revalidate authority age after waits with both nodes' uncertainty. Restart, promotion, resume, discontinuities or missing/stale/unbounded evidence pause affected grants; they cannot reclaim allocations, extend checkout or authorize unsafe monetary effects.
Disadvantages: Conservative guards reduce availability near boundaries. Trusted source and platform assumptions limit the guarantee; clock agent/DB integration, jump detection, Linux chrony configuration and Windows/WSL inheritance remain unproved. No global per-hold time authority is added; enforcement cost and downtime count against unchanged p99, RTO and availability targets.
Related concepts: Fresh wall-clock reading versus bounded UTC uncertainty; uncertain deadline boundary versus proven expiry; boot-bound monotonic age versus transferable deadline. See [ADR-0053](adr/0053-bounded-clock-uncertainty-and-time-guards.md) and Review 053. Thresholds are requirements, not measured accuracy.

## D-054: Cancel and replace materially changed activated occurrences
Date: 2026-10-11
Status: Accepted
Problem: In-place changes to an activated date, venue, seat mapping or currency alter purchased rights and make old payment/allocation commands ambiguous.
Options: Rewrite the occurrence; design consent-based entitlement transfer; cancel the old occurrence and offer independent replacement purchases.
Decision: Use a stable audited replacement workflow. Prepare the new occurrence separately, but require proven effective D-050 fences for the old occurrence before replacement activation and sales eligibility. Keep old cancellation irreversible even when replacement preparation fails or is abandoned.
Reason: Preserve old IDs, Orders, quotes, deadlines, allocations and charge bindings. Recover original funding refunds under D-048/D-049/D-050 regardless of voluntary cutoff, with exact closure/revocation and monetary guards. New occurrence purchases use normal FIFO, quota, fresh quotes and separate payment; no automatic seat, price or priority transfer occurs.
Disadvantages: Customers can lose prior seats or prices and may need new funds while old refunds are pending. Effective cancellation is distinct from per-booking withdrawal and completed refunds. Venue-calendar safety, notifications and physical admission remain unproved; no provider settlement or Bangladesh legal guarantee is inferred.
Related concepts: Material occurrence change versus commercial update; replacement occurrence versus entitlement transfer. See [ADR-0054](adr/0054-material-changes-through-cancellation-and-replacement.md) and Review 054. A requested consent-based transfer needs explicit review of D-023/D-045/D-051, not silent exclusion for deadline reasons.

## D-055: Reserve non-overlapping venue occupancy before occurrence activation
Date: 2026-10-11
Status: Accepted
Problem: Independently safe occurrences can sell the same physical seat during overlapping venue use. Labels and partial preparation can bypass a weak calendar.
Options: Treat occurrence IDs as sufficient; check a cached calendar; enforce durable canonical conflict-resource reservations before activation.
Decision: Event and Venue owns the canonical calendar. Reserve all required resources in one PostgreSQL transaction using resource-specific range exclusions. Require finite approved occupancy covering setup, early access, performance and teardown. Permit simultaneous use only for validated disjoint spaces; aliases and layout versions cannot duplicate physical capacity.
Reason: Prepared reservations block conflicts before activatable commands. Bind activation to the durable reservation and frozen resource/schedule version. Unknown outcomes retain blockers; release requires proof that delayed activation is impossible or effective cancellation fences plus irreversible calendar closure. Refund settlement is independent of safe calendar release.
Disadvantages: Unknown work can block a replacement. Canonical mappings, buffers, schema constraints and failure guards need validation. Registered schedules do not prove absence of external bookings or real-world overruns; operational coverage remains explicit. Calendar work stays outside the hold hot path and all original scale/SLO requirements remain.
Related concepts: Occurrence seat safety versus physical venue schedule safety; performance duration versus venue occupancy interval. See [ADR-0055](adr/0055-durable-non-overlapping-venue-occupancy.md) and Review 055. Preserve D-031/D-032 durability, D-050 fences and D-051/D-054 activation/change guards. D-081 narrows early release where check-in exists or physical clearance is uncertain: retain original occupancy blockers and do not infer clearance from digital fences or time.

## D-056: Certify advisory availability freshness and expose unknown state
Date: 2026-10-11
Status: Accepted
Problem: Outbox lag, missing events, Redis recovery and cache redelivery can make an old seat map look current. A read cannot prevent a racing hold.
Options: Trust recent Redis/Kafka activity or fall back to primary reads per client; certify applied source coverage and degrade explicitly.
Decision: Inventory owns Redis availability reads. Initially require worst-case certified source age at server response generation at most two seconds, with usable responses for at least 99.9 percent of eligible logical seat-map reads over rolling thirty days at declared load. Missing, expired or invalid proof returns UNKNOWN/UPDATING rather than invented availability or sold-out state; unusable reads count against this target.
Reason: Certify complete relevant source cuts with original time, authority, configuration, partition coverage and actual projection generation. Persist Inbox/update work before checkpoints, then guard Redis application; intents alone are not applied coverage. Replay, TTL expiry, restart and cache revalidation cannot renew proof or free seats. Only authoritative Inventory hold success grants allocation, independent of projection publication.
Disadvantages: Fresh-looking seats can lose races and projection failure reduces usable browsing. Coalesced bounded rebuilds avoid per-user primary scans. Two seconds is a server freshness bound, not browser delivery latency; frontier/rebuild mechanics, transport/fanout and measured capacity remain unproved. Preserve privacy, existing checkout recovery and every original scale/SLO requirement.
Related concepts: Availability display versus exclusive allocation; source completeness frontier versus recent message receipt; source-proof lifetime versus cache lifetime. See [ADR-0056](adr/0056-certified-advisory-availability-and-explicit-degradation.md) and Review 056. D-024/D-026 preserve event/replay work and D-053 bounds proof age.

## D-057: Certify source cuts through snapshot manifests and isolated rebuilds
Date: 2026-10-11
Status: Accepted
Problem: IDs do not follow commit order. Kafka publication can race receipt persistence, and received work or mixed-snapshot pages can hide missing projection changes.
Options: Trust maximum IDs or heartbeat activity; add a commit-ordered CDC protocol; seal consistent Outbox manifests and prove actual projection coverage.
Decision: Store acknowledged Kafka publication receipts with exact event identity/hash and routing coverage. Capture conservative UTC before the snapshot transaction, then seal one owner REPEATABLE READ view of published-offset vectors and every outstanding committed projectable fact with a real logged D-032 write and verified COMMIT. Initially attempt coalesced cuts every 500 ms per Inventory HA group outside the hold path.
Reason: Certification needs matching baselines, safely applied published prefixes and every relevant outstanding fact in actual Redis generations. Published, received and applied remain distinct. Rebuild complete isolated artifacts from one consistent snapshot, retain delayed/unpublished facts and catch up before switching; lost exporters cannot be resumed with unrelated live pages.
Disadvantages: Receipts, manifests, artifact storage and long-snapshot costs need measurement. Unknown or oversized work cannot be truncated into a valid proof. Redis layout, routing/epoch validation and two-second compliance remain unproved; preserve all original safety, scale, retention and SLO requirements without per-hold shared cut locks.
Related concepts: Source-cut manifest versus maximum Outbox ID; publication receipt versus applied projection coverage; consistent snapshot artifact versus paginated live reads. See [ADR-0057](adr/0057-snapshot-manifests-and-isolated-projection-rebuilds.md) and Review 057. Preserve D-024/D-026/D-032/D-053/D-056 and stable historical proof time.

## D-058: Publish immutable section frames in isolated sharded Redis read pools
Date: 2026-10-11
Status: Accepted
Problem: Separate proof and seat keys can expose mismatched versions. Whole-event slots create hotspots, and restored Redis guards cannot prove current owner authority.
Options: Mutable seat keys with separate certificates; one event-wide atomic slot; bounded immutable section frames with guarded publication and section sharding.
Decision: Bind exact public state, scope, original cut, coverage, generation and digest in immutable frames. Initially cap each frame at 512 seats and 64 KiB including proof, splitting prepared sections when needed. Persist guarded publication intent, stage exact bytes and switch the same-slot head only under current owner authority; readers verify the complete matching frame and fresh control evidence.
Reason: Occurrence-plus-section hash tags provide bounded atomic publication without concentrating all event keys. Separate production availability resources from coordination, initially designing at least three primaries with one independently hosted replica each; reads start on primaries and shard counts require measurements.
Disadvantages: Copying, retention, proof refresh and fencing add costs. Missing frames or uncertain placement/control produce UNKNOWN; revalidation preserves the original cut. Script errors do not roll back earlier writes. Bound all work and disclose same-host/free failure-domain gaps without claiming the 1M target is proved.
Related concepts: Immutable certified frame versus mutable data with separate proof; atomic publication scope versus whole-event sharding; Redis acknowledgment versus durable owner authority. See [ADR-0058](adr/0058-immutable-certified-frames-and-sharded-redis-reads.md) and Review 058. Preserve D-002/D-032/D-056/D-057 and all original SLOs.

## D-059: Use proof-aware conditional HTTP and explicit polling budgets
Date: 2026-10-11
Status: Accepted
Problem: One million active clients can overload request processing, authentication and egress even when seat mutation demand is admitted safely. A 304 can accidentally extend an old proof.
Options: Unbounded full polling; assume streaming solves fanout; conditional HTTP with explicit client cadence, certified cache reuse and measured resource budgets.
Decision: Initially poll private queue status at least five seconds apart with zero-to-one-second positive jitter. Refresh visible details at least one second apart with small positive jitter, up to two sections and one in-flight refresh; retain anonymous/waiting detailed browsing. Use stable scoped representation ETags and digest-bound freshness headers from one validated immutable frame, checking certification before 200 or 304.
Reason: Conditional responses save unchanged payload while proof-aware coalesced application caches bound source fetches. Explicit public no-cache/must-revalidate and private private/no-store behavior preserve freshness and privacy. Clients account conservatively for transit and elapsed time and label expired observations stale; admission still starts at durable issuance.
Disadvantages: Polling still costs requests, authentication and connections. Model the full-detail hotspot and 1M mixed demand, including wire overhead and bursts; capacity is unproved. Backoff does not extend SelectionWindow, unhealthy admission delivery pauses new grants, and conforming rejected/UNKNOWN reads still count against the SLO.
Related concepts: Unchanged representation versus renewed source proof; concurrent clients versus requests and egress per second; admission issuance time versus client observation time. See [ADR-0059](adr/0059-conditional-http-delivery-and-polling-budgets.md) and Review 059. Preserve D-009/D-010/D-014/D-019/D-056/D-058 and all original requirements.

## D-060: Separate Redis demand control from durable business guards and recovery
Date: 2026-10-11
Status: Accepted
Problem: Redis token or counter loss can admit duplicate work. Unbounded bypass overloads PostgreSQL, while blanket shutdown blocks valid existing checkout.
Options: Trust Redis locks as allocation authority; bypass failed Redis for all work; pause uncertain new demand and reserve bounded guarded recovery paths.
Decision: Keep bounded same-slot Redis coordination, ownership-checked finite-TTL tokens and request gates. Inventory durably enforces bundle allocation, purchase quota, logical attempts, unresolved work and account/occurrence cooldown; Waiting Room owns durable FIFO and capacity. A failed required gate pauses affected new joins, admissions and allocation attempts, using 503 for uncertainty and 429 for known rate exhaustion.
Reason: Existing payment conversion, confirmation, callback ingestion, closure and monetary recovery can use separate reserved owner paths without a new advisory Redis lock, while preserving customer/service authority, clock, fencing, durability and original deadlines. Unknown external dispatch still follows its existing provider policy; Redis TTL never proves closure.
Disadvantages: Durable guards add writes and Redis uncertainty reduces availability. Use a separate production coordination cluster, initially at least three primaries with independently hosted replicas, plus bounded local containment. Reconcile active/unknown work and conservatively recover lost counter windows before guarded reopening; exact algorithms, generations, capacities and outage performance remain unproved.
Related concepts: Advisory contention token versus authoritative allocation guard; new demand pause versus reserved workflow recovery; lost request counter versus reset business entitlement. See [ADR-0060](adr/0060-redis-coordination-failure-and-durable-business-guards.md) and Review 060. Preserve D-002/D-010/D-014/D-019/D-032/D-053/D-058 and all original SLOs.

## D-061: Establish FIFO with transactional acceptance batches and guarded dispatch
Date: 2026-10-11
Status: Accepted
Problem: Independently allocated IDs can commit out of order. Parallel admission workers can bypass an earlier eligible locked entry, and Redis counts cannot establish safe capacity.
Options: Redis ordering or independent sequences; unrestricted SKIP LOCKED dispatch; transactional occurrence ordinals with bounded batching and serialized admission.
Decision: Assign immutable ordinals through a locked logged append-control row with Queue Entries, deduplication receipts and Outbox work in one Waiting Room transaction. Start with at most 256 distinct joins or five milliseconds collection time; acknowledge only verified D-032 commits. Duplicate/reconnect retains the same valid entry, buffered requests have no promised priority and recovered visible facts need durability barriers.
Reason: Separate append/dispatch controls prevent join lock contention from directly holding the dispatcher. A database-generation-guarded logical dispatcher selects the earliest eligible entry without locked-head bypass, then atomically issues the lease and reserves occurrence/global capacity and rate budgets in the same owner database. No external wait runs inside critical locks.
Disadvantages: Hot-occurrence ordering and global admission accounting remain serialized resources. Eligibility, status recovery, batching limits and numeric progress/ingress SLOs still need proof. Recover original entries and active/unknown leases before guarded reopening; Redis rebuilds never reassign priority or reset capacity. Measure concentrated bursts, durable throughput and failover without claiming replica count proves 1M capacity.
Related concepts: Allocated sequence value versus durable acceptance order; buffered join request versus accepted Queue Entry; serialized FIFO dispatch versus parallel background work. See [ADR-0061](adr/0061-durable-fifo-batches-and-serialized-admission.md) and Review 061. Preserve D-010/D-011/D-013/D-014/D-032/D-060 and all original SLOs.

## D-062: Preserve queue membership while suspending expired presence
Date: 2026-10-11
Status: Accepted; presence-renewal receipt history only is replaced by [D-063](adr/0063-presence-only-cumulative-receipts-and-replay-guards.md). All other scopes remain accepted. Pure presence projection delivery is specialized by [D-064](adr/0064-coalesced-presence-projection-and-immutable-lifecycle-events.md); critical event history remains unchanged.
Problem: Disconnect or missing Redis data can falsely discard priority, while undefined presence allows admission to an absent client and consumption of its fixed selection time.
Options: Delete missing heartbeat entries; admit all waiting entries indefinitely; preserve durable membership with separately renewed presence and suspended eligibility.
Decision: Give pre-admission Queue Entries an owner-durable presence deadline of at most 120 seconds from the original authorized observation, renewed by authenticated POST commands at least thirty seconds apart. GET polling does not renew presence. Guard entry generation, fresh authorization, clock uncertainty and owner durability; duplicate responses retain original deadlines. Safely proven expiry suspends eligibility while preserving the original ordinal.
Reason: Same-account authorized renewal reactivates valid waiting membership without undoing already issued leases. Missing Redis data or uncertain evidence cannot prove absence; explicit leave or permanent admission end retires membership, while temporary pause does not. Issued SelectionWindow, Active Hold and Payment Reservation keep their original deadlines and existing closure/requeue rules.
Disadvantages: Roughly 33,333 durable renewals per second at 1M continuously active clients add WAL, replication, projection and receipt storage cost. D-043 retention remains unchanged pending a separate explicit amendment; sustained all-day distinct renewals imply about 2.88 billion receipts per day. Failed renewals may suspend eligibility and consume availability budget; capacity and private status recovery remain unproved.
Related concepts: Waiting membership versus current admission eligibility; presence renewal versus reservation extension; heartbeat acknowledgment versus status observation. See [ADR-0062](adr/0062-durable-queue-presence-and-suspended-eligibility.md) and Review 062; Queue Presence is defined in CONTEXT.md. Preserve D-011/D-017/D-019/D-032/D-038/D-043/D-053/D-061 and all original requirements.

## D-063: Compact only presence receipts behind cumulative durable replay guards
Date: 2026-10-11
Status: Accepted; replaces only presence-renewal individual receipt history inherited from D-043/D-062. Other command and event scopes remain unchanged. Pure presence projection delivery is specialized by [D-064](adr/0064-coalesced-presence-projection-and-immutable-lifecycle-events.md); critical event history remains unchanged.
Problem: Per-pulse receipt archives grow rapidly. Deleting evidence without a durable guard lets old requests renew presence after compaction or snapshot rollback.
Options: Keep every pulse receipt for thirty days; prune by TTL; retain cumulative scoped progress and the latest receipt with explicit superseded outcomes.
Decision: Scope presence renewal to account, occurrence, exact entry and recovery generation. In owner PostgreSQL store highest accepted sequence, latest canonical payload hash, original observation/deadline and latest receipt. Accept only the next sequence under original rate, membership, authority and durability guards; matching latest retries preserve their deadline, changed payload conflicts and older sequences have no effect.
Reason: Superseding an older presence receipt after a later verified commit bounds receipt bodies by retained entry scopes while preserving replay fencing. Keep cumulative and lifecycle guards across suspension and retirement; never auto-initialize missing history or reuse retired identity. Ordinary failover preserves acknowledged progress; rollback restore requires reconciliation and a fresh fenced presence recovery generation.
Disadvantages: Exact old heartbeat responses cannot be reproduced after compaction. Owner writes, WAL, synchronous replication and unchanged Outbox/Kafka history costs remain. Sequence overflow, missing guards and uncertain recovery pause renewal; cleanup, restore and full 1M capacity remain unproved. No booking, payment, refund, allocation, admission, join, leave or operator receipt gets this exception.
Related concepts: Cumulative command guard versus individual response archive; superseded pulse versus new presence observation; ordinary failover versus rollback restore of replay evidence. See [ADR-0063](adr/0063-presence-only-cumulative-receipts-and-replay-guards.md) and Review 063. Preserve D-024/D-026/D-032/D-038/D-053/D-062 and all original safety/SLO requirements.

## D-064: Coalesce pure presence projection work and preserve immutable lifecycle events
Date: 2026-10-11
Status: Accepted; specializes only pure presence delivery inherited from D-024/D-062/D-063. Materialized events and critical history retain D-024/D-026 guarantees.
Problem: Per-pulse immutable archives remain expensive after receipt compaction. Rewriting events or clearing newer work through an older worker can corrupt recovery.
Options: Archive each pulse; mutate event envelopes; coalesce replaceable current-state work separately from immutable lifecycle facts.
Decision: Atomically commit presence, cumulative evidence and one desired projection record per exact entry generation with verified owner durability. Separate pulse and lifecycle revisions; retain immutable lifecycle Outbox events. Bound unresolved publication intents to one per entry generation and publish complete owner snapshots through one fenced path outside SQL locks.
Reason: Guarded completion clears only the captured revision under current authority. Newer pulses remain pending; unknown publication retains recovery work. Preserve original source time, deadlines, image digest and generation; Redis acknowledgment flags alone cannot prove a current image after loss or rollback.
Disadvantages: Pulse-by-pulse bus history is absent. Steady-state owner writes and projection delivery may still approach 33,333 per second at 1M participation, plus barriers and lifecycle work. Status certification, bounded recovery, retention and capacity need proof; no fallback scan or simplified deployment establishes production readiness.
Related concepts: Coalesced projection work versus immutable event history; captured projection revision versus current desired revision; pulse revision versus critical lifecycle revision. See [ADR-0064](adr/0064-coalesced-presence-projection-and-immutable-lifecycle-events.md) and Review 064. Preserve all original correctness, scale, deadline and SLO requirements.

## D-065: Bound private queue status freshness and admission visibility separately
Date: 2026-10-11
Status: Accepted; numeric targets and read semantics are requirements, not measured guarantees.
Problem: Fast stale reads can hide admission or show a closed lease. Publication delay consumes the fixed Selection Window, and Kafka offsets do not cover coalesced pulses.
Options: Unbounded advisory status; reset selection time when observed; certify complete private observations with separate freshness and delivery objectives.
Decision: Bound worst-case source age to five seconds at server response. Target 99.9% usable fresh eligible logical reads over thirty days and p99 below 200 ms including gateway, authentication and internal queues. Separately target 99.9% of issued leases becoming certified and server-servable within two seconds of original owner issuance, including commit delay and never-visible failures.
Reason: Source proof covers lifecycle and coalesced work against actual images. Reserve delivery capacity and reduce/pause new admission when evidence or budgets fail. Unknown/stale images yield unavailable observations with bounded retry, preserving membership and deadlines. Current lease authority remains a checkout guard; original credentials and private/no-store responses cannot create new admission.
Disadvantages: Certification and private polling add substantial owner, Redis, authentication and network cost. Separate percentiles cannot prove a combined browser bound; modeled 8.2-second visibility excludes client transport and scheduling. Overload, unknown reads and platform-caused admission loss consume the SLO budget. Exact proof schema, capacity and recovery remain unvalidated.
Related concepts: Status freshness versus admission visibility delay; source completeness across coalesced and immutable work; separate percentile objectives versus a joint delivery bound. See [ADR-0065](adr/0065-private-status-freshness-and-admission-visibility.md) and Review 065. Preserve D-019/D-033/D-040/D-053/D-059/D-064 and all original requirements.

## D-066: Certify private status through transactional bucket revisions and immutable directories
Date: 2026-10-11
Status: Accepted; the algorithm is selected, while implementation, failure recovery, sizing and capacity remain unproved.
Problem: Clearing publication work can erase uncertified change evidence. Hash membership, Kafka offsets or fresh timestamps alone cannot establish complete owner coverage.
Options: Per-pulse immutable history; full owner scans per poll; coalesced transactional source tracking with background cuts and immutable directory proofs.
Decision: Start with 1,024 stable hash buckets per Waiting Room HA group. Every relevant mutation atomically updates its logged bucket counter, owner state and latest per-entry certification-dirty evidence. Retain that evidence separately from delivery work until a complete consistent cut covers it. Seal bounded manifests from one Repeatable Read snapshot and a proved baseline with verified owner durability.
Reason: Immutable Merkle directory versions bind exact images, revisions and scope to a certified root; actual coverage and baseline checks supply completeness. Guard head switches and owner baseline advancement, preserve later dirty work, use original source time and invalidate lost/unsafe generations before isolated rebuild. Per-client reads need image/directory/control proof rather than a primary query or full directory download.
Disadvantages: Counters, evidence, hashing, proof lookup and retained objects add cost. Lock ordering, shared-control tracking, revision domination, object retention and complete writer coverage need validation. Merkle membership cannot certify an incomplete source cut; bucket count cannot prove 1M capacity or free deployment readiness.
Related concepts: Publication completion versus certified coverage; transactional bucket revision versus FIFO ordinal; Merkle membership versus source completeness. See [ADR-0066](adr/0066-bucket-revisions-and-certified-private-directories.md) and Review 066. Preserve D-032/D-053/D-057/D-060/D-061/D-064/D-065 and all original requirements.

## D-067: Set separate queue ingress and admission progress targets
Date: 2026-10-11
Status: Accepted; capacity floors and workload profiles are targets, not measured production guarantees.
Problem: Active sessions can coexist with slow durable joins or stalled admission. Spreading bursts, counting duplicates and dropping offered work can hide failure.
Options: Concurrency-only benchmarks; unrestricted buffers and mass rejection; explicit steady/burst ingress and independently measured dispatch progress.
Decision: Keep a one-occurrence 1M active thirty-minute profile. Require 25,000 distinct durable joins per second for sixty seconds with healthy ingress p99 below two seconds; test 1M offered opening joins within one second and at least 99.9% timely durable receipts within sixty seconds of first gateway arrival. Preserve full offered-request accounting and rolling logical-operation availability.
Reason: Bound unaccepted buffering to forty-five seconds and 1M distinct pending logical joins globally through conservative nonoverlapping instance budgets, without buffer-assigned priority. Require a separate sixty-second 1,000-durable-lease-per-second fixture with 75,000 accounted slots and 99.9% permitted-opportunity issuance within one second. Real admission follows measured downstream capacity and accounted residence time.
Disadvantages: Buffers, connections, serialized controls, WAL and retained lifecycle history add cost. Fixture slots do not define deployed capacity or booking throughput. Rejections, unknown work, delayed receipts and overload pauses remain visible; short or generator-limited runs cannot prove thirty-day SLOs, 1M capacity or free-tier readiness.
Related concepts: Queue acceptance latency versus checkout waiting time; dispatch capacity versus completed-booking throughput; lease residence time and capacity accounting. See [ADR-0067](adr/0067-queue-ingress-and-admission-progress-objectives.md) and Review 067. Preserve all original safety, deadline, availability and hold latency requirements.

## D-068: Require useful hold throughput and history-based contention correctness
Date: 2026-10-11
Status: Accepted; capacity, correctness and workload targets remain unmeasured.
Problem: Receipt replay can inflate useful throughput, fast Redis refusals can conceal unavailable owners and final database counts can miss transient double ownership.
Options: HTTP-only benchmarks and final counts; reject contested work; real owner-path capacity plus authoritative conflict decisions and complete safety history.
Decision: Require 1,000 new distinct durable bundle holds per second for thirty minutes with sufficient disjoint inventory. Exercise one-seat and four-seat bundles through all original guards, commits and Outbox work. Separately test 5,000 valid logical attempts per second for sixty seconds and 10,000 first attempts within one second against a shared four-seat bundle, plus overlapping/order variants.
Reason: Preserve successful and proven-conflict p99 below 200 ms and rolling availability accounting. A healthy contested bundle has at most one new valid winner and no partial losing allocations. Validate complete committed history, original deadlines, generations, quota and command effects; duplicates do not count as new useful holds and unproved Redis refusals are unavailable outcomes.
Disadvantages: The synthetic 600,000-seat and 200,000-slot fixture is not a real venue or production default. Real two-minute expiry, accounted closure and unresolved tails add cost. Repeat with 1M background traffic and covered faults; full journey, provider throughput, actual capacity and thirty-day SLO compliance remain unproved.
Related concepts: Useful hold throughput versus receipt replay throughput; authoritative conflict versus coordination refusal; safety history versus a final database snapshot. See [ADR-0068](adr/0068-useful-hold-throughput-and-contention-correctness.md) and Review 068. Preserve all original allocation, payment, scale and deadline requirements.

## D-069: Separate local payment objectives from external provider guarantees
Date: 2026-10-11
Status: Accepted; local throughput, provider capabilities and test isolation remain unproved.
Problem: Fast acceptance or callback ACK can hide stalled fulfillment. A simulator cannot prove monetary replay, external quotas or refund settlement.
Options: Assume sandbox throughput; omit high-volume payment validation; keep actual sandbox contract tests plus isolated supplemental provider tests.
Decision: Keep SSLCOMMERZ sandbox mandatory. Initially cap aggregate sandbox client work at one request per second and one active client HTTP call per merchant/environment. Accept a deterministic isolated test double through the normal adapter and verification path, with no external payment egress, real credentials or database injection. Sandbox/live deployment rejects test adapters and evidence.
Reason: Require StartCheckout acceptance p99 below 300 ms and durable callback ACK p99 below 200 ms. Healthy eligible profiles target 99.9% proven conversion within one second of acceptance, safe initial dispatch within one second of conversion and confirmation within two seconds of verified eligible charge evidence. Preserve original deadlines, the ten-second fixture margin and all safety/recovery guards in Review 069.
Disadvantages: Separate sixty-second simulated profiles require 1,000 distinct conversions/dispatches and correct confirmations per second, 3,000 valid callbacks per second with 1,000 distinct charges, and 1,000 correct durable refund obligations per second in compensation tests. Provider settlement, capacity, live readiness and thirty-day SLO compliance remain unproved; simulator assumptions and real sandbox findings need separate evidence.
Related concepts: Local payment capacity versus provider capability evidence; pending checkout acceptance versus payment readiness; verified charge evidence versus refund settlement. See [ADR-0069](adr/0069-payment-journey-targets-and-isolated-provider-testing.md) and Review 069 for fixtures, fault cases, isolation and timing boundaries. D-005 sandbox scope and D-035 replay gates remain in force.

## D-070: Require mixed public reads and all-detail capacity evidence
Date: 2026-10-11
Status: Accepted; capacity, wire encoding and overview/search semantics remain unproved.
Problem: Public reads can exhaust gateway, Redis or egress capacity while checkout admission remains bounded. High cache reuse or falling offered load can hide limits.
Options: Assume cache hits; force summary-only browsing; preserve mixed and all-detail profiles with independent capacity measurements.
Decision: Require thirty-minute 1M-active-user mixed and all-detail profiles under D-059. The mixed nominal public budget is 380,000 HTTP requests per second before jitter; all-detail reaches two million section requests per second. Include applicable queue/presence/Auth, source certification, checkout and recovery work with correct fixtures. Keep anonymous browsing and original safety requirements.
Reason: Target section/overview server p99 below 200 ms and bounded catalog/search p99 below 500 ms. Preserve two-second certified availability freshness and 99.9% usable reads. Fetch two sections sequentially inside one refresh; measure whole-refresh and per-section outcomes separately. Keep at most 512 seats/64 KiB per certified frame, use initial limits of at most 4 KiB overview and twenty items/32 KiB catalog/search pages without truncating facts.
Disadvantages: Full-body all-detail payload alone models 1.048576 Tbit/s before overhead. Cold caches, proof verification, connections, retries, hot shards and publication add cost. Frame-cache hits and conditional-body reuse differ; conforming rejection, UNKNOWN and generator limits cannot establish capacity or SLO compliance.
Related concepts: Active users versus offered requests and network bytes; conditional body reuse versus frame cache hits. See [ADR-0070](adr/0070-public-read-workloads-and-worst-case-fanout.md) and Review 070 for mixes, faults, resource separation and free-profile evidence. Search, overview certification and actual deployment limits remain follow-ups.

## D-071: Bound discovery freshness and certify complete overview truth
Date: 2026-10-11
Status: Accepted; search-reader binding, summary production and capacity remain unproved.
Problem: Old search prices or cancellation observations can conflict with fresh seats. Adding independently timed section counts cannot prove a coherent occurrence total.
Options: Treat index ACK and heartbeat as freshness; silently merge section counts; preserve separate owner observations and prove complete source coverage.
Decision: Event and Venue owns public discovery; Elasticsearch contains only public catalog revisions and advertised activated terms. Require complete query-visible source proof no older than thirty seconds and 99.9% usable eligible queries over thirty days at declared load. At least 99.9% of healthy-profile public revisions must be reflected or proven superseded within thirty seconds of their publicly eligible owner commit.
Reason: Inventory retains authoritative allocation and two-second advisory availability proof. Any exposed occurrence counts need one complete owner cut and mutually exclusive categories. Missing proofs yield explicit updating/unknown; stale prices require expected-version reconfirmation without changing valid Checkout Quotes or deadlines. Newer known withdrawal/cancellation cannot be overwritten by older replay or cache.
Disadvantages: A bounded old search card can still require reconfirmation or be rejected by owner guards. Completeness, actual reader visibility, consistent summaries and rebuilding add cost; fresh metadata beside UNKNOWN availability is degraded and consumes its read SLO budget. No proof of capacity or free-cloud readiness exists yet.
Related concepts: Discovery observation versus permission to purchase; query visibility versus index acknowledgment; complete occurrence summary versus independently timed section counts. See [ADR-0071](adr/0071-discovery-freshness-and-owner-certified-overview-truth.md) and Review 071 for privacy, controls, timing and failure boundaries. Preserve D-021/D-051 quotes and D-056/D-070 freshness, traffic and latency targets.

## D-072: Bind complete search coverage to shared audited PITs
Date: 2026-10-11
Status: Accepted; audit capacity, pinned-version behavior and failure handling remain unproved.
Problem: A certificate outside the actual search reader can hide missing documents. Per-user PITs multiply resources; pagination retention does not renew source freshness.
Options: Trust index ACKs or markers; allocate PITs per user; enroll bounded shared readers after complete owner-to-reader comparison.
Decision: Build complete expected public state from owner baseline/cut evidence and audit every candidate PIT's actual canonical document set, including missing/extra documents and tombstones. Initially coalesce source cuts every five seconds, allow ten seconds from capture to ready and account at most eight candidate/serving/retiring/unresolved PITs globally per catalog generation. Unknown opens/closes remain accounted.
Reason: Durable descriptors, bounded server query shapes and tamper-evident cursors bind the verified reader, source cut, registered indices/shards, schema, query/sort and original expiry. Use search_after and documented same-PIT concurrent ID updates. New or unproved replacement readers need certification. Reject partial/failed/timed-out reads; a platform-created expiry remains unavailable.
Disadvantages: Whole-catalog readback, retained contexts and document churn consume background CPU, bytes, disk and heap. Known newer visibility/commercial facts invalidate affected old views. Keeping contexts alive cannot refresh source proof; incremental audit skipping needs separate proof and review. No capacity, availability or free-cloud result is established yet.
Related concepts: Pinned search reader versus complete source coverage; search cursor lifetime versus observation freshness. See [ADR-0072](adr/0072-audited-shared-search-pits-and-original-expiry-cursors.md) and Review 072 for versions, replay, scope, cleanup and failures. Preserve D-070/D-071 workloads, payloads, latency and thirty-second discovery targets.

## D-073: Produce complete inventory summaries from transactional striped counters
Date: 2026-10-11
Status: Accepted; counter correctness, contention, publication, audits and capacity remain unproved.
Problem: One shared counter serializes unrelated holds. Independent deltas or expiry arithmetic can misstate seats. Correct totals alone cannot prove correct classifications.
Options: One hot count row; asynchronous deltas or repeated seat scans; fixed transactional stripes and consistent owner snapshots.
Decision: Keep one occurrence's allocation, bundles, quota and summary state in one Inventory PostgreSQL HA group. Seal fixed seat membership in initially 1,024 possible hash buckets. Protected mutations update changed categories, quota, receipts and required Outbox facts atomically. Categories distinguish ledger-free, unclosed temporary, current confirmed and other blocked units.
Reason: A canonical complete lock plan preserves whole-bundle reclaim and after-wait guards. Coalesced 500 ms owner snapshot attempts read every expected bucket from one consistent cut. Logged sealing, Outbox/Kafka and immutable Redis frames preserve original age and independent summary coverage. Counts remain advisory; expiry alone cannot free stock.
Disadvantages: Extra writes, synchronous lock time, retained artifacts and audits consume capacity. A hot occurrence retains a measured primary write limit. Fully verify preparation and uncertain rebuilds; initially audit every fifteen minutes while active. Mismatch invalidates certification and needs audited fenced recovery. Buckets and replicas do not prove 1M throughput.
Related concepts: Transactional striped counters versus asynchronous deltas; unclosed temporary allocation versus available stock. See [ADR-0073](adr/0073-transactional-inventory-counters-and-consistent-summaries.md) and Review 073 for lock order, controls, proofs, retention, payloads and failure tests. Preserve D-008/D-016/D-020/D-024/D-026/D-030/D-032/D-053/D-056/D-057/D-058/D-068/D-070/D-071. D-081 refines used-seat accounting: confirmed used stock remains CurrentConfirmed and revoked used stock becomes OtherUnavailable, with atomic source/certificate evidence and no use reset.

## D-074: Bound aggregate database backends and reserve accepted-work resources
Date: 2026-10-11
Status: Accepted; numeric budgets, pinned versions, identity integration and surviving capacity remain unproved.
Problem: Autoscaling and independent proxy pools can collectively exhaust PostgreSQL. Shared queues can starve accepted checkout, payment evidence and recovery.
Options: Per-replica pools with optimistic limits; one shared pool with spare slots; aggregate backend budgets and separate protected work classes.
Decision: Add self-hosted PgBouncer transaction pooling for normal owner SQL. Preserve each complete transaction and durability barrier on one backend. Bound aggregate physical-group backends across proxies, aliases, roles, jobs and rollout overlap. Initially assign nonoverlapping static shares and retain uncertain lost shares until closure/fencing is proved.
Reason: Separately capped owner pools protect accepted checkout, evidence ingestion, recovery and publication from new demand. Bound queues by bytes, count and remaining deadline. No caller-selected privilege, RPC under SQL locks or timeout-based replay is allowed. Include pool and lock waits in end-to-end targets.
Disadvantages: Idle protected shares cannot initially be borrowed by new demand. CPU, IO, WAL and lock contention still need measured headroom. Sample capacity health every second with five-second original-age expiry; adjust admission within measured ceilings and count overload failures. Production needs independently hosted poolers and proved survivor capacity.
Related concepts: Client connections versus database backend capacity; recovery bulkheads versus spare connections in a shared pool. See [ADR-0074](adr/0074-aggregate-backend-budgets-and-protected-work-pools.md) and Review 074 for transaction restrictions, security, HA routing and failure tests. Refines D-010/D-030 pool enforcement; preserves D-031/D-032/D-033/D-041/D-042/D-043/D-060 and all capacity targets.

## D-075: Expose evidence-bound private order status with separate outcomes
Date: 2026-10-11
Status: Accepted; source publication, causal proof and capacity remain unproved.
Problem: Payment success does not prove confirmed seats. Revocation does not prove returned money. A fresh local ledger can contain old provider evidence or hide newer acknowledged cancellation.
Options: One SUCCESS flag or provider polling per read; independently certified owner observations behind an authenticated Booking facade.
Decision: Separate Booking workflow, Inventory allocation/control and Payment charge/refund evidence. Bind account, Order, allocation lifecycle, revisions, generations and independent source cuts. Preserve historical confirmation. Current claims need matching causal evidence; missing proof returns processing/unknown. Provider-confirmed refund outcome never promises bank credit.
Reason: Bound required local observations to five seconds at response. Target 99.9% usable eligible reads over thirty days, p99 below 200 ms and separately 99.9% of durable customer-visible transitions becoming certified and server-servable within two seconds. Preserve provider-evidence time, original unresolved age and read-your-command minima without inventing a global snapshot.
Disadvantages: Object authorization, proof construction and private fanout add cost. Use private/no-store, no 304, no per-client primary/provider fallback and five-to-six-second polling. Cap summary envelopes at 8 KiB and paginate financial history. Missing keys cannot prove absence. UNKNOWN/rejection remains an SLO failure; actual bank-credit and local scale evidence remain separate gaps.
Related concepts: Order observation versus a global transaction snapshot; local payment freshness versus provider evidence age. See [ADR-0075](adr/0075-evidence-bound-private-order-status.md), Review 075 and its validation proposal for state rules, timing, privacy, fixtures and read minima. Preserve D-007/D-023/D-032/D-034/D-038/D-043/D-045/D-046/D-048/D-050/D-053/D-069/D-074.

## D-076: Certify private owner dictionaries before causal status merging
Date: 2026-10-11
Status: Accepted; hash encoding, complete writer coverage, recovery, retention and capacity remain unproved.
Problem: Fresh Booking timestamps cannot refresh old external-owner facts. Cache misses cannot prove absence, and inclusion proofs alone cannot prove complete source coverage.
Options: Re-time composed cache entries or query all primaries per poll; independently certify complete owner dictionaries and merge causal evidence.
Decision: Each status owner uses initially 1,024 fixed hash buckets with transactional revisions and latest certification-dirty evidence. Build complete baselines and consistent owner cuts, initially attempting coalesced private cuts every second. Seal logged manifests and immutable sparse Merkle dictionaries with distinct populated, empty and retired encodings and purpose-scoped owner descriptors.
Reason: Prove baseline/change/control completeness separately from dictionary membership or exact-key absence. Verify actual images and paths before fenced Redis head publication. Advance baselines and prune only covered unchanged dirty revisions. Booking validates independent cuts, generations, account scope, matching causal receipts and command minima; a composite seal cannot renew underlying evidence.
Disadvantages: Source writes, hashing, proof lookup and retained nodes add cost. Bound internal readback initially to 64 KiB total and public summaries to 8 KiB. Unknown proof or generation returns unavailable. Local Payment absence cannot authorize provider replay. Rebuild isolated lost generations; safe object cleanup and complete capacity remain unresolved.
Related concepts: Certified absence versus a missing cache key; causal merge versus timestamp ordering. See [ADR-0076](adr/0076-owner-certified-private-dictionaries-and-causal-reads.md), Review 076 and its validation/recovery entry for scopes, encoding, writer/lock rules and tests. Extends D-066's certification discipline to distinct status owners without changing D-024/D-026 critical history or D-075 semantics. D-084 extends protected certification writer/image coverage to Ticket issuance and credential enrollment, replacement, use and revocation; original completeness, cut-age and recovery rules remain. D-089 extends owner-certified completeness/change/control patterns to Notification private feed writers; feed freshness remains separate from current Booking/Inventory/Payment authority.

## D-077: Persist due work and measure guarded resource closure
Date: 2026-10-12
Status: Accepted; worker safety, complete scheduling coverage, recovery capacity and timing remain unproved.
Problem: Lost expiry hints can strand resources. Stale work can close a newer phase, and a scheduler with no excess capacity cannot drain a failure backlog.
Options: Redis expiry notifications or volatile timers alone; durable owner-local due work with canonical transition guards and measured progress.
Decision: Persist due work with allocation and lease transitions. Keep original deadlines and stable task identities. Initially poll idle groups every 250 ms, claim at most 64 metadata rows with SKIP LOCKED, and drain bounded batches under reserved budgets. Recheck complete locks, current phase, fences and justified primary time in each business transaction.
Reason: Superseded jobs cannot close converted or confirmed allocations. Unknown commits retain resources and recover the same canonical outcome. Claimed-slot retirement requires matching Inventory terminal proof and a fence against later allocation; confirmed seats and consumed quota survive retirement. This is a narrow clarification of D-015.
Disadvantages: Scheduling writes, receipts, audits and slot reconciliation add cost. Target 99.9% expired allocation and safely unused lease closure within five seconds of original deadlines, and claimed-slot retirement within two seconds of Inventory terminal commit. Safety uncertainty remains a missed target. Financial recovery keeps D-034 rules.
Related concepts: Eligibility expiry versus resource closure lag; scheduling claim versus business authority. See [ADR-0077](adr/0077-durable-due-work-and-guarded-closure-progress.md), Review 077 and accepted validation for 1,000 closures/s, a 30,000-job backlog drained within sixty seconds with continuing arrivals, alerting and fault accounting. All original correctness, availability, latency and scale requirements remain.

## D-078: Issue stable per-seat tickets with Booking confirmation
Date: 2026-10-12
Status: Accepted; implementation, artifact formats, rendering budgets, capacity and venue-admission scope remain unproved or unresolved.
Problem: Retry can create duplicate tickets. A saved artifact can outlive cancellation or be mistaken for current rights to a resold seat.
Options: Independently issue entitlement-bearing documents; create stable Booking-owned records and keep Inventory as the entitlement authority.
Decision: Create one ticket per Event Seat in the same local transaction as Booking confirmation, using matching durable allocation and funding proofs. Bind account, Order, occurrence, seat, configuration and exact allocation lifecycle. Uniqueness and canonical recovery preserve identities across replay and unknown commits.
Reason: Ticket records, rendering and notification do not allocate seats. Cancellation applies to the original allocation without waiting for document deletion. Preserve historical tickets through resale. Per-seat identity does not authorize partial cancellation, transfer or quota restoration.
Disadvantages: Ticket rows, retained references and private representations add work. Every read/download checks fresh authentication and object ownership. Saved artifacts show history; current entitlement uses separately timed D-075/D-076 observations. Render outside business locks under bounded resources; format-specific promises require further decisions.
Related concepts: Ticket; Ticket Artifact; per-seat identity versus bundle cancellation. See [ADR-0078](adr/0078-stable-per-seat-ticket-issuance-and-artifact-boundaries.md), Review 078 and accepted validation. Preserve D-007/D-008/D-032/D-043/D-045/D-048/D-050/D-069/D-075/D-076 and existing confirmation/status/1M targets; D-079 now selects online venue check-in as a separate scope addition without changing ticket ownership or artifact authority.

## D-079: Own online single-use venue check-in in Inventory
Date: 2026-10-12
Status: Accepted as an explicit scope addition; credentials, staff policy, entry windows, consumed-ticket rules, operating procedures and capacity remain unresolved or unproved.
Problem: Correct booking cannot prevent copied artifacts from being accepted at two gates or stale entitlement from authorizing entry after cancellation.
Options: Delegate entry to a separate venue system; add online single-use check-in to TicketForge with Inventory as its authority.
Decision: Add backend venue check-in and reproducible simulated gate clients within the original eight services. Require scoped staff authority and a durable Inventory first-use outcome bound to the Ticket, occurrence, Event Seat and exact confirmed allocation lifecycle. Serialize check-in with revocation and occurrence fences.
Reason: At most one logical first use succeeds. Check-in does not free seats, restore quota, transfer ownership or change money. Recover unknown commands using the same identity; a recovered receipt is historical evidence, not a new passage authorization. Later cancellation preserves recorded use and cannot undo physical attendance.
Disadvantages: New authorization, policy, load and gate operating obligations apply. Loss of authoritative proof pauses new acceptance. Independent disconnected gates cannot freely accept duplicate credentials while preserving one winner and immediate revocation. Redundant production connectivity and free-profile gaps need evidence.
Related concepts: Venue Check-in; exclusive allocation versus first use; recorded outcome versus physical passage. See [ADR-0079](adr/0079-online-single-use-venue-check-in-scope-and-authority.md), Review 079 and accepted validation. Extends D-078 scope while preserving D-001/D-008/D-032/D-043/D-048/D-050/D-073 and all original 1M/latency/availability requirements; additional gate SLOs remain to be selected.

## D-080: Enroll and reissue opaque bearer venue credentials in Inventory
Date: 2026-10-12
Status: Accepted; wire/encryption profiles, complete guards, delivery, recovery, bulk compromise fencing and capacity remain unproved. Venue policy and gate budgets remain unresolved.
Problem: Group purchasers need separate attendee credentials. Copies can be stolen, and enrollment or reissue retries can race cancellation and first use.
Options: Named-attendee identity checks; bearer secrets accepted only by authorized staff through current Inventory guards.
Decision: Use one Inventory-owned 256-bit-or-stronger CSPRNG secret per Ticket/version in a bounded non-URL QR, initially at most 512 bytes. Register exact Booking issuance/allocation evidence through durable work and one canonical owner transaction. Store domain-bound verification digests and purpose-encrypted recoverable delivery material. Keep raw secrets out of Kafka, logs and traces.
Reason: Purchasers may privately share credentials without transferring account, quota or cancellation/refund rights. Initial enrollment and reissue recover the same command/version/material. Reissue requires fresh password authentication, a sixty-second action-bound grant and current thirty-second Auth evidence, then atomically replaces the unused version without overlap or first-use reset.
Disadvantages: Bearer copies do not prove identity; stolen valid copies can win first use. Enrollment and protected delivery add writes and lag. Rendering cannot activate a credential. Private retrieval requires current authorization; lost authority fails closed. Validate the four-seat 4,000-enrollments/s case alongside 1,000 confirmations/s and 1M background without claiming gate/render capacity.
Related concepts: Entry Credential; bearer possession versus identity; replacement versus first-use reset. See [ADR-0080](adr/0080-owner-enrolled-bearer-entry-credentials-and-atomic-reissue.md), Review 080 and accepted validation. Narrowly clarifies D-040 admission-purpose scope, leaves D-039 refresh rules intact and preserves D-032/D-043/D-048/D-069/D-075/D-078/D-079. Entry windows, used-seat policy and representation/gate SLOs remain explicit next decisions. D-088 selects customer/privileged MFA and prior recovery evidence, strengthens reset/reissue assurance and narrowly defines lost-mailbox recovery; ordinary account/domain guards remain.

## D-081: Bind admission windows and preserve used-seat lifecycle fences
Date: 2026-10-12
Status: Accepted; owner guards, configuration coverage, recovery, physical clearance procedures and capacity remain unproved.
Problem: Whole-bundle cancellation can resell used seats. Digital event cancellation cannot prove a venue empty or justify early overlapping reuse.
Options: Reset use with revocation or new credentials; preserve occurrence-level use history and define separate entry and cancellation policy.
Decision: Require approved finite half-open Admission Windows within original occupancy and bind the activated policy to purchases. Guard first use with conservative fresh primary time after all locks. Preserve Event Seat use across credentials, allocation generations and restore; no re-entry, use reset or used-seat resale. No-show/window closure does not free confirmed seats, restore quota or imply refunds.
Reason: Voluntary whole-bundle cancellation additionally requires every seat unused, while retaining D-049's cutoff and full quote. Authorized Event Cancellation still revokes and refunds used tickets without erasing use. Revoked used seats become OtherUnavailable; confirmed used seats remain CurrentConfirmed. Updates and certification evidence stay atomic under D-073.
Disadvantages: A partly used bundle cannot cancel only its unused tickets. Used stock remains blocked after revocation. Where check-in exists or clearance is uncertain, retain original occupancy blockers without automatic early release; operational clearance is distinct from digital fences and elapsed time. Exceptions cannot silently reset use or backdate authority.
Related concepts: Admission Window; Used Event Seat; calendar reservation versus physical clearance. See [ADR-0081](adr/0081-approved-admission-windows-and-used-seat-lifecycle-protection.md), Review 081 and accepted validation. Adds scoped D-049 eligibility and D-051 policy requirements, narrows D-055 early release and refines D-073 category accounting; preserves all original correctness/SLO/1M and financial guards. Staff operations and gate/artifact budgets remain next decisions.

## D-082: Scope staff/scanner authority and recover passage conservatively
Date: 2026-10-12
Status: Accepted; wire profiles, journal durability, compromise handling, operations and capacity remain unproved.
Problem: Forged device IDs, stolen access tokens and replayed success indications can authorize unsafe gate behavior despite one durable use record.
Options: Token/device-ID-only check-in and automatic success replay; scoped named staff, enrolled software-key proof and conservative lane recovery.
Decision: Use MFA staff/gate assignments, signed session-bound scanner requests, thirty-second nonce/authority bounds, five-minute access and eight-hour absolute/fifteen-minute inactivity staff sessions. Inventory owns fenced durable lanes with one outstanding check-in; persist client intent and claim indication before display. Never automatically green a duplicate or recovered receipt.
Reason: Staff identity and software-key possession have distinct roles. Durable matching passed reports permit lane progress; ambiguous or not-passed outcomes require scoped supervisor disposition while preserving Event Seat use, original windows, booking and money guards.
Disadvantages: Client crashes or response loss can pause legitimate attendees for investigation. Software keys do not prove hardware trust or exactly-once physical passage; staffing and spare scanner/network capacity need evidence.
Related concepts: Staff assignment versus scanner proof; receipt versus indication and passage report. See [ADR-0082](adr/0082-scoped-gate-authority-and-conservative-passage-recovery.md) and Review 082. Extends D-036/D-038/D-039/D-040/D-041 with a gate-specific authority profile, preserves customer lifetimes and D-079/D-081 use fences, and grants no financial or calendar-clearance powers. Gate/enrollment/artifact capacity remains next. D-088 selects customer/privileged MFA and prior recovery evidence, strengthens reset/reissue assurance and narrowly defines lost-mailbox recovery; ordinary account/domain guards remain.

## D-083: Measure useful gate cycles and protect enrollment/recovery capacity
Date: 2026-10-12
Status: Accepted; measured capacity, resource shares, staffing and fault behavior remain unproved.
Problem: Fast replayed receipts can hide stopped scanner lanes, slow enrollment and insufficient capacity for passage reports or recovery.
Options: API-only gate throughput and best-effort credentials; complete fresh lane cycles, separate readiness SLIs and protected operating budgets.
Decision: Require 200 fresh first uses and durable passed reports/s for thirty minutes across 1,000 lanes with original 1M/hold traffic and the checkout peak. Gate APIs retain p99 below 200 ms; measured scanner journey targets p99 below one second in the declared device/network envelope. Eligible enrolled/private-retrieval readiness targets 99.9% within two seconds of original confirmation.
Reason: Useful cycles, four-seat 4,000-enrollments/s peak and separate good/total SLIs include queues, unknown commits and faults. Preserve all original floors and protected resource budgets without treating rejection or receipt replay as successful entry.
Disadvantages: More writes and staffing are required. Detect unresolved lanes within ten seconds, create cases within thirty seconds and target production supervisor acknowledgement within two minutes without promising resolution; free-profile gaps remain visible.
Related concepts: Useful gate throughput; credential readiness. See [ADR-0083](adr/0083-useful-gate-throughput-enrollment-readiness-and-recovery-objectives.md) and Review 083. Extends D-078/D-080/D-082 metrics and D-074 capacity budgets while preserving original safety/SLOs. PDF/render and notification contracts remain next.

## D-084: Deliver version-bound private artifacts with isolated rendering
Date: 2026-10-12
Status: Accepted; complete proof coverage, library/font/storage choices and capacity remain unproved.
Problem: Old render output can be falsely labelled current after reissue, and large downloads can consume gate, enrollment or financial recovery resources.
Options: Public saved-document links and inline rendering; private exact-version artifacts with independently bounded jobs and fresh owner evidence.
Decision: Deliver bounded JSON, per-Ticket QR PNG and up-to-four-page Order PDFs through Booking with current authentication, ownership and complete owner-certified evidence at most five seconds old at release. Extend D-076 Ticket/credential writer coverage. Use exact-input durable jobs, isolated workers and encrypted regenerable caches; retries preserve the original credential.
Reason: Printed/saved artifacts record a version and cannot grant current entry independently. Rendering never activates, consumes or rotates a credential, and cached output never bypasses proof/authorization. Protected resource shares preserve all existing workloads.
Disadvantages: Eligible cold jobs target 99.9% downloadable within five seconds; format limits and separate p99 delivery targets need validation. Stage 1,000 JSON/QR reads/s and fifty PDF jobs/s for thirty minutes with a 250-job/s cold peak; capped output can approach 4.2 Gbit/s, requiring explicit free-profile gaps.
Related concepts: Artifact version binding; regenerable artifact cache. See [ADR-0084](adr/0084-version-bound-private-ticket-artifacts-and-isolated-rendering.md) and Review 084. Extends D-076/D-078/D-080 delivery coverage and D-074/D-083 capacity budgets without changing owner authority, first use or original SLOs. Notifications remain next.

## D-085: Own durable historical notices and report email submission honestly
Date: 2026-10-12
Status: Accepted; contact routing, Auth mail, retry/transport, SLOs and capacity remain unresolved or unproved.
Problem: SMTP response loss can duplicate mail, and delayed confirmations can arrive after cancellation without proving current booking or entry authority.
Options: Payment-triggered success mail and implied exactly-once delivery; owner-evidenced historical notices with durable local identity and explicit channel outcomes.
Decision: Notification owns PostgreSQL Inbox, one logical intent per owner transition/channel and dispatch attempts, with authenticated private in-app history and transactional email. Use matching durable Booking/Inventory/funding evidence for confirmation and distinct owner facts for cancellation and refund messages; no domain mutation depends on mail success.
Reason: Deduplicate intent creation, preserve original fact/time and known causal supersession, and link to current private Order Observation without QR/PDF or secret attachments. Persist attempts before submission; known relay acceptance stops automatic resubmission, while unknown submission may duplicate the same email under a later bounded retry policy.
Disadvantages: SMTP acceptance does not prove inbox placement or reading, and submitted mail cannot be recalled. Protected Mailpit tests only sandbox SMTP capture; external transport, recipient assurance, deliverability and capacity remain preserved production requirements.
Related concepts: Logical Notification Intent; historical notice versus current status. See [ADR-0085](adr/0085-durable-historical-notifications-and-honest-email-delivery.md) and Review 085. Preserves D-024/D-032/D-037/D-075/D-084 and all payment/booking replay guards. Contact and Auth security-mail routing follow next. D-086 adds exact contact/purpose routing, fixed Auth challenges and a separate protected security-mail adapter; business notices remain secret-free and account/MFA guards remain.

## D-086: Bind email routing and fixed challenges to Auth authority
Date: 2026-10-12
Status: Accepted; email identity/recovery, transport/retry, SLOs, retention and capacity remain unresolved or unproved.
Problem: Contact changes can redirect unknown mail or old reset tokens, while resends, previews and delayed capture can weaken recovery authority.
Options: Mutable-address job routing and renewed delivery-time links; exact Auth-owned contact/purpose binding and fixed original challenges.
Decision: Use Auth contact/routing evidence at most thirty seconds old, preserve exact possibly submitted attempt recipients and pause retry when that binding loses authority. Auth issues single-use 256-bit-or-stronger challenges with fifteen-minute reset or thirty-minute verification/change deadlines; active-flow resends reuse material and time.
Reason: Keep digest-only redemption and separate encrypted scoped security-mail delivery, reference-only Kafka work, fragment landing and explicit guarded POST without GET consumption. Preserve old/new mailbox, configured MFA, session invalidation and normal-login rules; test capture never proves production mailbox control.
Disadvantages: Unknown recipient changes require delivery cases and delayed links may expire. Scoped secret material, keyed sensitive-command fingerprints, protected backup retention and client handling need validation; no immediate SMTP/contact atomicity or protection against compromised endpoints is claimed.
Related concepts: Contact Binding; Auth Challenge; contact revision and fixed deadline. See [ADR-0086](adr/0086-auth-owned-contact-routing-and-fixed-security-mail-challenges.md) and Review 086. Extends D-037 and narrowly clarifies D-085 Auth-purpose delivery while preserving D-032/D-038/D-040/D-043/D-053 and all booking/payment guards. Equality/reuse and independent recovery evidence follow next. D-088 selects customer/privileged MFA and prior recovery evidence, strengthens reset/reissue assurance and narrowly defines lost-mailbox recovery; ordinary account/domain guards remain.

## D-087: Preserve mailbox meaning and guard verified contact history
Date: 2026-10-12
Status: Accepted; parser/profile, internationalized transport, migration and independent recovery remain unproved.
Problem: Inconsistent comparison, pre-registration and retired-address reuse can select the wrong account or inherit another holder's credentials/history.
Options: Whole-address/provider folding and unrestricted reuse; explicit Auth comparison with atomic verified claims and retained ownership guards.
Decision: Normalize validated domains with a versioned IDNA profile, preserve semantic local-part case/bytes and avoid provider dot/tag transformations. Keep internationalized transport in scope and fail without recipient approximation when capability is absent. Atomically allow one verified canonical binding per realm.
Reason: Signup needs the verifying holder's final password, fences provisional sessions/factors and never resets another verified account. Retired keys retain protected account-bound guards without automatic TTL reuse; original-account rebind needs full current change/verification authority.
Disadvantages: Provider aliases/case variants can still share mailboxes/persons, and retired keys block a different account even after legitimate mailbox reassignment. Sensitive guards and profile/key migration need protection; current-mailbox recycling remains a separate recovery risk.
Related concepts: Canonical mailbox key; retired contact guard. See [ADR-0087](adr/0087-explicit-mailbox-equality-verified-claims-and-retired-contact-guards.md) and Review 087. Extends D-037/D-086 identity rules, preserves D-012 account-level fairness, D-032/D-043 unknown-outcome safety and stable domain ownership. MFA/independent recovery follows next. D-088 selects customer/privileged MFA and prior recovery evidence, strengthens reset/reissue assurance and narrowly defines lost-mailbox recovery; ordinary account/domain guards remain.

## D-088: Require prior recovery evidence and preserve privileged MFA
Date: 2026-10-12
Status: Accepted; profiles, devices, independent staffing, abuse budgets and Auth/recovery capacity remain unproved.
Problem: Recycled mailboxes and weak support/factor fallback can take over historical accounts or bypass privileged authority.
Options: Email-only reset and discretionary support overrides; prior enrolled evidence, offline kits and guarded recovery without assurance downgrade.
Decision: Keep everyday customer MFA optional with WebAuthn UV/TOTP choices; require acknowledged ten-code offline kits before first queue eligibility. Reset needs the fixed mail challenge plus enrolled factor or unused saved code. Privileged sign-in/step-up requires password plus UV WebAuthn without email/TOTP fallback.
Reason: Stage then atomically finalize exact recovery with consumed evidence, required factor/kit replacements and old-session fencing before normal login. Lost-mailbox recovery narrowly permits prior saved/UV evidence plus new-mailbox proof. Last privileged factor loss requires saved evidence, distinct current-UV operator approval, new enrollment and role reauthorization.
Disadvantages: All evidence loss can leave customer access unrecoverable; support cannot invent historical identity proof. Device/kit capture does not prove hardware trust, physical independence or safe offline storage, and single-maintainer sandbox cannot establish two-person production recovery.
Related concepts: Recovery Kit; Account Recovery Workflow; prior evidence versus mailbox possession. See [ADR-0088](adr/0088-mfa-assurance-offline-kits-and-independent-account-recovery.md) and Review 088. Extends D-036/D-037/D-080/D-082/D-086/D-087 assurance while preserving normal customer MFA optionality, original challenge deadlines, owner guards and all booking/payment obligations.

## D-089: Measure channel readiness and bound mail retry/capacity
Date: 2026-10-12
Status: Accepted; feed certification, transport, actual Oracle limits and useful capacity remain unproved.
Problem: Sender counters hide missing feed/captured output, retries can send expired links, and free email allowances cannot sustain the declared peak.
Options: One sent flag and unbounded catch-up; separate original-source SLIs, bounded attempts, class shares and explicit free deployment gaps.
Decision: Set thirty-day 99.9% intent/feed/security-mail/business-mail readiness at 2/5/10/30 seconds, with feed p99 below 200 ms and complete five-second owner cuts. Business mail has at most six attempts/24 hours with conservative backoff, exact unknown-recipient binding and no deadline renewal or live-slot release from timeout alone.
Reason: Separate security/business SMTP shares within initially 256 live jobs/connections per environment pool and protect all existing owner budgets. Stage 100 business facts/s, 100 security jobs/s and 10,000 feed reads/s for thirty minutes plus the 1,000-confirmations/s peak; distinguish unknown versus proved pre-submission outage recovery.
Disadvantages: Auth links may expire before retry, and relay acceptance does not prove inbox placement. Oracle advertises 3,000/month while its Always Free service table lists zero/day; actual quotas and external transport are unknown. Protected Mailpit capture/in-app history preserve free testability without proving production delivery or throughput.
Related concepts: Channel readiness; protected scheduling versus expiry/catch-up. See [ADR-0089](adr/0089-notification-slis-bounded-retries-and-free-transport-gaps.md) and Review 089. Extends D-076 private feed coverage and D-074/D-083 protected budgets while preserving D-085/D-086/D-088, original 1M and all domain/financial safety/SLOs.

## D-090: Separate Auth session capacity from login and abuse work
Date: 2026-10-12
Status: Accepted; source proof, placement, protected counter/budget enforcement and capacity remain unproved.
Problem: Signature-only tests hide authority/refresh demand, and password-guessing work can starve memory, revocation and valid active sessions.
Options: Shared best-effort Auth work and lowered security cost; useful per-class floors with protected resources and counted overload failures.
Decision: Target 50,000 valid source-fresh proof deliveries/s and 5,000 durable strict rotations/s for thirty minutes with 1M active sessions and original workloads. Select proof/refresh/password-phase/MFA-completion p99 at 100/200/750/200 ms and separate thirty-day 99.9% eligible-operation SLIs.
Reason: Use jittered renewal, real hashing and separate fresh-login/onboarding/security/recovery profiles. Preserve original source, token/session and MFA deadlines; initial account/factor attempt budgets do not reset through new request IDs. Separate authenticated, revocation/recovery and unauthenticated CPU/memory/SQL/signing shares.
Disadvantages: Shared-network or repeated-victim throttling can reject legitimate new sign-ins and must count against SLOs. Calibrated Argon2 memory, finite malicious-offer tests and valid useful floors need physical evidence; no unlimited DDoS or free-capacity guarantee is implied.
Related concepts: Session Authority Proof; renewal versus password login; throttling versus revocation. See [ADR-0090](adr/0090-auth-workload-slis-and-protected-abuse-budgets.md) and Review 090. Preserves D-037/D-038/D-039/D-060/D-074/D-088 and all original 1M/hold/checkout/gate targets; source publication and counter/failure consistency follow next.

## D-091: Certify Auth source observations and retain primary grant boundaries
Date: 2026-10-12
Status: Accepted; source writer coverage, profiles, deployment capacity and counter/resource enforcement remain unproved.
Problem: A new signature or refresh time can make stale account state or unused enrolled factors appear authoritative.
Options: Sign best-effort projections and repair cache misses at the primary; certify complete primary cuts and keep credential mutations separate.
Decision: Retain cohesive Auth guards in one logical owner database with dedicated production HA. Extend complete baseline/change/control certification to non-secret authority images; derive scope-bound proofs at most four KiB with expiry no later than original observation plus thirty seconds.
Reason: Independent resource owners verify bindings and expiry after waits. Primary guards still consume credentials and perform recovery; a committed command can supply its own original guarded observation only in a proved safe unfenced source generation, without renewing age or redelivering credentials.
Disadvantages: Source certification, signing and safe recovery add dependencies; cohesive primary writes and synchronous WAL remain measured bottlenecks. Stale, incomplete or unsafe evidence fails closed and all affected SLO misses count.
Related concepts: Certified observation versus credential issuance; original authentication time. See [ADR-0091](adr/0091-certified-auth-observations-and-primary-grant-boundaries.md) and Review 091. Refines D-038 and extends D-076 while preserving D-030/D-039/D-040/D-053/D-074/D-088/D-090 and original 1M/hold/availability targets.

## D-092: Preserve Auth attempt allowance and physical capacity through uncertainty
Date: 2026-10-12
Status: Accepted; enforcement, sizing, safe reopening and recovery capacity remain unproved.
Problem: Redis rollback resets guessing counters, parallel factor checks bypass failure limits, and timed-out workers may still consume reassigned slots.
Options: Cache-only counters and expiring slot leases; durable rolling attempt guards and finite physically fenced worker shares.
Decision: Auth durably reserves exact admitted verification work across canonical account/purpose/factor guards. Pending work remains charged; completed password charges conservatively age from proved execution completion. MFA/code reservations cover concurrent unknown validations without clearing exact one-use evidence.
Reason: Nonoverlapping finite grants and physical limits protect work classes across replicas and rollouts. Only proved release or independent consumer fencing returns capacity; current primary guards still authorize credentials, and uncertain Redis gates reopen only after complete fenced reconciliation.
Disadvantages: Additional synchronous WAL, retained unknown work and victim throttling can reduce useful login/recovery availability. Conservative closed windows may miss the original thirty-second recovery target; all eligible-operation misses count and no target is waived.
Related concepts: Authentication Attempt; rolling budget versus cache counter; expiry versus completion. See [ADR-0092](adr/0092-durable-auth-attempt-budgets-and-physical-resource-fencing.md) and Review 092. Refines D-090 and extends D-060/D-074 while preserving D-038/D-043/D-053/D-088/D-091 and all original 1M/correctness/SLO requirements.

## D-093: Separate deployment profiles from independent production capability
Date: 2026-10-12
Status: Accepted; actual cloud entitlement, physical placement, complete-stack fit and capacity remain unproved.
Problem: Same-host replicas, small free quotas and running Pods can hide missing durability, survivor capacity and paid dependencies.
Options: Change requirements to fit a demo; preserve full architecture in explicit profiles with independent readiness evidence and recorded gaps.
Decision: Define local-development, local-conformance, oci-free and production-reference profiles with unchanged owner/domain/security contracts. Retain independent production HA/replication floors and all original SLOs; prefer verified free OKE Basic with assessed K3s fallback.
Reason: Audit actual free eligibility, resource/failure placement and full-stack dependencies before provisioning. Record passed/failed/unverified evidence at the declared load/fault model; local simulations and reference configuration cannot certify physical-host recovery or actual 1M capacity.
Disadvantages: Free full-stack fit, external transport and required independent capacity may remain blocked. Additional controller/storage/process resources and retained safety history cannot be removed to make the deployment appear complete.
Related concepts: Profile versus capability; replica count versus failure placement. See [ADR-0093](adr/0093-deployment-profiles-and-independent-production-placement.md) and Review 093. Extends D-030/D-031 placement and D-033 readiness; preserves D-003/D-025/D-058/D-089 and all requested technologies, features and 1M/latency/availability requirements.

## D-094: Select Patroni control and independently fence PostgreSQL writers
Date: 2026-10-12
Status: Accepted; release pins, fencing evidence, readiness enforcement and recovery timing remain unproved.
Problem: A lease winner can overlap a surviving old writer; ordinary sync mode, route changes and accepted STOP requests do not prove required durability/fencing.
Options: Election and health checks alone; Patroni/etcd strict control with complete predecessor fencing and separate safe write readiness.
Decision: Use independent three-member etcd, Patroni strict sync with one required standby, safe timeline/history and mandatory pre-promote fencing. Initially test twenty-second TTL, two-second loop wait and three-second retry timeout, without claiming measured thirty-second recovery.
Reason: Fence every possibly writable incarnation through independently verified infrastructure effect. Quarantine old nodes; require fresh complete readiness, a synchronous follower and logged barrier before critical success or dispatch. Keep per-command D-032 proof and protected HAProxy/PgBouncer routing.
Disadvantages: Independent control, fence adapters, WAL probes and rejoin restrictions add resource and availability costs. Cloud completion delays or missing evidence can block promotion and miss SLOs; watchdog and configuration alone are insufficient.
Related concepts: Election versus physical fencing; strict replication versus command durability. See [ADR-0094](adr/0094-patroni-etcd-independent-fencing-and-safe-write-readiness.md) and Review 094. Extends D-031/D-032/D-074/D-093 while preserving original RPO zero, thirty-second recovery, 99.9%, 1M and hold latency targets.

## D-095: Keep encrypted PITR restore separate from current business authority
Date: 2026-10-12
Status: Accepted; actual backup coverage, keys, repository placement, restore enforcement and capacity remain unproved.
Problem: Old consistent snapshots can omit executed payments, consumed tickets/codes or later security changes and wrongly revive authority.
Options: Resume directly from a backup; independently verify complete owner/control/irreversible history in a fenced isolated restore.
Decision: Use pgBackRest continuous WAL with weekly full, daily differential and hourly incremental backups. Require a real thirty-day PITR chain, two independent encrypted repositories including an off-region copy, protected metadata/keys/deletion and no WAL-drop archival success.
Reason: Verify physical system/timeline/schema and reconcile owner facts before positive certification or effects. Missing history quarantines affected or broader scopes; generation changes, database visibility, customer claims and NotFound cannot prove non-execution or restore identity.
Disadvantages: Independent repositories, retained WAL/keys and daily isolated drills add storage/IOPS/compute. Incomplete history can block authority indefinitely; restoring files is not safe-service recovery and free capacity is unverified.
Related concepts: Restore consistency versus irreversible history; archive lag versus safety guards. See [ADR-0095](adr/0095-encrypted-pitr-and-business-safe-isolated-restore.md) and Review 095. Extends D-026/D-029/D-040/D-094 while preserving all original durability, deadlines, 1M and SLOs; regional numerical objectives follow next.

## D-096: Extend protected authoritative history to regional loss
Date: 2026-10-12
Status: Accepted; D-097 selects the off-region durability protocol and D-098 selects control placement. Quorum-loss restoration, receiver lifecycle evidence, capacity and measured latency/recovery remain pending.
Problem: A sixty-second archive gap can omit externally exposed effects or consumed guards and prevent safe regional recovery.
Options: Accept lost history with possibly permanent quarantine; independently protect exposed/admitted critical history before work and recovery.
Decision: Add regional RPO zero for acknowledged/exposed authoritative history and admitted protected-work guards. Select separate sixty-second complete bulk archive coverage and initially four-hour safe-service recovery with ten-minute sustained useful validation.
Reason: Verify independent recovery history, current control, old-writer/dispatcher fencing and full required readiness before effects. Include remote gate waits in original latency and count impaired scopes, regional outages and all useful-work misses in SLIs.
Disadvantages: Remote durability and warm independent infrastructure add WAN latency, resource costs and fail-closed dependencies. A four-hour outage can breach original 99.9%; home-region free allowances do not provide a second free recovery site or proven capacity.
Related concepts: Regional acknowledged-history protection; useful recovery versus file restore. See [ADR-0096](adr/0096-regional-zero-loss-history-and-useful-recovery-objectives.md) and Review 096. Explicitly extends D-003/D-033 and D-032/D-094/D-095 gates; D-097 selects its WAL coverage protocol while preserving local RPO zero/thirty-second recovery and all original 1M/latency/availability requirements.

## D-097: Gate critical effects on exact remote WAL coverage
Date: 2026-10-12
Status: Accepted; D-098 selects quorum placement and membership rules. Receiver lifecycle evidence, resource thresholds and measured behavior remain unproved.
Problem: Local COMMIT or a marker alone cannot prove an independently recoverable regional history contains the complete committed owner guard.
Options: Trust an async archive/marker; add native remote physical-WAL coverage and a same-backend post-COMMIT capture gate.
Decision: Require two of three same-cohort off-region receivers to flush the exact captured prefix across three production sites. Add bounded backend-pinned capture while ordinary SQL remains transaction-pooled.
Reason: Preserve full owner-phase history before protected work/effects; fail closed if a third independent cohort is unavailable after one-site loss, without retrying effects or extending deadlines.
Disadvantages: Adds WAN/disk waits, receiver capacity and a new bounded SQL lane; free-tier sites and original latency targets are unproved.
Related concepts: Post-COMMIT WAL boundary; remote coverage versus execution permission. See [ADR-0097](adr/0097-three-site-remote-wal-coverage-gate.md) and Review 097. Extends D-032/D-074/D-094/D-096; preserves all original SLOs.

## D-098: Place control quorum and receiver membership across sites
Date: 2026-10-12
Status: Accepted; D-099 selects fenced new-cluster restoration and D-100 selects journaled control-change reconciliation. Cross-region latency, independent-root proof, journal placement and storage remain unproved.
Problem: A site-local controller majority cannot safely retain membership authority through regional loss or partition.
Options: Keep control voters together; place one voter in each production site and require an independent majority.
Decision: Use three etcd voters across three independent sites; two are required. Quorum-back receiver/cohort membership, retirement and recovery-generation changes; keep audited recovery credentials outside every database rollback domain.
Reason: One site loss preserves a majority; a partition without two voters cannot mutate recovery authority. Retain prior WAL coverage until replacement history is complete and independently verified.
Disadvantages: Cross-region RTT and disk sync affect control stability; loss of quorum blocks authority until controlled recovery. Free/site-independence and timing remain unproved.
Related concepts: Control quorum versus data cohort. See [ADR-0098](adr/0098-three-site-control-quorum-and-membership.md) and Review 098. Extends D-094/D-097; preserves original correctness, SLO and free-cost constraints.

## D-099: Recover control quorum only from fenced, verified history
Date: 2026-10-12
Status: Accepted; D-101 selects all-site copies for normal control changes. Journal implementation, serial writer and independent recovery-root proof remain pending.
Problem: A restored etcd snapshot can omit later authority/fencing changes, while force-removing a minority can create a divergent cluster.
Options: Resume the minority or trust a snapshot; restore a new cluster after independent history verification and physical fencing.
Decision: Freeze control changes and critical work; use D-036 independent step-up, verify snapshot plus monotonic post-snapshot journal, fence all old potential actors, then restore new membership/generation. Never force-remove a minority or trust the DCS snapshot alone.
Reason: Preserve one authoritative control history and prevent stale leases, credentials, receiver proofs or writers from regaining authority. Gaps remain quarantined and count against SLO/RTO.
Disadvantages: Control recovery can remain unavailable indefinitely when journal continuity or physical fencing is missing; recovery adds operator and audit work.
Related concepts: Control snapshot versus authority journal. See [ADR-0099](adr/0099-fenced-recovery-after-control-quorum-loss.md) and Review 099. Extends D-036/D-040/D-094/D-095/D-098; no SLO or safety relaxation.

## D-100: Reconcile control mutations through a durable authority journal
Date: 2026-10-12
Status: Accepted; D-101 selects all-site acknowledgement and D-102 adds a fenced single-site recovery exception. Journal implementation, serialization and capacity remain unproved.
Problem: A control mutation may commit in etcd while its journal reply is lost, or be journaled without the etcd change applying.
Options: Trust one side; prepare the exact command in an independent journal, apply etcd, then record verified outcome.
Decision: Journal exact command/scope/actor approvals/generation before quorum change; append outcome after. Freeze and reconcile the same command ID after ambiguity.
Reason: Avoid guessing which control state is authoritative or replaying a mutation under a new ID; gaps block recovery authority.
Disadvantages: Adds an administrative dependency and can block rare control changes during partitions; physical copies and serial append remain undecided.
Related concepts: Control snapshot versus authority journal. See [ADR-0100](adr/0100-journaled-control-changes-and-ambiguous-outcomes.md) and Review 100. Extends D-098/D-099; preserves all application SLOs and correctness requirements.

## D-101: Require all-site durable authority-journal copies
Date: 2026-10-12
Status: Accepted; amended only for D-102's declared single-site recovery plan. Normal all-site acknowledgement remains; journal implementation and capacity are unproved.
Problem: With only two-of-three acknowledgements, both copies of a control change could be lost with those two sites, leaving the last site's journal stale.
Options: Acknowledge two copies and quarantine after some losses; require all three site copies before normal recovery-critical changes.
Decision: Store independent authenticated copies at all three sites and require all three durable acknowledgements before accepting prepare. Use a monotonic serialized command sequence; partial/unknown appends freeze later changes.
Reason: Any one surviving site retains every fully accepted normal control change. This rare administrative gate does not add a per-booking cross-region write.
Disadvantages: Any unavailable site blocks these control mutations; physical placement/durability and regional recovery compatibility remain unproved.
Related concepts: All-site journal acknowledgement versus control quorum. See [ADR-0101](adr/0101-all-site-durable-recovery-journal.md) and Review 101. Extends D-098/D-100; preserves application safety and SLOs.

## D-102: Prepare and fence single-site recovery through both survivors
Date: 2026-10-13
Status: Accepted; physical proof, journal implementation, rejoin and measured recovery remain unproved.
Problem: D-101 blocks promotion when one site is lost; fencing before emergency preparation also contradicts D-100's intent-before-effect rule.
Options: Wait for the lost site; permit one exact survivor-journal recovery plan with verified physical fencing and current native quorum.
Decision: Verify both survivor histories/root/quorum and D-036 approval, prepare the exact plan durably at both sites, perform guarded physical fences, then conditionally advance generation and retain outcome before protected promotion.
Reason: Preserve intent ordering, original identities/uncertainty, safe history, native synchronous followers and D-097 remote coverage. Quarantine returning sites and restore three journal copies before ordinary administration.
Disadvantages: The recovery interval has two journal sites and cannot promise arbitrary compound-loss survival. Missing fences/history/approval blocks progress and counts against unchanged SLOs.
Related concepts: Prepared intent versus authority; survivor journals versus native quorum. See [ADR-0102](adr/0102-fenced-single-site-recovery-with-survivor-journals.md). Scoped amendment to D-101; retains D-036/D-094/D-096/D-097/D-100 guards.

## D-103: Use Go for all eight backend services
Date: 2026-10-13
Status: Accepted; implementation, dependency compatibility and capacity remain unproved.
Problem: The original brief permits Go or Java/Spring Boot; a concrete language is needed for the build and deployment package.
Options: Go; Java/Spring Boot.
Decision: Use Go 1.27.2 for all eight services and their workers, with reproducible Linux amd64/arm64 builds and bounded concurrency.
Reason: Native binaries and explicit resource/lifecycle handling suit this deployment workflow; keep all accepted services, technologies, patterns and correctness contracts.
Disadvantages: Application wiring and validation require explicit implementation; goroutines do not prove resource bounds or 1M capacity. Installed Go 1.24.1 needs upgrading at implementation start.
Related concepts: Bounded concurrency and toolchain compatibility. See [ADR-0103](adr/0103-go-backend-and-supported-toolchain.md) and Review 103. No feature, SLO, ownership or cost requirement is reduced.

## D-104: Approve the full package and implementation start
Date: 2026-10-13
Status: Accepted
Problem: The final bounded review needed package acceptance and build authorization.
Options: Approve the documented package; request specific changes.
Decision: The user approved the package and requested the ask-matt workflow.
Reason: Shared understanding is complete. Start the full dependency-linked build with TDD and code review.
Disadvantages: Approval does not prove runtime, physical durability, free capacity or SLOs.
Related concepts: Tracer-bullet delivery and evidence gates. See [ADR-0104](adr/0104-approved-delivery-package-and-build-start.md).
