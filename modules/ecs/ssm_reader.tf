data "aws_ssm_parameter" "sg_id" {
  name = "/network/ecs-sg/id"
}
data "aws_ssm_parameter" "subnet_1a_id" {
  name = "/network/ecs-subnet-1a/id"
}
data "aws_ssm_parameter" "subnet_1b_id" {
  name = "/network/ecs-subnet-1b/id"
}
data "aws_ssm_parameter" "tg_id" {
  name = "/network/ecs-tg/id"
}
data "aws_ssm_parameter" "ec2_pub_arn" {
  name = "/secrets/ecs/key-pair/public/arn"
}

data "aws_ssm_parameter" "database_credentials" {
  name = "/secrets/database/credentials/arn"
}

data "aws_ssm_parameter" "email_address" {
  name = "/email/send-from-address"
}