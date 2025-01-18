locals {
  efs_sg_id = data.aws_ssm_parameter.efs_sg_id.value
}

resource "aws_efs_file_system" "certbot_efs" {
  creation_token = "certbot-storage-${var.env}"
  encrypted      = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "efs_mount_targets" {
  for_each        = { for i, v in local.ecs_subnets : i => v }
  file_system_id  = aws_efs_file_system.certbot_efs.id
  subnet_id       = each.value
  security_groups = [local.efs_sg_id]
}
