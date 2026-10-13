# TicketForge

TicketForge manages event ticket reservations and bookings.

## Language

**Customer Account**:
The stable identity used by a customer to join a waiting room and own seat allocations and bookings; changing a login email or recovering credentials does not create another account. An account does not establish a unique real-world person.
_Avoid_: Login email, IP address, browser tab, verified person.

**Event Occurrence**:
One scheduled performance or instance of an event. The same venue and physical seats may serve different occurrences.
_Avoid_: Event when the schedule instance is ambiguous.

**Event Seat**:
A seat offered for one event occurrence. Its allocation is distinct from the same physical seat at another occurrence.
_Avoid_: Seat when the event occurrence is ambiguous.

**Occurrence Configuration**:
The approved definition of one Event Occurrence's seat layout, schedule and purchase terms. A changed commercial offer does not create another copy of its seats.
_Avoid_: Search document, active allocation, booking confirmation.

**Sales Window**:
The occurrence-specific period in which new seat holds may be created. It is separate from the event duration and the deadlines of existing checkout.
_Avoid_: Event duration, hold lifetime, payment timeout.

**Seat Bundle**:
The complete set of event seats requested together for one event occurrence. Allocation succeeds for the whole set or for none of it.
_Avoid_: Partial reservation when a successful bundle is intended.

**Checkout Quote**:
The fixed price agreement for an exact seat bundle, including currency, price breakdown, and total, established with its successful hold. It remains the agreement for that valid hold and its payment reservation.
_Avoid_: Current catalog price, client-supplied total, merchant net settlement.

**Order**:
A customer's purchase of one complete seat bundle for one event occurrence. Purchases for different occurrences use separate orders.
_Avoid_: Cross-event cart when a single order is intended.

**Order Observation**:
A customer's view of an Order's workflow, seat entitlement and monetary outcomes at their reported observation times. It is separate from a command outcome or permission to change the Order.
_Avoid_: Payment success, command receipt, cross-service atomic snapshot.

**Purchase Quota**:
The limit on a customer account's confirmed tickets and active reserved ticket entitlement for one event occurrence. Starting another checkout does not reset the quota.
_Avoid_: Per-order limit, admission capacity slot.

**Checkout Admission**:
Permission for a sale participant to attempt checkout under the waiting room's capacity control. Admission does not reserve seats or guarantee a purchase.
_Avoid_: Seat allocation, guaranteed ticket.

**Admission Lease**:
A participant's accounted checkout capacity slot for one event occurrence. Its slot remains occupied while checkout is ongoing or its outcome is unresolved, even if the admission credential expires; completed checkout can release this capacity while confirmed seat rights remain.
_Avoid_: Seat hold, credential lifetime.

**Admission Claim**:
An admission lease's assignment to one checkout workflow before seat allocation begins. A claim does not itself reserve seats.
_Avoid_: Active Hold, Confirmed Booking.

**Selection Window**:
The fixed period after checkout admission during which a participant may obtain the first successful active hold. It is separate from the lifetime of a hold that has already succeeded.
_Avoid_: Hold duration, payment reservation duration.

**Queue Entry**:
A participant's accepted place in the waiting room for one event occurrence. Its priority follows server acceptance order while the entry remains valid.
_Avoid_: Seat reservation, guaranteed purchase.

**Active Hold**:
A successful, time-limited reservation that gives its holder exclusive allocation of an event seat while the hold is valid.
_Avoid_: Cache entry, best-effort reservation.

**Payment Reservation**:
An exclusive event seat reservation used during checkout, with its own fixed deadline. It replaces a valid active hold and ends through confirmation or closure.
_Avoid_: Extended hold when the separate checkout deadline is intended.

**Payment Attempt**:
A TicketForge record of one logical payment initiation for an order. Its outcome can remain unknown while provider records are reconciled.
_Avoid_: Provider transaction when the local initiation record is intended.

**Provider Charge**:
A distinct, verified payment charged to a customer by the payment provider. Multiple notifications about the same charge do not represent additional customer payments.
_Avoid_: Payment Attempt, callback count, merchant net settlement.

**Refund Intent**:
A planned return of a specified amount against one provider charge. An intent with a pending or unknown outcome is not a completed refund.
_Avoid_: Refund completion, booking cancellation.

