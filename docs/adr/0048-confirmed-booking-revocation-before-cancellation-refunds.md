# Revoke confirmed entitlement before cancellation refund dispatch

Status: Accepted. Date: 2026-10-11. Decision: D-048.

Refunding a confirmed booking before revocation can leave its entitlement active, while restoring it after refund failure can conflict with resale. An authorized cancellation uses a separate durable whole-bundle Saga, conditional charge-level refund planning and proven Inventory revocation before financial dispatch, preserving original confirmation history and allocation generations. Revocation and refund completion remain separate outcomes; see D-048 and Review 048 for safety guards and unresolved business policy.
