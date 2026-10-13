# Preserve acknowledged allocations after one database host fails

Status: Accepted. Date: 2026-10-10. Decision: D-003.

Acknowledged allocations have RPO zero after loss of one database host, with success requiring durable WAL on the primary and at least one synchronous standby on an independent host. Promote only a candidate that preserves acknowledged writes, fence the former primary, and stop new allocation success if the required durability or safe ownership cannot be established; do not silently downgrade to async writes. This trades latency and some write availability for durability; replica count, failure domains, failover mechanism, RTO, whole-region recovery, and the free deployment's verified capabilities remain unresolved.

Scoped extension: [D-096](0096-regional-zero-loss-history-and-useful-recovery-objectives.md) adds regional RPO zero for exposed authoritative history and admitted protected-work guards. The original single-host guarantee remains; independently durable off-region protection is an additional gate whose exact mechanism and latency still require proof.
