# Bound private status freshness and admission visibility separately

Status: Accepted. Date: 2026-10-11. Decision: D-065.

A fast queue response can conceal a delayed admission and consume its fixed Selection Window. Bound certified private status source age to five seconds, target 99.9% usable eligible reads over thirty days with p99 below 200 ms, and separately target 99.9% of durable leases becoming certified and server-servable within two seconds of original issuance. Preserve original deadlines, count overload and invisible leases as failures, pause unhealthy new admission, validate current authority at checkout and return unknown for unproved images; see D-065 and Review 065 for source coverage, polling, client age rules and unproved certification, capacity and delivery evidence.
