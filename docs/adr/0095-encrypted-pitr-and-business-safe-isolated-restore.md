# Restore encrypted PostgreSQL history without reviving irreversible effects

Status: Accepted. Date: 2026-10-12. Decision: D-095. Chains, repository/key placement, enforcement and restore capacity remain unproved.

A consistent old database cannot prove later payments, ticket use or security consumption never happened, so use encrypted pgBackRest physical backups and continuous WAL with verified thirty-day PITR coverage, two independent repositories and protected key/deletion authority. Restore only into fenced isolated namespaces, verify complete owner/timeline/history and independent recovery control before positive publication or external effects, and quarantine affected or broader scopes when history is missing rather than recreating rights, credentials or provider calls. Review 095 forbids WAL-drop archival success, preserves original replay/deadline/durability guards and requires isolated restore drills without claiming measured capacity or regional RPO/RTO.

Scoped follow-up: [D-096](0096-regional-zero-loss-history-and-useful-recovery-objectives.md) separates sixty-second complete bulk archive coverage from regional zero-loss critical history. Remote protected history must bridge the archive tail; file restore or Recovery Quarantine does not satisfy the four-hour useful recovery objective.
