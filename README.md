# group3b - Recover it

Cloud Engineering Internship, Cohort 3.

## This group

- **Project:** Recover it
- **Competing group:** see your brief
- **AWS region:** `eu-west-1` (Europe - Ireland)

## Members

| Name | GitHub | Owns |
|---|---|---|
|Yasir Abdul-Rahaman|olooyasir-cmd| - |
|Gideon Awuku|gideonawuku100| - |
| - | - | - |

Fill this in during week 1. Every person should have a row, and by week 5
every row should name something that person owns.

## Running it

_Fill this in as you go. By week 3 someone who has never seen this repo
should be able to follow this section and get the app running._

```
# week 2: deployed by hand in the console - write down the steps here
# week 3: make up
# week 4: push to main
```

## Decisions

Write down why you chose what you chose, in `docs/`. One short file per
decision. You will be asked about these in week 7.

### Database Protection and Teardown

- The `infra/` directory manages the application infrastructure, including the RDS database.
- The RDS database has deletion protection enabled and Terraform `prevent_destroy = true`.
- A normal Terraform destroy of the shared `infra/` configuration is therefore blocked while this protection remains in place.
- The `infra-bootstrap/` directory manages foundational resources, including Terraform state storage and GitHub deployment access. It must be preserved.
- The database has seven-day automated backup retention and a configured final snapshot.
- No database teardown or Terraform destroy has been performed as part of this recovery work.

**Teardown decision:** Pending. We must evaluate the ongoing AWS cost of retaining the database against the alternative of separating database resources into their own Terraform state. No infrastructure changes will be made until the decision is reviewed and authorised.
