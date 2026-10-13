# Pause uncertain new Redis demand while preserving guarded recovery

Status: Accepted. Date: 2026-10-11. Decision: D-060.

Redis failover can lose advisory tokens or counters; blanket bypass overloads owners, while blanket shutdown strands accepted work. Keep bounded Redis atomic coordination, but enforce allocation, attempts and quotas through Inventory's durable guards and admission capacity through Waiting Room. Pause affected new joins, admissions and allocation attempts when required coordination is uncertain; existing guarded checkout and financial recovery use separate reserved paths under all original authority and deadline rules. Use an isolated production coordination cluster and reconcile durable state before reopening lost counters or control generations. See D-060 and Review 060 for ownership-checked tokens, attempt ledger, conservative window recovery, resource limits and unproved enforcement/failover capacity; preserve all original requirements.

Scoped follow-up: [D-092](0092-durable-auth-attempt-budgets-and-physical-resource-fencing.md) applies uncertain-gate closure and fenced reconciliation to Auth. Auth owns its durable attempt ledger and finite work grants; Redis recovery cannot erase attempts, reopen unknown grants or borrow protected existing-session/recovery shares.
