# Gate PostgreSQL promotion and write readiness with independent fencing

Status: Accepted. Date: 2026-10-12. Decision: D-094. Versions, fence adapters, physical proof, timing and capacity remain unproved.

A majority election cannot stop an old PostgreSQL writer, so use Patroni with independent three-member etcd control, strict synchronous mode, safe-history candidate selection and a mandatory bounded pre-promotion gate covering every potentially writable predecessor incarnation. Require independently verified physical fencing, quarantined rejoin and fresh complete write-readiness evidence before routing critical success; OCI hard STOP is a candidate adapter whose completed effect and timing still need proof. Review 094 keeps D-032 command barriers, treats watchdog/demotion as additional protection, counts every failed recovery objective and preserves thirty-second recovery, RPO zero and all original 1M/latency targets.

Scoped follow-up: [D-097](0097-three-site-remote-wal-coverage-gate.md) preserves local Patroni strict synchronization and fencing, then adds a distinct two-of-three off-region WAL coverage gate. The three-site recovery layout and receiver roles do not make a remote cohort an automatic promotion target; D-094's physical fencing and safe-history checks still apply.

Scoped follow-up: [D-098](0098-three-site-control-quorum-and-membership.md) places one etcd voter at each production site and requires two-of-three quorum for control changes. A partition without quorum blocks new critical authority; physical fencing and controlled regional promotion remain mandatory.
