locals {
  ecs_subnets = [data.aws_ssm_parameter.subnet_1a_id.value, data.aws_ssm_parameter.subnet_1b_id.value, data.aws_ssm_parameter.subnet_1c_id.value, data.aws_ssm_parameter.subnet_1d_id.value, data.aws_ssm_parameter.subnet_1e_id.value, data.aws_ssm_parameter.subnet_1f_id.value]
  # We cannot create more EC2s than the number of EIPs we have
  # If we need to create more EC2s, first create more EIPs
  # If this ever gets to the point where we have 4+ EIPs in use, it may well be worth using an ELB.
  eip_count = data.aws_ssm_parameter.eip_count.value
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template"
  image_id      = data.aws_ami.custom_ecs_ami.id
  instance_type = var.instance_type

  key_name = aws_key_pair.ec2_ecs_key.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 12
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "sotw-ecs-instance-${var.env}"
    }
  }

  update_default_version = var.update_default_version

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_ssm_parameter.sg_id.value]
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

data "template_file" "user_data" {
  template = file("user_data.sh")

  vars = {
    ecs_cluster_name = aws_ecs_cluster.this.name
  }
}


data "aws_ami" "custom_ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["unofficial-amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["self"]
}


resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = local.ecs_subnets
  desired_capacity    = var.desired_ec2_instances
  min_size            = var.minimum_ec2_instances
  max_size            = min(var.maximum_ec2_instances, local.eip_count)
  dynamic "mixed_instances_policy" {
    for_each = var.use_spot_instances == true ? ["use spot instances"] : []
    content {
      instances_distribution {
        on_demand_base_capacity                  = var.min_on_demand_ec2_instances
        on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
        spot_allocation_strategy                 = "capacity-optimized"
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.ecs_lt.id
          version            = "$Latest"
        }

        override {
          instance_type     = var.instance_type
          weighted_capacity = "1"
        }
      }
    }
  }
  dynamic "launch_template" {
    for_each = var.use_spot_instances == false ? ["must specify launch template for on-demand instances"] : []
    content {
      id      = aws_launch_template.ecs_lt.id
      version = "$Latest"
    }
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

}

data "aws_ssm_parameter" "ec2_public_key" {
  name = "/secrets/ecs/key-pair/public"
}

resource "aws_key_pair" "ec2_ecs_key" {
  key_name   = "sotw-ec2-ecs-key-${var.env}"
  public_key = data.aws_ssm_parameter.ec2_public_key.value
}

resource "aws_autoscaling_lifecycle_hook" "eip_assignment_hook" {
  name                    = "EIPAssignment-Hook"
  autoscaling_group_name  = aws_autoscaling_group.ecs_asg.name
  default_result          = "ABANDON"
  heartbeat_timeout       = 180
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_target_arn = aws_sns_topic.eip_assignment_topic.arn
  role_arn                = aws_iam_role.autoscaling_notification_role.arn
}