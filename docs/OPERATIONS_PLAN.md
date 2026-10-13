# TicketForge operating and deployment plan

## Status and evidence policy
Defaults approved as D-104. No runbook command, deployment or physical proof was executed during review. Record implementation evidence separately.
Retain all four D-093 profiles and the full stack. Record actual shared failure domains, artifact/config identity, required guards, PASSED/FAILED/UNVERIFIED/SIMULATED evidence and measured limits.
Add runnable commands to RUNBOOK.md only after they work. A configuration, same-laptop replica, software watchdog or signed receipt does not prove an independent site or completed physical fence.

## Container and native infrastructure
Keep eight independent Docker/Kubernetes deployments with scoped identities, network/egress policy, finite resources, startup/readiness, drain and rollback.
Critical production PG/control/fence nodes use verified Linux VM/host storage and independent execution/write fencing under D-094; pod deletion and removed routes are insufficient.
Separate public Gateway, private services/data and independent control/recovery access. HPA/rollout includes old and unknown workers in aggregate shares; it never multiplies per-pod full budgets.
Use authenticated Redis client/cluster bus, separate coordination/read planes, Kafka TLS/SASL/ACL with three brokers/separate controllers and actual Elasticsearch Basic/PIT coverage.

## Telemetry architecture
Services expose Prometheus and safe structured logs; OpenTelemetry carries W3C trace context through HTTP/gRPC/guarded phases/Kafka, with a self-hosted bounded Collector and Jaeger backend.
Grafana dashboards cover service SLIs, useful throughput, original-source freshness, uncertainty, resource shares and fault recovery. No paid observability backend is required.
Propose one-percent ordinary tracing with separately bounded slow/fault sampling. Export queues have count/byte/drop limits and their own CPU/IO shares; dropped telemetry remains visible.
Never capture passwords, bearer QR, refresh/recovery/challenge secrets, SMTP bodies or provider credentials. Use bounded class/route/outcome/profile labels, not account/seat/order/command IDs.

## Dashboard and alert groups
Inventory: active allocation/quota, conflict/closure, expiry age/backlog, SQL/lock/WAL/capture/remote waits and invariant mismatch.
Workflow: FIFO/slot/presence/admission, Booking Saga, funding/refund/unknown calls, feed/mail/render, entry/passages and unresolved cases.
Authority: Auth/control/source original ages, role/key/epoch revocation, KDF/signing grants, clock, receiver/base/timeline, journal/fence/archive completeness.
Infrastructure: physical-group connections, CPU/RAM/fsync/WAL/disk, Kafka ISR/lag/Outbox, Redis headroom/rejects, ES shards/PIT/heap, NIC and generator saturation.
Keep original D-034/D-083/D-089/backup/abuse alert-case timing. An acknowledged incident is not a resolved obligation.

## SLO measurement and response
Measure eligible logical operations from original arrival/acceptance, not individual retry successes. Keep 429/503/timeouts, stale useful views, affected scopes and fault windows in the accepted denominators.
Export availability, freshness, useful throughput and latency separately with relevant 100/200/300/500-ms buckets and independent load evidence for actual p99.
Immediately stop affected new authority when required clock/trust/fence/history evidence is unsafe. Admission reduction preserves safety but does not remove failed eligible demand.
Implement deduplicated alerts with runbook links; this review creates no external notifications or recurring automation.

## Secrets, root and workload trust
No private key/provider password/raw token/QR or encrypted secret payload enters Git, Kafka, public/private source dictionaries, logs or Terraform outputs/state.
Use actually eligible OCI Vault references and protected local encrypted stores; Kubernetes Secret encoding alone does not establish encryption or independent recovery.
Generate secrets outside Terraform, retain purpose/environment key status and backup/replay decryption versions, and protect current recovery roots outside Auth/PG/DCS rollback domains.
Use scoped SPIFFE/SPIRE mTLS and current policy. Key rotation or a new realm cannot repair lost identity/consumption history; unknown trust/root/key evidence blocks affected authority.

## Browser, callback and staff clients
Only Gateway accepts public customer/provider traffic; private SQL/cache/Kafka/control ports and metrics are restricted.
Provide actual trusted HTTPS/origin/CSRF, object/role checks and bounded request parsing. Pin sandbox hosts and prevent SDK/proxy financial retries.
Ship minimal browser/demo/staff clients needed for WebAuthn, non-extractable signing, lane passage journal and SSL redirects; never retain raw scanned secrets in the device journal.
Public callback TLS/hostname and actual sandbox reachability remain unverified. Bounded server reconciliation preserves money obligations even when no IPN arrives.

