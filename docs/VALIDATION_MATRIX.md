# TicketForge correctness, capacity and readiness validation

## Status and execution boundary
Every test/capacity result in this document is NOT RUN. This is the final-review acceptance matrix, not a validation report.
Build these harnesses during implementation. Focused component checks accompany code; full local deployment, integration, load and failure campaigns follow Day 2.
Record profile, build/dependency digests, native topology, data size, actual physical placement, clock/storage evidence, duration, offered/completed/useful rates, tails and failure timeline for each result.
Use PASSED, FAILED, UNVERIFIED and explicitly SIMULATED evidence. A model or configuration is never labelled a passed physical fault/1M test.

## Original requirements traceability
| Requirement | Required evidence | Accepted contract |
| --- | --- | --- |
| Zero overselling/double booking | Independent accepted-history oracle and native invariant/fault tests | D-001–D-003, D-008, D-015–D-017, D-031–D-032 |
| Million concurrent users | Full offered workload, staged measured capacity and explicit scale gaps | D-009–D-010, D-067–D-070, D-090 |
| Hold p99 below 200 ms | Entire Gateway operation including authorization, locks, local/remote durability and queues | D-009, D-068, D-097 |
| 99.9% availability | Per-class thirty-day eligible logical operations, including eligible refusals and faults | D-033, D-065, D-075, D-083, D-089–D-090 |

## Functional and platform traceability
| Requirement | Evidence family |
| --- | --- |
| Browse/search/availability/Waiting Room | Read completeness/freshness, actual search PITs, FIFO/admission/presence/closure |
| Holds/booking/payment/release | Atomic bundle/quota, fixed deadlines, owner Saga, sandbox adapter, timeout/failure/compensation |
| Notification and accepted venue scope | Recipient binding, feed/capture, issuance/artifacts/reissue/use/passage/cancellation |
| PostgreSQL/Redis/Kafka/Elasticsearch | Native component tests and independent fault/read/write-history checks |
| Docker/Kubernetes/Terraform/CI/observability/k6 | Reproducible profile rendering, actual smoke deployment, measured telemetry and open-loop load |

## Independent oracle and fixture rules
Seed occurrences, accounts, holds, funding, codes, entry credentials and notices through owner commands/approved test-fixture interfaces that execute real guards, commits and Outbox history. No raw SQL sets a confirmed/use/recovery-ready state.
An external test collector records original command IDs, semantic inputs, source times, acknowledged outcomes, known external effects and uncertainty through normal interfaces. Reconcile this history with owner state after crashes; do not let the tested implementation certify itself.
Use actual PostgreSQL locks/constraints, Redis scripts, Kafka broker behavior and signed/read-back source state. Mocks isolate adapters in unit tests; they cannot prove native concurrency or durability.
Prepare enough distinct eligible accounts/seats/occurrences and real original windows for each profile. Fixture creation, scarcity refusals, abandoned clients or deliberate expiry are not counted as useful successful throughput.

## Inventory contention and time tests
Run overlapping multi-seat bundles, reordered seat IDs, duplicated commands, quota races, closure versus confirmation, stale quotes and occurrence-cancellation races. Assert whole-bundle atomicity and at most one valid allocation per Event Seat.
Delay every lock, SQL pool, Auth/source lookup and WAL gate until just before/after original hold/reservation deadlines. Use the post-lock authoritative time bounds; transaction-start time and client timestamps must not authorize expired work.
Inject commit warnings/cancellation/lost replies and late commands after WR slot retirement. Preserve the original unknown receipt; no cache TTL, missing row or rediscovery makes a seat or slot reusable.
Test overdue closure once-only counters and used/revoked category transitions without resurrecting quota, old credentials or physical venue availability.

## Redis coordination and CQRS tests
Exercise same-slot atomic scripts, owner-token renewal/release, script errors, lost WAIT responses, failover, resharding and partitions. Neither WAIT nor script atomicity supplies authoritative PG durability.
Lose coordination while hot reads continue; verify new affected demand pauses and accepted recovery retains bounded reserved work. No primary SQL flood, replacement local bucket or unbounded lookup is permitted.
Corrupt/miss frame/dictionary nodes, baselines, source coverage or actual readback. Test issued-root expiry, known higher revisions, generation retirement, wrong namespace/key, partial sections and source-time propagation.
Race GC with active readers, old roots, unknown publications and restores; missing object/reference evidence must fail closed and retain uncertain resources.

