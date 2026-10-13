# Bound clock uncertainty before time-dependent owner decisions

Status: Accepted. Date: 2026-10-11. Decision: D-053.

Fresh wall time alone cannot prove safe eligibility, expiry or evidence age across failover. Require an initial estimated UTC error threshold of 100 ms and node-bound clock-health evidence no older than five seconds. Use conservative interval guards, preserve original deadlines and deny affected grants during uncertain time; see D-053 and Review 053 for source assumptions, recovery rules and unproved enforcement/capacity costs.
