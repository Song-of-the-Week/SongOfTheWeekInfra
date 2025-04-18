include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../secrets", "../network", "../ecr"]
}

inputs = {
  instance_type = "t3.micro"
  desired_count_sotw_ecs_tasks = 1
  desired_ec2_instances = 1
  maximum_ec2_instances = 2
  minimum_ec2_instances = 1
  on_demand_percentage_above_base_capacity = 0
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100
  send_registration_emails = false
  use_spot_instances = false
}


terraform {
  source = "../../../modules/ecs/"

  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
    ]
  }
}