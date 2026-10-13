# Issue stable tickets without creating another entitlement authority

Status: Accepted. Date: 2026-10-12. Decision: D-078. Formats, rendering budgets, admission scope and capacity remain unresolved or unproved.

Duplicate issuance and saved documents must not create new rights to a cancelled or resold seat, so Booking creates one stable Ticket per Event Seat atomically with its matching-proof confirmation and recovers the same identities after retry or unknown commit. Inventory retains entitlement authority, and whole-bundle cancellation preserves historical Ticket records while private reads show current rights as separately timed observations. Review 078 defines ownership, privacy, bounded representation work and validation without assuming physical venue admission, partial cancellation or transfer.

Scope follow-up: [D-079](0079-online-single-use-venue-check-in-scope-and-authority.md) now explicitly adds online Venue Check-in. Ticket identity and saved artifacts still do not grant entry independently; Inventory owns the separate first-use decision.
