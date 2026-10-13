# Journal recovery-critical control changes before applying them

Status: Accepted. Date: 2026-10-12. Decision: D-100. D-101 selects normal all-site copies and D-102 selects fenced single-site recovery; implementation and independent trust-root proof remain unproved.

Before an etcd membership, recovery-generation, receiver-cohort, promotion/fence-authority or key-status change, durably append an authenticated prepare record bound to exact command ID, scope, actor approvals and old/new generation; only then apply the etcd quorum transaction and append its verified outcome. A crash or lost reply freezes that same command until both histories are reconciled; never infer success from one side or retry under a new ID. Keep gaps/conflicts quarantined, retain a snapshot anchor and record control transitions only, not business events. This extends D-098/D-099; no journal implementation or measured durability is claimed.

Scoped follow-up: [D-101](0101-all-site-durable-recovery-journal.md) requires normal control prepares to be durably copied at all three sites and serialized by command sequence. D-102 specifies the scoped one-site-loss recovery path needed to preserve D-096 recovery feasibility.

Scoped follow-up: [D-102](0102-fenced-single-site-recovery-with-survivor-journals.md) retains prepare-before-effect during single-site recovery. Both survivor journals must durably record the approved plan before fencing; no prepare receipt alone permits promotion or repeated external effects.
