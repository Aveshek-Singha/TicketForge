# Define the 1M-user workload and hold latency boundary

Status: Accepted. Date: 2026-10-10. Decision: D-009.

Design for one million simultaneously active client sessions aimed at the same flash sale, including waiting and admitted users, with checkout admission bounded by measured safe capacity; stored queue records alone do not demonstrate active-user capacity. Admitted hold requests target Gateway-to-response p99 below 200 ms including internal queues and required durable commit, while queue wait, admission delay, external-network latency, and success, conflict, rejection, timeout, and error outcomes are reported separately. Test concurrency and independent arrival rates, expose dropped work and load-generator limits, and distinguish measurements from extrapolation; arrival profile, minimum useful throughput, admission limits, numeric error objectives, and full SLO windows remain unresolved.
