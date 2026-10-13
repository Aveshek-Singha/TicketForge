# Concepts

## Atomicity and durability
Definition: Atomicity prevents a partial operation. Durability preserves committed data after failures covered by the storage guarantee.
Why we use it: A seat hold needs both concurrency safety and a clear recovery guarantee.
Example in this project: An atomic Redis write can still be lost during failover.
Location in code: No implementation exists yet.
Related decisions: D-001.
Source: https://redis.io/docs/latest/operate/oss_and_stack/management/replication/

## Authoritative record
Definition: The record used to resolve disagreements between copies of data.
Why we use it: Recovery needs one consistent basis for deciding seat ownership.
Example in this project: Inventory's PostgreSQL allocation record overrides conflicting Redis availability data.
Location in code: No implementation exists yet.
Related decisions: D-002.

## Recovery Point Objective (RPO)
Definition: The maximum acceptable data loss after recovery, often expressed as a time window.
Why we use it: Durability must specify which successful operations survive which failures.
Example in this project: RPO zero for acknowledged allocations after loss of one database host.
Location in code: No implementation exists yet.
Related decisions: D-003.

## Fencing
Definition: Prevent a former owner from continuing to write after ownership moves to another node.
Why we use it: A network partition must not leave two active database writers.
Example in this project: Block the former primary from allocation writes before enabling the replacement.
Location in code: No implementation exists yet.
Related decisions: D-003. The fencing mechanism is unresolved.

## Fail-closed allocation
Definition: Stop accepting seat allocation when exclusive ownership cannot be established.
Why we use it: Failure recovery must not create competing valid allocations.
Example in this project: Pause affected hold and confirmation operations during ambiguous failover.
Location in code: No implementation exists yet.
Related decisions: D-001.

## Unknown payment outcome
Definition: A request timed out without proving whether the payment provider accepted it.
Why we use it: A communication failure must not be mistaken for a definitive payment rejection.
Example in this project: Reconcile a payment after a timeout; its late success must not reclaim a released seat.
Location in code: No implementation exists yet.
Related decisions: D-004.

## Payment compensation
Definition: A corrective operation for money taken or authorized when the booking cannot complete.
Why we use it: Payment success can arrive after the seat allocation has closed.
Example in this project: Refund captured money or void an authorization without reviving the closed booking.
Location in code: No implementation exists yet.
Related decisions: D-004. Provider support and recovery details remain unresolved.

## Provider sandbox and failure simulator
Definition: A sandbox tests a real provider's integration without real-money transactions; a simulator creates controlled failure scenarios locally.
Why we use it: External API behavior and reproducible failure recovery need different tests.
Example in this project: Test real payment callbacks in a sandbox and inject duplicate or delayed outcomes with a simulator.
Location in code: No implementation exists yet.
Related decisions: D-005 selects the real SSLCOMMERZ sandbox. A separate simulator remains proposed.

## Application and provider idempotency
Definition: Application idempotency prevents duplicate local effects; provider idempotency prevents duplicate external effects under the provider's documented contract.
Why we use it: A local unique key cannot prove that an external request was executed only once.
Example in this project: SSLCOMMERZ transaction queries can return multiple attempts for one tran_id.
Location in code: No implementation exists yet.
Related decisions: D-006.
Source: https://sandbox-gw.sslcommerz.com/docs

## Server-to-server payment validation
Definition: Verify payment evidence through the provider's authenticated API rather than trusting a browser return or callback payload.
Why we use it: A public callback can contain forged or mismatched transaction data.
Example in this project: SSLCOMMERZ validation must match the stored transaction ID, expected amount, and currency before payment is treated as verified.
Location in code: No implementation exists yet.
Related decisions: D-005. This is a provider integration requirement; risk handling remains unresolved.
Source: https://sandbox-gw.sslcommerz.com/docs

## Durable Saga orchestration
Definition: One service stores workflow progress and coordinates retries and compensation across service boundaries.
Why we use it: Recovery needs to resume unfinished steps after a process crash.
Example in this project: Booking Service orchestration reconciles payment, inventory confirmation, and order finalization.
Location in code: No implementation exists yet.
Related decisions: D-007.

## Outbox
Definition: Store outbound work in the same local database transaction as the business state change; deliver it after commit.
Why we use it: A process crash between database commit and message publication must not lose required work.
Example in this project: Persist Saga progress and its next command together, then publish through Kafka.
Location in code: No implementation exists yet.
Related decisions: D-007. Delivery, deduplication, and replay details remain unresolved.

## Atomic seat bundle
Definition: Allocate every requested seat together or allocate none of them.
Why we use it: A partial result may leave a customer with fewer seats than requested.
Example in this project: A four-seat hold fails entirely when any requested seat is unavailable.
Location in code: No implementation exists yet.
Related decisions: D-008.

## Redis hash slot boundary
Definition: Redis Cluster groups keys into slots; atomic multi-key operations require the relevant keys in the same slot.
Why we use it: A seat bundle may span keys that cannot be updated atomically by one Redis operation.
Example in this project: Key placement must support the agreed bundle boundary without assuming a hot event scales across Redis nodes.
Location in code: No implementation exists yet.
Related decisions: Pending. Inventory partitioning is unresolved.
Source: https://redis.io/docs/latest/operate/oss_and_stack/reference/cluster-spec/

## Concurrency versus arrival rate
Definition: Concurrency counts simultaneous active users or operations; arrival rate counts how much new work arrives per unit of time.
Why we use it: One million users does not specify how many requests each endpoint must handle per second.
Example in this project: One million users polling every five seconds produce about 200,000 polls per second before retries.
Location in code: No implementation exists yet.
Related decisions: D-009. Exact request rates and client behavior remain unresolved.

## Coordinated omission
Definition: A load generator may send less work when the system slows, hiding latency under sustained incoming demand.
Why we use it: Capacity tests must distinguish client concurrency from independent request arrival rates.
Example in this project: Pair concurrency scenarios with k6 arrival-rate scenarios and report dropped iterations.
Location in code: No implementation exists yet.
Related decisions: D-009. Concurrency and arrival-rate coverage are accepted; detailed scenarios remain unresolved.
Source: https://grafana.com/docs/k6/latest/using-k6/scenarios/concepts/open-vs-closed/

## FIFO and pre-sale randomization
Definition: FIFO admits earlier entries first. A pre-sale randomization assigns one random order to eligible entries present at sale opening.
Why we use it: These are alternative admission-order policies; neither a pre-sale window nor randomization is mandatory for ticket booking.
Example in this project: A randomized pre-sale cohort was proposed before confirming that a pre-sale window is needed; it is not accepted.
Location in code: No implementation exists yet.
Related decisions: D-011 selects FIFO. The earlier pre-sale randomization proposal was not adopted.

## Admission budget
Definition: A limit on new work allowed into a service or workflow, based on capacity and resource constraints.
Why we use it: New seat demand must not consume capacity needed to finish existing checkout and recovery work.
Example in this project: Per-event and global budgets constrain new checkout admission even when no waiting page is visible.
Location in code: No implementation exists yet.
Related decisions: D-009; D-010. Numeric budget details remain unresolved.

## Hysteresis
Definition: Use different entry and recovery conditions so a control mode does not switch repeatedly around one threshold.
Why we use it: A fluctuating load signal can repeatedly open and close admission and create bursts.
Example in this project: Controlled recovery from queueing after capacity remains healthy, instead of admitting every waiting user at once.
Location in code: No implementation exists yet.
Related decisions: D-010. Exact thresholds and recovery windows remain unresolved.

## Server acceptance order
Definition: Order assigned when the server authoritatively accepts queue entries, rather than when users click or when separate nodes record local timestamps.
Why we use it: Concurrent requests and different network delays cannot establish a shared order from client clocks.
Example in this project: FIFO priority uses a stable accepted queue sequence for each event occurrence.
Location in code: No implementation exists yet.
Related decisions: D-011. Queue durability and the ordering primitive remain unresolved.

## Account identity versus human identity
Definition: A login identifies an account; it does not prove that each account belongs to a different person.
Why we use it: Duplicate-entry controls and automated account farming are separate problems.
Example in this project: Account-bound queue entries stop extra entries from one account, but not from an attacker with many accounts.
Location in code: No implementation exists yet.
Related decisions: D-012. Account-farming defenses remain unresolved.
Source: https://owasp.org/projects/automated-threats-to-web-applications?tab=ontology

## Admission lease and credential expiry
Definition: An admission lease accounts for a workflow's capacity slot; an expiring credential authorizes requests and may have a different lifetime.
Why we use it: Credential expiry alone does not prove that active checkout work has ended.
Example in this project: A lease remains counted while its active hold, payment reservation, or allocation outcome is unresolved.
Location in code: No implementation exists yet.
Related decisions: D-013. Credential design and the claim protocol remain unresolved.

## Arrival and in-flight limits
Definition: An arrival limit bounds new work per unit of time; an in-flight limit bounds work that remains active.
Why we use it: Long-lived checkouts can accumulate even under a fixed arrival rate.
Example in this project: Admission checks both the new-user rate and active checkout slots.
Location in code: No implementation exists yet.
Related decisions: D-010 and D-013. Numeric budgets and their storage remain unresolved.

## Durable queue acceptance
Definition: An accepted queue entry or admission lease survives the specified failure because its authoritative commit has a surviving durable copy.
Why we use it: Queue priority and active capacity must not disappear merely because a cache fails.
Example in this project: Waiting Room acknowledges joins after primary and independent synchronous replica commits; Redis serves fast status projections.
Location in code: No implementation exists yet.
Related decisions: D-014. Ordering throughput, failover implementation, and whole-region recovery remain unresolved.

## Closure barrier and tombstone
Definition: A closure barrier rejects future work for a retired identity; a tombstone is a retained record of that closure.
Why we use it: A delayed request may arrive after a timeout or after a query found no record.
Example in this project: Inventory closure records reject delayed allocation commands before Waiting Room reuses the checkout slot.
Location in code: No implementation exists yet.
Related decisions: D-015. Record retention and the detailed claim protocol remain unresolved.

## Logical expiry and cleanup
Definition: Logical expiry ends a reservation's eligibility at its deadline; cleanup persists closure and releases resources through safe transitions.
Why we use it: A late timer or cleanup worker must not extend a customer's eligibility.
Example in this project: Inventory checks reject an expired hold even while its cleanup job is delayed.
Location in code: No implementation exists yet.
Related decisions: D-004 and D-016. Cleanup scheduling and its SLO remain unresolved.

## Fresh time after lock acquisition
Definition: Evaluate a deadline using a new time reading after acquiring every lock needed for the guarded transition.
Why we use it: A transaction may wait for a lock long enough to cross a deadline.
Example in this project: Inventory checks use fresh database time; PostgreSQL now() stays at transaction start.
Location in code: No implementation exists yet.
Related decisions: D-016. Clock health, failover implementation, and error bounds remain unresolved.
Source: https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT

## Reservation policy snapshot
Definition: A reservation stores the duration and policy version used to set its deadline when created.
Why we use it: Changing configuration must not silently change deadlines for existing customers.
Example in this project: Two-minute holds and five-minute payment reservations keep their original deadlines if future defaults change.
Location in code: No implementation exists yet.
Related decisions: D-017 sets the duration policy; D-016 requires fixed deadlines without retry extensions.

## Conflict retry versus reservation reacquisition
Definition: A conflict retry follows a confirmed allocation failure; reacquisition creates another reservation after an earlier successful one has ended.
Why we use it: Retrying an unsuccessful seat choice and renewing an expired reservation have different fairness and capacity effects.
Example in this project: Bounded conflict retries are allowed before the first successful hold, then fresh FIFO admission is required after that lifecycle closes.
Location in code: No implementation exists yet.
Related decisions: D-018 defines the lifecycle; D-013 and D-015 establish safe slot closure. D-019 sets numeric selection and attempt limits.

## Logical attempt budget and transport retries
Definition: A logical attempt budget limits distinct seat-allocation choices; a transport retry repeats the same operation after an uncertain response.
Why we use it: Retry limits must bound new work without turning one lost response into multiple allocations or consuming the budget twice.
Example in this project: Admission allows five distinct logical allocation attempts, including the first; idempotent replay does not add another logical attempt.
Location in code: No implementation exists yet.
Related decisions: D-018 and D-019. Durable counter implementation and request/recovery budgets remain unresolved.

## Reserved purchase quota
Definition: A purchase quota limits confirmed purchases plus currently reserved ticket entitlement for an account and event occurrence.
Why we use it: Checking completed orders alone ignores holds and payment reservations, while queueing alone does not limit repeated purchases.
Example in this project: Inventory accounting reserves quota with the whole seat bundle, moves reserved units to confirmed units on allocation confirmation, and releases unconfirmed units on safe closure.
Location in code: No implementation exists yet.
Related decisions: D-020 sets four-seat bundles, four-ticket quotas, and Inventory ownership; post-confirmation restoration remains unresolved.

## Immutable checkout quote
Definition: A quote records the exact seat bundle, price breakdown, total, currency, and pricing version accepted for one reservation lifecycle.
Why we use it: Catalog updates and client-supplied totals must not change the price of an existing valid checkout.
Example in this project: Inventory snapshots the executable server price with the successful hold, and Booking and Payment use that same quote.
Location in code: No implementation exists yet.
Related decisions: D-021. Currency, price components, publication, and rounding rules remain unresolved.

## Payment amount versus merchant settlement
Definition: The customer's payment amount and the merchant's amount after provider charges are different values.
Why we use it: Comparing an order total with net settlement can reject a correct payment or mask an incorrect amount.
Example in this project: SSLCOMMERZ exposes amount and store_amount separately and requires merchant-side validation of amount, currency, and transaction identity.
Location in code: No implementation exists yet.
Related decisions: D-005 and D-021. Provider field handling and mismatch recovery remain unresolved.
Source: https://sandbox-gw.sslcommerz.com/docs

## Integer minor units and exact rounding
Definition: Store money as a currency plus a whole-number count of its smallest accounting unit; use exact arithmetic when calculating fractional components.
Why we use it: Quote, charge, validation, and refund amounts must agree without floating-point tolerance.
Example in this project: BDT amounts use integer paisa, with 125050 representing BDT 1250.50; fractional fee/tax components round half-up once per line before summing.
Location in code: No implementation exists yet.
Related decisions: D-022. Fee and tax values remain undecided.

## Provider transaction amount bounds
Definition: A payment provider can restrict the total amount of one transaction independently of the number or price of tickets.
Why we use it: A valid seat bundle must also have a payable total before a successful hold is returned.
Example in this project: SSLCOMMERZ documents total_amount from BDT 10.00 to BDT 500000.00; checks reject unsupported totals without clamping or automatic splitting.
Location in code: No implementation exists yet.
Related decisions: D-022. Verify boundary behavior and refund-specific limits with the actual sandbox.
Source: https://sandbox-gw.sslcommerz.com/docs

## Charge-level refund accounting
Definition: Account for refunds against each distinct verified provider charge, rather than only against an order total.
Why we use it: Repeated notifications are not extra charges, while an order may unexpectedly receive more than one distinct charge.
Example in this project: Payment ledger deduplicates charge identity and bounds completed plus pending or unknown refund amounts by that charge's verified original amount.
Location in code: No implementation exists yet.
Related decisions: D-023 defines ledger safety; D-007 assigns payment evidence and compensation execution to Payment.

## Refund initiation versus refund completion
Definition: Provider acceptance of a refund request does not prove that the customer has received the refund.
Why we use it: Lost responses and processing refunds must stay recoverable without unsafe duplicate initiation.
Example in this project: SSLCOMMERZ returns refund_ref_id at initiation and uses it for a separate query with refunded, processing, or cancelled status.
Location in code: No implementation exists yet.
Related decisions: D-023 requires verified refund completion and rejects blind uncertain dispatch; D-006 applies the corresponding initiation rule to payments.
Source: https://sandbox-gw.sslcommerz.com/docs

## Transactional inbox and duplicate delivery
Definition: An inbox stores received event identities and their processing state in the same database as the consumer's local business state.
Why we use it: A consumer can crash after applying an event but before saving its Kafka offset, causing redelivery.
Example in this project: Consumers commit deduplication, guarded business changes, and new Outbox work together, then advance only safely completed Kafka offsets.
Location in code: No implementation exists yet.
Related decisions: D-007 and D-024 require local deduplication and the durable Inbox/offset contract.
Source: https://kafka.apache.org/41/design/design/

