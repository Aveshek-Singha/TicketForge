# Implementation tracker

## Approved route and evidence
The upfront grill is closed as D-104. Use ask-matt: to-spec, to-tickets, then implement each unblocked ticket in a fresh context with TDD and Standards/Spec review.
PRD: [GitHub #1](https://github.com/Aveshek-Singha/TicketForge/issues/1). The [build spec](BUILD_SPEC.md) synthesizes the approved package.
All 24 tickets exist with native GitHub blocking links. The parent PRD remains open. No required ticket has been declared complete.
Draft bootstrap [PR #26](https://github.com/Aveshek-Singha/TicketForge/pull/26) preserves reviewed partial progress. BK-001 is assigned and in progress. No application service or native correctness, provider, load, physical-recovery or production-readiness result is claimed.

## Foundation and scarce-seat path
| Work | Ticket | State | Blocked by BK |
| --- | --- | --- | --- |
| BK-001 Workspace | [#2](https://github.com/Aveshek-Singha/TicketForge/issues/2) | In progress | None |
| BK-002 Contracts | [#3](https://github.com/Aveshek-Singha/TicketForge/issues/3) | Open | 001 |
| BK-003 Guarded receipt | [#4](https://github.com/Aveshek-Singha/TicketForge/issues/4) | Open | 002 |
| BK-004 Verified access | [#5](https://github.com/Aveshek-Singha/TicketForge/issues/5) | Open | 003 |
| BK-005 Occurrence | [#6](https://github.com/Aveshek-Singha/TicketForge/issues/6) | Open | 003 |
| BK-006 Seat Bundle | [#7](https://github.com/Aveshek-Singha/TicketForge/issues/7) | Open | 004, 005, 007 |

## Admission, money and read path
| Work | Ticket | State | Blocked by BK |
| --- | --- | --- | --- |
| BK-007 FIFO | [#8](https://github.com/Aveshek-Singha/TicketForge/issues/8) | Open | 004, 005 |
| BK-008 Handoff/closure | [#9](https://github.com/Aveshek-Singha/TicketForge/issues/9) | Open | 006, 007 |
| BK-009 Saga | [#10](https://github.com/Aveshek-Singha/TicketForge/issues/10) | Open | 008 |
| BK-010 Sandbox money | [#11](https://github.com/Aveshek-Singha/TicketForge/issues/11) | Open | 009 |
| BK-011 Reliable facts | [#12](https://github.com/Aveshek-Singha/TicketForge/issues/12) | Open | 003 |
| BK-012 Certified reads | [#13](https://github.com/Aveshek-Singha/TicketForge/issues/13) | Open | 004, 005, 008, 009, 010, 011 |

## Identity, entry and recovery path
| Work | Ticket | State | Blocked by BK |
| --- | --- | --- | --- |
| BK-013 MFA/recovery | [#14](https://github.com/Aveshek-Singha/TicketForge/issues/14) | Open | 004, 012 |
| BK-014 Tickets/artifacts | [#15](https://github.com/Aveshek-Singha/TicketForge/issues/15) | Open | 010, 012, 013 |
| BK-015 Gate passage | [#16](https://github.com/Aveshek-Singha/TicketForge/issues/16) | Open | 014 |
| BK-016 Notifications | [#17](https://github.com/Aveshek-Singha/TicketForge/issues/17) | Open | 010, 012, 013, 014 |
| BK-017 Native HA | [#18](https://github.com/Aveshek-Singha/TicketForge/issues/18) | Open | 003 |
| BK-018 Remote coverage | [#19](https://github.com/Aveshek-Singha/TicketForge/issues/19) | Open | 017 |

## Control, deployment and validation path
| Work | Ticket | State | Blocked by BK |
| --- | --- | --- | --- |
| BK-019 Journal/PITR | [#20](https://github.com/Aveshek-Singha/TicketForge/issues/20) | Open | 018 |
| BK-020 Full profiles | [#21](https://github.com/Aveshek-Singha/TicketForge/issues/21) | Open | 012, 013, 016, 017, 018, 019 |
| BK-021 Terraform | [#22](https://github.com/Aveshek-Singha/TicketForge/issues/22) | Open | 020 |
| BK-022 Telemetry/CI | [#23](https://github.com/Aveshek-Singha/TicketForge/issues/23) | Open | 020 |
| BK-023 Harnesses | [#24](https://github.com/Aveshek-Singha/TicketForge/issues/24) | Open | 010, 011, 012, 013, 015, 016, 019, 020, 022 |
| BK-024 Audit/handoff | [#25](https://github.com/Aveshek-Singha/TicketForge/issues/25) | Open | 021, 023 |

## Blocker and completion rules
The GitHub dependency graph is canonical. Only start a ticket when all its native blockers are closed and required capability gates are verified.
Subsequent sessions read the real ticket body/comments plus relevant ADRs. Do not infer completion from this static index; update actual evidence as work lands.
Closing a ticket requires all its acceptance criteria. Partial progress and unavailable pins/runtime stay open and visible.