**Fulfillment Charge Binding**:
The assignment of one eligible verified provider charge to fund one Order and its allocation lifecycle. This assignment does not itself establish confirmed seat allocation or completed compensation.
_Avoid_: Payment success, callback count, Confirmed Booking.

**Confirmed Booking**:
A booking recognized by the system as a completed allocation of its full seat bundle. Its event seats must not conflict with other valid allocations.
_Avoid_: Payment success when booking confirmation is intended.

**Booking Cancellation**:
The authorized withdrawal of a confirmed booking's entitlement to its complete seat bundle. It is separate from returning money and does not erase the original confirmation.
_Avoid_: Hold expiry, failed checkout, completed refund.

**Ticket**:
A stable record of one Event Seat in a customer's Confirmed Booking. Its existence records confirmation history and does not by itself establish current seat rights or permission to enter a venue.
_Avoid_: Provider Charge, current seat entitlement, admission credential.

**Ticket Artifact**:
A digital representation of a Ticket that a customer can view or save. A saved artifact does not continuously reflect later changes to the booking's entitlement.
_Avoid_: Current entitlement proof, completed refund, single-use venue entry.

**Venue Check-in**:
A recorded decision accepting one Ticket's first use for entry to its Event Occurrence. It is distinct from checkout admission and actual physical passage.
_Avoid_: Checkout Admission, seat release, proof of physical attendance.

**Entry Credential**:
A secret a holder presents with a Ticket for an authorized venue-entry decision. Sharing it does not transfer the purchaser's account ownership or cancellation and refund rights, and possessing it does not prove attendee identity.
_Avoid_: Public Ticket ID, login token, Checkout Admission, named attendee identity.

**Admission Window**:
The approved period for first entry to one Event Occurrence. It is separate from the Sales Window and from the venue's full Occupancy Interval.
_Avoid_: Sales Window, performance duration, hold deadline.

**Used Event Seat**:
An Event Seat for which first venue entry has been accepted. It cannot be sold again for that occurrence, even if the original booking is revoked; recorded use does not prove current physical occupation.
_Avoid_: Currently occupied physical seat, available cancelled seat, reusable ticket.

**Cancellation Terms**:
The purchase-specific conditions that define permitted booking cancellation and the corresponding refund amount. They remain distinct from the current catalog's terms and from completed refunds.
_Avoid_: Current catalog policy, checkout failure, refund completion.

**Event Cancellation**:
The authorized termination of one Event Occurrence and its associated booking withdrawal and refund obligations. It does not cancel other occurrences of the same event or establish that refunds are complete.
_Avoid_: Series cancellation, catalog flag, completed refund.

**Operator Recovery Case**:
An accountable investigation of an unresolved booking or monetary outcome. It identifies the evidence and responsibility needed for safe resolution; opening a case does not establish payment or refund completion.
_Avoid_: Refund completion, permission to bypass reservation or payment rules.

**Replacement Occurrence**:
A separately defined Event Occurrence offered in place of a cancelled occurrence. Linking the two does not transfer existing bookings, seat rights or payments.
_Avoid_: Edited original occurrence, transferred booking, completed refund.

**Venue Space**:
A physical portion of a venue that can be scheduled independently when its use does not conflict with another portion. Different names do not establish separate physical spaces.
_Avoid_: Event Seat, layout version, independent space without physical validation.

**Occupancy Interval**:
The period for which an occurrence needs its venue resources, including setup, customer access, performance and teardown.
_Avoid_: Performance duration, Sales Window, checkout deadline.

**Venue Reservation**:
A claim on the venue resources needed for one occurrence during its Occupancy Interval. It is separate from any customer's seat allocation or booking.
_Avoid_: Active Hold, Admission Lease, Confirmed Booking.

**Availability View**:
An advisory view of observed seat availability for an Event Occurrence. It neither reserves a seat nor guarantees that a later hold will succeed.
_Avoid_: Active Hold, exclusive allocation promise, Confirmed Booking.

**Queue Presence**:
A waiting participant's time-bounded indication of continued participation. Losing current presence can suspend admission eligibility without retiring the Queue Entry or its accepted priority.
_Avoid_: Queue membership, Admission Lease, Selection Window, Active Hold.