## Aggregate revision and causal prerequisites
Definition: A revision orders changes from one state owner; causal prerequisites describe facts needed before another workflow step is valid.
Why we use it: Events from different owners or topics can arrive in different orders, and stale updates must not undo terminal decisions.
Example in this project: Booking retains an early payment event until matching allocation evidence is available rather than confirming from arrival order alone.
Location in code: No implementation exists yet.
Related decisions: D-024. No global revision or cross-topic ordering is assumed.

## Provider session lifetime versus seat deadline
Definition: A payment provider's session lifetime and TicketForge's allocation eligibility deadline are separate controls.
Why we use it: Closing local allocation does not establish that a provider can no longer accept payment.
Example in this project: SSLCOMMERZ documents expired sessions, but the checked material does not establish an exact hosted-session TTL or merchant-controlled expiry guarantee.
Location in code: No implementation exists yet.
Related decisions: D-004 and D-016. Verify sandbox behavior and retain reconciliation and late-payment compensation.
Sources: https://sslcommerz.com/faq/ ; https://sandbox-gw.sslcommerz.com/docs

## Replication factor and minimum in-sync replicas
Definition: Replication factor sets the number of Kafka copies; minimum ISR sets the required in-sync replica count for safe writes with acks=all.
Why we use it: A single acknowledged copy can disappear with its host, even when consumers deduplicate perfectly.
Example in this project: RF3/minimum ISR2 pauses publication below two safe in-sync copies; acks=all waits for all current ISR members, not just two when three are present.
Location in code: No implementation exists yet.
Related decisions: D-025 defines broker durability; D-024 handles duplicate effects. Version-specific ELR behavior must be verified.
Source: https://kafka.apache.org/43/configuration/topic-configs/

## KRaft controller quorum and failure placement
Definition: KRaft controllers replicate Kafka metadata; their quorum needs a living majority to maintain availability.
Why we use it: Replicated topic data alone does not provide a healthy metadata control plane or independent failure domains.
Example in this project: Three controller voters tolerate one controller failure; putting multiple voters on one failing host can remove the majority.
Location in code: No implementation exists yet.
Related decisions: D-025 separates production broker/controller roles; local shared-host tests have a narrower failure boundary.
Source: https://kafka.apache.org/43/operations/kraft/

## Transport retention and durable recovery history
Definition: Transport retention is how long Kafka keeps events; durable owner history preserves the facts or original messages needed for later recovery.
Why we use it: A consumer can fall behind the retained Kafka log, even though its business obligation remains unresolved.
Example in this project: Seven-day Kafka retention and thirty-day exact event history do not expire an unresolved refund or unapplied event.
Location in code: No implementation exists yet.
Related decisions: D-024, D-025, and D-026. Kafka is not the authoritative seat or money ledger.
Source: https://kafka.apache.org/43/configuration/topic-configs/

## Replay identity and irreversible-effect guards
Definition: Replay delivers existing facts again; a business-effect guard records whether an allocation or financial action is already applied, closed, or uncertain.
Why we use it: Removing an event ID from an Inbox must not authorize a second charge/refund or revive a closed reservation.
Example in this project: Replay preserves original IDs/revisions and checks retained charge/refund identities and allocation closure guards; a projection rebuild cannot dispatch provider operations.
Location in code: No implementation exists yet.
Related decisions: D-006, D-015, D-023, D-024, and D-026; concrete safe deletion rules remain unresolved.

## Poison event and durable quarantine
Definition: A poison event cannot be handled correctly by the current consumer; quarantine retains the original event and its failure state for controlled recovery.
Why we use it: Endless retries can block unrelated work, while dropping the event can break an order's correctness.
Example in this project: Consumers retain the raw event and block its dependent workflow before advancing safe offsets; a Kafka DLQ is a mirror of that recovery record.
Location in code: No implementation exists yet.
Related decisions: D-024, D-026, and D-027 preserve unapplied work and define bounded retry/quarantine behavior.

## Transport progress versus workflow progress
Definition: A saved Kafka offset means transport consumption has advanced; it does not prove that every received business event has been applied.
Why we use it: A failed event may be safely stored locally while its dependent workflow must still wait.
Example in this project: Durable aggregate blocking lets independent orders proceed; an unidentifiable dependency boundary pauses the affected partition.
Location in code: No implementation exists yet.
Related decisions: D-024 distinguishes received/applied states; D-027 defines workflow-aware isolation and safe offset progress.
Source: https://kafka.apache.org/43/design/design/

## Wire compatibility and semantic compatibility
Definition: Wire compatibility means old/new code can decode messages; semantic compatibility means both versions interpret their business meaning safely.
Why we use it: An unchanged integer field can silently change meaning from paisa to taka or from gross charge to net settlement.
Example in this project: Contract checks preserve money units and enum meanings in addition to Protobuf field tags/types; missing financial fields and unknown states cannot become success.
Location in code: No implementation exists yet.
Related decisions: D-022 defines money meaning; D-026, D-027, and D-028 require safe replay, quarantine, and contract evolution.
Sources: https://protobuf.dev/programming-guides/proto3/ ; https://protobuf.dev/best-practices/dos-donts/

## Consumer-first rollout and rollback floor
Definition: Consumer-first rollout installs safe readers before producers emit a new contract; a rollback floor is the oldest release still safe with current emitted data and durable states.
Why we use it: Reverting an image does not remove new messages or database states already created by that image.
Example in this project: Rollout first deploys readers for old/new contracts, then enables producer output; archived and unresolved old events keep their supported decoders.
Location in code: No implementation exists yet.
Related decisions: D-026 preserves original history; D-027 and D-028 define unsupported-event handling and compatible rollout/rollback boundaries.

## Local Protobuf compatibility checks
Definition: Buf CLI can lint Protobuf schemas and compare them with earlier schemas stored in Git or descriptor files.
Why we use it: Automated structural checks catch incompatible schema changes before release, while semantic tests cover business behavior that a schema diff cannot see.
Example in this project: CI must run local pinned Buf and local generators against supported schema baselines and replay fixtures.
Location in code: No implementation exists yet.
Related decisions: D-028; no paid registry or hosted generation is required by this approach.
Sources: https://buf.build/docs/breaking/ ; https://github.com/bufbuild/buf

## Expand, migrate, and contract
Definition: Add compatible structures first, move data and application behavior safely, then remove obsolete structures only after their dependencies end.
Why we use it: Old and new application writers coexist during deployment, and a one-time backfill can miss later old-version updates.
Example in this project: Owner-local bridge writes and guarded resumable backfills preserve the old authoritative representation until all writers can safely cut over.
Location in code: No implementation exists yet.
Related decisions: D-007 defines owner-local writes; D-028 and D-029 define compatibility gates and staged migration.

## DDL locking and partial index failure
Definition: DDL changes database structure and can block readers/writers; concurrent index creation uses multiple phases and can leave an invalid index after failure.
Why we use it: A schema operation can exceed hold latency budgets or leave a structure that a migration ledger cannot safely treat as complete.
Example in this project: Migrations must bound lock waits, schedule heavy work with capacity headroom, inspect failed concurrent builds, and preserve safety constraints throughout.
Location in code: No implementation exists yet.
Related decisions: D-009 preserves hold latency; D-029 governs migration. Concurrent index creation cannot run inside a normal transaction block; invalid unique indexes can still enforce uniqueness.
Sources: https://www.postgresql.org/docs/current/sql-altertable.html ; https://www.postgresql.org/docs/current/sql-createindex.html

## Application rollback versus database restore
Definition: Application rollback changes the running code; database restore reconstructs an earlier database state and may omit later accepted work.
Why we use it: Restoring old data cannot undo a provider charge and can erase allocation or idempotency evidence needed for safe recovery.
Example in this project: Release recovery uses compatible code rollback or forward repair; database restore requires fencing and reconciliation before writes resume.
Location in code: No implementation exists yet.
Related decisions: D-003, D-023, D-026, D-028, and D-029; exact restore procedures and broader disaster-recovery objectives remain unresolved.
Source: https://www.postgresql.org/docs/current/continuous-archiving.html

## Logical database ownership and physical resource isolation
Definition: A logical database groups one owner's SQL objects and access rights; a physical PostgreSQL server supplies shared compute, storage, WAL, and connection resources.
Why we use it: Separate data ownership does not stop one workload from consuming another workload's shared infrastructure capacity.
Example in this project: Inventory and Payment databases have separate credentials, while a shared free deployment still has a common failure and contention boundary.
Location in code: No implementation exists yet.
Related decisions: D-007 defines owner boundaries; D-029 scopes migrations; D-030 defines logical ownership and documented physical placement profiles.
Sources: https://www.postgresql.org/docs/current/managing-databases.html ; https://www.postgresql.org/docs/current/ddl-schemas.html

## Connection budget and autoscaling
Definition: A connection budget caps database sessions across all application replicas and jobs, leaving capacity for recovery and operations.
Why we use it: Adding application pods multiplies their connection pools and can overload the same PostgreSQL server.
Example in this project: Pool planning sums replica count times each pool limit, plus worker/job and reserved capacity; one million client sessions do not require one million database connections.
Location in code: No implementation exists yet.
Related decisions: D-009 and D-010 require measured load and backpressure; D-030 requires bounded aggregate pools, while numeric limits and enforcement mechanics remain unresolved.
Source: https://www.postgresql.org/docs/current/runtime-config-connection.html

## RPO versus post-failure write availability
Definition: RPO describes accepted data that recovery may lose; write availability describes whether safe new writes can continue after a failure.
Why we use it: Two independent durable copies can preserve acknowledged data after one host fails but leave only one surviving data copy.
Example in this project: The production HA contract requires at least three data nodes so a safe promoted primary can establish a surviving independent synchronous follower.
Location in code: No implementation exists yet.
Related decisions: D-003, D-014, and D-023 require single-host-loss durability; D-031 defines the post-failure HA contract, with RTO unresolved.
Sources: https://patroni.readthedocs.io/en/latest/replication_modes.html ; https://www.postgresql.org/docs/current/warm-standby-failover.html

## SQL visibility versus synchronous durability
Definition: A transaction can become visible locally before a synchronous replication wait finishes; cancelling that wait can leave locally visible data without the required replica durability.
Why we use it: A worker must not treat local row visibility as proof that allocation or financial dispatch evidence survives safe failover.
Example in this project: Required external dispatch gates verify durability; cancelled COMMIT stays unknown and is reconciled through the original identity before safe further action.
Location in code: No implementation exists yet; the durability-barrier protocol remains unresolved.
Related decisions: D-006, D-023, and D-024 require durable evidence; D-031 requires a durability barrier, and Review 032 proposes its protocol.
Source: https://patroni.readthedocs.io/en/latest/replication_modes.html

## Safe promotion and fencing
Definition: Safe promotion chooses a replica preserving acknowledged history; fencing prevents the former primary from continuing as a competing writer.
Why we use it: Failure detection or changing a load-balancer route alone does not stop writes through stale connections or a hung controller.
Example in this project: HA recovery must prove leadership and fencing, then restore the required independent synchronous follower before new critical success.
Location in code: No implementation exists yet; controller, fencing mechanism, and recovery timings remain unresolved.
Related decisions: D-003 and D-030 preserve fail-closed durability; D-031 defines the HA contract without claiming default controller settings suffice.
Sources: https://www.postgresql.org/docs/current/warm-standby-failover.html ; https://patroni.readthedocs.io/en/latest/watchdog.html

## Later synchronous write as a WAL durability barrier
Definition: A later real logged transaction in the same valid WAL history can establish replica durability for earlier records when its synchronous replication wait completes successfully.
Why we use it: Recovery and background workers can see earlier rows before their original caller has received replication acknowledgment.
Example in this project: The worker must validate owner-local facts, write a guarded dispatch claim, and verify synchronous COMMIT before publication or provider dispatch; an empty/read-only COMMIT does not provide this wait.
Location in code: No implementation exists yet; this is an engineering inference requiring fault tests, not a built-in application barrier API.
Related decisions: D-031 requires safe HA and durability proof; D-032 defines the logged-write barrier and preserves D-006/D-023 financial ambiguity rules.
Source: https://www.postgresql.org/docs/current/warm-standby.html

## Replication cancellation warning and unknown commit outcome
Definition: Cancelling a PostgreSQL synchronous replication wait can produce a warning after local commit rather than an ordinary transaction-aborted error.
Why we use it: A driver's no-error result or COMMIT command tag alone may hide an interrupted replication wait; local state is not proof of the required independent durable copy.
Example in this project: Critical transaction handling must capture relevant warnings, cancellation, and connection failures; unknown outcomes keep their original identity and cannot authorize external dispatch until new verified proof.
Location in code: No implementation exists yet; warning handling must be checked against the selected PostgreSQL version and driver.
Related decisions: D-031 and D-032 require verified commit handling and barriers, while exact driver selection remains unresolved.
Source: https://github.com/postgres/postgres/blob/REL_18_STABLE/src/backend/replication/syncrep.c

## Recovery time objective and recovery evidence
Definition: RTO is the target time from a covered disruption to restoration of the specified usable capability; it is separate from data-loss tolerance and backlog resolution.
Why we use it: A database leader or process becoming healthy does not prove that safe checkout, FIFO admission, or workflow progress has returned.
Example in this project: D-033 targets at most thirty seconds from a single-host fault to sustained safe affected-path work at the declared design workload, without weakening durability or extending deadlines.
Location in code: No implementation exists yet; fault timestamps, sustained recovery criteria, and repeatable load conditions need implementation.
Related decisions: D-031 defines safe HA, D-032 defines durability barriers, and D-033 defines recovery and availability measurement targets.

## Request availability and error budget by capability
Definition: Request availability is the fraction of eligible operations served correctly; an error budget is the allowed bad-operation fraction over a stated measurement window.
Why we use it: A large number of successful browse requests can hide broken booking, and fast rejection can hide missing useful work.
Example in this project: D-033 sets separate rolling thirty-day 99.9 percent critical-capability targets; capacity rejection and fail-closed failure count as bad, while verified business outcomes have explicit classification.
Location in code: No implementation exists yet; operation identity, ingress denominators, deadline classifiers, and low-traffic probes remain to be specified.
Related decisions: D-009 requires honest latency/load reporting; D-033 defines availability accounting without treating pending financial outcomes as completed payments.
Source: https://sre.google/sre-book/service-level-objectives/

## Recovery processing time versus provider settlement time
Definition: Recovery processing time measures the platform's progress from evidence to a safe durable decision; provider settlement time measures external completion of the money movement.
Why we use it: Recording or initiating a refund does not prove that the provider has completed it or that the customer has received the money.
Example in this project: D-034 sets thirty-second first recovery attempts and sixty-second evidence-to-decision targets; verified final refund evidence is tracked separately from intent and initiation.
Location in code: No implementation exists yet; provider final-settlement timing is not established.
Related decisions: D-023 defines refund obligations, D-033 measures availability honestly, and D-034 defines processing and escalation targets.
Source: https://developer.sslcommerz.com/doc/v4/

## Persistent unresolved age and operator escalation
Definition: An unresolved case keeps its original start time until evidence establishes resolution; escalation assigns visible recovery work without pretending the underlying money movement is complete.
Why we use it: Repeated callbacks, retries, or restarts must not make an old financial obligation look new or erase responsibility for it.
Example in this project: D-034 sets alerts at five minutes and audited operator cases at fifteen minutes for ambiguous/blocked money outcomes, with immediate safety alerts and no implied human-response guarantee.
Location in code: No implementation exists yet; operator permissions, alert delivery, and provider-pending aging policy remain unresolved.
Related decisions: D-006 and D-023 forbid blind financial replay; D-034 requires durable recovery scheduling and escalation without weakening those rules.

## Provider identity versus validated replay guarantee
Definition: A unique merchant-supplied identity identifies an operation; a replay guarantee states what the provider does when that operation is submitted again, including concurrency, changed payloads, and retention limits.
Why we use it: A unique ID field does not alone prove that retrying an uncertain money-moving request is safe.
Example in this project: D-035 requires durable tran_id/refund_trans_id mappings and operation-specific evidence before ambiguous initiation replay; unsupported cases remain unresolved and visible.
Location in code: No implementation exists yet; sandbox behavior and authoritative replay contracts remain unverified.
Related decisions: D-006 and D-023 restrict financial retry, D-034 retains recovery obligations, and D-035 defines provider capability gates.
Source: https://developer.sslcommerz.com/doc/v4/

