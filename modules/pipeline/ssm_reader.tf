data "aws_ssm_parameter" "github_token" {
  name = "/secrets/github/token/arn"
}