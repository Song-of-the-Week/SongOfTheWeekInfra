resource "aws_ssm_parameter" "ecs_api_version" {
  name  = "/ecs/api/image-version"
  type  = "String"
  value = "latest"
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "ecs_frontend_version" {
  name  = "/ecs/frontend/image-version"
  type  = "String"
  value = "latest"
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "ecs_nginx_version" {
  name  = "/ecs/nginx/image-version"
  type  = "String"
  value = "latest"
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "ecs_cluster_name" {
  name  = "/ecs/cluster-name"
  type  = "String"
  value = aws_ecs_cluster.this.name
}

resource "aws_ssm_parameter" "ecs_service_name" {
  name  = "/ecs/primary-service-name"
  type  = "String"
  value = aws_ecs_service.this.name
}
