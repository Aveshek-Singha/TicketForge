# Mistakes

No implementation bugs have been observed yet.

## M-001: Proposed pre-sale lottery before confirming its relevance
Symptom: The user questioned why ordinary ticket booking needs sales opening and a pre-sale lottery.
Cause: The review moved from the stated flash-sale requirement to an unstated pre-sale waiting window.
Fix: Mark the hybrid policy unaccepted and optional; distinguish booking opening from event start; clarify queue activation first.
Lesson: Establish the business scenario before choosing its fairness algorithm.

## M-002: Let the upfront grill expand without a completion boundary
Symptom: The user reports three days of grilling; 101 decisions are recorded and the earlier remaining-question estimate was exceeded.
Cause: Each recovery/control detail created another interview branch without a fixed closeout rule. Unmeasured implementation facts were mixed with choices requiring user input.
Fix: Cap the remaining interview at three decision rounds, prepare routine recommendations independently and present a consolidated architecture/delivery package. Preserve unresolved correctness as explicit gates.
Lesson: End a requirements review when decisions and evidence obligations are clear; another questionnaire cannot prove runtime correctness or capacity.

## M-003: Put the proposed emergency journal record after fencing
Symptom: The previous Review 102 required physical fencing before emergency journal acceptance, although D-100 requires journaling the fencing intent before its effect.
Cause: The proposal mixed permission to prepare a recovery plan with permission to promote a new writer.
Fix: Propose prepare on both verified survivor journals first, then exact fenced phases, then conditional generation change and protected promotion. Accepted as D-102; no implementation exists.
Lesson: A recovery plan may authorize only its guarded next phase. Preparing it does not certify that fencing or promotion already succeeded.

## M-004: Unquoted GitHub assignee in PowerShell
Symptom: gh issue edit rejected an empty --add-assignee argument.
Cause: Unquoted @me was interpreted by PowerShell rather than passed as literal text.
Fix: Quote '@me'. The retry successfully assigned BK-001 issue #2; no duplicate issue was created.
Lesson: Pass CLI arguments literally and check native exit status before treating a mutation as successful.

## M-005: Use a minimum Go version as an exact compiler pin
Symptom: Review found that a newer installed compiler could satisfy go.mod while violating D-103's exact reproducible compiler choice.
Cause: The go directive sets a minimum, not an exact toolchain selection.
Fix: scripts/go.ps1 and the doctor Go subprocess set GOTOOLCHAIN=go1.27.2. Verify with an inherited go1.24.1 value and restore the caller environment.
Lesson: Distinguish a compatibility floor from a deterministic build input. See https://go.dev/doc/toolchain.

## M-006: Treat one successful Docker observation as lasting readiness
Symptom: A later doctor probe returned exit 1 after earlier Linux engine checks passed.
Cause: Direct docker info reports a missing Linux pipe; both WSL distributions are stopped and no Docker backend process is present. Context remains desktop-linux. The stop trigger is unverified.
Fix: Retain the failed current observation, keep BK-001 open and recheck after an authorized Desktop start. Do not attribute this engine shutdown to the Go pin.
Lesson: A tooling observation is point-in-time evidence. A successful startup cannot establish continuing engine or system availability.
