# Store callback receipts before acknowledgement and reconcile independently

Status: Accepted. Date: 2026-10-11. Decision: D-047.

An early callback acknowledgement can lose payment evidence, while synchronous provider validation can block ingestion. Payment durably stores bounded untrusted receipt evidence and verification work before acknowledgement, then verifies asynchronously with independent pre-dispatch reconciliation intent. Additional writes and query capacity are required, and provider delivery/history guarantees remain unproved; see D-047 and Review 047 for the full contract.
