include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../secrets", "../network", "../ecr"]
}

inputs = {
  instance_type = "t3.micro"
  desired_count_sotw_ecs_tasks = 2
  maximum_ec2_instances = 2
  minimum_ec2_instances = 2
  on_demand_percentage_above_base_capacity = 0
  use_spot_instances = true
}

terraform {
  source = "../../../modules/ecs/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}