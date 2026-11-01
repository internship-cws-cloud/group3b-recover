# Week 7 Demo Script — Group 3B: Recover It

**Target duration:** 8 minutes maximum
**Demonstration approach:** Live logical restore + recorded PITR evidence

## 1. Introduce the scenario (45 seconds)

"Today we are demonstrating how Group 3B protects and recovers application data after accidental deletion.

We will demonstrate a logical backup and restore using an authorised demonstration database. We will also present evidence from our earlier RDS Point-in-Time Recovery drill.

Our main objective is to recover the data, validate it, and demonstrate that the application can continue working."

## 2. Show the application and existing data (60 seconds)

- Open the application.
- Show that the application is running.
- Display the existing tasks.
- Record and show the original row count.

**Evidence to show:**
- Application screenshot.
- Original task count: `[INSERT MEASURED ROW COUNT]`.
- Latest task timestamp: `[INSERT MEASURED TIMESTAMP]`.

Presenter statement:

"Before the incident, our tasks table contained [COUNT] records. We have recorded this information so that we can compare the recovered data against the original state."

## 3. Demonstrate the data-loss scenario (60 seconds)

- Confirm that the demonstration database and dataset are authorised for destructive testing.
- Record the deletion start time in UTC.
- Delete the demonstration records using the approved procedure.
- Show that the records are no longer present.
- Record the post-deletion row count.

Presenter statement:

"We are simulating accidental data loss in our controlled demonstration environment. We have recorded the incident time and will use our recovery procedure to restore the missing records."

**Safety:** Never execute the deletion against the live shared application database.

## 4. Follow the logical restore runbook (90 seconds)

- Open `docs/restore-runbook.md`.
- Show the logical backup and restoration instructions.
- Use the previously prepared and verified backup file.
- Restore the records using the approved PostgreSQL procedure.
- Record the restore completion time.

Example restore command:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f tasks-data.sql
```

Presenter statement:

"We follow our documented recovery procedure rather than improvising commands. The backup contains the task data needed to restore the demonstration dataset."

The dump must be prepared before the presentation and stored in an approved durable, versioned backup location.

## 5. Validate the recovered data (60 seconds)

Run the approved validation query:

```sql
SELECT
    COUNT(*) AS task_count,
    MAX(created_at) AS newest_task
FROM public.tasks;
```

Compare:
- Original row count.
- Recovered row count.
- Latest task timestamp.
- Representative task records.

Presenter statement:

"We do not consider recovery successful simply because the database is available. We compare the recovered data against our original measurements."

Show the recovered application data if the demonstration environment is connected.

## 6. Present PITR evidence and measured recovery objectives (90 seconds)

Open the recorded evidence from the earlier RDS PITR drill.

Present:

- Incident detection timestamp (UTC): `[MEASURED VALUE]`
- Selected restore timestamp (UTC): `[MEASURED VALUE]`
- New RDS instance available timestamp (UTC): `[MEASURED VALUE]`
- Application restored timestamp (UTC): `[MEASURED VALUE]`
- Measured RTO: `[MEASURED VALUE]`
- Measured RPO: `[MEASURED VALUE]`

Explain:

- **RTO:** The measured time from incident detection until the service was restored.
- **RPO:** The measured amount of data potentially lost, based on the last usable recovered point compared with the incident.

Show the supporting timestamps and screenshots. Do not present estimated values as measured results.

## 7. Explain decisions and close (45 seconds)

Discuss:

- Why seven-day backup retention was selected.
- Why deletion protection and final snapshots are configured.
- Why Terraform `prevent_destroy` is enabled.
- The cost implications of retaining RDS resources.
- What would change with a real production budget.

Closing statement:

"Our recovery approach combines logical backups for fast table-level recovery with RDS Point-in-Time Recovery for broader database incidents. We validate the recovered data before considering application cutover. Our final recovery measurements are supported by recorded evidence."

## Presenter checklist

- [ ] Application is running in the authorised demo environment.
- [ ] Original data count and timestamp recorded.
- [ ] Demonstration dataset is authorised for deletion.
- [ ] Incident time recorded in UTC.
- [ ] Logical backup prepared and verified.
- [ ] Backup stored in an approved durable location.
- [ ] Runbook available.
- [ ] Restored row count and timestamp verified.
- [ ] PITR evidence and timestamps prepared.
- [ ] Measured RTO and RPO entered.
- [ ] Credentials and sensitive information hidden.
- [ ] No unapproved production database deletion or cutover.
