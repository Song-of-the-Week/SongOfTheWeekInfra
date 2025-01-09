include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../secrets", "../network", "../ecr"]
}


terraform {
  source = "../../../modules/ecs/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}