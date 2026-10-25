# RDS needs to be told which subnets it may live in.

resource "aws_db_subnet_group" "db" {
  name       = "${var.group_name}-db"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_db_instance" "tasks" {
  identifier     = "${var.group_name}-tasks"
  engine         = "postgres"
  engine_version = "16"

  # The smallest and cheapest instance for this project.
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name  = "tasks"
  username = "tasks"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  # Private database; not directly reachable from the internet.
  publicly_accessible = false
  multi_az            = false

  # Week 5–6 recovery configuration.
  backup_retention_period = 7
  apply_immediately       = true
  backup_window           = "02:00-03:00"
  copy_tags_to_snapshot   = true

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.group_name}-final-${formatdate("YYYYMMDDhhmm", timestamp())}"

  lifecycle {
    prevent_destroy = true
  }
}