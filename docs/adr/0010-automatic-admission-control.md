# Enforce admission budgets with automatic queueing

Status: Accepted. Date: 2026-10-10. Decision: D-010.

Always enforce measured per-event and global admission budgets, automatically queue excess demand, and reduce or pause new admission when safe capacity falls, signals become stale, or ownership safety is uncertain. Reserve bounded capacity for existing checkout, durable payment evidence ingestion, expiry, reconciliation, and compensation, while unsafe operations still pause; use conservative resource limits and hysteresis with controlled recovery instead of a latency-only trigger or a synchronized queue release. Operators may tighten or pause admission without bypassing safety, and scheduled advance queueing remains optional; fairness, numeric budgets, freshness bounds, recovery tuning, and credential lifecycle are unresolved.
