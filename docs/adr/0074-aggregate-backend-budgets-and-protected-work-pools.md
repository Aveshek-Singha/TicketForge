# Bound database backends and protect accepted work

Status: Accepted. Date: 2026-10-11. Decision: D-074. Sizing, versions, security integration and survivor capacity remain unproved.

Independent service and proxy pools can exhaust PostgreSQL and starve recovery during autoscaling. Use self-hosted PgBouncer transaction pooling with measured physical-group backend budgets, initially nonoverlapping static proxy/work-class shares, bounded queues and separately reserved accepted-checkout, payment-evidence, recovery and publication capacity. Review 074 specifies transaction and timeout semantics, uncertain-share accounting, original-age health evidence, secure HA routing and validation under the full workload; protected connections alone do not establish resource isolation, throughput or free-cloud readiness.

Scoped follow-up: [D-092](0092-durable-auth-attempt-budgets-and-physical-resource-fencing.md) extends aggregate share accounting to Auth CPU, KDF memory, signing and execution grants across active, uncertain and replacement workers. Permission expiry does not prove physical completion; uncertain slots remain charged until actual release or independent consumer fencing.

Scoped follow-up: [D-097](0097-three-site-remote-wal-coverage-gate.md) adds one finite backend-pinned session-pooling capture lane for verified COMMIT plus same-backend WAL boundary capture. Keep ordinary SQL transaction-pooled; count session backends, overlap, receiver work and waiters inside D-074's existing physical shares.
