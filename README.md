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
|Yaw Kyeremeh| - | - |
|⁠Felix Essun| - | - |
|Albert Phinehas Owusu| - | - |
|Dominic Boadu Agyenim| - | - |
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

🚀 AWS Infrastructure Recovery & Deployment with Terraform
Over the past few weeks, I worked on an AWS infrastructure project where I used Terraform to recover, manage, deploy, and troubleshoot a containerized application environment.
The project involved provisioning and managing an application stack using:
🔹 Terraform – Infrastructure as Code
🔹 AWS ECS Fargate – Container orchestration
🔹 Amazon ECR – Docker image registry
🔹 Application Load Balancer (ALB) – Application traffic routing
🔹 Amazon RDS PostgreSQL – Managed database
🔹 Amazon CloudWatch Logs – Container logging
🔹 AWS IAM – Roles and permissions
🔹 Amazon VPC & Security Groups – Network security
🏗️ Architecture
The application flow was designed around:
Internet → ALB → ECS Fargate → PostgreSQL RDS
The ECS application container listened on port 8080, while the ALB exposed HTTP traffic on port 80.
Security groups were configured so that:
•	The ALB accepted HTTP traffic.
•	The application accepted traffic only from the ALB.
•	PostgreSQL accepted traffic only from the application security group.
🔧 Challenges I Encountered
This project became particularly valuable because the infrastructure did not work perfectly on the first attempt.
I encountered and resolved a number of real-world Infrastructure-as-Code issues.
1️⃣ Existing AWS infrastructure
Some resources already existed in AWS while Terraform did not initially have them in its state.
I had to understand the difference between:
•	Resources existing in AWS
•	Resources tracked by Terraform
•	Resources that Terraform planned to create
This led me to use Terraform state management and imports rather than blindly recreating infrastructure.
________________________________________
2️⃣ Terraform state and tainted resources
Several resources became marked as tainted after interrupted or failed deployments.
Examples included:
•	Security groups
•	ECS cluster
•	ALB target group
•	ALB listener
•	ECS task definition
Terraform therefore wanted to replace resources that were actually usable.
I learned how to inspect the Terraform plan and safely use commands such as:
terraform untaint
when the existing AWS resource was valid and did not need replacement.
________________________________________
3️⃣ IAM permission errors
One of the biggest lessons was how much Terraform depends on AWS IAM permissions.
During deployment, different API operations failed because the deployment IAM user did not have specific permissions.
Examples included:
•	ec2:DescribeVpcAttribute
•	ec2:DescribeSecurityGroups
•	elasticloadbalancing:CreateLoadBalancer
•	elasticloadbalancing:CreateListener
•	elasticloadbalancing:DescribeListeners
•	elasticloadbalancing:ModifyLoadBalancerAttributes
•	ecs:RegisterTaskDefinition
•	ecs:DescribeTaskDefinition
•	ecs:CreateService
•	ecs:DescribeServices
•	iam:PassRole
•	rds:DescribeDBInstances
•	CloudWatch Logs permissions
Instead of immediately giving the deployment user administrator access, I progressively identified the missing API actions and updated the IAM policy.
This reinforced an important principle:
Infrastructure automation is only as capable as the permissions granted to its deployment identity.
________________________________________
4️⃣ Docker image and ECR
The ECS task definition referenced:
task-tracker:v1
in Amazon ECR.
An early deployment failed because the expected image was not available in the ECR repository.
This demonstrated an important dependency:
ECS cannot start a task successfully if the referenced container image cannot be pulled from ECR.
I therefore had to verify the local Docker image, ECR repository, AWS region, authentication, and image tag.
________________________________________
5️⃣ AWS region mismatch
I also encountered an ECR authentication issue caused by using the wrong AWS region.
The infrastructure was running in:
eu-west-1
but an earlier ECR login targeted another region.
That experience reinforced the importance of consistently verifying:
•	AWS region
•	ECR registry URL
•	Terraform provider region
•	ECS cluster region
•	RDS region
________________________________________
6️⃣ Security group conflicts
Terraform attempted to manage security group rules that already existed in AWS.
AWS returned duplicate permission errors when Terraform tried to create rules that were already present.
The solution was to understand the difference between AWS's default security-group behavior and explicitly managed Terraform rules.
I adjusted the Terraform configuration so that existing default egress behavior was not duplicated.
________________________________________
7️⃣ ALB and ECS dependencies
The ALB, target group, listener, ECS service, and task definition have dependencies that must be respected.
A failure in one part of the deployment could prevent another resource from being created or read correctly.
This taught me to use:
terraform plan
as a dependency and state diagnostic tool rather than simply treating it as a preview before apply.
________________________________________
8️⃣ Terraform destroy and IAM permissions
When I eventually decided to tear down the environment, I encountered another set of IAM permission issues.
Destroy operations require different API actions from deployment.
For example:
•	ecs:DeleteCluster
•	ecs:DeregisterTaskDefinition
•	elasticloadbalancing:DeleteListener
•	ec2:RevokeSecurityGroupIngress
•	iam:DetachRolePolicy
This was an important lesson:
Create permissions and destroy permissions are not necessarily the same.
________________________________________
📚 Key Lessons
This project significantly improved my understanding of Infrastructure as Code and AWS.
Some of my biggest takeaways were:
✅ Terraform state is critical when managing existing infrastructure.
✅ terraform plan is one of the most useful debugging tools in Terraform.
✅ AWS IAM permissions need to match the actual API operations Terraform performs.
✅ Failed deployments can leave resources in partially-created or tainted states.
✅ ECS, ECR, ALB, IAM, networking, and RDS have important dependencies.
✅ Region consistency is essential across AWS services.
✅ Infrastructure destruction requires just as much permission planning as infrastructure creation.
✅ Least-privilege IAM is preferable to simply granting broad administrator permissions.
🎯 Final Takeaway
What initially looked like a straightforward Terraform deployment turned into a practical exercise in cloud infrastructure recovery, IAM troubleshooting, state management, networking, container deployment, and AWS service dependencies.
The biggest lesson wasn't simply learning Terraform syntax.
It was learning how to diagnose infrastructure systematically when real AWS resources, Terraform state, IAM permissions, and application dependencies don't perfectly match.
This experience has given me a much stronger foundation for working with AWS, Terraform, DevOps, and Infrastructure as Code.