## Side-effect classification independent of HTTP method
Definition: An adapter must classify operations by their actual effect; a provider can expose a money-moving operation using GET.
Why we use it: Generic GET retry, redirect, or caching behavior can repeat or interfere with a financial initiation whose replay safety is unknown.
Example in this project: SSLCOMMERZ refund initiation is documented as GET; D-035 requires explicit dispatch handling with implicit retries disabled and credentials redacted.
Location in code: No implementation exists yet; actual SDK/client/proxy behavior needs inspection and fault tests.
Related decisions: D-006, D-023, and D-032 preserve dispatch evidence and ambiguity; D-035 defines transport and evidence gates.
Source: https://sandbox-gw.sslcommerz.com/docs

## Transaction-bound operator authorization
Definition: Permission to perform an intervention is bound to a specific resource, action, payload, and current state; being logged in as an operator is not enough.
Why we use it: An old approval or edited amount must not authorize a different refund, stale recovery action, or another customer's booking.
Example in this project: D-036 requires typed owner-service recovery commands, step-up, one-use scoped approval, execution-time checks, and unchanged allocation/payment safety guards.
Location in code: No implementation exists yet; roles, MFA mechanism, approval lifetime, and resource policy remain unresolved.
Related decisions: D-034 defines Operator Recovery Cases, D-035 gates provider evidence, and D-036 defines the operator authorization contract.
Sources: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html ; https://cheatsheetseries.owasp.org/cheatsheets/Transaction_Authorization_Cheat_Sheet.html

## Separation of duties and a sandbox-only exception
Definition: Separation of duties requires independent people to request and approve a high-risk intervention; two accounts owned by one person do not create independence.
Why we use it: One privileged session must not silently become both the requester and independent approver of a manual monetary action.
Example in this project: D-036 requires production dual control for high-risk manual finance and documents a single-operator sandbox profile with step-up and full audit, without live authorization.
Location in code: No implementation exists yet; real independent approvers are not provided by creating test users.
Related decisions: D-005 limits provider execution to sandbox; D-036 defines role separation and the explicit environment-bound exception.

## Owner-local audit atomicity and tamper evidence
Definition: Owner-local audit records the authorized action with its state mutation; tamper evidence makes later alteration detectable but does not make storage invulnerable to all administrators.
Why we use it: A successful financial intervention must not exist without durable accountability, and a mutable application log is insufficient recovery evidence.
Example in this project: D-036 requires append-only scoped audit, separately controlled export, rejection of unauditable financial/domain interventions, and disclosed privileged-compromise/free-profile limitations.
Location in code: No implementation exists yet; retention, export protection, and outage/emergency behavior remain unresolved.
Related decisions: D-030 scopes database identities, D-032 gates required durability, and D-036 defines audit and operator boundaries.
Source: https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

## Stable account identity versus login address
Definition: An account identifier stays the same when its owner changes their login email or password.
Why we use it: A login attribute must not reset purchase quota or transfer seat/booking ownership.
Example in this project: D-037 keeps queue, Admission Lease, holds and bookings bound to the same Customer Account ID after recovery.
Location in code: No implementation exists yet; email normalization/reuse and session enforcement remain unresolved.
Related decisions: D-012 defines account-scoped admission, D-020 defines account/event quota, and D-037 defines the stable identity lifecycle.

## Single-use recovery tokens and session invalidation
Definition: A purpose-bound recovery token authorizes one guarded account change; invalidating sessions separately limits access through previously issued credentials.
Why we use it: Replayed reset links and stolen sessions can retain access even after a password changes.
Example in this project: D-037 requires atomic token consumption with credential mutation, session/refresh invalidation, normal login after reset, and preserved account ownership.
Location in code: No implementation exists yet; token lifetimes, propagation bounds, MFA recovery evidence and Auth durability need decisions.
Related decisions: D-036 guards operator intervention; D-037 defines customer recovery without financial or allocation overrides.
Source: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html

## Password hashing and bounded authentication capacity
Definition: Memory-hard password hashing makes offline guessing expensive; bounded authentication work prevents login bursts from exhausting service resources.
Why we use it: Strong password storage and 1M active sessions need separate capacity controls; every seat hold must not repeat password hashing.
Example in this project: D-037 requires Argon2id, maintained libraries, bounded hashing workers and login budgets, with measured costs and stronger settings where capacity permits.
Location in code: No implementation exists yet; benchmark results and admission/session protocol remain unresolved.
Related decisions: D-009 retains the 1M active-client target, D-010 bounds overloaded work, and D-037 defines the authentication baseline.
Source: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html

## Email capture versus verified external delivery
Definition: A test SMTP sink captures messages for inspection; it does not establish delivery to a real recipient or their control of that mailbox.
Why we use it: A free integration test must not be presented as production identity or notification delivery evidence.
Example in this project: D-037 uses protected Mailpit and labeled sandbox test accounts while preserving production mailbox verification and reliable email delivery requirements.
Location in code: No implementation exists yet; real SMTP delivery, sender/domain ownership, abuse controls and free-cloud capacity need validation.
Related decisions: D-005 limits payment execution to sandbox; D-037 defines the explicit email-testing boundary.
Source: https://mailpit.axllent.org/docs/

## Token validity versus current session authority
Definition: A valid token signature proves who issued its claims; it does not prove that the account or session remains authorized after a reset, logout or disable.
Why we use it: A stolen JWT must not retain all access until expiration solely because its signature still verifies.
Example in this project: D-038 requires five-minute access JWTs plus a separately bounded thirty-second account/session security-state proof for protected customer requests.
Location in code: No implementation exists yet; algorithms, libraries, proof format and safe key rotation remain unresolved.
Related decisions: D-037 preserves stable customer identity and recovery; D-038 defines bounded current session authorization.
Source: https://datatracker.ietf.org/doc/html/rfc8725

## Bounded revocation freshness and fail-closed expiry
Definition: A cached authority observation has a fixed maximum age; a validator must reject protected access once freshness cannot be proved, including during outages.
Why we use it: Receiving an old cache entry or delayed event must not restart a revoked session's authorization window.
Example in this project: D-038 requires a thirty-second bound measured from durable revocation, absolute proof expiry anchored at primary observation, guarded owner checks and clock-error allowance inside that budget.
Location in code: No implementation exists yet; capacity, partitions, cache restart, clock uncertainty and owner-lock delay need tests.
Related decisions: D-031/D-032 guard authoritative history and durability, D-033 measures availability, D-037 requires invalidation, and D-038 defines the bounded exposure/failure contract.

## Customer session authority versus service recovery authority
Definition: Customer credentials authorize new customer requests; authenticated service authority carries previously accepted Saga work and verified provider evidence through recovery.
Why we use it: Logging out must block new customer access without abandoning a real charge, extending seats or falsely releasing an unresolved admission slot.
Example in this project: D-038 requires fail-closed customer access after proof expiry while preserving independently authorized expiry, callback validation and financial recovery.
Location in code: No implementation exists yet; workload identities, callback authentication and precise service transport are pending.
Related decisions: D-007 defines owner Saga responsibilities, D-034 retains financial obligations, D-036 guards operators, D-037 preserves obligations during recovery, and D-038 separates their authority.

## Refresh token rotation and session family reuse
Definition: Refresh rotation consumes one secret and creates a successor; its session family records the related generations so proven reuse can revoke remaining authority.
Why we use it: A stolen refresh token must not keep minting access tokens independently of the legitimate client's session lifecycle.
Example in this project: D-039 requires one guarded durable successor and family revocation on consumed-secret reuse, without a blanket grace window.
Location in code: No implementation exists yet; lineage retention, client coordination and ambiguous family-revocation recovery need validation.
Related decisions: D-038 requires current Auth checks and durable security changes; D-039 defines strict rotation and its reauthentication trade-off.
Source: https://www.rfc-editor.org/rfc/rfc9700.html#section-4.14.2

## Lost refresh response versus credential replay
Definition: A successful server-side rotation can leave a client holding only the consumed secret if the response is lost; its later use resembles a stolen-secret replay.
Why we use it: An unknown refresh outcome must not justify creating another successor or weakening reuse detection silently.
Example in this project: D-039 requires safe owner reconciliation and fresh authentication when current credentials cannot be recovered, with old-family fencing and preserved domain ownership/deadlines.
Location in code: No implementation exists yet; response loss, ambiguous COMMIT, delayed cookies and multi-tab races need tests.
Related decisions: D-032 treats unknown commits cautiously, D-037 preserves Account ID, D-038 bounds revoked access, and D-039 defines strict refresh failure behavior.

## Refresh inactivity versus absolute session lifetime
Definition: Inactivity expiry limits time without successful refresh; absolute expiry limits total family lifetime even if refresh keeps succeeding.
Why we use it: A browser's background requests must not extend session authority indefinitely or be mistaken for human presence.
Example in this project: D-039 requires thirty minutes without refresh and twenty-four hours from login, with server-enforced expiry and no revival by changed policy.
Location in code: No implementation exists yet; policy snapshots, clock guards and expiry/renewal load need validation.
Related decisions: D-038 caps access-token/proof lifetime; D-039 defines refresh/session deadlines independent of reservation deadlines.
Source: https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html

## HttpOnly cookies and CSRF boundaries
Definition: HttpOnly prevents script access to a cookie's secret; CSRF defenses separately restrict unwanted requests that a browser sends with that cookie.
Why we use it: A protected refresh cookie alone does not authorize arbitrary cross-origin token rotation or logout requests.
Example in this project: D-039 requires Secure/HttpOnly host-only cookies, explicit SameSite, POST mutations, maintained CSRF protection and exact configured-origin policy, with separately validated provider callbacks.
Location in code: No implementation exists yet; pre-login/refresh CSRF bootstrap, origin fallback and XSS controls remain unresolved.
Related decisions: D-005 requires sandbox provider integration, D-037 guards recovery, D-038 checks Auth authority, and D-039 defines browser credential transport.
Sources: https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html ; https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html

## Signing purpose separation and trust bootstrap
Definition: Each credential purpose uses an explicit verification profile and scoped key set; bootstrap trust determines which sources may introduce or revoke keys.
Why we use it: A customer token must not become operator authority, and a stolen credential key must not approve its own replacement or active status.
Example in this project: D-040 requires separate access, security-proof, operator and admission key sets plus independently authenticated key-status control.
Location in code: No implementation exists yet; algorithms, runtime isolation, bootstrap and control topology remain unresolved.
Related decisions: D-036 scopes operator authority, D-038 validates customer proof, D-039 guards refresh, and D-040 defines purpose/control trust separation.
Source: https://datatracker.ietf.org/doc/html/rfc8725

## Routine key overlap versus emergency revocation
Definition: Normal rotation retains bounded old-key verification for legitimate issued credentials; emergency revocation rejects a compromised key without that overlap.
Why we use it: A stolen signing key can forge new credentials, so token expiry alone cannot contain the incident.
Example in this project: D-040 requires thirty-day routine rotation and at most thirty seconds from durable trusted key revocation to denial of new affected authorization, with issuer fencing and no stale-key resurrection.
Location in code: No implementation exists yet; issuer cutoff, key-status freshness, partitions, clocks and rollback need tests.
Related decisions: D-031/D-032 guard durable authority, D-038 bounds session revocation, D-039 retains session deadlines, and D-040 defines key-specific enforcement.
Source: https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html

## Key containment time versus compromise detection time
Definition: Containment time measures enforcement after a trusted incident directive; detection time measures how long it takes to discover the compromise.
Why we use it: A thirty-second revocation bound cannot prove that undiscovered key theft is stopped thirty seconds after it happens.
Example in this project: D-040 starts the key enforcement timer at durable trusted control acceptance and separately requires detection evidence and out-of-band recovery if control trust is compromised.
Location in code: No implementation exists yet; detection targets, protected control recovery and investigation procedures remain unresolved.
Related decisions: D-036 requires accountable intervention, D-038 defines measurable revocation, and D-040 distinguishes credential-key containment from root-trust failure.

## Encrypted secret storage versus runtime key extraction
Definition: Encryption protects stored secret material; a permitted runtime or privileged host can still access software-held private keys used for signing.
Why we use it: Self-hosted encrypted Secrets must not be presented as non-exportable hardware protection or immunity to host administrators.
Example in this project: D-040 requires encrypted storage/backups, scoped mounts and RBAC with explicit free-profile limits; Kubernetes base64 alone does not encrypt a Secret.
Location in code: No implementation exists yet; secret tooling, pod/CI permissions, backup protection and signing isolation need validation.
Related decisions: D-036 discloses privileged-compromise limitations, D-039 keeps refresh secrets out of browser persistence, and D-040 defines signing-material management.
Sources: https://kubernetes.io/docs/concepts/security/secrets-good-practices/ ; https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html

## Workload identity versus permission and owner truth
Definition: Workload identity authenticates a service or worker; permission allows a scoped operation, and owner evidence establishes the domain facts required for that operation.
Why we use it: A valid Booking identity must not bypass Inventory guards or invent Payment evidence, and Notification credentials must not authorize financial effects.
Example in this project: D-041 requires SPIFFE/SPIRE mTLS plus owner action/resource/workflow authorization and explicit trusted-owner failure assumptions.
Location in code: No implementation exists yet; attestation, policy matrix, evidence transport and compromise recovery are unresolved.
Related decisions: D-007 separates Saga/financial/allocation ownership, D-030 scopes storage, and D-040 scopes trust; D-041 requires service authority boundaries.
Source: https://spiffe.io/docs/latest/spiffe-about/spiffe-concepts/

## Kafka principal and topic provenance versus payload claims
Definition: Kafka ACLs authorize authenticated principals on broker resources; an event's owner field is data and cannot independently prove who produced it.
Why we use it: A forged Payment claim must not become a verified charge merely because a consumer can decode its schema.
Example in this project: D-041 requires scoped TLS/SCRAM principals, owner-topic publisher restrictions and audited original-history replay; default Kafka certificate DN mapping does not automatically identify SPIFFE URI SANs.
Location in code: No implementation exists yet; topic/group permissions, principal mapping, replay provenance and credential revocation need tests.
Related decisions: D-024 guards local event effects, D-026 retains owner history, D-027 guards replay, and D-040 scopes trust; D-041 requires Kafka authorization boundaries.
Source: https://kafka.apache.org/41/security/authorization-and-acls/

## Established connection versus current authorization
Definition: A previously authenticated connection can outlive a certificate or policy change; new actions still need current valid authority.
Why we use it: A revoked workload must not keep issuing protected commands indefinitely through a pooled RPC connection.
Example in this project: D-041 requires owner-guard policy/certificate checks and a thirty-second RPC policy-revocation bound, while separately measuring native Kafka propagation and connection behavior.
Location in code: No implementation exists yet; pooled connections, expiry, agent outages, policy cache and broker version behavior need tests.
Related decisions: D-038 bounds customer freshness and D-040 bounds key-status trust; D-041 requires workload authorization enforcement.

## Network reachability versus business authorization
Definition: Network isolation limits which endpoints can exchange traffic; application authorization limits which actions a verified caller may perform.
Why we use it: An allowed network route to Inventory must not grant every operation, and an unenforced NetworkPolicy cannot prove isolation.
Example in this project: D-041 requires an enforcing Kubernetes CNI and tested default-deny rules alongside mTLS, owner guards and documented Docker/host connection differences.
Location in code: No implementation exists yet; CNI choice, egress rules, host traffic and existing connections need validation.
Related decisions: D-030 isolates storage ownership and D-040 protects key control; D-041 requires network/application defense boundaries.
Source: https://kubernetes.io/docs/concepts/services-networking/network-policies/

## RPC outcome uncertainty versus business completion
Definition: An RPC response reports an observation; losing that response does not establish whether the owner's transaction committed.
Why we use it: A timed-out hold cannot safely become a new allocation or a freed admission slot without owner reconciliation.
Example in this project: D-042 requires bounded internal gRPC calls with stable command identities and authoritative outcome lookup.
Location in code: No implementation exists yet; receipt states, deadlines and unknown-result handling need review.
Related decisions: D-015 fences delayed allocation, D-032 verifies durability, and D-041 enforces owner authority; D-042 requires transport rules.
Sources: https://grpc.io/docs/guides/deadlines/ ; https://grpc.io/docs/guides/cancellation/

## Durable Saga intent versus an in-memory RPC chain
Definition: A durable Saga retains intended steps and outcomes so recovery can continue after its worker or customer request disappears.
Why we use it: Transport failure must not erase an accepted order or cause a fresh provider side effect.
Example in this project: D-042 requires persisted Booking step identities, owner RPC commands and Outbox-published owner facts.
Location in code: No implementation exists yet; step states, command receipts and recovery dispatch remain unresolved.
Related decisions: D-007 assigns Saga ownership and D-024 governs event effects; D-042 requires canonical command delivery.

