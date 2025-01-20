data "aws_ssm_parameter" "github_token" {
  name = "/secrets/github/token"
}

resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_ssm_parameter.github_token.value
}

resource "aws_codestarconnections_connection" "this" {
  name          = "sotw-connection-${var.env}"
  provider_type = "GitHub"
}