## Local environment work
At implementation start, restore the Linux Docker/WSL engine, project-local Go 1.27.2/tools, durable volumes and measured RAM/disk budgets.
Provide full-stack Compose then supported local Kubernetes manifests. All components stay present; actual fit and contention on the observed 12-GB/4-logical-CPU host require measurements.
Use clearly isolated test-only site/fence/device simulations and real native transaction guards. Production identity/capability paths reject simulated proof.
Separate fresh test-realm seeding from migration of continuing business/security history. Linux ARM service binaries do not prove x86/ARM physical PG/WAL compatibility.

## OCI free constraints
| Documented allowance/limit | Impact and closest free remedy |
| --- | --- |
| Home-region compute; A1 currently 2 OCPU/12 GB | No free three-region protection is established; verify existing independent sites or block that capability. |
| 200-GB combined boot/block; five backups | Size full replicas, WAL and retention before apply; use independent existing repositories where possible. |
| 20-GB object storage; 50k monthly API requests | Measure actual PITR/object bytes and requests; do not shorten safety history to fit. |
| Capacity and idle reclamation uncertain | Do not rely on post-outage free instance acquisition or a guaranteed rollout date. |
Source: [Oracle Always Free](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm). Actual tenant eligibility is unverified; paid shapes/upgrades/trial reliance are excluded.

## OCI topology and rollout gates
Prefer explicit free-eligible OKE Basic, otherwise assess K3s; workers, volumes, network and native controller resources must all pass the cost/capability manifest.
Inspect home region/quota/availability, architecture, disks/IOPS, IAM/fence APIs, public TLS and every resource type before approving Terraform apply.
A ten-Mbps free load-balancer path cannot certify required traffic. Assess eligible routing/NLB and actual NIC/egress/object budgets without inventing free capacity.
Keep independent production-reference IaC even when OCI-free protection or full-stack fit is blocked. No component, replica guarantee or retained guard disappears silently.

## Runbook families: load and financial uncertainty
For overload, identify constrained/unknown work, reduce new admission, preserve accepted/evidence/closure/recovery shares and measure original useful progress.
Keep exact command/phase/provider IDs and original deadlines. A timeout, missing row, Redis TTL or worker lease alone never authorizes a repeated effect or resource release.
For provider outage, durably receive callbacks, distinguish verified money from possibly sent work, query exact original references under bounded gates and refund only with charge/entitlement evidence.
Unknown execution remains charged until exact outcome or independently proved fence/non-execution. Preserve all alert/case/SLO misses and avoid fabricated settlement or external inbox assurances.

## Runbook families: host, site and trust failure
Covered host failure follows D-094: authenticated current quorum, complete predecessor fences, native safe candidate/follower/readiness and original thirty-second useful recovery.
One-site loss follows D-102: both survivor histories/root/approval, durable prepare before physical effects, fenced old actors, conditional generation/outcome, then guarded promotion.
Return/replacement stays quarantined through settled infrastructure actions, exact history and native safe re-enrollment; no minority force-removal or hand-built two-voter rule.
Missing quorum/history/root uses D-099/D-095 isolated restore/quarantine. Preserve money, ownership, credential/use and occupancy obligations; file restore is not useful RTO.

## Runbook families: archive, PITR and retention
Keep encrypted pgBackRest continuous WAL, weekly full/daily differential/hourly incremental, actual thirty-day chain and independent repositories including off-region coverage.
Verify consecutive source frontiers, base/timeline/key and protected deletion authority; never drop unarchived WAL, report queue-drop success or prune the sole recoverable chain.
Perform isolated latest/older restores per group daily and after schema/key/storage changes, with live provider/SMTP/consumer/control egress denied.
Reconcile independent irreversible history and rebuild complete certified baselines before effects. Bounded referenced-object cleanup retains uncertain readers/publications/worker history; backups do not authorize deletion of live safety guards.

## Migrations and rollback
Use owner-scoped expand/bridge/backfill/validate/contract with finite jobs, compatibility and replay horizon; runtime service roles cannot perform DDL.
Rollout counts old/new/unknown shares and checks current route/capture/source membership. Drain exact original work without turning connection loss into non-execution.
Rollback only to a compatible retained image/schema/config; otherwise forward repair. Historical database restore cannot undo payments, consumed factors or entry.
Before removal/pruning, prove old readers, receipts, replays and required backups no longer depend on the data and retain unresolved obligations.

## Cost and license posture
Use free/self-hosted services and standard hosted CI for the existing public repository, with bounded artifacts/cache and no paid larger runners.
Verify image/package storage, certificates, SMTP, objects and AI-account limits before relying on them. No new paid tool, credits, domain or cloud resource is authorized.
References: [Redis licensing](https://redis.io/blog/agplv3/), [Elastic Basic](https://www.elastic.co/docs/deploy-manage/license/manage-your-license-in-self-managed-cluster), [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions).
Record selected license/feature/redistribution notices and actual free gaps. Required Redis/Elasticsearch technologies are retained rather than substituted.
