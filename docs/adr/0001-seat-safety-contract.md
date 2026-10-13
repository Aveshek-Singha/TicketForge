# Protect active holds and confirmed bookings

Status: Accepted. Date: 2026-10-10. Decision: D-001.

A successful active hold is an exclusive seat allocation promise, as is a confirmed booking. When exclusive ownership cannot be established during failover or a network partition, affected seat allocation must stop until safety can be established. The user accepted reduced write availability during these failures instead of allowing conflicting allocations; authoritative storage, covered failures, recovery procedures, and SLO accounting remain unresolved.
