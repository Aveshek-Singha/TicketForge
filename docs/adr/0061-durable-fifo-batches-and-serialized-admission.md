# Establish durable FIFO through bounded batches and guarded dispatch

Status: Accepted. Date: 2026-10-11. Decision: D-061.

Independent sequence allocation and skipping locked entries can invert accepted FIFO order. Use occurrence-specific transactional append ordinals and small bounded ingress batches, initially up to 256 distinct joins or five milliseconds collection time, acknowledging only verified synchronous owner commits; duplicate reconnect preserves its accepted entry. Keep append and admission controls separate, serialize each occurrence's guarded dispatcher and atomically reserve occurrence/global capacity with lease issuance in the Waiting Room database. Rebuild observations and recover dispatch from durable ordered entries and active/unknown lease state without Redis-based priority or capacity reset. See D-061 and Review 061 for proof barriers, eligibility, global contention and unproved ingress/progress/capacity; retain all original requirements.
