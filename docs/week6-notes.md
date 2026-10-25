# Week 6 Notes — Validation, Cutover, and Reporting

## Learning objectives
- Validate restored data with more than a single row-count query.
- Test connectivity from the correct network path without making a database public.
- Describe an approved application endpoint cutover and rollback path.
- Calculate achieved recovery time and recovery point from recorded timestamps.

## Validation checklist
- [ ] Target DB status is `available`.
- [ ] Endpoint and port are recorded without exposing credentials.
- [ ] Row count and latest timestamp are compared with a known-good baseline.
- [ ] Representative records and application-specific invariants are checked.
- [ ] API/UI smoke test succeeds.
- [ ] Logs show no new database connection errors.
- [ ] Service owner approves cutover.

## RTO and RPO
- **RTO (Recovery Time Objective):** the target maximum time to restore service. Record the actual elapsed time from incident start to verified healthy service.
- **RPO (Recovery Point Objective):** the target maximum acceptable data-loss window. Record the restore point and latest confirmed recovered write, then compare them with the incident time.
- Do not invent the organisation's target values; mark them as not supplied if no target has been defined.

## Completion checklist
- [ ] Demo delivered with credentials and sensitive data hidden.
- [ ] Recovery report completed with evidence references.
- [ ] Issues, deviations, and follow-up owners recorded.
- [ ] Source instance/snapshot retention decision approved.
- [ ] Temporary resources cleaned up only after approval.

## Reflection
- Which checks proved the data was correct?
- What would cause you to stop before cutover?
- What should be automated or clarified before the next recovery exercise?
