resource "aws_secretsmanager_secret" "ec2_pub" {
  name = "/ecs/key-pair/public"
}

resource "aws_secretsmanager_secret" "ec2_priv" {
  name = "/ecs/key-pair/private"
}

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "_%@"
}

# Creating a AWS secret for database master account (Masteraccoundb)

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "/database/credentials"
}

# Creating a AWS secret versions for database master account (Masteraccoundb)

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = <<EOF
   {
    "username": "${var.db_username}",
    "password": "${random_password.db_password.result}"
   }
EOF
}

resource "aws_secretsmanager_secret" "spotify_credentials" {
  name = "/spotify/credentials"
}

resource "aws_secretsmanager_secret" "github_token" {
  name = "/secrets/github/token"
}
