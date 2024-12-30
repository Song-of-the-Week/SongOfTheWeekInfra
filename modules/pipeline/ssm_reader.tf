data "aws_ssm_parameter" "github_token" {
  name = "/secrets/github/token/arn"
}

# data "aws_ssm_parameter" "codebuild_subnet_id" {
#   name = "/network/codebuild-subnet/id"
# }
data "aws_ssm_parameter" "codebuild_subnet_arn" {
  name = "/network/codebuild-subnet/arn"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/network/sotw-vpc/id"
}

data "aws_ssm_parameter" "ecs_cluster_name" {
  name = "/ecs/cluster-name"
}

data "aws_ssm_parameter" "ecs_service_name" {
  name = "/ecs/primary-service-name"
}