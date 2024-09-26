resource "aws_ssm_parameter" "ecs_pub" {
  name  = "/secrets/ecs/key-pair/public/arn"
  type  = "String"
  value = aws_secretsmanager_secret.ec2_pub.arn
}

resource "aws_ssm_parameter" "ecs_priv" {
  name  = "/secrets/ecs/key-pair/private/arn"
  type  = "String"
  value = aws_secretsmanager_secret.ec2_priv.arn
}

resource "aws_ssm_parameter" "db_credentials" {
  name  = "/secrets/database/credentials/arn"
  type  = "String"
  value = aws_secretsmanager_secret.db_credentials.arn
}