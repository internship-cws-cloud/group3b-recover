# RDS Recovery Exercise Report

> Complete after the exercise. Do not claim success until the evidence has been collected and reviewed.

## 1. Summary
- **Exercise/incident ID:** `<ID>`
- **Environment:** `<non-production / approved environment>`
- **AWS account (masked):** `<ACCOUNT>`
- **Region:** `<REGION>`
- **Source DB:** `group3b-tasks`
- **Target restored DB:** `<TARGET-ID>`
- **Status:** `<planned / in progress / successful / unsuccessful>`

## 2. Timeline (UTC)
| Event | Timestamp | Evidence/notes |
|---|---|---|
| Exercise/incident began | `<UTC>` | `<ticket/log>` |
| Snapshot requested/completed | `<UTC>` | `<snapshot ID/status>` |
| Recovery window checked | `<UTC>` | `<earliest/latest>` |
| Restore requested | `<UTC>` | `<target ID>` |
| Target became available | `<UTC>` | `<status output>` |
| Data validation completed | `<UTC>` | `<query results reference>` |
| Application smoke test passed | `<UTC>` | `<test reference>` |
| Service owner accepted recovery | `<UTC>` | `<approval>` |

## 3. Recovery parameters
- **Selected restore point (UTC):** `<TIMESTAMP>`
- **Reason for selection:** `<why this is before the damage and within the valid window>`
- **Engine/version:** `<ENGINE/VERSION>`
- **Subnet group/security groups:** `<VERIFIED VALUES>`
- **Snapshot ID:** `<SNAPSHOT-ID>`

## 4. Validation evidence
| Check | Expected result/baseline | Actual result | Pass/fail |
|---|---|---|---|
| DB status | `available` | `<value>` | `<pass/fail>` |
| Task row count | `<baseline>` | `<value>` | `<pass/fail>` |
| Latest `created_at` | `<expected>` | `<value>` | `<pass/fail>` |
| Representative records | `<expected>` | `<result>` | `<pass/fail>` |
| Application/API smoke test | Successful response | `<result>` | `<pass/fail>` |
| Error logs | No new DB connectivity errors | `<result>` | `<pass/fail>` |

## 5. Recovery objectives
- **Recovery time achieved:** `<service healthy time - incident start time>`
- **RTO target:** `<team-defined target or not supplied>`
- **Recovery point achieved / estimated data loss:** `<latest confirmed recovered write compared with incident time>`
- **RPO target:** `<team-defined target or not supplied>`
- **Targets met?** `<yes/no/not assessed>`

## 6. Issues and mitigations
| Issue | Impact | Action taken | Owner/status |
|---|---|---|---|
| `<issue or none>` | `<impact>` | `<mitigation>` | `<owner/status>` |

## 7. Cutover and rollback
- **Cutover approved by:** `<name/role>`
- **Configuration changed:** `<where/how; no secrets>`
- **Rollback path:** `<restore prior endpoint/configuration and verify>`
- **Source DB/snapshot retention decision:** `<decision and approver>`

## 8. Lessons and follow-up actions
1. `<action, owner, due date>`
2. `<action, owner, due date>`
3. `<action, owner, due date>`

## 9. Sign-off
- **Operator:** `<name/date>`
- **Reviewer/service owner:** `<name/date>`
- **Evidence location:** `<approved repository/ticket>`

## RDS Automated Backups and Recovery Validation

### 1. Automated Backup Configuration

The Amazon RDS database instance `group3b-tasks` was configured with a backup retention period of 7 days.

The AWS CLI verification returned the following results:

| Configuration | Result |
|---|---|
| Database instance | `group3b-tasks` |
| AWS Region | `eu-west-1` |
| Instance status | `available` |
| Backup retention period | 7 days |
| Pending modifications | None |
| Latest restorable time | `2026-10-23T21:09:25+00:00` |

These results confirm that the retention setting has been applied and that AWS reports a latest restorable time.

### 2. Snapshot Verification

The following manual and automated snapshots were listed by AWS RDS:

| Snapshot identifier | Status | Created (UTC) |
|---|---|---|
| `group3b-pre-restore-20261022213215` | `available` | 2026-10-22 21:46:53 |
| `group3b-tasks-snapshot` | `available` | 2026-09-26 02:47:45 |
| `rds:gr21-04` | `available` | 2026-10-23 21:04:57 |

The snapshots were reported as `available` by AWS. The `rds:gr21-04` identifier appears to be an RDS-managed snapshot; its exact purpose should be confirmed from the AWS console or snapshot details if needed.

### 3. Recovery Testing Plan

The next step is to validate that the database can be restored successfully.

1. Select an appropriate snapshot or use point-in-time recovery.
2. Restore it to a separate RDS instance rather than overwriting the live database.
3. Wait until the restored instance status is `available`.
4. Verify the restored database endpoint and connectivity.
5. Validate the application data and confirm that expected tables and records are present.
6. Record the test date, snapshot or recovery point, validation results, and any issues found.
7. Only consider switching the application to the restored database after validation and approval.

### 4. Recovery Test Status

**Status:** Backup configuration verified; recovery validation pending.

The AWS CLI confirms a 7-day backup retention period, no pending modifications, a reported latest restorable time, and three snapshots in `available` status. A successful restore and data validation have not yet been demonstrated by these checks alone.