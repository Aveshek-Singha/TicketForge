# Measure durable queue ingress and admission progress separately

Status: Accepted. Date: 2026-10-11. Decision: D-067.

One million active users do not establish durable join throughput or a functioning dispatcher. Require the declared active-session profile, a 25,000-join-per-second ingress floor with p99 below two seconds, the concentrated 1M opening profile with a sixty-second receipt target, and separate 1,000-lease-per-second dispatch and one-second opportunity progress targets. Preserve bounded unaccepted buffering, FIFO, original deadlines and honest offered-load/failure accounting; see D-067 and Review 067 for durations, fixture limits, survivor capacity and unproved end-to-end throughput, free topology and thirty-day SLO compliance.
