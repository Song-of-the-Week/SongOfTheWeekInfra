inputs = {
    env = "dev"
    account_id = "418272759779"
    assume_role_name = "terraform"
}

remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "sotw-dev-terraform-state-management"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "sotw-lock-table-dev"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    provider "aws" {
      region = "us-east-1"
      assume_role {
        role_arn = "arn:aws:iam::$${var.account_id}:role/$${var.assume_role_name}"
      }
    }
EOF
}