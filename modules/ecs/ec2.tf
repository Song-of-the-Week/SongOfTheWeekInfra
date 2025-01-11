resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  key_name = aws_key_pair.ec2_ecs_key.key_name
  #   vpc_security_group_ids = [data.aws_ssm_parameter.sg_id.value]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
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


data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}


resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [data.aws_ssm_parameter.subnet_1a_id.value, data.aws_ssm_parameter.subnet_1b_id.value]
  desired_capacity    = 1
  min_size            = var.minimum_ec2_instances
  max_size            = var.maximum_ec2_instances

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_schedule" "on" {
  scheduled_action_name  = "sotw-ecs-ec2-schedule-on-${var.env}"
  min_size               = var.minimum_ec2_instances
  max_size               = var.maximum_ec2_instances
  desired_capacity       = 1
  recurrence             = "${var.app_on_time} * * *"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}
resource "aws_autoscaling_schedule" "off" {
  scheduled_action_name  = "sotw-ecs-ec2-schedule-off-${var.env}"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "${var.app_off_time} * * *"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}

data "aws_secretsmanager_secret" "ec2_public_key" {
  arn = data.aws_ssm_parameter.ec2_pub_arn.value
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.ec2_public_key.id
}

resource "aws_key_pair" "ec2_ecs_key" {
  key_name   = "sotw-ec2-ecs-key-${var.env}"
  public_key = data.aws_secretsmanager_secret_version.current.secret_string
}