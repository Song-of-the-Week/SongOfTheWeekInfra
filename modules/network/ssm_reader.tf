data "aws_ssm_parameter" "cloudfront_domain_name" {
  name = "/maintenance/cloudfront/domain-name"
}

data "aws_ssm_parameter" "cloudfront_hosted_zone_id" {
  name = "/maintenance/cloudfront/hosted-zone-id"
}
