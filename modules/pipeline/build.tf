locals {
  codebuild_subnet_arn = data.aws_ssm_parameter.codebuild_subnet_arn.value
  # codebuild_subnet_id  = data.aws_ssm_parameter.codebuild_subnet_id.value
  vpc_id = data.aws_ssm_parameter.vpc_id.value
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

resource "aws_security_group" "this" {
  name   = "codebuild-${var.env}"
  vpc_id = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "codebuild-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:us-east-1:${var.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = [
        local.codebuild_subnet_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
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
    actions = ["ssm:GetParamter", "ssm:GetParamters"]
    resources = [
      "arn:aws:ssm:*:${var.account_id}:parameter/ecr/*"
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
      "arn:aws:ecr:*:${var.account_id}:repository/sotw-api-repo-prod",
      "arn:aws:ecr:*:${var.account_id}:repository/sotw-frontend-repo-prod",
      "arn:aws:ecr:*:${var.account_id}:repository/sotw-nginx-repo-prod",
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

resource "aws_iam_role_policy" "codeuild_role_policy" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

resource "aws_codebuild_project" "this" {
  name          = "sotw-build-${var.env}"
  description   = "Builds images for the SOTW app and pushes them to ECR"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # environment_variable {
    #   name  = "SOME_KEY1"
    #   value = "SOME_VALUE1"
    # }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }

    # environment_variable {
    #   name  = "SOME_KEY2"
    #   value = "SOME_VALUE2"
    #   type  = "PARAMETER_STORE"
    # }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild-${var.env}"
      stream_name = "codebuild-${var.env}"
      status      = "ENABLED"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codepipeline_bucket.id}/build-log"
    }
  }

  source {
    # type            = "GITHUB"
    # location        = "https://github.com/mitchellh/packer.git"
    # git_clone_depth = 1
    type = "CODEPIPELINE"


    # git_submodules_config {
    #   fetch_submodules = true
    # }
  }

  # vpc_config {
  #   vpc_id = local.vpc_id

  #   subnets = [
  #     local.codebuild_subnet_id,
  #   ]

  #   security_group_ids = [
  #     aws_security_group.this.id
  #   ]
  # }

  tags = {
    Environment = var.env
  }
}
