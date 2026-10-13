# Certify private status with transactional buckets and immutable directories

Status: Accepted. Date: 2026-10-11. Decision: D-066.

Publication ACKs and empty work queues cannot prove a current complete private status image. Start with 1,024 stable hash buckets, transactionally track every relevant status change with a bucket revision and coalesced certification evidence, and build each cut from a proved baseline plus one consistent owner snapshot; immutable Merkle directories bind exact image membership while the manifest establishes source completeness. Retain uncertified and unresolved evidence, guard cleanup against newer revisions, invalidate lost baselines and rebuild in isolation; see D-066 and Review 066 for writer coverage, source-time preservation, current authority and unproved schema, recovery and capacity costs.
