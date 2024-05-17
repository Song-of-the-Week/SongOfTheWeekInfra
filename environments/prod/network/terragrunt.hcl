include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "../../../modules/network/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
      "-var-file=account.tfvars",
      "-var-file=region.tfvars"
    ]
  }
}