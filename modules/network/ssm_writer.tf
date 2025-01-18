# Write the VPC ARN to SSM to be used in other modules
resource "aws_ssm_parameter" "sotw_vpc_id" {
  name  = "/network/sotw-vpc/id"
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "ecs_security_group_id" {
  name  = "/network/ecs-sg/id"
  type  = "String"
  value = aws_security_group.ecs.id
}


resource "aws_ssm_parameter" "efs_security_group_id" {
  name  = "/network/efs-sg/id"
  type  = "String"
  value = aws_security_group.efs.id
}

resource "aws_ssm_parameter" "ecs_subnet_1a_id" {
  name  = "/network/ecs-subnet-1a/id"
  type  = "String"
  value = aws_subnet.ecs_1a.id
}

resource "aws_ssm_parameter" "ecs_subnet_1b_id" {
  name  = "/network/ecs-subnet-1b/id"
  type  = "String"
  value = aws_subnet.ecs_1b.id
}
resource "aws_ssm_parameter" "ecs_subnet_1b_arn" {
  name  = "/network/ecs-subnet-1b/arn"
  type  = "String"
  value = aws_subnet.ecs_1b.arn
}

resource "aws_ssm_parameter" "ecs_subnet_1c_arn" {
  name  = "/network/ecs-subnet-1c/arn"
  type  = "String"
  value = aws_subnet.ecs_1c.arn
}

resource "aws_ssm_parameter" "ecs_subnet_1d_arn" {
  name  = "/network/ecs-subnet-1d/arn"
  type  = "String"
  value = aws_subnet.ecs_1d.arn
}

resource "aws_ssm_parameter" "ecs_subnet_1e_arn" {
  name  = "/network/ecs-subnet-1e/arn"
  type  = "String"
  value = aws_subnet.ecs_1e.arn
}

resource "aws_ssm_parameter" "ecs_subnet_1f_arn" {
  name  = "/network/ecs-subnet-1f/arn"
  type  = "String"
  value = aws_subnet.ecs_1f.arn
}

resource "aws_ssm_parameter" "ecs_subnet_1c_id" {
  name  = "/network/ecs-subnet-1c/id"
  type  = "String"
  value = aws_subnet.ecs_1c.id
}

resource "aws_ssm_parameter" "ecs_subnet_1d_id" {
  name  = "/network/ecs-subnet-1d/id"
  type  = "String"
  value = aws_subnet.ecs_1d.id
}

resource "aws_ssm_parameter" "ecs_subnet_1e_id" {
  name  = "/network/ecs-subnet-1e/id"
  type  = "String"
  value = aws_subnet.ecs_1e.id
}

resource "aws_ssm_parameter" "ecs_subnet_1f_id" {
  name  = "/network/ecs-subnet-1f/id"
  type  = "String"
  value = aws_subnet.ecs_1f.id
}

resource "aws_ssm_parameter" "domain" {
  name  = "/network/domain/name"
  type  = "String"
  value = var.domain_name
}
