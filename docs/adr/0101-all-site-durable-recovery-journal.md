# Require all-site journal durability for normal control mutations

Status: Accepted. Date: 2026-10-12. Decision: D-101. D-102 scopes single-site emergency behavior; journal implementation, disk evidence and measured latency remain unproved.

Keep one independently authenticated authority-journal copy in each of the three production sites and require durable acknowledgement from all three before normal recovery-critical control mutations. Serialize command IDs/generations; partial or ambiguous writes freeze subsequent changes until reconciled. This ensures any one remaining site has every fully accepted record after loss of the other two, assuming independently verified placement and durable storage. It blocks rare control administration whenever a site is unavailable; D-102 adds the scoped survivor-journal recovery exception while retaining this normal all-site rule.

Scoped amendment: [D-102](0102-fenced-single-site-recovery-with-survivor-journals.md) permits one prepared recovery plan at both verified surviving journals during a declared single-site loss. Physical fencing, native quorum, conditional generation change and guarded promotion remain required; ordinary administration resumes only after restoring all three journal copies.
