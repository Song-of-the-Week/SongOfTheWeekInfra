
# S3 Bucket for Static Website
resource "aws_s3_bucket" "static_website" {
  bucket = "sotw-app-maintenance-page-${var.env}" # Replace with your unique bucket name
}

resource "aws_s3_bucket_acl" "public_read_acl" {
  bucket = aws_s3_bucket.static_website.id
  acl    = "public-read"
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "files" {
  for_each = fileset("${path.module}/files", "**/*")

  bucket       = aws_s3_bucket.static_website.id
  key          = each.value
  source       = "${path.module}/files/${each.value}"
  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
    },
    split(".", each.value)[-1],
    "application/octet-stream" # Default MIME type
  )
}