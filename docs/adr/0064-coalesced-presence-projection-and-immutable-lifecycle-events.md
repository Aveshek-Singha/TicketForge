# Coalesce presence projection work without rewriting lifecycle events

Status: Accepted. Date: 2026-10-11. Decision: D-064. Specializes only pure presence delivery inherited from D-024/D-062/D-063.

Immutable per-pulse event archives grow with every renewal even after receipt compaction. For pure Queue Presence, atomically commit current evidence and one desired projection-work record per entry generation, with at most one unresolved publication intent, while retaining immutable Outbox/Kafka events for critical lifecycle facts. Use separate pulse and lifecycle revisions and one complete guarded image publication path; clear only the matching captured work after proven publication, retain uncertain work and rebuild without changing owner truth or original deadlines; see D-064 and Review 064 for source-time preservation, stale-worker races, retention boundaries and unproved status certification, recovery and capacity; all original safety and scale requirements remain.
