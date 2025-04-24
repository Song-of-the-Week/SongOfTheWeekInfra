locals {
  domain_name = data.aws_ssm_parameter.domain_name.value
}

resource "aws_ssm_parameter" "hostname" {
  name  = "/pipeline/vite-hostname"
  type  = "String"
  value = "https://${local.domain_name}/"
}

resource "aws_ssm_parameter" "api_hostname" {
  name  = "/pipeline/vite-api-hostname"
  type  = "String"
  value = "https://${local.domain_name}/"
}

resource "aws_ssm_parameter" "spotify_callback_uri" {
  name  = "/pipeline/vite-spotify-callback-uri"
  type  = "String"
  value = "https://${local.domain_name}/"
}