## Kafka and reliable event tests
Crash before/after owner TX, publish acknowledgement, Inbox effect and offset commit. Duplicate, reorder and replay stable events; assert one domain effect per original semantic identity and contiguous handled-offset advancement.
Kill a broker/controller, reduce ISR, exhaust publication shares and lose ACKs. Enforce RF=3, acks=all, minISR=2, no unclean election and durable Outbox obligations; broker acknowledgement is not invented disk-flush proof.
Poison payloads and causal gaps must park/quarantine with bounded retries and durable ownership. A parked record is not a completed workflow; do not reset offsets to latest or resend financial commands under new IDs.
Run consumer-first mixed-version rollout and replay horizons, original AppendTime/retention rules, dirty projection coalescing and interrupted source rebuilds.

## Payments and compensation tests
Use the actual SSLCOMMERZ sandbox for session creation, server validation, IDs/amount/currency/risk matching and supported refund/query behavior. Keep provider rate/credential/routability evidence separate from the isolated test double.
Inject callback-before-local-observation, duplicate/out-of-order callback, delayed validation, charge-after-closure, multiple charges, invalid/risky funding, refund-after-revocation and lost initiate/refund replies.
Assert callback receipt before ACK, no browser-success confirmation, no repeated funding for an unknown attempt, correct fulfillment-charge binding and total refunds no greater than verified charge.
Distinguish proved pre-dispatch non-execution from possibly sent work. A query NotFound, worker timeout, expired lease or new gateway request is never alone permission for another financial call.

## Auth, contact and recovery tests
Race account/contact claims, equivalent mailbox parsing, retired addresses, refresh use, code/TOTP consumption, reset with MFA, factor re-enrollment and concurrent recovery finals.
Verify dummy-password work, original five-minute attempt windows, pre-KDF durable allowance, pending reservations, physical-worker grants, lost responses, unknown signing/KDF execution and correct slot/accounting retention.
Revoke accounts/sessions/roles/keys while a source cut or queued operation is in flight. Validate original proof age, higher negative evidence, credential lineage, no renewed ceremony and no disclosure on stale or malformed private authorization.
Use virtual authenticators for reproducible WebAuthn flows and separately test actual operator/staff devices. Software simulation or two synced credential IDs do not prove independent hardware/operator recovery domains.

## Tickets, gate and cancellation tests
Exercise per-seat issuance/enrollment, immutable secret delivery, wrong realm/version, rendering/cache races, reissue versus use, strict entry windows, event cancel and all-unused customer cancellation.
Replay bearer QR and staff signed requests across lanes; crash before persisted green or passage reporting. Only the first authorized use/green can admit; historical/recovered receipts never mint another green.
Keep unknown passage and physical occupancy visible through lane retirement, supervisor disposition and event/venue rescheduling. Refund or calendar cancellation never erases ticket-use history.
Test QR/PNG/PDF payload/time/resource ceilings, template escaping, no renderer network, no-store/private ownership and delayed rendering after authority or credential revision changes.

## Notifications and safe email tests
Exercise notice Inbox/intent/channel duplicates, source causal minima, certified feed age, known SMTP acceptance, unknown submission, fixed Message-ID/MIME and exact recipient-binding retention.
Change a verified email while unsent or possibly sent work exists; verify no rebinding of uncertain mail and no challenge expiry extension on resend/retry.
Measure actual Mailpit capture and preserved fixtures separately from external recipient delivery. Disable forwarding; verify default pruning cannot remove needed evidence from the load fixture.
Test finite reserved mail lanes under business peaks and Auth attack. Business notifications cannot starve security mail or protected acceptance/recovery work.

## PostgreSQL and regional failure tests
Pause primary/VM/control processes, retain old connections, cancel sync COMMIT, drop post-COMMIT capture, fork timelines and delay real fence completion. Verify same backend/system/history/leadership and durable complete-prefix receiver coverage.
Reject pre-COMMIT markers, written-but-unflushed WAL, startup sentinel positions, missing base/WAL/timeline/key material, different storage incarnations and receipt signatures without actual complete history.
Run primary and standby loss with native strict follower readiness and full useful survivor load. Physical independent-host RPO zero/30-second recovery is a separate evidence class from same-laptop process failure.
Lose one entire site, apply D-102's approved prepare/fence/generation order, rebuild sources and validate useful service for at least ten minutes within the four-hour regional target. Quarantine alone is not successful recovery.