## Transport retry versus safe business replay
Definition: Transport retries resend a call; safe business replay preserves the original logical identity and guarded owner outcome.
Why we use it: Retrying an internal Payment command must not blindly repeat an uncertain SSLCOMMERZ operation.
Example in this project: D-042 requires explicit mutation retry controls, with separately tested gRPC transparent retry and provider dispatch behavior.
Location in code: No implementation exists yet; pinned clients, proxies, attempt counters and idempotency receipts need tests.
Related decisions: D-006 and D-035 restrict uncertain provider dispatch; D-042 requires bounded internal replay.
Source: https://grpc.io/docs/guides/retry/

## Idempotency key versus business identity
Definition: An idempotency key identifies a submitted logical request; business identity identifies the hold, Order, attempt or refund whose duplicate effects must remain forbidden across keys.
Why we use it: A new key must not create a second Order from one hold or another payment while the first outcome remains unknown.
Example in this project: D-043 requires owner-scoped durable key mappings plus separate business uniqueness and lifecycle guards.
Location in code: No implementation exists yet; receipt and business indexes need specification.
Related decisions: D-018 guards hold lifecycles, D-023 guards charge/refund obligations, and D-042 defines command transport; D-043 requires replay boundaries.
Source: https://www.postgresql.org/docs/current/ddl-constraints.html

## Semantic request fingerprint
Definition: A semantic fingerprint summarizes explicitly normalized business fields under a known version; it is not an authorization token or an arbitrary serialized request hash.
Why we use it: The same command identity cannot silently change its seats, quote, target or transition across retries and upgrades.
Example in this project: D-043 requires storing canonical meaning and rejecting changed payloads while excluding trace IDs and replaced credentials.
Location in code: No implementation exists yet; per-operation normalization and schema bridge rules remain unresolved.
Related decisions: D-021 fixes the quote and D-028 guards schema meaning; D-043 requires command payload binding.

## Historical command outcome versus current allocation state
Definition: A command can have succeeded earlier while its resulting hold has since expired or closed; these are different observations.
Why we use it: Replaying an old successful response must not claim fresh seat ownership or renew its deadline.
Example in this project: D-043 requires original outcome/timestamps with separately identified current state and protected retired identities.
Location in code: No implementation exists yet; response shapes and retained evidence need review.
Related decisions: D-016 enforces original deadlines, D-026 retains safety evidence, and D-042 distinguishes delivery from completion; D-043 requires safe result replay.

## Checkout acceptance versus reservation eligibility
Definition: Accepting checkout records a recoverable request; reservation eligibility is determined by Inventory when it guards the actual conversion.
Why we use it: A Pay click or pending Order must not extend an almost-expired hold.
Example in this project: D-044 requires CHECKOUT_PENDING before conversion and PAYMENT_PENDING only after matching proven reservation evidence.
Location in code: No implementation exists yet; checkout routes, phases and response fields need review.
Related decisions: D-016 defines deadline eligibility, D-042 requires durable Saga intent and D-043 binds command replay; D-044 requires checkout-start acceptance.

## Owner snapshot versus guarded transition
Definition: A snapshot reports owner state at an observation point; a guarded transition checks whether its preconditions still hold when applying the effect.
Why we use it: A previously valid hold may expire or close while Booking prepares its Order.
Example in this project: D-044 requires a trusted quote/hold read followed by Inventory's locked conversion without treating the earlier read as an eligibility guarantee.
Location in code: No implementation exists yet; snapshot proofs and conversion checks remain unresolved.
Related decisions: D-021 fixes quote ownership and D-032 verifies durable evidence; D-044 requires explicit read-to-conversion handling.

## Saga acceptance versus cross-service atomicity
Definition: A durable Saga coordinates separately committed owner steps; accepted workflow intent does not make their effects one atomic transaction.
Why we use it: Pending Orders, committed conversions with lost responses and in-flight provider calls need retained evidence and recovery.
Example in this project: D-044 requires Order-first intent, matched reservation proof and separate payment initiation while retaining late-charge compensation.
Location in code: No implementation exists yet; later Saga steps and race handling need review.
Related decisions: D-004 governs late charges, D-007 assigns orchestration and D-042 defines transport; D-044 requires checkout-start ordering.
Source: https://learn.microsoft.com/en-us/azure/architecture/patterns/saga

## Fulfillment charge binding versus payment success
Definition: A verified successful charge records money received; a fulfillment binding selects which eligible charge may fund one Order/allocation lifecycle.
Why we use it: Two real charges or duplicate callbacks must not select two funding paths or accidentally refund the charge protecting a good booking.
Example in this project: D-045 requires one immutable selected charge under Payment-owned serialization and separate extra-charge compensation.
Location in code: No implementation exists yet; binding schema and proof transport need review.
Related decisions: D-023 separates charges and obligations and D-043 guards business identities; D-045 requires charge selection.

## Terminal allocation decision versus elapsed deadline
Definition: A terminal allocation decision proves whether the guarded lifecycle confirmed or closed; elapsed time alone does not reveal an earlier committed confirmation.
Why we use it: A lost confirmation response must not trigger compensation against an already confirmed allocation.
Example in this project: D-045 requires durable matching Inventory closure proof before selected-charge compensation.
Location in code: No implementation exists yet; finalization locks, receipts and recovery proofs remain unresolved.
Related decisions: D-016 guards deadline decisions, D-032 verifies recovered durability and D-044 binds conversion; D-045 requires finalization evidence.
Source: https://www.postgresql.org/docs/current/explicit-locking.html

## Compensation obligation versus completed refund
Definition: Compensation records an accountable corrective action; external refund completion still requires verified provider evidence.
Why we use it: A durable local ledger or successful initiation cannot prove the customer's money has been returned.
Example in this project: D-045 preserves selected-charge closure evidence, separate extra-charge intents and uncertain provider recovery.
Location in code: No implementation exists yet; failure and late-response tests remain pending.
Related decisions: D-023 defines the refund ledger, D-034 measures recovery and D-035 restricts uncertain dispatch; D-045 requires safe compensation authorization.
Source: https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction

## Provider validation status versus TicketForge fulfillment
Definition: Provider validation reports a payment observation; TicketForge fulfillment additionally needs matching owner evidence and eligible Inventory confirmation.
Why we use it: VALIDATED must not be interpreted as another charge or a locally confirmed booking.
Example in this project: D-046 requires strict sandbox validation for VALID/VALIDATED with exact identity, amount, currency and risk checks.
Location in code: No implementation exists yet; per-endpoint response profiles and actual sandbox evidence remain pending.
Related decisions: D-005 selects sandbox, D-021 fixes quote matching and D-045 guards fulfillment; D-046 requires verification eligibility.
Sources: https://developer.sslcommerz.com/doc/v4/ ; https://sandbox-gw.sslcommerz.com/docs

## Verified charge versus merchant risk eligibility
Definition: A provider-successful verified charge can still be ineligible for service under the merchant's risk policy; money evidence and fulfillment permission are distinct.
Why we use it: A risky or missing-risk result must not become safe automatically or erase a real compensation obligation.
Example in this project: D-046 requires safe risk 0 eligibility, blocked risk 1 and pending unknown risk with original deadlines retained.
Location in code: No implementation exists yet; risk fields, binding/fencing races and compensation need sandbox/failure validation.
Related decisions: D-023 retains charge obligations and D-045 binds one candidate; D-046 requires versioned merchant policy.
Source: https://developer.sslcommerz.com/doc/v4/

## Contradictory provider evidence versus state overwrite
Definition: Conflicting authoritative observations need retained investigation and guarded recovery, rather than replacing an earlier verified financial fact with the latest arriving label.
Why we use it: Delayed failure, risk changes or external reversals cannot safely release a confirmed allocation or trigger an additional refund automatically.
Example in this project: D-046 requires disputed-evidence recovery, retained observations and reconciliation of external corrections with existing obligations.
Location in code: No implementation exists yet; provider reversal semantics and dispute handling remain unproved.
Related decisions: D-034 assigns recovery/escalation, D-035 restricts uncertain dispatch and D-045 requires allocation proof; D-046 requires evidence conflict handling.

## Receipt acknowledgement versus verified financial outcome
Definition: A receipt acknowledgement proves accepted notification evidence and recovery work were stored. It does not prove the payment or booking succeeded.
Why we use it: Crashes must not lose acknowledged notifications, and provider outages must not hold every callback connection open.
Example in this project: D-047 requires durable Payment receipt and work before HTTP 200, followed by asynchronous sandbox validation.
Location in code: No implementation exists yet; acknowledgement behavior and crash recovery need validation.
Related decisions: D-032 requires durability proof and D-046 requires provider verification; D-047 requires the receipt boundary.

## Notification deduplication versus charge deduplication
Definition: Repeated input messages and repeated evidence of one verified charge have different identities and trust levels.
Why we use it: An attacker must not reserve a financial identity through an unverified callback and suppress real evidence later.
Example in this project: D-047 requires bounded exact observation deduplication while preserving independently verified charge guards.
Location in code: No implementation exists yet; distinct references and forged-before-genuine notifications need failure tests.
Related decisions: D-023 guards verified charges and D-043 guards owner commands; D-047 requires untrusted receipt handling.

## Callback delivery versus owner reconciliation
Definition: A callback reports an observation. Owner reconciliation independently investigates known financial work and its unresolved outcomes.
Why we use it: Callback loss, duplicate delivery or a worker race cannot be the only way payment recovery progresses.
Example in this project: D-047 requires pre-dispatch reconciliation intent and work generations that retain notifications arriving during validation.
Location in code: No implementation exists yet; provider query visibility, quotas and polling completion horizons remain unproved.
Related decisions: D-006 preserves unknown attempts and D-034 measures recovery; D-047 requires independent scheduling.

## Historical confirmation versus current entitlement
Definition: A completed allocation remains a historical fact even when a later authorized workflow revokes its current entitlement.
Why we use it: A cancelled booking must not be rewritten as a checkout that never succeeded, and old success evidence must not restore it.
Example in this project: D-048 requires a separate confirmed-booking cancellation with guarded whole-bundle revocation.
Location in code: No implementation exists yet; cancellation business policy and state schema remain undecided.
Related decisions: D-043 separates historical outcomes from current state and D-045 guards checkout finality; D-048 requires later revocation.

## Entitlement revocation versus refund completion
Definition: Revocation ends the right to use an allocation. Refund completion proves that the provider returned the permitted money.
Why we use it: External refund failure cannot safely restore a seat that may have been allocated to another customer.
Example in this project: D-048 requires proven revocation before cancellation refund dispatch and separate pending-money status.
Location in code: No implementation exists yet; revocation, provider uncertainty and recovery need failure validation.
Related decisions: D-023/D-035 preserve refund obligations and uncertain dispatch; D-048 requires the post-booking boundary.
Source: https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction

## Reallocation generation versus restored old booking
Definition: A seat allocated again after proven release belongs to a new lifecycle. Commands for the old lifecycle cannot mutate it.
Why we use it: Delayed cancellation, confirmation or expiry commands must not affect another customer's allocation.
Example in this project: D-048 requires fresh lifecycle identity and generation for policy-permitted resale after proven revocation.
Location in code: No implementation exists yet; resale eligibility and stale-command races remain under review.
Related decisions: D-015/D-045 preserve allocation identity guards and D-020 retains quota accounting; D-048 requires reallocation safety.

## Cancellation policy snapshot versus current catalog rules
Definition: A policy snapshot fixes the cancellation terms associated with a purchase. A later catalog policy applies to its own eligible purchases.
Why we use it: Configuration changes must not silently remove or create rights on an existing booking.
Example in this project: D-049 requires a fixed twenty-four-hour cutoff and full-quote refund terms captured with the successful hold.
Location in code: No implementation exists yet; policy publication, activation and rescheduling treatment remain under review.
Related decisions: D-021 snapshots quote terms and D-048 separates revocation from refund; D-049 requires the business policy.

## Conditional refund reservation versus outstanding refund obligation
Definition: Conditional work reserves capacity for a permitted refund if its required revocation succeeds. An outstanding obligation follows proven authorization and revocation.
Why we use it: A failed cancellation must not refund an active entitlement, while unknown revocation must not free reserved money accounting.
Example in this project: D-049 requires retiring conditional work only from matching proven rejection and delayed-execution fencing.
Location in code: No implementation exists yet; acceptance, rejection and unknown-owner races require failure tests.
Related decisions: D-023 guards charge totals and D-048 requires revocation before dispatch; D-049 requires conditional-work finalization.

## Customer-paid refund target versus merchant settlement
Definition: A customer refund target concerns the permitted original customer payment. Merchant settlement may differ because of provider deductions.
Why we use it: A net settlement value must not silently reduce a promised customer refund or prove refund completion.
Example in this project: D-049 requires full original quote refunds, including quoted fees/taxes, with separate provider capability tests.
Location in code: No implementation exists yet; actual sandbox refund limits and response semantics remain unproved.
Related decisions: D-022 preserves exact money and D-023/D-035 guard refunds; D-049 requires full customer cancellation refunds.
Source: https://developer.sslcommerz.com/doc/v4/

## Cancellation request versus effective owner fences
Definition: A request records intended event cancellation. Effective owner fences prove the responsible services have stopped the covered new work.
Why we use it: Delayed events and stale catalog state must not permit new allocation after a proven stop.
Example in this project: D-050 requires matching Inventory, Waiting Room and Payment fence proofs before effective event cancellation.
Location in code: No implementation exists yet; authority, topology and fence proof schema remain under review.
Related decisions: D-032 proves owner durability and D-041 guards authority; D-050 requires cancellation effectiveness.

## Shared occurrence guard versus exclusive cancellation barrier
Definition: Compatible guards let ordinary transactions proceed together. A conflicting barrier orders cancellation after earlier covered transactions and before later permitted work.
Why we use it: A plain state read cannot safely order concurrent confirmation and cancellation.
Example in this project: D-050 requires a bounded owner-local shared/exclusive gate with persistent closing/fence state and consistent lock order.
Location in code: No implementation exists yet; PostgreSQL lock choice, contention and 1M capacity require measurement.
Related decisions: D-016/D-045 guard allocation transitions; D-050 requires the occurrence boundary.
Source: https://www.postgresql.org/docs/current/explicit-locking.html

## Effective event cancellation versus completed booking recovery
Definition: An event can be proven closed to new allocation while existing booking revocations and monetary returns remain unfinished.
Why we use it: One status must not hide active refund obligations or turn a global sales stop into per-bundle revocation proof.
Example in this project: D-050 requires authoritative resumable scans, exact allocation terminal proofs and separate backlog counts.
Location in code: No implementation exists yet; bulk targets, checkpoint recovery and provider capacity remain unproved.
Related decisions: D-034 measures recovery and D-048/D-049 require safe revocation/refunds; D-050 requires bounded bulk work.

## Catalog publication versus executable occurrence configuration
Definition: Publication records approved event information. Executable configuration defines the complete owner-controlled version eligible for guarded ticket operations.
Why we use it: A listing or partial import must not authorize incomplete or cancelled inventory.
Example in this project: D-051 requires complete sealed Inventory preparation and guarded activation with matching owner readiness evidence.
Location in code: No implementation exists yet; publication authority and readiness proof schema remain under review.
Related decisions: D-021 activates local pricing and D-050 fences cancellation; D-051 requires the publication boundary.

## Structural occurrence identity versus commercial version
Definition: Structural identity fixes which occurrence and physical seats a purchase concerns. A commercial version fixes the pricing and terms offered to its new purchases.
Why we use it: Changing a venue template or price must not silently move a confirmed seat or change existing rights.
Example in this project: D-051 requires frozen activated structure, future-hold commercial versions and separately reviewed material-change workflows.
Location in code: No implementation exists yet; schedule/venue changes and initial sales window remain undecided.
Related decisions: D-021/D-049 preserve purchased snapshots; D-051 requires structural and commercial update boundaries.

## Source durability versus search visibility
Definition: Source durability proves owner records survived the covered failure. Search visibility means a derived index has made its projected data searchable.
Why we use it: An Elasticsearch refresh cannot prove Inventory activation or grant seat availability.
Example in this project: D-051 requires revision-aware asynchronous search projections and owner-authorized allocation.
Location in code: No implementation exists yet; search lag and rebuild/correction behavior need separate validation.
Related decisions: D-024/D-028 guard event projections and D-032 proves durability; D-051 requires visibility separation.
Source: https://www.elastic.co/docs/manage-data/data-store/near-real-time-search

