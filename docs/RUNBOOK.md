# Runbook

No runnable services or deployment steps exist yet.
Add verified commands as implementation proceeds.

## Workspace tooling — verified 2026-10-13
Run from F:\TicketForge with PowerShell 7: `pwsh -File scripts/doctor.ps1 -TimeoutSeconds 20`.
The command checks the exact Go 1.27.2 toolchain and a Linux Docker engine with bounded probes. Its JSON scope is local-tooling-only; native booking tests remain NOT RUN.
Use `pwsh -File scripts/go.ps1 version` and `pwsh -File scripts/go.ps1 mod verify`. The entry forces GOTOOLCHAIN=go1.27.2, preserves literal arguments and restores the caller's environment. The module has no external dependencies yet; no application compile/test is claimed.
Docker Desktop was started with `docker desktop start --detach`; `docker info` confirms Linux, four CPUs and 5161996288 memory bytes. Existing containers/volumes were preserved.

## GitHub workflow — verified 2026-10-13
`gh issue view 2 --repo Aveshek-Singha/TicketForge --comments --json body,comments,labels` reads the current bootstrap ticket and comments explicitly. Use `gh issue edit 2 --repo Aveshek-Singha/TicketForge --add-assignee '@me'` to claim it in PowerShell.
The PRD and 24 tickets are linked in [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md). Native blocking relationships are published; work the unblocked frontier only.
Use fresh per-ticket context with implement, TDD and code-review. The upfront grill is complete and does not restart.
Do not close BK-001 before all required immutable pins and focused readiness evidence exist. Do not run cloud apply or live merchant calls.

## Planned operating references
See [DELIVERY_PACKAGE.md](DELIVERY_PACKAGE.md), [OPERATIONS_PLAN.md](OPERATIONS_PLAN.md) and [VALIDATION_MATRIX.md](VALIDATION_MATRIX.md).
Historical review observation before D-104: the Linux Docker daemon was unavailable and the SDK needed upgrading. The verified workspace-tooling section above records the new state.
Setup, start, seed, test, deploy, rollback and recover commands will be added only after implementation and actual verification. This reference is not a runnable deployment.
