resource "aws_ssm_parameter" "website_endpoint" {
  name  = "/maintenance/bucket/website-endpoint"
  type  = "String"
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

resource "aws_ssm_parameter" "website_hosted_zone_id" {
  name  = "/maintenance/bucket/website-hosted-zone-id"
  type  = "String"
  value = aws_s3_bucket.static_website.hosted_zone_id
}
