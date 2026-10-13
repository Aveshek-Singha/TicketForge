# Restore control only after fencing old authority and verifying its history

Status: Accepted. Date: 2026-10-12. Decision: D-099. D-100 selects journal prepare/outcome reconciliation and D-101 selects three-site copies; journal implementation and recovery-root evidence remain pending.

After permanent etcd quorum loss, stop control mutations and critical work; use the D-036 independent audited recovery path, authenticate the last control snapshot plus monotonic post-snapshot authority journal, and physically fence every possible old controller/writer/issuer/dispatcher before restoring a new three-voter cluster with fresh membership and generation. Never force-remove a minority, reuse divergent cluster identity or bootstrap authority from the restored DCS alone. Missing snapshot/journal continuity or fence evidence keeps affected scopes in Recovery Quarantine and counts against recovery/SLO objectives; a revision bump does not reconstruct omitted application history.
