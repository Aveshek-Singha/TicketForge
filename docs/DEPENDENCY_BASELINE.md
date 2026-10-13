# Dependency and reproducible build baseline

## Bootstrap progress — 2026-10-13
Go 1.27.2 now runs through Go's checksum-verified toolchain download. go.mod selects this baseline; the global 1.24.1 install was not overwritten.
The Linux Docker engine now responds. The doctor command reports exact observed tooling and retains native booking, physical recovery and full-scale capacity as unverified.
Principal image digest observations are recorded separately; remaining modules, actions, providers, tools, scans and native compatibility remain open in BK-001.
The project has no application packages or external Go modules yet. go mod verify succeeds for this empty dependency set; this is not a service build or native test.

## Status and pin acceptance
Go 1.27.2 is accepted as D-103; client/platform defaults are approved as D-104. No install, compile or runtime compatibility check was performed during review. Record implementation evidence separately.
BK-001 resolves exact modules/transitive sums, image/provider/action digests and source/signature/license evidence into a committed manifest before native component work.
Verify security/support and actual Linux amd64/arm64 protocol behavior at implementation start. Never ship mutable latest tags or compare/restore incompatible physical PG histories.
An upstream release or supporting README is evidence of a candidate, not a tested system. Block unsafe incompatibilities and record the supported repair without another version questionnaire.

## Proposed principal runtime versions
| Component | Candidate | Primary release evidence |
| --- | --- | --- |
| Go applications | 1.27.2 | [Go history](https://go.dev/doc/devel/release). |
| PostgreSQL | 17.11 | [Supported release table](https://www.postgresql.org/support/versioning/). |
| Redis | 8.10.2 core with authenticated client/cluster bus | [Redis releases](https://github.com/redis/redis/releases). |
| Kafka | Apache 4.2.2 / KRaft | [Apache downloads](https://kafka.apache.org/community/downloads/). |
| Elasticsearch | 9.5.5 / self-managed Basic | [Elastic releases](https://www.elastic.co/docs/release-notes/elasticsearch). |

## Native control and deployment candidates
Patroni 4.1.5 documentation supplies the verified strict-sync/pre-promote basis; select a compatible exact source/image and test with PG 17 and native etcd.
Use supported etcd v3 with guarded transactions, majority, sequential/learner membership and authenticated transport. Existing TTL/loop/follower settings remain test candidates, not proven recovery time.
Resolve PgBouncer, HAProxy, pgBackRest, SPIRE, Kubernetes/OKE-or-K3s, Terraform/providers, Helm, Docker/buildx, k6 and Protobuf/Buf to supported exact patches/digests.
Resolve Prometheus, Grafana, OTel Collector, Jaeger and Mailpit with resource/retention manifests. Their memory/IOPS and identities are real full-stack cost.
Sources: [Patroni](https://patroni.readthedocs.io/en/latest/yaml_configuration.html), [etcd membership](https://etcd.io/docs/v3.6/op-guide/runtime-configuration/), [pgBackRest](https://pgbackrest.org/user-guide.html).

## Go application and persistence defaults
Use standard net/http, explicit routing/middleware, context, crypto/tls and slog; grpc-go/Protobuf for internal commands.
Use pgx/v5 parameterized SQL and owner SQL migrations; sqlc is the proposed typed-query generator. No shared cross-owner ORM/domain transaction layer.
Enforce original pgx notice/COMMIT/connection handling and the still-leased same-backend capture lane, with native lost/cancelled warning tests.
Ordinary SQL remains transaction-pooled; capture alias session backends are finite and included in physical shares. Avoid session-only SQL features or implicit retries.
Driver source: [pgx](https://github.com/jackc/pgx), whose stable v5 and notice support are documented; exact system behavior remains untested.

## Integration client defaults
Use go-redis/v9, franz-go and the official elastic/go-elasticsearch/v9 client behind bounded domain-aware adapters.
Use pinned OpenTelemetry Go and Prometheus Go clients, supported WebAuthn/strict TOTP, purpose-scoped crypto and audited bounded SMTP.
The SSL sandbox adapter uses Go HTTP with exact merchant/reference/validation semantics and disabled implicit financial retry. Test double identity/egress never reaches real provider credentials.
Verify Go 1.27.2 compatibility, security/support and exact locked release before use: [go-redis](https://github.com/redis/go-redis), [franz-go](https://github.com/twmb/franz-go), [Elastic Go](https://github.com/elastic/go-elasticsearch), [OTel Go](https://github.com/open-telemetry/opentelemetry-go).

## Artifact and journal defaults
Use a pinned QR encoder and signintech/gopdf for fixed-layout rendering with approved fonts, escaped content, no HTML/network fetch and exact output/CPU/memory limits.
Use supported exclusive Linux file creation and durable file/directory sync in isolated journal agents; this does not itself prove independent storage, monotonic root or safe membership.
Build minimal runtime images with verified native/cgo/font dependencies and non-root/readonly/finite scratch where appropriate. Race/component builder jobs can need C even if runtime builds are cgo-free.
PDF library source/license: [gopdf](https://github.com/signintech/gopdf). Selected patch, renderer and security behavior remain untested.

## Manifest and compatibility gates
Record component/version/digest/source/license, transitive sums, support status, target architectures and required protocol/fault tests for every build input.
Test PostgreSQL warning/capture/pool behavior, Redis Lua/ACL/TLS/resharding, Kafka clients/offsets/security, actual ES PIT/readback, Auth/mail parsing and source hash encoding.
Test rolling mixed readers, replay horizons, restore keys and schema/physical compatibility before changed native/runtime versions ship.
Reproduce a clean checkout and verify declared artifact identities. No candidate pin certifies capacity, physical independence, quota fit, durability or latency.
