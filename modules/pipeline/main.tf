locals {
  ecs_cluster_name = data.aws_ssm_parameter.ecs_cluster_name.value
  ecs_service_name = data.aws_ssm_parameter.ecs_service_name.value
}

resource "aws_codepipeline" "codepipeline" {
  name          = "sotw-pipeline-${var.env}"
  role_arn      = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = [var.build_branch]
        }
        # tags {
        #   includes = ["^v\\d+\\.\\d+\\.\\d+$"]
        # }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.this.arn
        FullRepositoryId     = var.repo_path
        BranchName           = var.build_branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF" // full clone so we can parse tags regardless of webhook or manual trigger
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "If you're an admin, approve this please :)"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = local.ecs_cluster_name
        ServiceName = local.ecs_service_name
        FileName    = "imagedefinitions.json" # this is set in buildspec.yml in the app repo, do not change
      }
    }
  }
}

# resource "aws_codestarconnections_connection" "example" {
#   name          = "example-connection"
#   provider_type = "GitHub"
# }

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}