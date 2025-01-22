include "root" {
  path = find_in_parent_folders("root.hcl")
}
dependencies {
  paths = ["../secrets", "../maintenance"]
}

# locals {
#   config = read_terragrunt_config("config.yml")
# }

inputs = {
  domain_name = "sotw-app-dev.com"
  acm_cert_id = "839b2ee5-94dc-4b3f-8c6c-2af5f2023c6b"
}

terraform {
  source = "../../../modules/network/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}