# Measure new durable holds and validate scarce-seat history

Status: Accepted. Date: 2026-10-11. Decision: D-068.

Fast retries and coordination refusals do not establish useful allocation capacity or correct seat conflicts. Require 1,000 new durable bundle holds per second for thirty minutes with sufficient inventory, separate sustained and synchronized scarce-seat profiles, and original p99/availability accounting through the real owner path. Use real deadlines, protected quota and lease closure, and complete allocation history to validate exclusion and atomicity; see D-068 and Review 068 for fixture sizes, authoritative outcomes, fault tests and unproved coupled throughput, free limits and production SLO compliance.
