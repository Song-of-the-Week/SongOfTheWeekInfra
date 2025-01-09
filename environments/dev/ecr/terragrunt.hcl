include "root" {
  path = find_in_parent_folders("root.hcl")
}
dependencies {
  paths = ["../secrets", "../network"]
}


terraform {
  source = "../../../modules/ecr/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}