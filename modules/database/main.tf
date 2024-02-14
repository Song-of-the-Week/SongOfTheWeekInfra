module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name           = "${var.env}-db"
  engine         = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.t4g.micro"
  instances = {
    one = {}
  }

  vpc_id               = "vpc-12345678"
  db_subnet_group_name = "db-subnet-group"
  security_group_rules = {
    ex1_ingress = {
      cidr_blocks = ["10.20.0.0/20"]
    }
    ex1_ingress = {
      source_security_group_id = "sg-12345678"
    }
  }

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}