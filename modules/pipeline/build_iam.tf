
resource "aws_iam_role" "codebuild" {
  name               = "codebuild-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

resource "aws_iam_role_policy_attachment" "codebuild_write_params" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.update_version_params.arn
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:*:${var.account_id}:parameter/ecr/*",
      "arn:aws:ssm:*:${var.account_id}:parameter/pipeline/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    // TODO: if this wasn't hardcoded it would be best
    resources = [
      "arn:aws:ecr:*:${var.account_id}:repository/sotw-api-repo-${var.env}",
      "arn:aws:ecr:*:${var.account_id}:repository/sotw-frontend-repo-${var.env}",
      "arn:aws:ecr:*:${var.account_id}:repository/sotw-nginx-repo-${var.env}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.this.arn]
  }
}

resource "aws_iam_policy" "update_version_params" {
  name = "update-version-params-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for v in var.version_parameters : {
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:AddTagsToResource"
        ]
        Resource = "arn:aws:ssm:*:${var.account_id}:parameter/${v}",
      }
    ]
  })
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
