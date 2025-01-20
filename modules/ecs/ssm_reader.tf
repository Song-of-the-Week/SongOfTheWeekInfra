data "aws_ssm_parameter" "sg_id" {
  name = "/network/ecs-sg/id"
}

data "aws_ssm_parameter" "efs_sg_id" {
  name = "/network/efs-sg/id"
}

data "aws_ssm_parameter" "subnet_1a_id" {
  name = "/network/ecs-subnet-1a/id"
}
data "aws_ssm_parameter" "subnet_1b_id" {
  name = "/network/ecs-subnet-1b/id"
}
data "aws_ssm_parameter" "subnet_1c_id" {
  name = "/network/ecs-subnet-1c/id"
}
data "aws_ssm_parameter" "subnet_1d_id" {
  name = "/network/ecs-subnet-1d/id"
}
data "aws_ssm_parameter" "subnet_1e_id" {
  name = "/network/ecs-subnet-1e/id"
}
data "aws_ssm_parameter" "subnet_1f_id" {
  name = "/network/ecs-subnet-1f/id"
}
data "aws_ssm_parameter" "ec2_pub_arn" {
  name = "/secrets/ecs/key-pair/public/arn"
}

data "aws_ssm_parameter" "database_credentials_username" {
  name = "/secrets/database/credentials/username"
}

data "aws_ssm_parameter" "database_credentials_password" {
  name = "/secrets/database/credentials/password"
}


data "aws_ssm_parameter" "database_credentials_host" {
  name = "/secrets/database/credentials/host"
}


data "aws_ssm_parameter" "database_credentials_port" {
  name = "/secrets/database/credentials/port"
}


data "aws_ssm_parameter" "database_credentials_db" {
  name = "/secrets/database/credentials/db"
}


data "aws_ssm_parameter" "spotify_credentials_client_id" {
  name = "/secrets/spotify/credentials/client-id"
}

data "aws_ssm_parameter" "spotify_credentials_client_secret" {
  name = "/secrets/spotify/credentials/client-secret"
}
data "aws_ssm_parameter" "domain_name" {
  name = "/network/domain/name"
}

data "aws_ssm_parameter" "ecs_api_version" {
  name       = "/ecs/api/image-version"
  depends_on = [aws_ssm_parameter.ecs_api_version]
}

data "aws_ssm_parameter" "ecs_frontend_version" {
  name       = "/ecs/frontend/image-version"
  depends_on = [aws_ssm_parameter.ecs_frontend_version]
}

data "aws_ssm_parameter" "ecs_nginx_version" {
  name       = "/ecs/nginx/image-version"
  depends_on = [aws_ssm_parameter.ecs_nginx_version]
}

data "aws_ssm_parameter" "lets_encrypt_email" {
  name = "/secrets/lets-encrypt-email"
}