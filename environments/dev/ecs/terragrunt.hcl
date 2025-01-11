include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../secrets", "../network", "../ecr"]
}

inputs = {
  instance_type = "t3.micro"
  maximum_ec2_instances = 3
}


terraform {
  source = "../../../modules/ecs/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}