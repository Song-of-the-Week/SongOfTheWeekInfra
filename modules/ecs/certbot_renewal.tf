resource "aws_ecs_task_definition" "certbot_task" {
  family             = "certbot-renewal-task-${var.env}"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "bridge"
  cpu                = "64"
  memory             = "64"

  container_definitions = jsonencode([
    {
      name      = "certbot"
      image     = "certbot/dns-route53"
      command   = ["renew", "--dns-route53", "--non-interactive", "--agree-tos"]
      essential = true
      mountPoints = [
        {
          sourceVolume  = "certificate-volume"
          containerPath = "/etc/letsencrypt"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "certificate-volume"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.certbot_efs.id
      root_directory     = "/certbot"
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_iam_role" "certbot_ecs_task_execution_role" {
  name = "certbot-ecs-task-execution-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEFSClientFullAccess"
  ]
}

resource "aws_iam_role" "certbot_ecs_task_role" {
  name = "certbot-ecs-task-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  ]
}

resource "aws_ecs_service" "certbot_service" {
  name            = "certbot-renewal-service-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.certbot_task.arn
  desired_count   = 1

  network_configuration {
    subnets          = local.ecs_subnets
    security_groups  = [data.aws_ssm_parameter.sg_id.value]
    assign_public_ip = false
  }
}

resource "aws_cloudwatch_event_rule" "certbot_renewal_schedule" {
  name                = "certbot-renewal-rule-${var.env}"
  description         = "Trigger certbot renewal every 60 days"
  schedule_expression = "cron(0 0 */60 * ? *)" # Every 60 days at midnight UTC
}

resource "aws_cloudwatch_event_target" "ecs_task_target" {
  rule = aws_cloudwatch_event_rule.certbot_renewal_schedule.name
  arn  = aws_ecs_cluster.this.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.certbot_task.arn
    task_count          = 1
    launch_type         = "EC2"
    network_configuration {
      subnets         = local.ecs_subnets
      security_groups = [data.aws_ssm_parameter.sg_id.value]
    }
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name = "EventBridgeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.eventbridge_role.name
}
