# Recovery Drills and Acceptance Criteria

Run these only in an authorised non-production environment. Record the command/output or screenshot for each drill, with credentials and sensitive data redacted.

## Drill 1 — Identify the correct account and Region
**Task:** Confirm the active AWS identity and Region before making changes.

**Evidence:** `aws sts get-caller-identity`, Region, source DB identifier.

**Pass:** Account and Region match the exercise approval. If not, stop.

## Drill 2 — Find the valid recovery window
**Task:** Retrieve earliest and latest restorable timestamps.

**Evidence:** CLI output and the selected UTC timestamp.

**Pass:** The selected point is inside the reported window and before the damage time. No future timestamp is used.

## Drill 3 — Protect current state
**Task:** Create an approved snapshot if permitted.

**Evidence:** Snapshot identifier and status.

**Pass:** Snapshot reaches `available`, or a documented reason and approved alternative are recorded.

## Drill 4 — Restore to a new instance
**Task:** Restore to a unique target identifier using verified network settings.

**Evidence:** Restore command with secrets omitted, target identifier, status, endpoint.

**Pass:** New instance reaches `available`, remains private, and the source instance remains unchanged.

## Drill 5 — Validate data
**Task:** Compare row count, latest timestamps, representative records, and application invariants.

**Evidence:** Queries, redacted results, baseline comparison.

**Pass:** Results match the expected pre-incident state closely enough for the incident owner to approve. Any discrepancy blocks cutover.

## Drill 6 — Test connectivity safely
**Task:** Connect from the approved application/test host and run a read-only query.

**Evidence:** Successful connection and query; security-group rule reviewed.

**Pass:** Only authorised sources can reach the database port; database is not publicly exposed.

## Drill 7 — Application smoke test and rollback plan
**Task:** In a non-production environment, update the endpoint through the supported configuration path and test the API/UI.

**Evidence:** Deployment/change record, API response, logs, rollback endpoint/configuration.

**Pass:** Service works with restored data, errors are absent, and rollback steps are documented.

## Drill 8 — Measure recovery objectives
**Task:** Calculate recovery time and the effective recovery point.

**Evidence:** UTC start/end timestamps, restore timestamp, latest recovered confirmed write.

**Pass:** Achieved RTO/RPO are calculated and compared with the team's target values. Do not invent targets if none were supplied.

## Drill 9 — Failure injection tabletop
Discuss, without damaging a shared environment:
- The chosen restore timestamp is outside the recovery window.
- The subnet group or security group is wrong.
- The database is `available` but the application cannot connect.
- Data checks disagree with the expected baseline.
- The API smoke test fails after cutover.

For each, identify the stop condition, who must be notified, evidence to collect, and rollback/escalation path.
