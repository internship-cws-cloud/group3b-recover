
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role: pulls images and sends logs to CloudWatch.
resource "aws_iam_role" "exec" {
  name               = "${var.group_name}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS task role: grants the running container permissions needed by ECS Exec.
resource "aws_iam_role" "task" {
  name               = "${var.group_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy" "ecs_exec" {
  name = "ECSExecSSMMessages"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = "*"
    }]
  })
}

# Application logs.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.group_name}"
  retention_in_days = 7
}

# Existing ECR repository.
data "aws_ecr_repository" "app" {
  name = "task-tracker"
}

# ECS task definition.
resource "aws_ecs_task_definition" "web" {
  family                   = "${var.group_name}-task-tracker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 256
  memory = 512

  execution_role_arn = aws_iam_role.exec.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name  = "web"
    image = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"

    essential = true

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    environment = [
      {
        name  = "APP_VERSION"
        value = var.image_tag
      },
      {
        name  = "DATABASE_URL"
        value = "postgresql://tasks:${var.db_password}@${aws_db_instance.tasks.address}:5432/tasks"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"

      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# ECS cluster.
resource "aws_ecs_cluster" "main" {
  name = "${var.group_name}-cluster"
}

# ECS service.
resource "aws_ecs_service" "web" {
  name                   = "${var.group_name}-svc"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.web.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.app.id]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web"
    container_port   = var.container_port
  }

  # Create the listener before registering service targets.
  depends_on = [aws_lb_listener.http]
}
