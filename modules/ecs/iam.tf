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
      }
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
      }
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
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          data.aws_ssm_parameter.database_credentials.value,
          data.aws_ssm_parameter.spotify_credentials.value,
          "arn:aws:kms:*:${var.env}:key/key_id"
        ]
        Effect = "Allow"
      }
    ]
  })
}