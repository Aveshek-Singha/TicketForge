# Close new sales before start without cancelling valid checkout

Status: Accepted. Date: 2026-10-11. Decision: D-052.

Late new sales can conflict with the chosen two-minute hold and five-minute payment windows. Close new holds seven minutes before occurrence start and new admission another sixty seconds earlier, with explicit opening and guarded owner time checks. Existing eligible checkout keeps its original deadlines, distinct from Event Cancellation; see D-052 and Review 052 for timing limits and unproved clock guarantees.
