# Demo Script — RDS Point-in-Time Recovery

**Target duration:** 5–7 minutes

## 1. Introduce the scenario (45 seconds)
“Today I’ll demonstrate how we would recover the `group3b-tasks` RDS database after accidental data loss. The priority is to restore to a point before the damage, validate the data, and only then reconnect the application. This is a controlled training workflow; I will not make destructive changes to the source database.”

## 2. Establish the environment (45 seconds)
- Show the authorised AWS account and Region using `aws sts get-caller-identity` and the configured Region.
- Show the source DB status and key configuration.
- Explain that the restore creates a separate DB instance and preserves the source for comparison and rollback.

## 3. Confirm the recovery window (45 seconds)
- Show `EarliestRestorableTime` and `LatestRestorableTime`.
- Explain how the incident time is used to choose a valid UTC restore point immediately before the damage.
- Highlight that the timestamp must be within the reported window and cannot be in the future.

## 4. Restore (60–90 seconds)
- Review the command with placeholders replaced by verified values.
- Explain the private subnet and security-group choices.
- Start the restore and show the target instance status. If the restore takes longer than the demo, use previously captured evidence and clearly label it as recorded evidence.

## 5. Validate before cutover (60–90 seconds)
- Connect through the approved network path.
- Run a row-count/latest-timestamp query and representative record checks.
- Compare with the expected pre-incident state. Explain that a count alone does not prove correctness.

## 6. Smoke test and close (45 seconds)
- Describe or demonstrate the approved application endpoint update.
- Call the API and check the UI/logs.
- State the measured recovery time, selected recovery point, validation outcome, and remaining follow-ups.

## Closing statement
“The key control is validate first, switch traffic second. We preserve the original database, record the recovery evidence, and keep a clear rollback path until the service owner accepts the recovery.”

## Presenter checklist
- [ ] Confirm account, Region, and authorisation.
- [ ] Use a valid restore timestamp from the actual recovery window.
- [ ] Hide credentials and sensitive customer data.
- [ ] Do not perform an unapproved production cutover.
- [ ] Have redacted screenshots/output ready if AWS provisioning exceeds demo time.
