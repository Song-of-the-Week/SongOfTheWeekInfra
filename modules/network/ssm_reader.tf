data "aws_ssm_parameter" "website_endpoint" {
  name = "/maintenance/bucket/website-endpoint"
}

data "aws_ssm_parameter" "website_hosted_zone_id" {
  name = "/maintenance/bucket/website-hosted-zone-id"
}
