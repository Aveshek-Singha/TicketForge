# Separate service database ownership and document shared deployment limits

Status: Accepted. Date: 2026-10-11. Decision: D-030.

Give each state-owning service one logical PostgreSQL database with tested scoped runtime/migration identities; runtime users are non-owner/non-superuser, API Gateway has no domain SQL authority, and cross-owner workflows use authorized contracts/events rather than shared SQL authority or transactions. The production design provides independently scalable HA infrastructure for critical/hot owners; a documented local/free profile may co-locate logical databases but shares physical resource, failover, and restore impact and must still meet required independent synchronous durability/fencing before claiming those guarantees. Bound deployment-wide connection pools including autoscaling and jobs, reserve recovery capacity, and record unverified free-profile gaps; exact physical placement, pool limits, failover, restore, and atomic-bundle-safe partitioning remain unresolved.

Scoped follow-up: [D-093](0093-deployment-profiles-and-independent-production-placement.md) defines four deployment profiles, the production placement floor and conditional zero-cost readiness. Co-location does not change logical ownership or establish independent fault tolerance; inadequate free full-stack capacity remains a delivery gap.
