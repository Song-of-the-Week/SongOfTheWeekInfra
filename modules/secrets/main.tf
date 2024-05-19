resource "aws_secretsmanager_secret" "ec2_pub" {
  name = "/ecs/key-pair/public"
}

resource "aws_secretsmanager_secret" "ec2_priv" {
  name = "/ecs/key-pair/private"
}