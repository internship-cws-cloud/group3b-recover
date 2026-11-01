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
- [x] Recovery validation and cutover procedures documented.
- [x] Recovery report structure prepared.
- [ ] Demo delivered with credentials and sensitive data hidden.
- [ ] Recovery report completed with actual evidence references.
- [ ] Issues, deviations, and follow-up owners recorded.
- [ ] Source instance/snapshot retention decision approved.
- [ ] Temporary resources cleaned up only after approval.

## Reflection

**Which checks proved the data was correct?**

The row count, latest timestamp, representative records, and application-specific invariants should be compared with a known-good baseline. A successful database connection alone does not prove that the recovered data is correct.

**What would cause you to stop before cutover?**

A database that is not available, incorrect or incomplete data, failed connectivity, application errors, missing approval, or an unverified rollback plan. Any discrepancy should be investigated before changing the application endpoint.

**What should be automated or clarified before the next recovery exercise?**

Automate backup verification, recovery-window checks, data validation queries, application health checks, and collection of UTC recovery timestamps. Clarify approval responsibilities, recovery targets, rollback procedures, and evidence requirements.

## Outstanding work
- Complete an authorised recovery and validation exercise.
- Perform application cutover only after approval.
- Record actual RTO and RPO using measured timestamps.
- Complete the demonstration and recovery report.

**Status:** Validation, cutover, and reporting procedures documented. Actual recovery validation and measured recovery objectives remain outstanding.