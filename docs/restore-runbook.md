# AWS RDS Point-in-Time Recovery Runbook

## Purpose
Recover the `group3b-tasks` database to a point immediately before accidental data loss, validate it, and switch the application only after the restored copy passes checks.

> **Safety:** Run only in the authorised internship AWS account and Region. Confirm the Region explicitly. The restore creates a new instance; it does not repair the existing instance in place. Do not delete the source instance.

## Logical Backup and Single-Table Recovery

### Purpose

Provide a faster recovery path for the `tasks` table using a prepared PostgreSQL data dump. This procedure is separate from RDS Point-in-Time Recovery (PITR).

The application uses SQLAlchemy and the verified `tasks` table contains:

| Column | Type |
|---|---|
| `id` | Integer, primary key |
| `title` | String(200), NOT NULL |
| `done` | Boolean, NOT NULL |
| `created_at` | DateTime |

### 1. Prepare the logical backup

Prerequisites:
- Confirm the correct database and AWS account.
- Obtain approval to access the database.
- Ensure PostgreSQL client utilities (`pg_dump` and `psql`) are installed.
- Obtain the database connection securely through the approved credential mechanism.
- Confirm the schema is `public` before using the example commands.

Use the `DATABASE_URL` environment variable without printing its value:

```bash
test -n "$DATABASE_URL" || {
  echo "DATABASE_URL is not set"
  exit 1
}

pg_dump \
  --data-only \
  --column-inserts \
  --table=public.tasks \
  "$DATABASE_URL" \
  > tasks-data.sql
```

Check that the dump file exists and is non-empty:

```bash
test -s tasks-data.sql && echo "Logical dump created"
```

Store the approved backup in durable storage with versioning, such as the project's approved S3 backup bucket. A laptop-only copy is not sufficient for the final project requirement.

### 2. Validate the backup

Record:
- Backup creation time in UTC.
- Database and table name.
- Dump file size.
- Row count before backup.
- Backup file location.
- Backup owner.

Protect the dump because it contains application data. Do not commit it to Git or upload it to an unapproved location.

### 3. Restore the table

**WARNING: The following restore procedure can overwrite existing application data. Do not execute it against the live database without explicit approval and a verified backup.**

First, confirm the target database and inspect the current row count.

The controlled drill must use an approved test environment or an explicitly approved recovery window.

After authorization, the table's existing rows can be cleared using:

```sql
DELETE FROM public.tasks;
```

Restore the prepared dump:

```bash
psql "$DATABASE_URL" \
  -v ON_ERROR_STOP=1 \
  -f tasks-data.sql
```

The dump uses column inserts so that original task IDs are preserved.

### 4. Validate the recovered data

Run:

```sql
SELECT COUNT(*) AS task_count,
       MAX(created_at) AS newest_task
FROM public.tasks;

SELECT id, title, done, created_at
FROM public.tasks
ORDER BY id
LIMIT 10;
```

Compare the recovered row count and representative records with the recorded pre-backup evidence.

Also verify the PostgreSQL ID sequence after restoring explicit task IDs.

Do not assume the sequence name. Inspect the actual PostgreSQL column definition and identify the sequence associated with `public.tasks.id`.

Use the following read-only query when an approved database connection is available:

```sql
SELECT pg_get_serial_sequence('public.tasks', 'id');
```

### 5. Record the logical recovery measurement

Record:
- Restore start time in UTC.
- Restore completion time in UTC.
- Rows before recovery.
- Rows after recovery.
- Whether original IDs were preserved.
- Application verification result.
- Measured logical recovery duration.

Do not report a recovery time until the drill has actually been performed.

**Safety:** Do not run the deletion or restore commands until the recovery target, backup, credentials, and approval have been verified.

## 0. Record incident details and protect the current state
Record UTC start time, incident owner, AWS account ID, Region, source DB identifier, approximate damage time, application impact, and approval/change ticket.

```bash
aws sts get-caller-identity
aws configure get region
aws rds describe-db-instances \
  --db-instance-identifier group3b-tasks \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Engine:Engine,EngineVersion:EngineVersion,Endpoint:Endpoint.Address,AZ:AvailabilityZone,BackupRetention:BackupRetentionPeriod}'
```

Confirm the returned account and Region are correct before continuing. If policy and permissions allow, take a snapshot of the current source state. Use a unique, approved identifier:

```bash
aws rds create-db-snapshot \
  --db-instance-identifier group3b-tasks \
  --db-snapshot-identifier <UNIQUE-PRE-RESTORE-SNAPSHOT-ID>
```

Wait for the snapshot to complete and record its identifier. If the source is unavailable or snapshot creation is not appropriate, record that fact and follow the incident lead's approved alternative.


## 1. Check the point-in-time recovery window

