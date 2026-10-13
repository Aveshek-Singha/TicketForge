# Evaluate allocation deadlines at guarded Inventory transitions

Status: Accepted. Date: 2026-10-10. Decision: D-016.

Follow-up: D-017 sets two-minute holds and five-minute payment reservations. Clock health, error bounds, cleanup SLO, and transaction implementation remain unresolved.

Inventory owns fixed UTC allocation deadlines and evaluates eligibility using fresh primary database time after acquiring all required locks. Hold conversion and payment confirmation require a time strictly before the relevant deadline; request arrival, transaction-start time, client clocks, Redis TTL, and provider timestamps cannot independently establish eligibility. Only a successfully committed guarded transition counts, though an eligible transition may commit or respond after the deadline. Expiry ends eligibility even if cleanup is late; release and reclaim use atomic Inventory closure and generation checks without releasing payment reservations or confirmed allocations through stale work. Retries do not reset deadlines. Establish clock health and failover safety or pause affected transitions; closed allocations cannot revive. Lock waits and delayed evidence can miss the deadline, with late verified payment success compensated under D-004. Numeric durations, clock error bounds, health checks, cleanup SLO, and transaction implementation remain unresolved.
