# Interview

No features are complete yet.
Add three questions and answers for each completed feature.

## Tooling guard: Why is go.mod insufficient for exact builds?
Q: Why does go.mod alone not pin the exact compiler?
A: Its go directive sets the minimum supported Go version. A newer installed compiler can still be selected. The project entry explicitly selects go1.27.2 and restores the caller's previous environment.

## Tooling guard: What does doctor readiness prove?
Q: Does a successful doctor prove the backend can handle one million users?
A: It only observes the exact local compiler and a responding Linux Docker engine. It does not execute native booking, payment or load validation. Those proofs have separate accepted tests and evidence gates.

## Tooling guard: Why return failure after a previous success?
Q: Why must a missing Docker pipe make the later doctor fail?
A: Infrastructure state changes between observations. The tool reports the current failure and exits one instead of caching an earlier success. The bootstrap ticket stays open until its required readiness and pin criteria are satisfied.
