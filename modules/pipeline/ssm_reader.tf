
data "aws_ssm_parameter" "vpc_id" {
  name = "/network/sotw-vpc/id"
}

data "aws_ssm_parameter" "ecs_cluster_name" {
  name = "/ecs/cluster-name"
}

data "aws_ssm_parameter" "ecs_service_name" {
  name = "/ecs/primary-service-name"
}

data "aws_ssm_parameter" "domain_name" {
  name = "/network/domain/name"
}