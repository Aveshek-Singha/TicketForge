# Booking owns durable Saga orchestration

Status: Accepted. Date: 2026-10-10. Decision: D-007.

Booking Service stores Saga progress and coordinates recovery, while Payment owns verified payment evidence and compensation execution and Inventory owns authoritative allocation transitions. Each service persists its own state and outbound Outbox work in a local transaction, with consumers deduplicating local effects; Booking confirms an order only after verified payment and matching durable inventory confirmation and reconciles uncertain allocation outcomes before retry or compensation. This centralizes workflow recovery at the cost of coordination state and Booking availability, with exact states, transport per step, data isolation, and recovery-time objectives still unresolved.
