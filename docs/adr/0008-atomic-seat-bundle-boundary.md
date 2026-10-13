# One event occurrence per atomic seat bundle and order

Status: Accepted. Date: 2026-10-10. Decision: D-008.

Each reservation and order targets one event occurrence and the entire requested seat bundle; hold acquisition, conversion to a payment reservation, and allocation confirmation are all-or-nothing, without silent partial fulfillment or seat substitution. Tickets for different event occurrences use separate orders, making cross-event all-or-nothing purchasing outside this accepted purchase contract. Bundle contention and compatible transaction and Redis hash-slot boundaries must be addressed without reducing the 1 million concurrent user target; bundle limits, adjacency selection, inventory types, and physical partitioning remain unresolved.
