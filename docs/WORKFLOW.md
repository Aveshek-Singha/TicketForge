# Matt Pocock implementation workflow

## Route
ask-matt selects to-spec, then to-tickets, then implement for this multi-session build.
The [approved spec](BUILD_SPEC.md) is published as [PRD #1](https://github.com/Aveshek-Singha/TicketForge/issues/1).
[Implementation status](IMPLEMENTATION_STATUS.md) links all 24 tickets and their native blocking edges. Do not triage these already approved tickets.
The upfront grill is closed. Missing runtime evidence is implementation work, not a reason to restart requirements questions.

## One ticket per fresh context
Start a fresh session for each implement ticket. Read AGENTS.md, instruction.md, the ticket body/comments, root glossary and relevant accepted ADRs.
Verify every native blocker is closed, then claim the ticket. Work one public/owner/adapter behavior at a time with TDD.
Run relevant type/build and focused tests while coding, then required full checks once at the end. Configuration-only bootstrap work uses actual CLI/static checks; no application behavior test is claimed.
Run separate Standards and Spec reviews against the recorded base. Fix findings, verify again and commit using a meaningful Conventional Commit.
Keep unmet acceptance criteria open. Publish/attach reviewed PRs; do not call a partial ticket complete.

## Skill references
Use the installed ask-matt, to-spec, to-tickets, implement, tdd and code-review skills. Setup already uses GitHub issues and root CONTEXT plus docs/adr.
Test seams were accepted with the validation matrix: public Gateway/API operations, owner command interfaces and explicit adapter/fault boundaries.
Bootstrap version/pin/runtime observations are not native booking, durability, load or physical-recovery validation.
The current phase follows approved defaults and workload dependencies. Ordinary engineering choices need no further upfront interview.

## Context handoff
Use handoff when changing sessions. Store its summary in the operating-system temporary directory and reference canonical artifacts rather than copying their contents.
A handoff does not create a new task, send messages to another task, close issues or certify capabilities.
The next implementation frontier is BK-001, [issue #2](https://github.com/Aveshek-Singha/TicketForge/issues/2). It remains open until all bootstrap acceptance criteria pass.
