include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../secrets", "../network", "../ecs"]
}

inputs = {
  build_branch = "main" // change this for testing stuff
}

terraform {
  source = "../../../modules/pipeline/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}