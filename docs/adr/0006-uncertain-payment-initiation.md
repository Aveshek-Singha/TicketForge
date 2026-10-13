# Reconcile uncertain payment initiation instead of blind retry

Status: Accepted. Date: 2026-10-10. Decision: D-006.

Persist a logical payment initiation identity before provider contact, serialize concurrent initiation for an order, and replay a known session result on retries. If dispatch or its result is ambiguous, block another initiation and reconcile provider records instead of blindly replaying the call; a not-found response alone is not proof of non-execution, and provider-side exactly-once behavior requires a documented and validated contract. This can delay checkout, while inventory still closes at its bounded deadline and monetary reconciliation and extra-charge compensation continue independently; terminal-state evidence, retention periods, and reconciliation cadence remain unresolved.