## Journal, trust and restore tests
Race appends at identical sequence, torn/partial/fsync/directory updates, signer retirement, lost prepare/outcome replies and rollbacked files. No different commands may both obtain complete valid receipts for the same authority transition.
Test all-site ordinary ACK and both-survivor emergency ACK, exact actor approval, native quorum preservation, unknown fences, a returning retired site and another survivor loss. Keep originals and stop affected new authority on missing continuity.
Restore encrypted base/PITR from before charge/use/password/contact/code changes. Deny provider/SMTP/live consumer egress and reconcile exact independent history before any authority opens.
Remove keys/middle WAL/archive repositories, simulate queue overflow and disk pressure. Never drop unarchived WAL, change realm to erase history, revive old credentials or claim file restore as useful RTO.

## Queue ingress and admission load — D-067
Maintain one million actively polling eligible sessions for thirty minutes under real presence/session policies.
Offer 25,000 joins/s for sixty seconds with accepted join p99 below two seconds, plus the one-million offered-join burst at one second and 99.9% durable receipts within sixty seconds.
Test the forty-five-second finite pre-acceptance buffer and its global one-million count/byte ceiling; no order exists before durable FIFO acceptance.
Separately deliver at least 1,000 useful admission leases/s for sixty seconds with 75,000 accounted slots and 99.9% issuance within one second of permitted opportunity; preserve actual selection windows and unknown heads.

## Holds and expiry load — D-068/D-077
Require 1,000 useful whole-bundle holds/s for thirty minutes with 1M background traffic, a 600,000-seat fixture, 200,000 accounted admission slots, original two-minute holds and full local/remote durability.
Measure hold p99 below 200 ms from Gateway arrival through response, including Auth, queues, locks, all phase intent/outcome gates and capture/proof waits.
Run scarcity at 5,000 logical requests/s for sixty seconds and 10,000 offers in the first second on the same four seats; at most one healthy whole-bundle winner, no overlap or partial effect. Refusals do not satisfy useful capacity.
Expire/close at least 1,000/s for thirty minutes; require 99.9% closure within five seconds and WR slot release within two seconds of the relevant evidence. Drain a 30,000-job, thirty-second fault backlog within sixty seconds while new work continues, implying at least 1,500 useful closures/s in that drain window.

## Payment journey load — D-069
Keep the real sandbox initial external gate at one request/s and one live HTTP request; actual provider throughput is unproved and cannot be extrapolated from fake responses.
Under the isolated same-adapter double, run sixty seconds of 1,000 conversion/dispatch/confirm operations/s, 3,000 callback receipts/s and 1,000 refund obligations/s with the 1M background.
Use pending-checkout p99 below 300 ms and callback ACK p99 below 200 ms; retain original evidence/remaining-time gates and the conversion/dispatch/confirmation visibility objectives in Review 069.
Measure refund obligations and useful progress separately from settled refunds. Retain original recovery processing/escalation targets, not an invented provider or human settlement SLA.

## Public and private read load — D-070/D-075
The thirty-minute 1M mixed fixture is 800k overview users at five seconds, 100k users reading two sections/s, and 50k users each on catalog/search at five seconds: about 380k public reads/s.
Target overview/section p99 below 200 ms and catalog/search below 500 ms with their original usable/freshness denominators; execute actual bounded payloads and varied cache/PIT hit patterns.
Add 50k private-order viewers at about 10k reads/s for thirty minutes, usable status age at most five seconds and p99 below 200 ms; measure 99.9% owner transitions server-servable within two seconds.
Model all 1M clients at two section requests/s separately: at the maximum 64-KiB payload that is roughly 1.05 Tb/s before protocol overhead. Measure actual payload/compression/egress; this model is not a passed test.

