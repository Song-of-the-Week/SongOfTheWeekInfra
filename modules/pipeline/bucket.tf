resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "sotw-codebuild-artifact-${var.env}"
}

resource "aws_s3_bucket_policy" "codebuild_bucket_policy" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.account_id
          }
        }
      }
    ]
  })
}
