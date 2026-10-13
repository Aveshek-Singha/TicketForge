# Certify bounded availability freshness and expose unknown read state

Status: Accepted. Date: 2026-10-11. Decision: D-056.

Recent message receipt cannot prove that Redis contains every required source change. Availability remains advisory, with an initial two-second worst-case source-proof age at server response generation and 99.9 percent usable eligible logical reads over rolling thirty days at declared load. Missing or expired completeness proof exposes UNKNOWN/UPDATING, while Inventory alone grants durable holds and safe checkout recovery remains independent of projection publication. See D-056 and Review 056 for cache age, rebuild, privacy, capacity and unproved source/delivery mechanisms.