## Auth and abuse load — D-090/D-091
Maintain 1M distinct verified, recovery-ready sessions for thirty minutes with useful 50k certified authority proofs/s and 5k durable refresh rotations/s; target proof p99 below 100 ms and refresh below 200 ms.
Use actual source cache verification, certificate/crypto work, strict lineage and staggered original times, not signature-only lookups. Preserve proof <=30-second source age and original session windows.
Run fresh login at 100/s for thirty minutes and 1,000/s for sixty seconds with the accepted password/TOTP/UV mix. Include 100/s verified signup, security revisions and step-up/recovery fixtures with actual owner flows.
Offer 20k malicious requests/s for sixty seconds in the joint profile, shared-IP/IPv6 cases and targeted victim allowance exhaustion. Preserve useful session floors; legitimate victims' failures remain counted, and no unlimited-DDoS promise is inferred.

## Gate and artifact load — D-078–D-084
Sustain 200 first uses/s and 200 passage reports/s for thirty minutes over 1,000 lanes with 1M background and declared checkout/read peaks; gate API p99 below 200 ms and original durable green cycle p99 below one second at the specified device RTT.
Use 400k pre-issued unused tickets and preserve real admission windows; separately stress 1,000 gate uses/s for sixty seconds. Physical passage is not proven by a successful logical check-in or a pre-seeded use row.
With 1,000 confirmations/s, validate 4,000 enrollment writes/s and 99.9% private readiness within two seconds. Alert/case unresolved lanes at the accepted original times.
Exercise 1,000 private JSON/QR reads/s and 50 PDFs/s for thirty minutes, plus 250 cold four-page renders/s for sixty seconds; keep exact version/auth proofs, JSON/ready-stream tails and cold-ready within five seconds. Report actual render CPU/memory and output bandwidth.

## Notification load — D-089
Require 100 business plus 100 security submissions/s and 10k feed reads/s over 50k accounts for thirty minutes with the accepted 1M background and Mailpit capture fixture.
At the sixty-second 1,000 confirmations/s peak, create 2,000 notices/s and require 1,000 business SMTP submissions/s while other joint peaks and security shares remain active.
Retain notice-intent, feed, security-mail and business-mail original-source readiness targets, payload ceilings and the 256-live submission limit with separate reserved classes.
Drain only proved pre-submission transport backlog: the accepted example requires at least 1,650 useful submissions/s while 1,100 new/s continues. Possibly sent messages do not become safe retries merely to satisfy a drain graph.

## Staged load method and capacity model
Start with fixed native correctness fixtures, then stepped offered load (for example 100, 1k, 10k and 100k active clients where resources permit), finally the full target profile on verified distributed generators.
Use open-arrival-rate scenarios for spikes, account dropped iterations and measure generator CPU/RAM/network. Closed-loop response slowing must not hide missed offered demand. [k6 scenario guidance](https://grafana.com/docs/k6/latest/using-k6/scenarios/concepts/open-vs-closed/).
Record measured CPU/service-time, SQL/WAL/fsync, crypto/KDF, Redis/Kafka/PIT, memory/live-state and bytes/request. Model capacity as the minimum of these resources, with finite wait/unknown shares and headroom under a declared fault.
Publish extrapolation ranges and uncertainty, not a straight line from a tiny successful test. Expected millions of objects, bandwidth and replicas remain costs even when admission limits the hot inventory command rate.

## SLI accounting and release evidence
Each eligible logical operation is observed from its first server acceptance/arrival through its outcome under the accepted class definition. Record physical retries separately without duplicating success denominators.
Include 429/503/timeouts, known degraded scopes, all injected covered faults and joint offered work as specified. Do not exclude a fault window or redefine a blocked customer as ineligible to improve the result.
Report request-based 99.9% over thirty days by class, source original age and useful throughput as separate measures. A four-hour regional outage can exceed the monthly availability budget; both targets remain and the miss is visible.
Code-complete requires all feature/harness/IaC/CI artifacts and relevant passed checks. Production-ready additionally requires actual independent topology/trust/transport and the stated load/failure/retention evidence; it cannot be asserted from Day 2 alone.

## Evidence report output
Store build/config/source digests, fixture definitions, generator saturation, native fault timelines, service SLIs, invariant-oracle findings and retained useful outcomes in versioned bounded reports.
For each required capability record PASSED/FAILED/UNVERIFIED, measured limit, fault model, free-profile difference, production remedy and next verification task.
A failed correctness invariant stops affected implementation/release and preserves evidence. A capacity failure remains a requirement gap and drives profiling/admission/resource correction, never a silent lower target.