## New sales closure versus existing checkout eligibility
Definition: A sales cutoff ends permission to create new holds. Existing eligible allocations keep their original checkout deadlines unless a separate authorized control ends them.
Why we use it: Closing sales must not accidentally cancel valid checkout or refund a booking in progress.
Example in this project: D-052 requires new holds ending seven minutes before start, while existing two-minute holds and five-minute reservations continue.
Location in code: No implementation exists yet; sales-window and clock contracts remain under review.
Related decisions: D-016/D-017 fix allocation eligibility and D-050 defines Event Cancellation; D-052 requires normal sales closure.

## Guarded eligibility time versus visible completion time
Definition: Eligibility time is the owner's fresh check under required guards. Visible completion can occur later after commit, recovery or projection.
Why we use it: A pre-start eligibility rule cannot guarantee payment settlement or customer-visible confirmation before event start.
Example in this project: D-052 preserves eligible late commit and independent recovery rather than promising instant physical-time completion.
Location in code: No implementation exists yet; clock error bounds and boundary tests remain unproved.
Related decisions: D-016/D-032 define guarded commit evidence; D-052 requires sales-window timing.

## Fresh wall-clock reading versus bounded UTC uncertainty
Definition: A fresh clock reading reports current local wall time. Uncertainty describes its possible distance from trusted UTC under justified assumptions.
Why we use it: Fresh SQL time alone cannot prove safe expiry, opening or proof freshness.
Example in this project: D-053 requires a 100 ms error threshold, current node-bound health evidence and conservative interval checks.
Location in code: No implementation exists yet; time-source assumptions and owner-local enforcement remain unproved.
Related decisions: D-016/D-052 require guarded time; D-053 requires uncertainty handling.
Sources: https://www.postgresql.org/docs/current/functions-datetime.html ; https://chrony-project.org/doc/4.8/chronyc.html

## Uncertain deadline boundary versus proven expiry
Definition: An interval overlapping a deadline cannot establish which side real UTC lies on. Proven expiry requires its lower bound to reach the deadline.
Why we use it: Clock uncertainty must not release a still-valid allocation or grant a potentially expired transition.
Example in this project: D-053 requires upper-bound eligibility and lower-bound expiry checks without changing stored durations.
Location in code: No implementation exists yet; boundary, failover and cleanup tests remain pending.
Related decisions: D-016 guards closure and D-017 fixes durations; D-053 requires conservative decisions.

## Boot-bound monotonic age versus transferable deadline
Definition: Monotonic elapsed time measures duration in a local clock/boot domain. Cross-node absolute UTC deadlines require justified clock bounds.
Why we use it: Restart, cache delivery and a backward wall clock must not renew old authority evidence.
Example in this project: D-053 requires node/boot-bound age and both-node uncertainty for cross-owner freshness.
Location in code: No implementation exists yet; suspend behavior and DB/agent integration require validation.
Related decisions: D-038/D-040/D-041 bound authority freshness; D-053 requires clock enforcement.

## Material occurrence change versus commercial update
Definition: A material change alters the scheduled performance or physical seat entitlement. A commercial update changes the offer for future purchases while preserving the same occurrence and seat identities.
Why we use it: A catalog edit must not silently change an existing customer's purchase.
Example in this project: D-054 requires cancellation and replacement for a changed date or venue. D-051 already permits new prices for future holds with old quotes preserved.
Location in code: No implementation exists yet; material-change workflow and customer communication remain unimplemented.
Related decisions: D-049 preserves terms and D-051 freezes activated structure; D-054 requires the change workflow.

## Replacement occurrence versus entitlement transfer
Definition: A replacement is a separately defined occurrence linked to a cancelled one. Entitlement transfer would explicitly move a customer's rights to another occurrence under agreed rules.
Why we use it: Linking two occurrences cannot by itself move seats, payments or customer consent.
Example in this project: D-054 requires independent new purchases and old refunds. Preserving seats through transfer would need a different approved contract.
Location in code: No implementation exists yet; replacement workflow and customer communication remain unimplemented.
Related decisions: D-023/D-045 bind money to one purchase lifecycle and D-050 defines cancellation; D-054 requires replacement semantics.

## Occurrence seat safety versus physical venue schedule safety
Definition: Seat safety prevents conflicting allocations within one occurrence. Schedule safety prevents different occurrences from claiming the same physical capacity during overlapping use.
Why we use it: Separate occurrence IDs alone do not establish that both performances can use the venue.
Example in this project: D-055 requires a canonical venue calendar before occurrence activation, separate from Inventory's per-seat hold guard.
Location in code: No implementation exists yet; venue-calendar guards and canonical mappings remain unimplemented.
Related decisions: D-001/D-002 protect allocations and D-051 governs activation; D-055 requires cross-occurrence safety.

## Performance duration versus venue occupancy interval
Definition: Performance duration covers the scheduled show. Occupancy also covers setup, early customer access and teardown that require the venue.
Why we use it: Back-to-back show times can still overlap during physical preparation or customer access.
Example in this project: D-055 requires explicit finite intervals and approved buffers before reserving venue resources.
Location in code: No implementation exists yet; buffer values, mapping and concurrent database enforcement remain unproved.
Related decisions: D-054 handles material replacement; D-055 requires schedule and occupancy guards.

## Availability display versus exclusive allocation
Definition: An availability view describes recently observed seat state. A successful authoritative hold grants exclusive allocation under the current owner guards.
Why we use it: A recent read cannot prevent another customer's concurrent hold.
Example in this project: D-056 requires bounded advisory Redis reads while D-002 requires durable Inventory success before granting a hold.
Location in code: No implementation exists yet; freshness enforcement and delivery capacity remain unproved.
Related decisions: D-001/D-002 protect allocation and D-042 separates owner commands from asynchronous facts; D-056 requires availability behavior.

## Source completeness frontier versus recent message receipt
Definition: A completeness frontier proves that all required source changes through a known cut are applied. Recent receipt only proves that some message arrived.
Why we use it: A fresh heartbeat can hide an old unpublished or missing allocation change.
Example in this project: D-056 requires original owner cut time, partition coverage and current generation before labeling availability fresh.
Location in code: No implementation exists yet; the exact snapshot/frontier algorithm needs design and fault validation.
Related decisions: D-024/D-026 guard event processing and D-053 bounds time; D-056 requires projection certification.

## Source-proof lifetime versus cache lifetime
Definition: Cache lifetime describes how long a stored response may be reused. Source-proof lifetime bounds how old its underlying certified knowledge may be.
Why we use it: Revalidation or redelivery must not relabel unchanged old knowledge as current availability.
Example in this project: D-056 requires preserving as-of and remaining freshness through every cache and client reuse.
Location in code: No implementation exists yet; HTTP and browser delivery budgets remain unresolved.
Related decisions: D-053 preserves original evidence age; D-056 requires a two-second server-side availability bound.

## Source-cut manifest versus maximum Outbox ID
Definition: A source-cut manifest records the source changes that must be covered for one consistent observation. A maximum ID describes allocated identifiers, not commit order.
Why we use it: A transaction can allocate a lower ID and commit after another transaction with a higher ID.
Example in this project: D-057 requires a published-offset vector plus exact outstanding Event IDs from one owner snapshot.
Location in code: No implementation exists yet; manifest schema, query cost and certification require validation.
Related decisions: D-024/D-026 retain stable events and D-056 requires completeness; D-057 requires its proof algorithm.

## Publication receipt versus applied projection coverage
Definition: A publication receipt proves where an acknowledged event was recorded in Kafka. Applied coverage proves that the required view changes exist in the current projection generation.
Why we use it: Published, durably received and Redis-applied are different stages.
Example in this project: D-057 requires both published-prefix and outstanding-event coverage before certifying a cut.
Location in code: No implementation exists yet; Redis certification layout and fault handling remain unproved.
Related decisions: D-024 distinguishes received from applied and D-056 forbids intent-only proof; D-057 requires manifest coverage.

## Consistent snapshot artifact versus paginated live reads
Definition: A consistent artifact preserves one source view across every chunk. Separate live queries can observe different committed states.
Why we use it: A rebuild can omit or mix seats when its pages belong to different moments.
Example in this project: D-057 requires complete isolated baselines and catch-up without treating an exported snapshot token as a permanent backup.
Location in code: No implementation exists yet; artifact storage, exporter lifetime and resource limits need validation.
Related decisions: D-026 guards rebuild/replay and D-056 requires safe generation changes; D-057 requires consistent snapshot handling.

## Immutable certified frame versus mutable data with separate proof
Definition: An immutable certified frame binds one bounded view's data and its completeness/freshness evidence in one fixed envelope. Separate mutable records can expose proof for different data.
Why we use it: A fresh certificate must not be read beside an older seat image.
Example in this project: D-058 requires section frames with exact scope, original cut time, generation and content digest.
Location in code: No implementation exists yet; encoding and publication/read guards remain unproved.
Related decisions: D-056 requires bounded advisory reads and D-057 requires actual coverage; D-058 requires frame publication.

## Atomic publication scope versus whole-event sharding
Definition: Atomic publication scope is the bounded set switched together. Sharding distributes different scopes across servers; it does not make them one atomic transaction.
Why we use it: Placing every event key in one Redis slot can concentrate flash-sale traffic on one shard.
Example in this project: D-058 requires section-specific hash tags, immutable frame reads and explicit per-section cuts.
Location in code: No implementation exists yet; section sizing, slot balance and hotspot capacity need measurement.
Related decisions: D-057 leaves Redis layout unresolved; D-058 requires its scope without cross-slot guarantees.

## Redis acknowledgment versus durable owner authority
Definition: A Redis acknowledgment reports completion under Redis's write behavior. Durable owner authority establishes accepted allocation/control facts under the selected PostgreSQL guarantees.
Why we use it: Losing a read image or a Redis-local fencing value must not create seats or permission to bypass owner guards.
Example in this project: D-058 requires rebuildable Redis read pools and source-bound revalidation after placement uncertainty.
Location in code: No implementation exists yet; control integration, isolation and failover behavior remain unproved.
Related decisions: D-002/D-032 retain allocation/durability authority and D-056 requires explicit unknown reads; D-058 requires read-pool recovery.

## Unchanged representation versus renewed source proof
Definition: Unchanged bytes can reuse a representation validator. A source proof needs new completeness evidence before its observation time can advance.
Why we use it: A 304 response can save bytes while still requiring a valid freshness check.
Example in this project: D-059 requires stable public seat bodies and matching proof headers derived together from a validated frame.
Location in code: No implementation exists yet; ETag variants, metadata merging and proof-aware cache behavior need validation.
Related decisions: D-056 forbids freshness extension by cache hits; D-057/D-058 bind actual coverage and immutable frames. D-059 requires the HTTP contract.

## Concurrent clients versus requests and egress per second
Definition: Client count describes simultaneous activity. Poll frequency and response size determine request rate and network demand.
Why we use it: A waiting room bounds seat mutations but does not automatically bound public reads or authentication work.
Example in this project: D-059 models 1M five-second pollers as at most 200,000 status requests per second before positive jitter, without claiming measured capacity.
Location in code: No implementation exists yet; staged load tests and capacity models must include wire overhead, read mix and bursts.
Related decisions: D-009 retains 1M active users and D-010 requires backpressure; D-059 requires explicit delivery budgets.

## Admission issuance time versus client observation time
Definition: A lease starts when its owner issues it durably. A later client poll observes the same lease and does not restart its lifetime.
Why we use it: Polling delays cannot create new selection time or silently alter capacity accounting.
Example in this project: D-059 preserves the original sixty-second SelectionWindow when queue status is polled every five seconds.
Location in code: No implementation exists yet; admission delivery health and stale status recovery need validation.
Related decisions: D-014 owns queue/admission facts and D-019 fixes the SelectionWindow; D-059 requires transport behavior.

## Advisory contention token versus authoritative allocation guard
Definition: An advisory token reduces competing work. An authoritative guard decides whether a state transition is allowed in the owning database.
Why we use it: Redis token loss must not permit two successful allocations of one seat.
Example in this project: D-060 requires ownership-checked Redis tokens while Inventory still validates and commits each complete bundle.
Location in code: No implementation exists yet; token scope, owner guards and failover races require validation.
Related decisions: D-002 owns allocation, D-008 requires whole bundles and D-019 bounds attempts; D-060 requires the coordination policy.

## New demand pause versus reserved workflow recovery
Definition: Pausing new demand stops additional workflows. Reserved recovery capacity lets already accepted work progress under its original safety rules.
Why we use it: Redis outages must not trigger unbounded database bypass or automatically abandon valid payments.
Example in this project: D-060 requires pausing new holds while guarded existing checkout and financial recovery use separate bounded paths.
Location in code: No implementation exists yet; ingress budgets, dependency isolation and recovery throughput remain unproved.
Related decisions: D-010 reserves recovery capacity and D-042 preserves accepted work; D-060 requires Redis-independent recovery paths.

## Lost request counter versus reset business entitlement
Definition: A request counter measures recent traffic. Business entitlement includes durable admission, attempt and purchase limits that survive coordination loss.
Why we use it: Restarting a limiter must not reset checkout attempts, priority or cumulative ticket quota.
Example in this project: D-060 requires conservative limiter recovery and an Inventory-owned durable attempt ledger while Waiting Room keeps durable capacity accounting.
Location in code: No implementation exists yet; ledger transactions, counter horizon and generation recovery need validation.
Related decisions: D-014/D-019/D-020 preserve durable business limits; D-060 requires their Redis failure boundary.

## Allocated sequence value versus durable acceptance order
Definition: A sequence value can be allocated before its transaction commits. Acceptance order is the authoritative order of successfully accepted queue entries.
Why we use it: A later committed participant must not bypass an earlier entry that appears after a stalled transaction.
Example in this project: D-061 requires transactional occurrence append ordinals with the control lock held through completion.
Location in code: No implementation exists yet; commit inversion, duplicate joins and synchronous recovery need validation.
Related decisions: D-011 requires accepted FIFO and D-014 preserves its durability; D-061 requires the ordering primitive.

## Buffered join request versus accepted Queue Entry
Definition: A buffered request awaits owner processing. An accepted Queue Entry has a durably established identity and priority.
Why we use it: Memory queues and lost responses must not create promised priority that cannot survive failure.
Example in this project: D-061 requires small bounded join batches, acknowledging entries only after verified owner durability.
Location in code: No implementation exists yet; batch sizing, ingress latency and backpressure remain unproved.
Related decisions: D-014/D-032 require durable acceptance and D-043 preserves command identity; D-061 requires batching.

## Serialized FIFO dispatch versus parallel background work
Definition: FIFO dispatch serializes selection of the earliest eligible entry. Background work can run in parallel when it does not change that ordering guarantee.
Why we use it: Skipping a locked earlier eligible entry can violate fairness even when every individual lease is valid.
Example in this project: D-061 requires separate append/dispatch controls and guarded global capacity reservation during lease issuance.
Location in code: No implementation exists yet; eligibility transitions, lock ordering and hot-occurrence capacity need validation.
Related decisions: D-010/D-011/D-013/D-014 own admission safety; D-061 requires serialized dispatch without head bypass.

## Waiting membership versus current admission eligibility
Definition: Membership preserves an accepted queue identity and priority. Eligibility determines whether that entry may receive admission now.
Why we use it: A temporary disconnect should not erase priority or require granting admission to an absent customer.
Example in this project: D-062 requires suspending expired presence while retaining the pre-admission entry and original ordinal.
Location in code: No implementation exists yet; presence deadlines, reactivation and dispatcher races need validation.
Related decisions: D-011 preserves valid priority and D-061 selects eligible entries; D-062 requires presence policy.

## Presence renewal versus reservation extension
Definition: Presence renewal records continued participation while waiting. Reservation extension would change an already issued checkout or seat deadline.
Why we use it: Heartbeats must not prolong SelectionWindow, Active Hold or Payment Reservation.
Example in this project: D-062 requires thirty-second authenticated POST renewals with a separate 120-second presence window before admission only.
Location in code: No implementation exists yet; durable receipt and clock guards remain unproved.
Related decisions: D-017/D-019 fix checkout deadlines and D-053 bounds clocks; D-062 requires a separate waiting-presence deadline.

## Heartbeat acknowledgment versus status observation
Definition: An acknowledged presence command records an owner-approved renewal. A status read observes state and does not request renewal.
Why we use it: Cache hits, browser prefetch and duplicate responses must not silently change admission eligibility.
Example in this project: D-062 requires POST presence changes retaining original renewal time; D-063 replaces individual presence receipt history with cumulative guards.
Location in code: No implementation exists yet; frequent update, receipt retention and Outbox costs need capacity modeling.
Related decisions: D-032/D-043 guard durable command effects and D-059 defines polling; D-062 requires explicit renewal commands.

