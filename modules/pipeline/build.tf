locals {
    subnet_1a = data.aws_ssm_parameter.subnet_1a_id.value
    subnet_1b = data.aws_ssm_parameter.subnet_1b_id.value
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
    name = "codebuild-security-group-${var.env}"
    vpc_id = local.vpc_id
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
        local.subnet_1a,
        local.subnet_1b,
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
    type = "NO_ARTIFACTS"
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
    type = "S3"
    

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  vpc_config {
    vpc_id = local.vpc_id

    subnets = [
        local.subnet_1a,
        local.subnet_1b,
    ]

    security_group_ids = [
      aws_security_group.this.id
    ]
  }

  tags = {
    Environment = var.env
  }
}
