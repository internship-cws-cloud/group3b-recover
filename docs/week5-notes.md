# Week 5 Notes — Recovery Preparation

## Learning objectives
- Confirm AWS identity, Region, and the correct RDS resource before changes.
- Understand RDS automated backups and point-in-time recovery windows.
- Explain why recovery should be performed to a new instance and validated before application cutover.
- Prepare a safe, reviewable runbook with checkpoints and stop conditions.

## Key commands reviewed
```bash
aws sts get-caller-identity

aws rds describe-db-instances \
  --db-instance-identifier group3b-tasks

aws rds describe-db-instances \
  --db-instance-identifier group3b-tasks \
  --query 'DBInstances[0].{Earliest:EarliestRestorableTime,Latest:LatestRestorableTime}'
```

## Important controls
- Verify account and Region before every state-changing command.
- Confirm the restore time is within the actual recovery window and expressed in UTC.
- Use a unique target identifier; do not overwrite or delete the source.
- Keep the database private and use approved security groups.
- Never place credentials in Git, reports, screenshots, or shell history.
- Validate restored data before application cutover.
- Keep the original database unchanged until recovery is approved.

## Completion checklist

- [x] Source DB configuration and recovery settings reviewed.
- [x] Recovery preparation and restore runbook drafted.
- [x] Recovery safety controls and stop conditions documented.
- [ ] Account/Region verification evidence recorded for the recovery exercise.
- [ ] Recovery window and selected restore timestamp documented with current evidence.
- [ ] Snapshot decision and status documented.
- [ ] Restore command reviewed by a second person.
- [ ] PITR restore and application recovery drill completed.

## Reflection

**What was the most important safety check?**

Confirming the AWS account, Region, and source database identifier before making changes. This prevents recovery operations from being performed against the wrong environment. The original database must also remain untouched while a new recovery instance is validated.

**Which configuration values needed verification?**

The database identifier, AWS Region, backup retention period, earliest and latest restorable timestamps, database subnet group, security groups, and database accessibility settings.

**What would you do if the desired restore time was outside the available window?**

Stop the restore attempt and do not select a timestamp outside the reported recovery window. Review available snapshots and other approved recovery options with the team, document the limitation, and obtain approval before proceeding.

## Outstanding work

- Complete an authorised recovery exercise.
- Record actual recovery timestamps and evidence.
- Validate restored data before any application cutover.
- Record measured RTO and RPO only after completing the recovery drill.

**Status:** Recovery preparation documented. Full PITR recovery validation remains outstanding.