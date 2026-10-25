# CC Internship — AWS RDS Recovery Exercise

## Objective
Practice a controlled recovery of the `group3b-tasks` database after accidental data loss, validate the recovered data, and document the recovery time and data-loss window.

## Scope and safety
- This is a runbook for an authorised training environment only.
- Do not run recovery or networking commands until the account, Region, database identifier, restore timestamp, subnet group, security groups, and change approval have been verified.
- Point-in-time recovery creates a **new DB instance**. Do not delete or overwrite the source instance as part of this exercise.
- Replace every `<PLACEHOLDER>` with a verified value. Never paste credentials into shell history or commit secrets to Git.
- The sample values in the original notes included a restore date in 2027; that is in the future relative to this exercise's current date (2026-10-23). Choose a timestamp inside the instance's actual available recovery window instead.

## Project files
- `restore-runbook.md` — operational recovery procedure and verification checklist.
- `demo-script.md` — short walkthrough for presenting the exercise.
- `drills.md` — practice scenarios and expected evidence.
- `report.md` — incident/recovery report template.
- `week5-notes.md`, `week6-notes.md` — learning notes and completion checklist.
- `decisions/README.md` — decision-log guidance.

## Completion criteria
1. Recovery point is within the source DB's reported restorable window.
2. The restored instance reaches `available` and is reachable from an authorised network path.
3. Data checks are recorded and compared with a known-good baseline or expected result.
4. Application endpoint/configuration is changed only after validation and approval.
5. End-to-end smoke tests pass, rollback options are documented, and elapsed recovery time is recorded.
