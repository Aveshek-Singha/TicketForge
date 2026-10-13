# Separate deployment profiles from proved production capability

Status: Accepted. Date: 2026-10-12. Decision: D-093. Physical placement, free full-stack fit and measured readiness remain unproved.

Same-host replicas and a running dashboard cannot prove independent recovery or million-user capacity, so keep local-development, local-conformance, oci-free and production-reference profiles with unchanged service boundaries, technologies, safety contracts and original acceptance targets. Production retains independent critical PostgreSQL HA, Kafka/Redis replication and measured survivor resources; Oracle deployment prefers explicitly free-eligible OKE Basic, with assessed K3s fallback, actual quota/cost checks and a versioned capability evidence matrix. Review 093 preserves all components and required history while treating insufficient free hosts/resources as an unresolved delivery gap, rather than weakening durability, shrinking requirements or declaring a partial deployment complete.
