# Bound payment reservations and compensate late success

Status: Accepted. Date: 2026-10-10. Decision: D-004.

Before contacting the payment provider, Inventory atomically validates the user's unexpired hold and converts it into an exclusive payment reservation with a fixed bounded deadline that retries cannot extend. Confirmation and expiry use guarded authoritative transitions: original hold expiry cannot release a payment reservation, confirmed allocation survives stale expiry work, and unconfirmed allocation closes at its payment deadline and becomes eligible for safe release. A timeout is an unknown payment outcome requiring reconciliation; success after allocation closes cannot revive the booking and requires durable, retried refund or authorization-void compensation, with provider capabilities, exact deadline duration, time checks, and multi-seat behavior still unresolved.
