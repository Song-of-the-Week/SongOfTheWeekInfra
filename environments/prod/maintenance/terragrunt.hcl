include "root" {
  path = find_in_parent_folders("root.hcl")
}


terraform {
  source = "../../../modules/maintenance/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}