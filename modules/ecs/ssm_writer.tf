resource "aws_ssm_parameter" "ecs_api_version" {
  name  = "/ecs/api/image-version"
  type  = "String"
  value = "latest"
}

resource "aws_ssm_parameter" "ecs_frontend_version" {
  name  = "/ecs/frontend/image-version"
  type  = "String"
  value = "latest"
}

resource "aws_ssm_parameter" "ecs_nginx_version" {
  name  = "/ecs/nginx/image-version"
  type  = "String"
  value = "latest"
}
