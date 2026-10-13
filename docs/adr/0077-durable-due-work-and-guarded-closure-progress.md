# Persist expiry work and guard resource closure

Status: Accepted. Date: 2026-10-12. Decision: D-077. Worker safety, coverage, capacity and timing remain unproved.

Expiry notifications and scheduling leases cannot prove permission to close an allocation, so owners persist original-deadline due work with lifecycle transitions and execute it through canonical guarded transactions. Review 077 defines supersession, unknown-commit recovery, complete source audits and separate allocation/unused-lease/claimed-slot progress objectives, including a 1,000-closure/s fixture and excess backlog drain capacity. D-015 is narrowly clarified: matching terminal confirmation with a fence against further claim allocation can retire checkout capacity while preserving confirmed seats and consumed quota; uncertain outcomes retain resources and all original requirements remain.