**Gate Staff Assignment**:
A named staff member's permission to operate within specified venue, occurrence and gate boundaries. It is distinct from customer ownership and financial recovery authority.
_Avoid_: Customer session, scanner device ID, unrestricted administrator.

**Scanner Lane**:
One assigned gate execution stream with an ordered check-in and passage-report history. Changing its operator or device does not resolve its earlier unknown outcomes.
_Avoid_: HTTP connection, browser tab, physical passage proof.

**Passage Report**:
A scoped staff observation of passed, not-passed or unknown passage for one exact Venue Check-in outcome. It does not prove physical attendance or erase recorded use.
_Avoid_: First-use reset, entry permission, confirmed physical attendance.

**Notification Intent**:
A planned notice to one Customer Account about one exact owner fact through one channel. Its existence does not establish that an external message reached a mailbox or was read.
_Avoid_: Provider Charge, current entitlement, delivered email, proof of attendance.

**Notification Attempt**:
One recorded submission effort for a Notification Intent through its channel and bound destination. Its outcome can remain unknown after response loss.
_Avoid_: New booking transition, mailbox delivery proof, automatically permitted financial retry.

**Contact Binding**:
An Auth-owned association between a Customer Account and a versioned contact destination with a defined purpose and status. Retiring that association does not retire the account or transfer its bookings.
_Avoid_: Raw email string, Customer Account ID, proof of current human identity.

**Auth Challenge**:
A purpose-bound secret for one account verification or recovery flow, tied to its exact contact and original expiry. Receiving or resending it does not create a new account permission or lifetime.
_Avoid_: Login session, Entry Credential, Notification Intent, proof of unique person.

**Mailbox Key**:
The address identity used by Auth under its explicit comparison profile. Equivalent provider delivery destinations or visual similarity do not by themselves make two Mailbox Keys equal.
_Avoid_: Customer Account, unique human identity, provider alias group.

**Retired Contact Guard**:
A retained association protecting a former Contact Binding from automatic reuse by another account. It grants no login, recovery or message-routing permission.
_Avoid_: Active verified contact, available signup address, account ownership proof.

**Recovery Kit**:
Account-bound saved recovery evidence given to a verified customer for safekeeping outside ordinary email delivery. Its acknowledgement does not prove safe storage or grant daily login authority.
_Avoid_: Reset email, current mailbox ownership, booking receipt, proof of a unique person.

**Account Recovery Workflow**:
A scoped process that collects prior account evidence and prepares an exact guarded credential/contact replacement. Preparation or a support case does not restore ordinary or privileged access.
_Avoid_: Password-only login, raw MFA override, booking cancellation, guaranteed account restoration.

**Session Authority Proof**:
An Auth-owned time-bounded observation of a specific session's permission within its defined scope and original observation time. It is separate from a login credential, a fresh authentication ceremony or authority to execute a domain command.
_Avoid_: JWT signature check alone, enrollment evidence, new login, current booking entitlement.

**Authentication Attempt**:
An admitted verification of one exact set of authentication evidence for an account or canonical identifier and purpose. An unknown outcome does not become a new attempt.
_Avoid_: Public request offer, authenticated session, consumed authenticator, Payment Attempt.

**Recovery Quarantine**:
A scope whose recovered history cannot establish current rights or safe effects. Its evidence and obligations remain, while affected authority stays blocked.
_Avoid_: Completed service recovery, cancelled booking, unused seat, erased account, proof of non-execution.

**Regional Coverage Gate**:
A protected action may proceed only after independent off-region receivers durably cover its exact committed history. Coverage proves recoverable bytes; current business guards still decide whether the action is allowed.
_Avoid_: Async archive freshness, permission to repeat an effect, replica count without site independence.

**Recovery Control Quorum**:
The majority of independent etcd voters allowed to update failover, receiver membership and recovery generation. It records control state; it does not prove that business WAL or external-effect history is recoverable.
_Avoid_: PostgreSQL replica cohort, three-node count without placement, permission to bypass fencing.

**Recovery Authority Journal**:
An independent monotonic record of authorized control changes used to reconcile a restored etcd snapshot. A missing or ambiguous entry blocks recovery authority.
_Avoid_: etcd snapshot, business Outbox, audit log that can be silently rewritten.
