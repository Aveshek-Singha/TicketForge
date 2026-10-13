# Bootstrap review

## Fixed scope
Base: 70ee911, the accepted architecture baseline. Initial candidate: 4d2172f. Issue: [BK-001 #2](https://github.com/Aveshek-Singha/TicketForge/issues/2).
The code-review skill ran independent read-only Standards and Spec agents. Scope is partial workflow/tooling bootstrap, not the complete BK-001 or backend.

## Standards
Initial findings: one documented-standard issue and zero actionable heuristic smells.
The runbook reported both a verified Linux engine and a current unavailable engine. The earlier review observation is now dated historical evidence; subsequent live status is recorded separately.
This fixes instruction.md Rules 1/7 documentation consistency. Shared finite probe handling was appropriate; no speculative-general interface was reported.

## Spec
Initial findings: three issues; highest priority was incomplete exact compiler selection. go.mod is a minimum. The Go command entry and doctor Go subprocess now force GOTOOLCHAIN=go1.27.2.
The ticket-read command omitted its body when no comments existed. The runbook now requests body,comments,labels as JSON.
The contradictory readiness statement is corrected as above. Required outstanding module/action/provider/tool pins and compatibility stay intentionally open, with a PARTIAL dependency manifest.
No unasked scope expansion or false service/native/provider/load/physical proof was found.

## Follow-up verification
The exact compiler entry selects go1.27.2 even with an inherited go1.24.1 setting and restores the caller environment. Empty module verification passes.
The actual absent-engine observation returns ready=false and exit 1. Earlier healthy-engine observations are retained as point-in-time evidence, not continuing availability.
The Inventory hold ticket now explicitly depends on Waiting Room admission as well as verified Auth and prepared occurrence. Native blockers are [#5, #6, #8] for #7; this prevents a fake admission dependency.
The whole BK-001 ticket remains open. Final focused/static checks and review follow-ups are recorded before PR publication.
