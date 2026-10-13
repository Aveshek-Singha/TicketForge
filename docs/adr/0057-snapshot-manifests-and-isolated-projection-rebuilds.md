# Certify Outbox completeness with snapshot manifests and isolated rebuilds

Status: Accepted. Date: 2026-10-11. Decision: D-057.

Outbox identifiers, Kafka receipt and independently paginated reads do not prove a complete current view. Use one owner snapshot to seal published-offset coverage plus exact outstanding facts, requiring actual projection coverage and a matching baseline before certification; rebuild in isolated generations from consistent artifacts and catch up before switching. Preserve original observation time and synchronous owner durability, initially attempting coalesced cuts every 500 ms per Inventory HA group; see D-057 and Review 057 for publication races, retention, exporter lifetime and unproved schema/capacity costs.
