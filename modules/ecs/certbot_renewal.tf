resource "aws_ecs_task_definition" "certbot_task" {
  family             = "certbot-renewal-task-${var.env}"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "bridge"

  container_definitions = jsonencode([
    {
      name              = "certbot"
      image             = "certbot/dns-route53"
      command           = ["renew", "--dns-route53", "--non-interactive", "--agree-tos"]
      essential         = true
      memoryReservation = 32
      mountPoints = [
        {
          sourceVolume  = "certificate-volume"
          containerPath = "/etc/letsencrypt"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "ecs/certbot-renewal-${var.env}",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = local.cluster_name
          awslogs-create-group  = "true"
        }
      },
    }
  ])

  volume {
    name = "certificate-volume"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.certbot_efs.id
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_iam_role_policy_attachment" "certbot_renewal_logs_attachment" {
  count = 1
  role  = aws_iam_role.certbot_ecs_task_execution_role.name

  policy_arn = aws_iam_policy.certbot_renewal_logs.arn
}

resource "aws_iam_policy" "certbot_renewal_logs" {
  name = "certbot-renewal-ecs-policy-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [ # TODO: dynamic region
          "arn:aws:logs:*:${var.account_id}:log-group:*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          data.aws_ssm_parameter.database_credentials.value,
          data.aws_ssm_parameter.spotify_credentials.value,
          "arn:aws:kms:*:${var.env}:key/key_id"
        ]
        Effect = "Allow"
      },
    ]
  })
}


resource "aws_iam_policy" "efs_access_policy" {
  name        = "certbot-efs-access-policy-${var.env}"
  description = "Policy for ECS task to access Amazon EFS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:CreateAccessPoint",
          "elasticfilesystem:DescribeTags",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRead"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role


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
  ]
}

resource "aws_iam_role_policy_attachment" "attach_efs_access_policy" {
  policy_arn = aws_iam_policy.efs_access_policy.arn
  role       = aws_iam_role.certbot_ecs_task_execution_role.name
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
  desired_count   = 0

  triggers = {
    redeployment = plantimestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }
  depends_on = [aws_autoscaling_group.ecs_asg]

}

resource "aws_cloudwatch_event_rule" "certbot_renewal_schedule" {
  name                = "certbot-renewal-rule-${var.env}"
  description         = "Trigger certbot renewal every 60 days"
  schedule_expression = "cron(0 0 ? * 2 *)"
}

resource "aws_cloudwatch_event_target" "ecs_task_target" {
  rule     = aws_cloudwatch_event_rule.certbot_renewal_schedule.name
  arn      = aws_ecs_cluster.this.arn
  role_arn = aws_iam_role.eventbridge_role.arn
  ecs_target {
    task_definition_arn = aws_ecs_task_definition.certbot_task.arn
    task_count          = 1
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name = "certbot-eventbridge-role-${var.env}"

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

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "eventbridge_policy" {
  name = "eventbridge-ecs-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ecs:RunTask",
        Resource = "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = aws_iam_role.certbot_ecs_task_execution_role.arn
      },
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = aws_iam_role.ecs_task_execution_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attachment" {
  policy_arn = aws_iam_policy.eventbridge_policy.arn
  role       = aws_iam_role.eventbridge_role.name
}
