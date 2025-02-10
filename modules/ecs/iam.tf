resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-role-profile-${var.env}"
  role = aws_iam_role.ecs_instance_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs-instance-role-${var.env}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_route53_zone" "this" {
  name         = local.domain_name
  private_zone = false
}

resource "aws_iam_policy" "ecs_instance" {
  name = "sotw-ecs-instance-policy-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = [
          "arn:aws:ses:*:${var.account_id}:identity/${local.domain_name}"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "ses:UseConfigurationSet",
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = [
          "arn:aws:ses:*:${var.account_id}:configuration-set/*"
        ]
        Effect = "Allow"
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ListHostedZones",
          "route53:GetChange"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets"
        ],
        Resource = data.aws_route53_zone.this.arn
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        Resource = aws_efs_file_system.certbot_efs.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  count = 1
  role  = aws_iam_role.ecs_instance_role.name

  policy_arn = aws_iam_policy.ecs_instance.arn
}

resource "aws_iam_role_policy_attachment" "ecs_instance_service_policy" {
  count = 1
  role  = aws_iam_role.ecs_instance_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "sotw-ecs-task-execution-role-${var.env}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  count = 1
  role  = aws_iam_role.ecs_task_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  count = 1
  role  = aws_iam_role.ecs_task_execution_role.name

  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name = "sotw-ecs-policy-${var.env}"
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
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:*:${var.account_id}:parameter/secrets/database/credentials/*",
          "arn:aws:ssm:*:${var.account_id}:parameter/secrets/spotify/credentials/*",
        ]
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role" "autoscaling_notification_role" {
  name = "AutoScalingNotificationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "autoscaling.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "sns_publish_policy" {
  name = "SNSPublishPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = aws_sns_topic.eip_assignment_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "autoscaling_notification_role_attachment" {
  role       = aws_iam_role.autoscaling_notification_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "EIPAssignmentLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eip_assignment_lambda_policy" {
  name = "EIPAssignmentLambdaPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeAddresses",
          "ec2:AssociateAddress",
          "autoscaling:CompleteLifecycleAction"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.eip_assignment_lambda_policy.arn
}
