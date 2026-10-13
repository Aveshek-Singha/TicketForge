# Reserve non-overlapping physical venue occupancy before activation

Status: Accepted. Date: 2026-10-11. Decision: D-055.

Different occurrence IDs do not prevent conflicting use of the same physical venue. Event and Venue reserves canonical conflict resources all-or-none before activation, with finite approved occupancy including setup, customer access, performance and teardown, and PostgreSQL resource-specific range exclusions. Unknown activation/cancellation retains blockers, and release requires old execution fencing rather than timers or completed refunds; see D-055 and Review 055 for space mapping, failure recovery and limits of registered-calendar evidence.

Scoped amendment: [D-081](0081-approved-admission-windows-and-used-seat-lifecycle-protection.md) prevents automatic early release where check-in exists or attendance/clearance is uncertain. Preserve the original occupancy blocker and execution fences; actual physical clearance is an operational responsibility, not a consequence of digital cancellation or elapsed time.