```bash
aws rds describe-db-instance-automated-backups \
  --db-instance-identifier group3b-tasks \
  --query 'DBInstanceAutomatedBackups[0].{Status:Status,Retention:BackupRetentionPeriod,Earliest:RestoreWindow.EarliestTime,Latest:RestoreWindow.LatestTime}' \
  --output table'
```

If the query does not return the expected fields, inspect the full DBInstanceAutomatedBackups[0] response and confirm the correct AWS Region. Select a restore timestamp **after the earliest restorable time and before the latest restorable time**, and just before the known damage. Confirm the timezone is UTC. Do not use a future timestamp. Record why this point was selected.

## 2. Capture source configuration

Record the source engine/version, DB instance class, storage settings, encryption/KMS requirements, DB subnet group, VPC security groups, parameter/option groups, monitoring settings, and relevant tags. Check whether the restored DB will need to be private and which application security group must reach it. Use the source configuration as a reference, but do not blindly copy values that are not valid for the target Region/account.

## 3. Restore to a new DB instance

The following is a template. Replace all placeholders with verified values. Confirm that the target identifier does not already exist and that the chosen DB class and subnet/security-group settings are valid.

```bash
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier group3b-tasks \
  --target-db-instance-identifier <NEW-RESTORED-DB-ID> \
  --restore-time <VALID-UTC-RESTORE-TIMESTAMP> \
  --db-subnet-group-name <VERIFIED-DB-SUBNET-GROUP> \
  --vpc-security-group-ids <VERIFIED-SECURITY-GROUP-ID> \
  --no-publicly-accessible
```

Notes:
- This command assumes a standard RDS DB instance. Check engine-specific requirements before using it.
- The original notes used `group3b-db-subnets`, `sg-0abc123`, and `db.t4g.micro` as examples; verify actual values rather than assuming they exist.
- If the engine, encryption, or organisational policy requires additional parameters, add them after reviewing the AWS CLI documentation and source configuration.
- Do not make the database public merely to simplify testing.

Wait for the new instance to become available:

```bash
aws rds wait db-instance-available \
  --db-instance-identifier <NEW-RESTORED-DB-ID>

aws rds describe-db-instances \
  --db-instance-identifier <NEW-RESTORED-DB-ID> \
  --query 'DBInstances[0].{Status:DBInstanceStatus,Endpoint:Endpoint.Address,Port:Endpoint.Port,Engine:Engine,Version:EngineVersion,AZ:AvailabilityZone}'
```

Recovery duration depends on engine, size, and AWS conditions. Start the recovery timer at Step 0, not when the wait command begins.

## 4. Validate the restored data before switching traffic

Connect from an approved host that has network access to the private DB. Use a secret manager or approved credential mechanism; do not put passwords directly in command history. The original notes use PostgreSQL on port 5432, so confirm the actual engine and database name first.

Example PostgreSQL checks (adapt table/column names to the actual schema):

```sql
SELECT COUNT(*) AS task_count, MAX(created_at) AS newest_task
FROM tasks;

SELECT COUNT(*) AS rows_at_or_after_damage_time
FROM tasks
WHERE created_at >= TIMESTAMPTZ '<DAMAGE-TIME-UTC>';
```

Compare counts and timestamps with known-good application logs, a baseline, or the expected state immediately before the incident. Also validate representative records, recent updates/deletes, constraints, indexes, and application-specific invariants. A row count alone is not sufficient. Capture the SQL used and redacted results in the report.

**Stop here if checks fail.** Do not repoint the application. Investigate another restore timestamp or escalate to the incident lead.

## 5. Repoint the application using the approved deployment path

1. Obtain approval from the incident/change owner.
2. Update the database endpoint in the application's supported configuration or secret store; do not hard-code it into source code.
3. Confirm the application security group can reach the DB security group on the correct database port. Keep the DB private.
4. Deploy/restart using the team's normal process.
5. Keep the old instance and its snapshot until recovery is accepted and retention policy permits cleanup.

Do not run a guessed task-definition update or replace the endpoint in production without identifying the actual service, task definition, secret/configuration mechanism, and rollback process.

## 6. Verify from the outside

Use the actual ALB/API endpoint and a known read-only smoke test:

```bash
curl -fsS "https://<APP-HOST>/api/tasks" | head
```

If the training endpoint is HTTP-only, use the approved URL instead. Verify the UI, API response, expected records, logs, and absence of database connection errors. Do not expose sensitive records in screenshots or logs.

## 7. Stop the clock and close out

Record:
- **Recovery Time (RTO achieved):** incident start to service verified healthy.
- **Recovery Point / data loss (RPO achieved):** latest confirmed data recovered versus incident time.
- Restore timestamp, source/target identifiers, snapshot ID, and AWS Region.
- Validation queries/results, smoke-test evidence, and approval to switch traffic.
- Issues, deviations, owner, follow-up actions, and cleanup/retention plan.

Only remove temporary resources after the owner approves, evidence is saved, and retention requirements are met.
