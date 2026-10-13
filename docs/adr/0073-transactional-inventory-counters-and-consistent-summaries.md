# Produce inventory summaries with transactional striped counters

Status: Accepted. Date: 2026-10-11. Decision: D-073. Correctness, contention and capacity remain unproved.

One count row serializes unrelated holds, while asynchronous deltas and expiry arithmetic can drift from owner state. Keep one occurrence's allocation, bundle, quota and summary state in one Inventory PostgreSQL HA group; use fixed sealed hash buckets, atomic category changes, a complete canonical lock plan and consistent owner snapshots, initially with 1,024 possible buckets and 500 ms cut attempts. Publish separately certified immutable summaries with original source time, verify preparation and uncertain rebuilds, and initially audit ledger correspondence every fifteen minutes while active; Review 073 specifies guarded recovery, lifecycle retention and measured hot-primary limits without claiming buckets prove scale.

Category follow-up: [D-081](0081-approved-admission-windows-and-used-seat-lifecycle-protection.md) retains used-seat fences across generations. First use keeps current confirmed stock in its category; revocation changes used stock to OtherUnavailable rather than free, with atomic category, revision, receipt and Outbox updates.
