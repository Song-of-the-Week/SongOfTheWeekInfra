# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=3.5.0".
# Note the extra `/` after the protocol is required for the shorthand
# notation.
# generate "backend" {
#   path = "backend.tf"
#   if_exists = "overwrite_terragrunt"
#   contents = <<EOF
#   terraform {
#     backend "s3" {
#       bucket = "sotw-prod-terraform-state-management"
#       key = "${path_relative_to_include()}/terraform.tfstate"
#       region = "us-east-1"
#       encrypt = "true"
#       dynamodb_table = "sotw-lock-table"
#     }
#   }
# EOF
# }
# remote_state {
#   backend = "s3"
#   generate = {
#     path      = "../../modules/backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
#   config = {
#     bucket = "sotw-prod-terraform-state-management"

#     key = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "sotw-lock-table"
#   }
# }

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::471112828417:role/terraform"
  }
}
EOF
}