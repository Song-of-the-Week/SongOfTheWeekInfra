locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
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

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }

    environment_variable {
      name  = "ENV"
      value = var.env
    }
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
    type = "CODEPIPELINE"
  }

  tags = {
    Environment = var.env
  }
}
