# Inventory owns authoritative seat allocation

Status: Accepted. Date: 2026-10-10. Decision: D-002.

Inventory/Seat Service is the sole writer of authoritative active hold and confirmed allocation records in PostgreSQL; Booking Service requests allocation changes through Inventory APIs. Hold success requires an authoritative commit with the required durability, while Redis retains atomic hold coordination, TTL tracking, and availability reads without overriding durable ownership. This adds database writes to successful holds to support recovery, with replication guarantees, expiry rules, contention controls, and capacity validation still to be resolved.
