data "aws_secretsmanager_secret" "github_token" {
  arn = data.aws_ssm_parameter.github_token.value
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}


resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_secretsmanager_secret_version.current.secret_string
}

resource "aws_codestarconnections_connection" "this" {
  name          = "sotw-connection-${var.env}"
  provider_type = "GitHub"
}