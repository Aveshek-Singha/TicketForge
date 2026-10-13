# Use Go for the complete eight-service backend

Status: Accepted. Date: 2026-10-13. Decision: D-103. The application is not implemented and compatibility/capacity evidence remains unproved.

Use Go for all eight backend services and their workers, retaining every accepted domain, datastore, messaging, security, infrastructure and observability requirement. Pin Go 1.27.2, verified against the official release history, for reproducible Linux amd64/arm64 builds; upgrade the installed 1.24.1 only during authorized implementation. Native binaries and explicit bounded concurrency suit the deployment work, while application wiring, guarded commit semantics, dependency compatibility and measured 1M/p99 performance still require implementation and validation.
