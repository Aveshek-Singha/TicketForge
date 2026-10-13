# Place recovery control quorum across three independent sites

Status: Accepted. Date: 2026-10-12. Decision: D-098. D-099 selects quorum-loss restore behavior; cross-region latency, trust-root independence and measured capacity remain pending.

Place one member of the three-voter etcd recovery-control quorum at each independent production site; two voters are required, so any one site may fail while a partition without majority stops new critical authority. Persist receiver/cohort membership, retirement and recovery-generation changes through quorum-backed control; keep audited recovery credentials outside every database rollback domain. Replace remote receivers only after complete compatible history and independent verification, preserving the last exposed-prefix evidence. This extends D-094/D-097 and retains all existing safety and SLO requirements without claiming measured placement or implementation.

Scoped follow-up: [D-099](0099-fenced-recovery-after-control-quorum-loss.md) forbids force-removing a minority or trusting a restored snapshot alone; a new control cluster requires independent post-snapshot authority history and verified physical fencing.
