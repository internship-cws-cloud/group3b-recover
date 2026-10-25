# Week 5 Notes — Recovery Preparation

## Learning objectives
- Confirm AWS identity, Region, and the correct RDS resource before changes.
- Understand RDS automated backups and point-in-time recovery windows.
- Explain why recovery should be performed to a new instance and validated before application cutover.
- Prepare a safe, reviewable runbook with checkpoints and stop conditions.

## Key commands practiced
```bash
aws sts get-caller-identity
aws rds describe-db-instances --db-instance-identifier group3b-tasks
aws rds describe-db-instances --db-instance-identifier group3b-tasks \
  --query 'DBInstances[0].{Earliest:EarliestRestorableTime,Latest:LatestRestorableTime}'
```

## Important controls
- Verify account and Region before every state-changing command.
- Confirm restore time is within the actual recovery window and in UTC.
- Use a unique target identifier; do not overwrite or delete the source.
- Keep the DB private and use approved security groups.
- Never place credentials in Git, reports, screenshots, or shell history.

## Completion checklist
- [ ] Account/Region verification documented.
- [ ] Source DB configuration recorded.
- [ ] Recovery window and selected timestamp recorded.
- [ ] Snapshot decision and status documented.
- [ ] Restore command reviewed by a second person.
- [ ] Risks and stop conditions explained.

## Reflection
- What was the most important safety check? `<write response>`
- Which configuration values needed verification? `<write response>`
- What would you do if the desired restore time was outside the available window? `<write response>`
