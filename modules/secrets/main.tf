resource "aws_ssm_parameter" "ecs_pub" {
  name  = "/secrets/ecs/key-pair/public"
  type  = "SecureString"
  value = "EC2 PUBLIC KEY"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "ecs_priv" {
  name  = "/secrets/ecs/key-pair/private"
  type  = "SecureString"
  value = "EC2 PRIVATE KEY"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_credentials_username" {
  name  = "/secrets/database/credentials/username"
  type  = "SecureString"
  value = "USERNAME"
  lifecycle {
    ignore_changes = [value]
  }
}
resource "aws_ssm_parameter" "db_credentials_password" {
  name  = "/secrets/database/credentials/password"
  type  = "SecureString"
  value = "PASSWORD"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_credentials_host" {
  name  = "/secrets/database/credentials/host"
  type  = "SecureString"
  value = "HOST"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_credentials_port" {
  name  = "/secrets/database/credentials/port"
  type  = "SecureString"
  value = "PORT"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_credentials_db" {
  name  = "/secrets/database/credentials/db"
  type  = "SecureString"
  value = "DB"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "github_token_secret" {
  name  = "/secrets/github/token"
  type  = "SecureString"
  value = "GITHUB TOKEN HERE"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "spotify_credentials_client_id" {
  name  = "/secrets/spotify/credentials/client-id"
  type  = "SecureString"
  value = "SPOTIFY CLIENT ID HERE"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "spotify_credentials_client_secret" {
  name  = "/secrets/spotify/credentials/client-secret"
  type  = "SecureString"
  value = "SPOTIFY CLIENT SECRET HERE"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "lets_encrypt_email" {
  name  = "/secrets/lets-encrypt-email"
  type  = "String"
  value = "LET'S ENCRYPT EMAIL HERE"
  lifecycle {
    ignore_changes = [value]
  }
}