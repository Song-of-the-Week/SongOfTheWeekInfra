include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../secrets"]
}

terraform {
  source = "../../../modules/network/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}