include "root" {
  path = find_in_parent_folders("root.hcl")
}


terraform {
  source = "../../../modules/pipeline/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    #   "-var-file=account.tfvars",
    #   "-var-file=region.tfvars"
    #   "-var-file=../common.tfvars"
    ]
  }
}