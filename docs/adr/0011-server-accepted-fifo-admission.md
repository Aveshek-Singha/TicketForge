# Admit queued participants in server-accepted FIFO order

Status: Accepted. Date: 2026-10-10. Decision: D-011.

For each event occurrence, admit eligible valid queue entries using a stable authoritative server acceptance sequence, rather than client click times, unsynchronized node clocks, or a lottery. Refresh and reconnect reuse the same valid entry and priority, duplicate requests cannot create extra entries for the same eligible identity, and new arrivals cannot bypass earlier eligible waiting entries when capacity or queue mode changes. FIFO orders checkout admission without guaranteeing seats or payment completion order; identity rules, the ordering primitive, queue durability and failover, stale-entry expiry, and admission leases remain unresolved and must be sized for the 1M-user workload.
