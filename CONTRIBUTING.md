# Contributing

## Issue-first work
Read AGENTS.md, instruction.md, the root glossary and relevant accepted ADRs before coding.
Use the approved GitHub PRD and dependency-linked tickets. Claim one unblocked ticket and read its body/comments. Do not close a ticket with unmet acceptance criteria.
Use feat/BK-<number>-<purpose> or fix/BK-<number>-<purpose> branches from main. Preserve existing history; do not force-push shared branches.

## Implementation and review
Use implement with TDD at the approved public/owner/adapter seams. Add one failing behavioral test, implement it, then continue the next vertical slice.
Keep owner persistence/domain imports separate. Do not weaken safety guards to make a simulator or free deployment pass.
Run relevant checks, then a separate Standards and Spec review against the recorded base commit before the final commit.
Use Conventional Commits and real issue references. PR descriptions explain behavior, validation and remaining limitations. Merge only with relevant passing checks and visible review.

## Evidence and documentation
Update decisions, concepts, learning log, questions, mistakes, architecture and runbook as applicable. Each documentation entry is at most ten lines.
For each completed feature, add three interview questions and answers. Code comments cite applicable D-IDs.
Label runtime, native, simulated and physical evidence correctly. Never mark an unexecuted test or unfinished feature complete.

## Secrets and infrastructure
Use placeholder examples and external secret stores. Never stage credentials, private keys, Terraform state or customer data.
Public/fork CI receives no provider or deployment credentials. No paid runners or services are authorized.
Cloud rollout waits for a concrete reviewed free-eligible plan and applicable safety evidence. Use compatible image/schema rollback or forward repair; never reset financial/identity history.
