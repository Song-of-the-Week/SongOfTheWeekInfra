inputs = {
    env = "prod"
    account_id = "471112828417"
    assume_role_name = "terraform"
}

generate "backend" {
  path = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  terraform {
    backend "s3" {
      bucket = "sotw-prod-terraform-state-management"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = "us-east-1"
      encrypt = "true"
      dynamodb_table = "sotw-lock-table"
    }
  }
EOF
}