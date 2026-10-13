# Use SSLCOMMERZ sandbox for a Bangladesh merchant

Status: Accepted. Date: 2026-10-10. Decision: D-005.

The user selected Bangladesh as the intended merchant country and SSLCOMMERZ sandbox-only integration for this delivery, preserving end-to-end payment and refund workflows without real-money transactions. Validate the actual sandbox contract instead of assuming another provider's semantics; sandbox results do not prove live onboarding, settlement, bank behavior, or production payment readiness. Keep future live requirements, onboarding, and fees documented separately; a local failure simulator was only a proposal at this decision, and D-069 now accepts isolated supplemental provider testing without replacing sandbox integration.