## Cumulative command guard versus individual response archive
Definition: A cumulative guard records progress that older commands cannot reverse or repeat. An individual archive retains each command's original response separately.
Why we use it: Frequent presence renewals need bounded receipt storage without allowing old renewals to execute again.
Example in this project: D-063 requires a presence-only highest accepted sequence and latest receipt while preserving other D-043 receipts.
Location in code: No implementation exists yet; sequence handling, compaction and restored history require validation.
Related decisions: D-043 retains individual receipts and D-062 introduces frequent renewal; D-063 requires an explicit narrow exception.

## Superseded pulse versus new presence observation
Definition: A superseded pulse belongs to an already advanced command scope. A new observation is a newly accepted authorized renewal under the current owner guard.
Why we use it: Old request delivery must not renew eligibility after receipt compaction or suspension.
Example in this project: D-063 requires effect-free stale outcomes for lower sequences and original deadlines for matching latest retries.
Location in code: No implementation exists yet; concurrent tabs, lost responses and reactivation races remain unproved.
Related decisions: D-062 fixes original presence deadlines and D-032 guards acknowledgments; D-063 requires cumulative retry semantics.

## Ordinary failover versus rollback restore of replay evidence
Definition: Safe ordinary failover preserves acknowledged owner history. Rollback restore can expose an older counter and requires a new fenced recovery scope before commands resume.
Why we use it: A retained high-water mark cannot block old requests if recovery silently rewinds that mark.
Example in this project: D-063 requires a fresh owner-controlled presence recovery generation after reconciled snapshot restore.
Location in code: No implementation exists yet; full disaster recovery and guard cleanup remain unresolved.
Related decisions: D-031 preserves covered-fault history and D-029 treats restore separately; D-063 requires presence restore fencing.

## Coalesced projection work versus immutable event history
Definition: Projection work requests a latest complete image. Immutable event history records specific facts with stable identity and payload.
Why we use it: Repeated current-state updates need bounded delivery work without rewriting facts used for recovery or side effects.
Example in this project: D-064 requires one desired presence projection record per entry while retaining critical lifecycle Outbox events.
Location in code: No implementation exists yet; revision domains, snapshot publication and retention boundaries need validation.
Related decisions: D-024/D-026 protect immutable events and D-063 compacts pulse receipts; D-064 requires presence-only delivery specialization.

## Captured projection revision versus current desired revision
Definition: A captured revision names the snapshot a worker is delivering. A desired revision names the newest work the owner has committed.
Why we use it: A worker completing an older image must not delete newer heartbeat work.
Example in this project: D-064 requires guarded completion that leaves later desired revisions pending.
Location in code: No implementation exists yet; concurrent pulse, claim expiry and lost Redis response races need validation.
Related decisions: D-032 requires durable owner barriers and D-060 guards Redis authority; D-064 requires revision-bound completion.

## Pulse revision versus critical lifecycle revision
Definition: A pulse revision tracks replaceable presence updates. A lifecycle revision tracks distinct facts such as accepted membership or issued admission.
Why we use it: Coalescing pulses must not make critical consumers interpret intentional omission as lost event history.
Example in this project: D-064 requires separate revision domains and one complete composite queue image publication path.
Location in code: No implementation exists yet; field ownership, gaps and terminal image precedence remain unproved.
Related decisions: D-024 protects owner event order and D-061/D-062 define queue lifecycle; D-064 requires revision separation.

## Status freshness versus admission visibility delay
Definition: Freshness measures the age of a proven owner observation. Visibility delay measures how long a new issued admission takes to become readable.
Why we use it: A fast response can contain an older valid observation and still hide a new lease long enough to consume selection time.
Example in this project: D-065 requires a five-second status age bound and a separate two-second admission publication target.
Location in code: No implementation exists yet; source coverage and joint delivery traces need validation.
Related decisions: D-019 fixes selection time and D-059 bounds polling; D-065 requires private read/delivery objectives.

## Source completeness across coalesced and immutable work
Definition: A read certificate must cover every relevant owner fact, including replaceable current-state work that never became a Kafka event.
Why we use it: Kafka offsets, worker activity and an empty pending-work queue cannot prove that a Redis image matches current owner evidence.
Example in this project: D-065 requires owner cuts covering lifecycle events and coalesced presence revisions against the actual read image.
Location in code: No implementation exists yet; proof schema, bounded source work and recovery remain unproved.
Related decisions: D-057 certifies lifecycle completeness and D-064 separates pulse delivery; D-065 requires the combined read proof.

## Separate percentile objectives versus a joint delivery bound
Definition: Two operations meeting individual percentile targets do not automatically make their combined journey meet the same percentile.
Why we use it: Publication, polling, response and client transport delays can overlap with different failure sets.
Example in this project: D-065 models an 8.2-second server observation under stated per-trace bounds, without claiming a browser percentile guarantee.
Location in code: No implementation exists yet; correlated end-to-end traces and load-generator limits need validation.
Related decisions: D-009 separates user concurrency from throughput and D-033 defines failure accounting; D-065 requires delivery measurement.

## Publication completion versus certified coverage
Definition: Publication completion proves delivery of one captured image. Certified coverage proves all relevant changes through a source cut are represented in a valid read directory.
Why we use it: Clearing delivery work too early can leave the certifier without evidence that an entry changed.
Example in this project: D-066 requires a separate coalesced dirty record retained until a proven cut covers its revision.
Location in code: No implementation exists yet; cleanup, source snapshots and newer-pulse races need validation.
Related decisions: D-064 guards image publication and D-065 requires source completeness; D-066 requires retained certification evidence.

## Transactional bucket revision versus FIFO ordinal
Definition: A bucket revision tracks committed projection changes in one source bucket. A FIFO ordinal establishes accepted waiting-room priority for an occurrence.
Why we use it: Read proof partitioning must not redefine admission fairness or treat an allocated sequence number as a committed frontier.
Example in this project: D-066 requires independent transactional bucket counters without changing D-061 occurrence ordering.
Location in code: No implementation exists yet; lock order, writer coverage and commit throughput need validation.
Related decisions: D-061 controls FIFO acceptance and D-064 separates pulse/event revisions; D-066 requires source-bucket revisions.

## Merkle membership versus source completeness
Definition: Merkle membership links exact content to a committed hash root. Source completeness establishes that the root covers every relevant owner change through its claimed observation cut.
Why we use it: A valid hash proof for an incomplete directory cannot make stale status current.
Example in this project: D-066 requires immutable per-version directories built from a proven baseline and complete coalesced change manifest.
Location in code: No implementation exists yet; canonical encoding, membership paths, source proof and retained object cost need validation.
Related decisions: D-058 binds immutable availability frames and D-065 requires complete private status; D-066 requires directory membership.

## Queue acceptance latency versus checkout waiting time
Definition: Acceptance latency ends when a valid join gets its durable entry receipt. Checkout waiting time ends when that entry receives admission.
Why we use it: A burst can queue before durable acceptance, and accepted FIFO participants can then wait longer for safe checkout capacity.
Example in this project: D-067 requires separate steady and burst acceptance targets without promising admission within sixty seconds.
Location in code: No implementation exists yet; gateway buffers, owner receipts and offered-load accounting need validation.
Related decisions: D-011 defines accepted FIFO and D-061 controls durable append; D-067 requires numeric ingress objectives.

## Dispatch capacity versus completed-booking throughput
Definition: Dispatch capacity measures durable lease issuance. Completed-booking throughput also depends on inventory, checkout, provider evidence and recovery.
Why we use it: Fast waiting-room issuance can overload downstream services if treated as safe end-to-end capacity.
Example in this project: D-067 requires a dispatch-only 1,000-lease-per-second benchmark and preserves measured production admission budgets.
Location in code: No implementation exists yet; useful hold/payment throughput and controller limits remain unresolved.
Related decisions: D-010 controls admission and D-013 accounts active/unknown leases; D-067 requires a dispatch-engine floor.

## Lease residence time and capacity accounting
Definition: Residence time is how long an admission slot remains accounted before owner-proven closure. In stable flow, average occupancy depends on issuance rate multiplied by average residence time.
Why we use it: Credentials expiring cannot safely reset active or unknown capacity, and slow checkout increases required slots.
Example in this project: D-067 models about 60,000 occupied slots for 1,000 unused leases per second lasting sixty seconds, before headroom.
Location in code: No implementation exists yet; real distributions, backlog and unknown-lease tails need measurement.
Related decisions: D-013 retains unresolved slots and D-019 fixes selection time; D-067 requires measured residence-based sizing.

## Useful hold throughput versus receipt replay throughput
Definition: Useful hold throughput counts new distinct successful durable bundle allocations. Replaying the same receipt does not create another allocation.
Why we use it: Idempotency retries can make HTTP throughput look large without serving more customers.
Example in this project: D-068 requires a 1,000-new-hold-per-second floor with separate logical success and physical request metrics.
Location in code: No implementation exists yet; client receipt, commit and unknown-outcome correlation need validation.
Related decisions: D-043 separates receipts from current state and D-067 measures queue capacity; D-068 requires useful hold throughput.

## Authoritative conflict versus coordination refusal
Definition: An authoritative conflict establishes that owner state prevents allocation. Coordination refusal only says the attempt could not safely proceed through its current resource gate.
Why we use it: A failed Redis lock cannot prove that another customer has a valid seat reservation.
Example in this project: D-068 requires proof-based conflict reporting and counts valid-load unavailable outcomes as failures.
Location in code: No implementation exists yet; conflict decision points and contention latency need validation.
Related decisions: D-002 makes Inventory authoritative and D-060 retains advisory coordination; D-068 requires conflict measurement rules.

## Safety history versus a final database snapshot
Definition: Safety history tracks valid ownership transitions over time. A final snapshot shows only the remaining state.
Why we use it: Two overlapping holds might later expire and disappear from a final count.
Example in this project: D-068 requires independent reconciliation of complete owner receipts, bundle transitions, generations and original deadlines.
Location in code: No implementation exists yet; evidence completeness and the correctness oracle need validation.
Related decisions: D-001 defines allocation exclusion and D-024/D-026 retain lifecycle facts; D-068 requires history-based validation.

## Local payment capacity versus provider capability evidence
Definition: Local capacity measures TicketForge processing under stated external responses. Provider capability evidence establishes what the real gateway actually supports.
Why we use it: A test double can generate high traffic but cannot establish sandbox quotas, monetary replay safety or settlement behavior.
Example in this project: D-069 requires isolated high-load simulation plus separate actual SSLCOMMERZ sandbox contract tests.
Location in code: No implementation exists yet; provider test adapter, observed contracts and network isolation need validation.
Related decisions: D-005 selects sandbox-only integration and D-035 gates monetary replay; D-069 requires supplemental simulation.

## Pending checkout acceptance versus payment readiness
Definition: Pending acceptance stores the request and recovery intent. Payment readiness requires a proven eligible reservation and safe provider prerequisites.
Why we use it: A fast HTTP 202 does not mean seat conversion or payment initiation has completed.
Example in this project: D-069 requires separate acceptance, conversion and actual dispatch timing objectives.
Location in code: No implementation exists yet; lifecycle timestamps and original-deadline accounting need validation.
Related decisions: D-044 defines pending checkout and D-047 separates receipt from verification; D-069 requires journey timing.

## Verified charge evidence versus refund settlement
Definition: Verified charge evidence establishes known money. A refund obligation or processing refund does not establish completed return of that money.
Why we use it: Internal Saga throughput and provider settlement are different outcomes with different proof and timing.
Example in this project: D-069 requires local confirmation/refund-obligation floors without a promised external settlement deadline.
Location in code: No implementation exists yet; charge/refund state evidence and provider delays need measurement.
Related decisions: D-023 retains charge-level accounting and D-034 bounds actionable recovery; D-069 requires performance evidence boundaries.

## Active users versus offered requests and network bytes
Definition: Active users describe concurrent participation. Offered requests describe work scheduled to arrive, and network bytes describe the cost of delivering responses.
Why we use it: The same user count can produce very different load depending on polling, visible sections, response changes and payload size.
Example in this project: D-070 requires a mixed 380,000-public-request profile and a separate two-million-section-request profile, before positive jitter.
Location in code: No implementation exists yet; client workload, wire encoding and generator capacity need validation.
Related decisions: D-009 keeps 1M active users and D-059 bounds polling; D-070 requires explicit public traffic profiles.

## Conditional body reuse versus frame cache hits
Definition: A 304 response lets a client reuse matching representation bytes. A frame cache hit lets a server avoid fetching those bytes again.
Why we use it: These save different work. Neither establishes current owner evidence or a complete source cut.
Example in this project: D-070 requires separate measurements for HTTP body reuse, local frame hits, actual origin reads and proof verification.
Location in code: No implementation exists yet; cache keys, source/control age and conditional responses need validation.
Related decisions: D-056 requires certified freshness and D-058/D-059 bind frames and HTTP validators; D-070 requires capacity evidence.

## Discovery observation versus permission to purchase
Definition: Discovery describes published event information observed at a source cut. Permission to purchase depends on current authoritative allocation and admission guards.
Why we use it: A search card can remain visible while its price changes or cancellation propagates.
Example in this project: D-071 requires thirty-second catalog freshness while Inventory retains two-second availability proof and authoritative hold checks.
Location in code: No implementation exists yet; discovery frontiers, reader binding and stale-version handling need validation.
Related decisions: D-021 fixes the held quote and D-051 separates publication from activation; D-071 requires discovery semantics.

## Query visibility versus index acknowledgment
Definition: An index acknowledgment reports write processing. Query visibility means the reader used for a search can actually observe the required changes.
Why we use it: Pending Outbox changes, refresh delay or a missing shard can leave incomplete results despite successful index writes.
Example in this project: D-071 requires proof of complete source coverage in the actual queried index view.
Location in code: No implementation exists yet; refresh, index generations and query-bound evidence need validation.
Related decisions: D-024 separates receipt from applied effects and D-057 proves source completeness; D-071 requires search evidence.

## Complete occurrence summary versus independently timed section counts
Definition: A complete summary describes all offered seats from one owner-consistent source cut. Separate section observations may represent different times.
Why we use it: Adding individually fresh counts does not establish one coherent event-wide total.
Example in this project: D-071 requires certified whole-occurrence counts and UNKNOWN when their required proof is missing.
Location in code: No implementation exists yet; summary scope, production algorithm and contention cost need validation.
Related decisions: D-056 bounds advisory availability and D-058 separates section cuts; D-071 requires summary truth.

## Pinned search reader versus complete source coverage
Definition: A pinned reader keeps one index view stable. Complete coverage proves that the view includes every required owner fact through a source cut.
Why we use it: A stable PIT can still be missing an unpublished event, document update or withdrawn listing.
Example in this project: D-072 requires auditing the candidate PIT against an independently built complete owner document set before serving it.
Location in code: No implementation exists yet; canonical readback, exact scope and PIT lineage need validation.
Related decisions: D-057 defines source completeness and D-071 requires query-visible coverage; D-072 requires reader binding.

## Search cursor lifetime versus observation freshness
Definition: A cursor identifies the view and boundary for another page. Its transport or storage lifetime cannot establish a newer owner observation.
Why we use it: Keeping an old search context alive can preserve consistent pages while their source proof expires.
Example in this project: D-072 requires original-cut expiry, explicit search restart and separate handling of platform-created delays.
Location in code: No implementation exists yet; signed cursor scope, query binding and source-age checks need validation.
Related decisions: D-040 separates signing purposes and D-071 preserves original source age; D-072 requires cursor semantics.

## Transactional striped counters versus asynchronous deltas
Definition: Transactional striped counters divide totals across fixed rows updated atomically with their source state. Asynchronous deltas can arrive late or more than once.
Why we use it: One count row can serialize all holds, while independent increment/decrement messages can drift from actual allocations.
Example in this project: D-073 requires fixed Inventory buckets and one consistent snapshot for an observed occurrence summary.
Location in code: No implementation exists yet; protected mutation routines, lock order and baseline verification need validation.
Related decisions: D-008/D-020 preserve bundle/quota atomicity and D-071 requires complete counts; D-073 defines counter production.

## Unclosed temporary allocation versus available stock
Definition: An unclosed temporary allocation remains represented in the owner ledger even when its original eligibility deadline has passed.
Why we use it: Expiry ends eligibility, but a cache timer cannot safely establish completed closure, quota release or free seats.
Example in this project: D-073 keeps such units in the temporary category until guarded owner closure or reclaim.
Location in code: No implementation exists yet; authoritative lifecycle classification and reclaim accounting need validation.
Related decisions: D-016 defines eligibility and closure, D-056 rejects TTL-based availability and D-071 requires truthful summaries; D-073 defines count classification.

