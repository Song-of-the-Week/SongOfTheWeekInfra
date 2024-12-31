resource "aws_ssm_parameter" "ecr_frontend_repo_uri" {
  name  = "/ecr/frontend/uri"
  type  = "String"
  value = aws_ecr_repository.frontend.repository_url
}

resource "aws_ssm_parameter" "ecr_api_repo_uri" {
  name  = "/ecr/api/uri"
  type  = "String"
  value = aws_ecr_repository.api.repository_url
}

resource "aws_ssm_parameter" "ecr_nginx_repo_uri" {
  name  = "/ecr/nginx/uri"
  type  = "String"
  value = aws_ecr_repository.nginx.repository_url
}