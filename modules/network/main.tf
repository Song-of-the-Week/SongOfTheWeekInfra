resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
    Description = "This is the primary VPC used by the SOTW app."
  }
}

resource "aws_subnet" "db_1c" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.128.0/20"
    availability_zone = "us-east-1c"
}

resource "aws_subnet" "db_1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.192.0/20"
    availability_zone = "us-east-1a"
}

resource "aws_security_group" "db" {
  name        = "db"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}