include "root" {
  path = find_in_parent_folders("root.hcl")
}
dependencies {
  paths = ["../secrets", "../maintenance"]
}

inputs = {
  domain_name = "sotw-app-dev.com"
  acm_cert_id = "839b2ee5-94dc-4b3f-8c6c-2af5f2023c6b"
  eip_count = 1
}

terraform {
  source = "../../../modules/network/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}