# TicketForge

TicketForge is an eight-service ticket booking and flash-sale backend. The required stack includes Go, PostgreSQL, Redis, Kafka, Elasticsearch, Docker, Kubernetes, Terraform, Prometheus, Grafana, OpenTelemetry, Jaeger, k6 and GitHub Actions.

## Current status
The full architecture and delivery package are approved as D-104. The upfront architecture grill is closed. Implementation has started; no complete backend or production-readiness result is claimed.
All original requirements remain, including one million concurrent users, zero overselling, hold p99 below 200 ms and 99.9% availability.
Bangladesh payments use SSLCOMMERZ sandbox only. Local and free-cloud limitations are recorded as capability/evidence gaps.

## Start here
Read [the build spec](docs/BUILD_SPEC.md), [the delivery package](docs/DELIVERY_PACKAGE.md), [the work order](docs/IMPLEMENTATION_BACKLOG.md), [the validation matrix](docs/VALIDATION_MATRIX.md) and [the runbook](docs/RUNBOOK.md).
Use [the domain glossary](CONTEXT.md) and [accepted ADRs](docs/adr) for terminology and decisions.
The implementation workflow is ask-matt: to-spec, to-tickets, then implement with TDD and separate Standards/Spec review.

## Workflow and safety
Track PRDs and tickets in [GitHub Issues](https://github.com/Aveshek-Singha/TicketForge/issues). Work tickets whose actual dependencies are complete.
Use short issue-linked branches, Conventional Commits and reviewed PRs. See [contributing](CONTRIBUTING.md).
Do not commit credentials, keys, runtime data or Terraform state. Current cloud apply, paid resources and live payments are outside build authorization.