## Client connections versus database backend capacity
Definition: A client connection reaches a pooler. A backend connection occupies a PostgreSQL server slot and its resources.
Why we use it: More service replicas can create more clients without creating safe writer capacity. Separate proxy limits do not establish one global database limit.
Example in this project: D-074 requires budgets that include all proxies, roles, aliases, rollout overlap and direct jobs.
Location in code: No implementation exists yet; topology, limits, enforcement and failure behavior need validation.
Related decisions: D-010 reserves accepted-work capacity and D-030 bounds deployment pools; D-074 defines enforcement.

## Recovery bulkheads versus spare connections in a shared pool
Definition: A recovery bulkhead reserves bounded resources for accepted work. Spare connections in a shared pool can still be consumed by new demand.
Why we use it: Saturated hold traffic must not prevent closure, verified confirmation or durable payment evidence ingestion.
Example in this project: D-074 requires separate trusted work classes with fixed backend shares and bounded queues.
Location in code: No implementation exists yet; resource isolation and surviving capacity need measurement.
Related decisions: D-034 protects recovery and D-060 separates new demand from accepted work; D-074 defines resource discipline.

## Order observation versus a global transaction snapshot
Definition: An order observation combines independently owned facts. It does not establish that all services were read at the same instant.
Why we use it: Saga evidence can arrive in different orders. Verified money alone cannot prove confirmed seats, and revocation alone cannot prove returned money.
Example in this project: D-075 requires independently timed Booking, Inventory and Payment components with explicit unknown fields.
Location in code: No implementation exists yet; causal evidence, source coverage and response rules need validation.
Related decisions: D-007 defines Saga ownership and D-045 requires matching fulfillment evidence; D-075 defines customer observations.

## Local payment freshness versus provider evidence age
Definition: Local freshness describes when the owner ledger was observed. Provider evidence age describes when an external payment or refund outcome was verified.
Why we use it: A fresh local snapshot can still contain an unresolved external operation or old provider evidence.
Example in this project: D-075 requires showing pending refund obligations separately from provider-confirmed outcomes without provider calls on every status read.
Location in code: No implementation exists yet; evidence timestamps, amount summaries and unknown outcomes need validation.
Related decisions: D-023 separates charges and refunds and D-034 preserves recovery age; D-075 defines read semantics.

## Certified absence versus a missing cache key
Definition: Certified absence proves that an exact key has no entry in a complete authenticated owner view. A missing cache key proves only that this lookup returned no value.
Why we use it: Lost projection data cannot safely establish a nonexistent Order or a payment that never started.
Example in this project: D-076 requires exact-key empty-leaf proofs under separately certified owner dictionaries, preserving retirement tombstones.
Location in code: No implementation exists yet; map encoding, empty-leaf proofs and owner completeness need validation.
Related decisions: D-057 requires complete source coverage and D-075 forbids cache-based absence; D-076 defines proof construction.

## Causal merge versus timestamp ordering
Definition: A causal merge checks which exact owner facts an outcome depends on. Timestamp ordering only compares reported times.
Why we use it: A later timestamp or unrelated owner revision cannot establish matching confirmation, closure or funding evidence.
Example in this project: D-076 requires immutable receipt references and separate owner revision minima during Booking facade reads.
Location in code: No implementation exists yet; dependency matching, generation recovery and bounded readback need validation.
Related decisions: D-024 forbids assumed cross-owner Kafka ordering and D-045 binds fulfillment evidence; D-076 defines read-time merging.

## Eligibility expiry versus resource closure lag
Definition: Eligibility expiry ends permission to convert or confirm. Resource closure lag measures the delay until the owner commits the guarded terminal transition.
Why we use it: A deadline cannot itself release seats, quota or a claimed admission slot. Delayed cleanup must not create extra checkout time.
Example in this project: D-077 requires separate Inventory closure and Waiting Room slot-retirement targets measured from original source times.
Location in code: No implementation exists yet; due-work durability, worker fencing and progress metrics need validation.
Related decisions: D-016/D-053 govern deadline safety and D-073 retains unclosed temporary stock; D-077 defines closure progress.

## Scheduling claim versus permission to close an allocation
Definition: A scheduling claim selects which worker may process due work. It does not establish that a business transition is eligible or safe.
Why we use it: A lost worker or expired work lease cannot release a newer reservation or prove a previous transaction failed.
Example in this project: D-077 requires short metadata claims followed by independent canonical owner guards and same-identity recovery.
Location in code: No implementation exists yet; task revisions, receipts, lock order and deferred outcomes need validation.
Related decisions: D-015 protects delayed allocation and D-032/D-043 preserve unknown commands; D-077 defines scheduler semantics.

## Ticket artifact versus current seat entitlement
Definition: A ticket artifact records a confirmed purchase. Current seat entitlement describes the seat rights that still exist under the allocation owner.
Why we use it: A saved document survives cancellation and cannot establish current rights by itself.
Example in this project: D-078 requires one stable Ticket per confirmed Event Seat, with current status shown separately.
Location in code: No implementation exists yet; issuance and retrieval need validation, while artifact formats and rendering budgets remain unresolved.
Related decisions: D-007/D-045 govern confirmation, D-048 governs revocation, D-075 governs observations and D-078 defines ticket issuance.

## Per-seat ticket identity versus whole-bundle cancellation
Definition: Individual ticket identities describe separate seats. They do not imply that the order permits separate cancellation or ownership transfer.
Why we use it: Rendering several tickets must not bypass the complete Seat Bundle's lifecycle rules.
Example in this project: D-078 requires four stable Ticket records for a four-seat order while retaining D-048 whole-bundle cancellation.
Location in code: No implementation exists yet; identity binding, duplicate issuance and stale artifact behavior need validation.
Related decisions: D-008/D-048 preserve bundle transitions; D-078 defines per-seat records and D-079 separately adds online venue check-in.

## Exclusive allocation versus single-use venue check-in
Definition: Exclusive allocation prevents competing rights to the same Event Seat. Single-use check-in prevents repeated authorization to enter using one ticket.
Why we use it: Correct booking does not by itself stop copied artifacts from being presented at two gates.
Example in this project: D-079 selects online owner-serialized per-ticket check-in as an explicit scope addition.
Location in code: No implementation exists yet; credential, policy, operating and performance contracts await decisions.
Related decisions: D-001/D-008 protect allocation, D-078 defines ticket records and D-079 defines check-in authority.

## Durable check-in outcome versus physical passage
Definition: A durable check-in outcome records a server decision. Physical passage is a person's actual movement through a staffed or automated gate.
Why we use it: A database transaction cannot prove whether a person walked through after a response was lost.
Example in this project: D-079 requires same-command recovery without granting a second check-in or claiming control of physical passage.
Location in code: No implementation exists yet; staff/device authorization, outcome recovery and gate operations remain unresolved.
Related decisions: D-032/D-043 protect unknown outcomes; D-079 defines venue scope without redefining physical events as exactly-once effects.

## Bearer entry credential versus attendee identity
Definition: A bearer credential can be presented by whoever holds its secret. A named-attendee policy also checks who the person is.
Why we use it: Cryptographic randomness and single use cannot distinguish a voluntarily shared copy from a stolen copy.
Example in this project: D-080 selects per-seat bearer QR credentials while the purchaser retains account ownership and cancellation rights.
Location in code: No implementation exists yet; enrollment, secret delivery, reissue and staff checks need validation.
Related decisions: D-078 separates Ticket identifiers from authorization, D-079 adds check-in and D-080 selects the bearer policy.

## Credential reissue versus ticket identity and first-use reset
Definition: Reissue replaces the secret accepted for an existing ticket. It does not create another ticket or undo recorded first use.
Why we use it: Replacing a compromised QR must not allow both versions to work or reactivate a consumed ticket.
Example in this project: D-080 requires atomic version replacement serialized with check-in and revocation under Inventory authority.
Location in code: No implementation exists yet; reissue authentication, payload recovery and stale-artifact behavior need validation.
Related decisions: D-032/D-043 preserve unknown outcomes, D-079 preserves single use and D-080 defines guarded reissue.

## Admission Window versus Sales Window
Definition: An Admission Window governs first venue entry. A Sales Window governs creating new seat holds.
Why we use it: Ending sales does not cancel confirmed tickets or establish that a venue is ready to admit people.
Example in this project: D-081 requires approved finite entry times within venue occupancy, separately guarded from sale opening and closing.
Location in code: No implementation exists yet; occurrence policy, version binding and clock guards need validation.
Related decisions: D-051/D-052 define occurrence and sales policy, D-053 governs time and D-081 defines entry policy.

## Used-seat fence versus cancellation and resale
Definition: A used-seat fence preserves the fact that an Event Seat has already authorized entry. Cancelling monetary or booking entitlement does not erase that use.
Why we use it: A fresh allocation or QR must not offer the same occurrence seat again after someone used it.
Example in this project: D-081 requires no voluntary cancellation when any bundle ticket is used and no resale of a Used Event Seat.
Location in code: No implementation exists yet; canonical guards, summary classification and recovery need validation.
Related decisions: D-048/D-049 govern whole-bundle cancellation, D-079 governs first use and D-081 preserves used-seat protection.

## Staff assignment versus scanner proof of possession
Definition: A staff assignment grants a person scoped gate permission. Scanner proof of possession shows control of an enrolled software key.
Why we use it: A device ID string or customer token cannot establish gate authority, and a software key cannot prove trustworthy hardware or human identity by itself.
Example in this project: D-082 requires named staff MFA, scoped gate assignments and session-bound signed scanner requests.
Location in code: No implementation exists yet; enrollment, signed-request profiles, policy freshness and takeover require validation.
Related decisions: D-036/D-040/D-041 define scoped authority; D-079 adds check-in and D-082 scopes staff/scanner authority.

## Check-in receipt versus permission indication and passage acknowledgement
Definition: A receipt records the owner outcome. An indication tells staff how to handle the current attempt, while an acknowledgement records their report of physical passage.
Why we use it: Replaying a success receipt must not display a new entry permission, and a staff report does not prove physical movement.
Example in this project: D-082 requires a durable scanner lane and metadata journal with no automatic green indication after recovery uncertainty.
Location in code: No implementation exists yet; lane fencing, client crashes, acknowledgement and supervisor recovery need validation.
Related decisions: D-032/D-043 recover commands, D-079 separates passage and D-081 prohibits use reset; D-082 governs conservative lane recovery.

## Useful gate throughput versus API response throughput
Definition: Useful gate throughput counts fresh first-use outcomes followed by matching durable passage reports. API response throughput also includes copies, rejections and historical retries.
Why we use it: Fast repeated receipts can hide stalled lanes and cannot prove attendees can enter at that rate.
Example in this project: D-083 requires 200 completed lane cycles/s and separately accounts for a 1,000-attempts/s stress test.
Location in code: No implementation exists yet; scanner, offered-load and owner durability measurements remain unproved.
Related decisions: D-079/D-082 define first use and lane recovery; D-083 selects useful throughput and enrollment readiness objectives.

## Credential readiness versus artifact and notification delivery
Definition: Credential readiness means the enrolled version is durably active and privately retrievable. A PDF or message may arrive separately.
Why we use it: A confirmed Booking or rendered QR alone cannot establish an active credential, and delayed email cannot redefine first-use authority.
Example in this project: D-083 requires a two-second enrollment/retrieval objective from original confirmation, with PDF and notification budgets decided separately.
Location in code: No implementation exists yet; enrollment, protected delivery and end-to-end evidence remain unproved.
Related decisions: D-078/D-080 define Ticket issuance and enrollment; D-083 selects useful throughput and enrollment readiness objectives.

## Artifact version binding versus current entry authority
Definition: Version binding records which enrolled credential and occurrence policy an artifact represents. Current entry authority is the owner's guarded decision at the gate.
Why we use it: A saved PDF cannot update itself when its credential is replaced, its seat is used or its entitlement is cancelled.
Example in this project: D-084 requires private version-bound QR/PDF delivery with bounded fresh owner evidence and no claim that printed bytes are current permission.
Location in code: No implementation exists yet; delivery proof coverage, rendering and independent QR validation remain unproved.
Related decisions: D-078/D-080/D-081 preserve Ticket and credential rules; D-084 defines private version-bound artifacts and isolated rendering.

## Regenerable artifact cache versus durable enrollment
Definition: An artifact cache holds reproducible encrypted output. Durable enrollment owns the credential/version that regeneration must preserve.
Why we use it: Losing a PDF must not rotate an entry secret, create another Ticket or move a render job into the payment transaction.
Example in this project: D-084 requires bounded isolated render work and disposable encrypted output caches backed by existing owner source records.
Location in code: No implementation exists yet; exact storage placement remains pending; resource limits and failure recovery remain unproved.
Related decisions: D-074/D-083 protect capacity and D-080 owns enrollment; D-084 defines private version-bound artifacts and isolated rendering.

## Logical notification identity versus SMTP delivery
Definition: Logical identity deduplicates a local notice and its channel work. SMTP submission can still produce multiple external copies after an unknown acknowledgement.
Why we use it: Replayed business events must not create new jobs, but a stable Message-ID cannot promise recipient-side exactly-once delivery.
Example in this project: D-085 requires one intent per owner transition/channel and explicit unknown versus relay-accepted email states.
Location in code: No implementation exists yet; channel authority and duplicate recovery remain unproved.
Related decisions: D-024/D-032 define durable receipt handling; D-085 defines durable historical notices and honest channel outcomes.

## Historical notification versus current Order Observation
Definition: A historical notification describes an original owner fact at its recorded time. Current Order Observation reports later workflow, entitlement and monetary evidence separately.
Why we use it: Email can arrive after cancellation and cannot recall its already delivered content or authorize entry.
Example in this project: D-085 requires historical confirmation wording, known supersession and trusted private status links without QR or secret attachments.
Location in code: No implementation exists yet; source evidence and in-app delivery remain unproved; contact routing is pending.
Related decisions: D-075/D-076 define current private status and D-084 defines artifacts; D-085 defines durable historical notices and honest channel outcomes.

## Contact revision binding versus mutable email address
Definition: Contact revision binding identifies the exact Auth-owned destination and purpose allowed for one dispatch. A mutable email string alone cannot establish that authority.
Why we use it: Changing a customer's address must not redirect an email that may already have been submitted or move an old reset challenge.
Example in this project: D-086 requires fresh Auth routing evidence, frozen unknown-attempt recipients and no automatic redirect after possible submission.
Location in code: No implementation exists yet; contact, grant and dispatch guards remain unproved.
Related decisions: D-037 owns identity, D-038 bounds authority freshness and D-085 owns mail attempts; D-086 defines exact routing and fixed security challenges.

## Fixed challenge lifetime versus resend and delivery time
Definition: A challenge's lifetime starts at original Auth issuance. Resending or receiving its email is separate and cannot renew that lifetime.
Why we use it: Queue delays or unauthenticated resend requests must not extend a reset secret or invalidate a victim's still-valid link.
Example in this project: D-086 requires same-secret active-flow resend, fifteen-minute reset and thirty-minute verification/change flow lifetimes.
Location in code: No implementation exists yet; protected delivery, purpose guards and time checks remain unproved.
Related decisions: D-037 governs recovery tokens, D-053 governs time and D-086 defines exact routing and fixed security challenges.

## Canonical mailbox key versus provider alias and person
Definition: A canonical mailbox key compares addresses under one explicit identity profile. A provider alias or shared mailbox can still map several different keys to one mailbox or person.
Why we use it: Inconsistent folding can choose the wrong account, while alias removal cannot establish unique people or fair purchase quotas.
Example in this project: D-087 requires domain normalization with preserved semantic local-part case/bytes and no provider dot/tag transformations.
Location in code: No implementation exists yet; parser/profile vectors, identity claims and transport capabilities remain unproved.
Related decisions: D-012 defines account-level fairness and D-037 stable identity; D-087 defines explicit mailbox claims and retired-address guards.

## Retired contact guard versus current mailbox control
Definition: A retired guard preserves an old account's contact history and blocks automatic reuse. Current mailbox control does not prove ownership of that historical account.
Why we use it: Changing an address must not let a later mailbox holder register or resurrect the former customer's account history.
Example in this project: D-087 requires retained protected guards and same-account rebind only through current guarded change evidence.
Location in code: No implementation exists yet; reuse and provisional activation remain unproved; D-088 selects independent recovery policy, with implementation unproved.
Related decisions: D-037/D-086 govern contact authority; D-087 selects contact comparison/reuse; D-088 adds prior evidence for currently recycled mailbox recovery.

