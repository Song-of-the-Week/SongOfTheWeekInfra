data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.5"
}

module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.3.1"

  name           = "${var.env}-db"
  engine         = data.aws_rds_engine_version.postgresql.engine
  engine_mode = "provisioned"
  engine_version = data.aws_rds_engine_version.postgresql.version

  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  db_subnet_group_name = aws_db_subnet_group.default.name
  security_group_rules = {
    ex1_ingress = {
      source_security_group_id = data.aws_ssm_parameter.sg_id.value
    }
  }

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10
  skip_final_snapshot = true

  # enabled_cloudwatch_logs_exports = ["postgresql"]

  master_username = "root"
  manage_master_user_password = true
  manage_master_user_password_rotation = true
  master_user_password_rotation_automatically_after_days = 30

  create_db_parameter_group      = true
  db_parameter_group_name        = "${var.env}-db-parameter-group"
  db_parameter_group_family      = "aurora-postgresql14"
  db_parameter_group_description = "${var.env} DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 4000
      apply_method = "immediate"
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [data.aws_ssm_parameter.subnet_1a_id.value, data.aws_ssm_parameter.subnet_1c_id.value]

  tags = {
    Name = "main"
    Description = "The main subnet group for the database"
  }
}
