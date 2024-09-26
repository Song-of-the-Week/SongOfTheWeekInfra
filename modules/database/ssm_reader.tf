data "aws_ssm_parameter" "vpc_id" {
    name = "/network/sotw-vpc/id"
}

data "aws_ssm_parameter" "sg_id" {
    name = "/network/db-sg/id"
}

data "aws_ssm_parameter" "subnet_1c_id" {
    name = "/network/db-subnet-1c/id"
}

data "aws_ssm_parameter" "subnet_1a_id" {
    name = "/network/db-subnet-1a/id"
}