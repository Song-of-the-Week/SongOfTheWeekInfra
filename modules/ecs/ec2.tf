resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"

  key_name               = aws_key_pair.ec2_ecs_key.key_name
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_id.value]

  iam_instance_profile {
    name = "ecsInstanceRole-profile"
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
      Name = "ecs-instance"
    }
  }

  update_default_version = var.update_default_version

  network_interfaces {
    associate_public_ip_address = false
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
  #   desired_capacity    = 3
  max_size = 1 // TODO: REVISIT
  min_size = 1

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