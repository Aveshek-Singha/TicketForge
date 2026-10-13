# Certify private owner dictionaries before merging status

Status: Accepted. Date: 2026-10-11. Decision: D-076. Encoding, writer coverage, recovery and capacity remain unproved.

Fresh composite timestamps and cache misses cannot establish complete owner state or non-execution. Each status owner maintains transactional bucket revisions and certification-dirty evidence, initially in 1,024 buckets with one-second coalesced private cut attempts, then publishes independently sealed sparse Merkle dictionaries with complete baseline/change/control proof and distinct populated, empty and retired encodings. Booking validates account scope, independent source cuts, current generations and matching causal receipts before merging; Review 076 defines bounded actual readback, baseline cleanup, isolated recovery and local-only absence semantics while preserving immutable critical history and all status SLOs.

Scoped follow-up: [D-084](0084-version-bound-private-ticket-artifacts-and-isolated-rendering.md) extends protected writer/image certification to Ticket issuance and credential enrollment, replacement, use and revocation for private artifact delivery. Exact scope/version binding and original completeness, source-age, control and recovery requirements remain.

Scoped follow-up: [D-089](0089-notification-slis-bounded-retries-and-free-transport-gaps.md) extends complete owner-certified baseline/change/control coverage to Notification intent, supersession, attempt and read-ack feed writers. A fresh feed certifies its own historical notices, not current Booking, Inventory or Payment authority.

Scoped follow-up: [D-091](0091-certified-auth-observations-and-primary-grant-boundaries.md) extends complete writer/image/control certification to non-secret Auth authority. A compact Session Authority Proof retains original source age and scope; certified membership does not grant credentials, expose secret validation state or prove source completeness by itself.
