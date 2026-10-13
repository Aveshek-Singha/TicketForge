# Use authenticated accounts for queue and checkout identity

Status: Accepted. Date: 2026-10-10. Decision: D-012.

Allow anonymous event browsing and search, but require an authenticated account for queue entry and seat allocation, with one active queue/admission lifecycle and one active checkout seat bundle per account and event occurrence. Reuse that account's valid entry and allocation across tabs or devices, bind admission permission to the account and occurrence, and enforce ownership server-side; IP and device signals assist abuse detection without serving as the sole identity or a hard IP binding. This adds login friction and authentication capacity work while establishing account-level fairness only; verification, purchase quotas, account-farming defenses, session design, and lifecycle closure remain unresolved.
