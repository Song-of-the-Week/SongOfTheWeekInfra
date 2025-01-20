resource "aws_ssm_parameter" "cloudfront_domain_name" {
  name  = "/maintenance/cloudfront/domain-name"
  type  = "String"
  value = aws_cloudfront_distribution.this.domain_name
}

resource "aws_ssm_parameter" "hosted_zone_id" {
  name  = "/maintenance/cloudfront/hosted-zone-id"
  type  = "String"
  value = aws_cloudfront_distribution.this.hosted_zone_id
}
