data "aws_ssm_parameter" "github_token" {
  name = "/secrets/github/token/arn"
}

data "aws_ssm_parameter" "subnet_1a_id" {
  name = "/network/ecs-subnet-1a/id"
}

data "aws_ssm_parameter" "subnet_1b_id" {
  name = "/network/ecs-subnet-1b/id"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/network/sotw-vpc/id"
}