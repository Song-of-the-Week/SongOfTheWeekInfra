resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "sotw-codebuild-artifact-${var.env}"
}