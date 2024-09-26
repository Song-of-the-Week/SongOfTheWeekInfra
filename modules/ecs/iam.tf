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

  #   inline_policy {
  #     name = "private-registry-auth"

  #     policy = jsonencode({
  #       "Version" : "2012-10-17",
  #       "Statement" : [
  #         {
  #           "Effect" : "Allow",
  #           "Action" : [
  #             "kms:Decrypt",
  #             "secretsmanager:GetSecretValue"
  #           ],
  #           "Resource" : [
  #             "arn:aws:secretsmanager:*:${var.env}:secret:secret_name",
  #             "arn:aws:kms:*:${var.env}:key/key_id"
  #           ]
  #         }
  #       ]
  #     })
  #   }
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
      }
    ]
  })
}