## Prior recovery evidence versus current mailbox access
Definition: Prior evidence was bound to the account before recovery, such as an enrolled authenticator or saved recovery code. Current mailbox access may belong to a later holder.
Why we use it: A valid reset email alone cannot distinguish a historical customer from the new holder of a recycled mailbox.
Example in this project: D-088 requires mandatory offline kits and email-plus-prior-evidence reset, with scoped lost-mailbox recovery.
Location in code: No implementation exists yet; authenticator, code and recovery guards remain unproved.
Related decisions: D-037/D-086/D-087 preserve identity; D-088 defines MFA and independent recovery policy.

## Recovery preparation versus restored account authority
Definition: Preparation collects exact evidence and stages a replacement. Restored authority begins only after the guarded final change and normal authentication.
Why we use it: A recovery workflow must not clear MFA temporarily or give a partial replacement access to bookings or privileged actions.
Example in this project: D-088 requires one atomic finalization, retained owner guards and no guaranteed restoration without prior evidence.
Location in code: No implementation exists yet; flow capabilities, finalization and recovery failure paths remain unproved.
Related decisions: D-032/D-043 preserve unknown outcomes and D-036 scopes privileged work; D-088 defines MFA and independent recovery policy.

## Channel readiness versus mailbox delivery and reading
Definition: Channel readiness records durable intent, private feed visibility or configured relay acceptance. Mailbox placement and human reading require different external evidence.
Why we use it: A sender success counter cannot establish actual recipient delivery or useful in-app history.
Example in this project: D-089 requires separate 2/5/10/30-second readiness objectives with fault and unknown-outcome accounting.
Location in code: No implementation exists yet; feed proof, transport evidence and channel SLOs remain unproved.
Related decisions: D-085/D-086 define notices and exact routing; D-089 defines separate channel readiness and protected mail recovery.

## Protected mail scheduling versus challenge expiry and catch-up
Definition: Protected scheduling reserves finite resources for a class of work. It cannot override an original secret expiry or an uncertain attempt's retry not-before.
Why we use it: Catch-up traffic must not send expired links, change recipients or consume finance and gate reserves.
Example in this project: D-089 requires security/business shares, conservative backoff and separate pre-submission versus unknown-outage drain tests.
Location in code: No implementation exists yet; quota enforcement, backlog storage and expiry/recovery remain unproved.
Related decisions: D-074/D-083 protect resources, D-086 fixes challenges and D-088 governs recovery; D-089 defines separate channel readiness and protected mail recovery.

## Session renewal workload versus password-login workload
Definition: Renewal maintains existing session authority and strict refresh lineage. A fresh password login performs memory-hard credential verification and may need MFA.
Why we use it: Counting only JWT signature checks cannot prove a million active users retain current authority without login storms exhausting resources.
Example in this project: D-090 requires 50,000 useful fresh-enough proof deliveries/s and 5,000 durable rotations/s with separate login/onboarding profiles.
Location in code: No implementation exists yet; source-proof publication and enforcement remain pending; measured capacity remains unproved.
Related decisions: D-038/D-039 define proof/refresh semantics and D-088 assurance; D-090 defines separate useful Auth floors and bounded abuse profiles.

## Authentication throttling versus account authority revocation
Definition: Throttling bounds attempts and resource use. Authority revocation is a guarded security change, not an automatic permanent account lock caused by anonymous failures.
Why we use it: Attackers must not reset counters with new request IDs or permanently disable victims through password guesses, and shared IPs are not single users.
Example in this project: D-090 requires account/factor and resource budgets with protected active-session/revocation paths and shared-network tests.
Location in code: No implementation exists yet; consistency/failure enforcement remains pending; classification remains unproved.
Related decisions: D-037/D-060/D-074/D-088 preserve guarded authority and resource limits; D-090 defines separate useful Auth floors and bounded abuse profiles.

## Certified security observation versus credential issuance
Definition: A certified observation reports Auth state at an original primary cut. Credential issuance changes or establishes guarded authority and still needs the owner transaction.
Why we use it: A stale cache, signed map or recently refreshed token must not mint another session or fabricate current MFA evidence.
Example in this project: D-091 selects complete Auth cuts and bounded compact observations while keeping mutation/refresh/recovery guards primary-owned.
Location in code: No implementation exists yet; source writer coverage, proof profiles and recovery remain unproved.
Related decisions: D-038 defines observation freshness and D-076 complete source cuts; D-091 selects certified observation and primary grant boundaries.

## Original authentication time versus refresh and source observation time
Definition: Authentication time records the successful password/factor ceremony. Refresh and a later source cut are different events and cannot make that ceremony recent again.
Why we use it: Enrolled MFA, current account state or new timestamps cannot prove the current session completed a required fresh factor.
Example in this project: D-091 selects exact session assurance context and separate source/time fields checked at owner guards.
Location in code: No implementation exists yet; assertion encoding, scope checks and time substitution tests remain unproved.
Related decisions: D-039/D-082/D-088 define session/MFA behavior and D-090 useful load; D-091 preserves original authentication and source ages.

## Rolling attempt budgets versus cache counters
Definition: A rolling budget covers attempts in the preceding interval. A cache counter can shed requests but cannot recover allowance lost through rollback or restart.
Why we use it: New request IDs, fixed-window boundaries and Redis loss must not create more password or low-entropy factor guesses.
Example in this project: D-092 selects durable account/purpose/factor attempt guards with conservative pending reservations and Redis admission coordination.
Location in code: No implementation exists yet; attempt locking, recovery and capacity remain unproved.
Related decisions: D-090 sets attempt limits and D-060 separates Redis from durable authority; D-092 selects rolling guards and safe reopening.

## Resource permission expiry versus physical work completion
Definition: A permission deadline stops new work authorization. It does not prove an existing hash, database backend or transport job has stopped consuming resources.
Why we use it: Releasing a slot on timeout can overlap old and replacement workers and exceed protected memory or CPU shares.
Example in this project: D-092 selects finite fenced worker shares and slot release only after proved completion or physical resource fencing.
Location in code: No implementation exists yet; worker termination, rollout overlap and enforcement remain unproved.
Related decisions: D-074 bounds aggregate backends and D-089 live mail slots; D-090 protects Auth resources; D-092 selects physical completion and share fencing.

## Deployment profile versus proved system capability
Definition: A profile describes placement and resource settings. A capability is supported only by evidence under the stated load and failure model.
Why we use it: Running all components or setting replica counts does not prove independent host recovery, full throughput or long-term availability.
Example in this project: D-093 selects separate local, Oracle-free and production-reference profiles with the same domain contracts and explicit readiness gaps.
Location in code: No implementation exists yet; topology, complete-stack fit and cloud quotas remain unproved.
Related decisions: D-003/D-025/D-030/D-031 require durability and independent placement; D-093 selects profiles and capability evidence.

## Replica count versus independent failure placement
Definition: Multiple replicas can fail together when they share a host, storage dependency or control authority. Their placement must match the declared fault model.
Why we use it: Three same-host containers cannot establish a surviving durable copy after that host is lost.
Example in this project: D-093 selects verified production placement and separate labels for local simulated failures and actual independent-host tests.
Location in code: No implementation exists yet; failure-domain inventory, survivor capacity and fencing remain unproved.
Related decisions: D-025/D-031/D-058 define independent replicas and D-033 safe survivor progress; D-093 preserves these floors across profiles.

## Leader election versus physical writer fencing
Definition: Election selects control authority. Fencing proves an old writer cannot continue committing, including through existing connections or a paused process that resumes.
Why we use it: An expired lease or removed route alone does not stop PostgreSQL and can leave two writable histories.
Example in this project: D-094 selects majority-backed Patroni control plus a mandatory independent pre-promotion fence gate.
Location in code: No implementation exists yet; fencing adapter, incarnation inventory and fault tests remain unproved.
Related decisions: D-031 requires safe promotion and D-092 physical consumer fencing; D-094 selects concrete control, promotion and write-readiness gates.

## Strict synchronous replication versus verified command durability
Definition: Strict mode keeps synchronous replication required when replicas disappear. Each command must still prove its own commit or recover through the accepted logged barrier.
Why we use it: Cancelled synchronous waits can leave visible rows without proving replicated durability, even with strict HA configuration.
Example in this project: D-094 selects strict Patroni settings and continued D-032 barriers before recovered results or external effects.
Location in code: No implementation exists yet; settings enforcement, driver behavior and promotion readiness remain unproved.
Related decisions: D-003/D-031 require durable acknowledged history and D-032 command barriers; D-094 preserves these alongside complete write-readiness checks.

## Restore consistency versus irreversible business history
Definition: A restored database can be internally consistent while missing later payments, allocations, security changes or one-use entry decisions.
Why we use it: Replaying an old snapshot cannot undo external money movement or establish that a missing effect never happened.
Example in this project: D-095 selects isolated owner restores and independently justified reconciliation before affected authority or effects reopen.
Location in code: No implementation exists yet; backup chains, restore fencing and reconciliation remain unproved.
Related decisions: D-026/D-029 preserve critical history and isolated restore and D-094 fences writers; D-095 selects PITR and business-safe restore.

## Archive recovery lag versus permission to lose safety guards
Definition: Archive lag bounds the age of independently recoverable data. It does not permit double allocation or reuse of missing consumed credentials.
Why we use it: A regional archive RPO can leave a lost suffix whose business meaning remains unknown and must be fenced.
Example in this project: D-095 selects complete archive frontiers and broad quarantine when safety history cannot be proved; regional targets follow separately.
Location in code: No implementation exists yet; complete archive frontier, restore generations and recovery capacity remain unproved.
Related decisions: D-003/D-033 keep covered host RPO/RTO and all SLOs; D-095 forbids treating archive lag as permission to reset guards.

## Regional acknowledged-history protection versus async archive freshness
Definition: Independently durable regional history protects acknowledged work or exposed authority. A fresh asynchronous archive can still omit the last unshipped effects.
Why we use it: An acceptable bulk archive lag cannot make missing allocation, money, credential or one-use history safe to reopen.
Example in this project: D-096 selects regional RPO zero for externally exposed/admitted authoritative history and separate sixty-second bulk archive coverage.
Location in code: No implementation exists yet; remote durability, complete histories and read/publication barriers remain unproved.
Related decisions: D-003 protects acknowledged host-loss history and D-095 safe restore; D-096 explicitly extends the regional scope.

## Safe-service recovery time versus restore or quarantine completion
Definition: Safe recovery restores sustained useful operations under the declared load and required guards. Starting databases or quarantining scopes is only a recovery step.
Why we use it: A four-hour recovery objective cannot be counted as met while previously eligible affected users still cannot use required services.
Example in this project: D-096 selects an explicit regional four-hour safe-service target with per-class useful readiness and counted blocked operations.
Location in code: No implementation exists yet; warm recovery capacity, fencing and complete authority restoration remain unproved.
Related decisions: D-033 keeps thirty-second covered-host recovery and thirty-day availability and D-095 safe restore; D-096 selects separate regional objectives.

## Post-commit WAL boundary versus an in-transaction marker
Definition: An in-transaction WAL record can exist before its commit record. A conservative post-commit boundary can cover the completed transaction only within the proved same writer history.
Why we use it: Remote storage of a marker alone must not be mistaken for a recoverable committed allocation or consumed guard.
Example in this project: D-097 captures the committed WAL prefix on the same pinned backend and requires two of three off-region receivers to flush it.
Location in code: No implementation exists yet; driver behavior, capture lane and proof encoding remain unproved.
Related decisions: D-032 requires logged durable barriers; D-096 defines regional protection and D-097 selects its coverage gate.

## Remote WAL durability versus permission to execute a command
Definition: WAL coverage proves recoverable bytes in a particular history. It does not authorize another verification, provider call, credential issue or ticket use.
Why we use it: A signed durability proof must not become a reusable business execution token or a way to renew a deadline.
Example in this project: D-097 requires the remote gate before protected phase work and again before its result or external effect is exposed.
Location in code: No implementation exists yet; receiver identity, complete storage continuity and phase enforcement remain unproved.
Related decisions: D-043 preserves exact command semantics; D-095 current restore authority; D-096 regional scope; D-097 remote coverage.

## Control quorum versus data recovery cohort
Definition: The control quorum agrees on current membership and recovery generation. The data cohort stores PostgreSQL WAL; neither one proves the other's state.
Why we use it: A healthy controller cannot recreate missing WAL, and complete WAL cannot prove who may promote or fence writers.
Example in this project: D-098 places one etcd voter per site while D-097 independently requires two of three WAL receivers in a remote site cohort.
Location in code: No implementation exists; quorum and cohort membership are not yet enforced.
Related decisions: D-094 fencing, D-097 WAL coverage and D-098 three-site control quorum.

## Control snapshot versus authority journal
Definition: An etcd snapshot is a point-in-time control state. A separate monotonic journal records later authority changes needed to reconcile that snapshot.
Why we use it: A restored snapshot may predate a fence, membership retirement or recovery-generation change.
Example in this project: D-099 requires both histories and physical fencing before starting a new etcd cluster after permanent quorum loss.
Location in code: No implementation exists; snapshot, journal and reconciliation are not yet implemented.
Related decisions: D-036 operator recovery, D-094 fencing, D-098 membership and D-099 quorum-loss recovery.

## Journal prepare versus applied control state
Definition: A prepare records the exact authorized control command before etcd applies it; an outcome records what etcd later proved. An unknown reply does not settle either state.
Why we use it: A crash between two systems can leave the journal and etcd at different points.
Example in this project: D-100 freezes the same command ID and reconciles both histories before another control mutation advances.
Location in code: No implementation exists; journal ordering and reconciliation remain pending.
Related decisions: D-098 quorum membership, D-099 control restore and D-100 journaled mutations.

## All-site journal acknowledgement versus quorum acknowledgement
Definition: An all-site acknowledgement means every independent journal copy durably stored a record. A quorum acknowledgement can leave a surviving site without that record.
Why we use it: Recovery after losing a quorum needs the last surviving site to retain every fully accepted control change.
Example in this project: D-101 requires three normal copies; D-102 permits an exact single-site recovery plan prepared at both verified survivors before fencing.
Location in code: No implementation exists; copy durability and the emergency path remain unproved.
Related decisions: D-098 native control quorum, D-100 journal semantics, D-101 normal all-site copies and D-102 scoped survivor recovery.

## Survivor journal evidence versus native control quorum
Definition: Survivor journal copies retain the exact approved recovery plan. Native etcd quorum separately controls generation and membership; journal receipts do not alter its voting rules.
Why we use it: Physical fencing and complete history must precede promotion even when a recovery prepare was accepted by two surviving sites.
Example in this project: D-102 preserves native majority and phase identities, then safely rebuilds a returning site instead of trusting its older journal.
Location in code: No implementation exists; journal, fence and re-enrollment evidence remain unproved.
Related decisions: D-094 promotion, D-098 control quorum, D-100 prepare ordering and D-102 survivor recovery.

## Code completion versus proved system capability
Definition: Complete code implements the required contracts and harnesses. Proved capability needs actual results for the declared load, fault, infrastructure and transport.
Why we use it: Forty-eight hours of coding, a rendered manifest or a simulated site cannot establish one-million capacity, regional durability or thirty-day availability.
Example in this project: Review 104 proposes full implementation plus explicit NOT RUN/UNVERIFIED/FAILED readiness evidence for later campaigns.
Location in code: No implementation exists; the delivery package and validation matrix are review artifacts.
Related decisions: D-033 availability/recovery, D-093 profiles, D-097 remote coverage, D-103 Go; Review 104 final package awaits acceptance.

## Tracer-bullet ticket and blocking edge
Definition: A tracer-bullet ticket delivers a narrow verifiable path through its required layers. A blocking edge names work that must complete first.
Why we use it: Fresh implementation sessions can take ready work without losing accepted contracts or starting dependencies too early.
Example in this project: BK-008 joins atomic Inventory entitlement with durable Waiting Room claims; both must be ready.
Location in code: GitHub issues linked in IMPLEMENTATION_STATUS.md; no application implementation exists yet.
Related decisions: D-104; ask-matt routes through to-spec, to-tickets, implement, TDD and code review.

## Minimum Go version versus selected toolchain
Definition: The go directive rejects older compilers. A specific GOTOOLCHAIN value selects the exact compiler for a command.
Why we use it: Reproducible builds must not silently use another installed compiler.
Example in this project: scripts/go.ps1 forces go1.27.2 and then restores the caller's prior environment.
Location in code: scripts/go.ps1 and scripts/doctor.ps1.
Related decisions: D-103, D-104. Official source: https://go.dev/doc/toolchain.
