resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "main"
    Description = "This is the primary VPC used by the SOTW app."
  }
}

resource "aws_subnet" "ecs_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "ecs-1a-${var.env}"
  }
}

resource "aws_subnet" "ecs_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "ecs-1b-${var.env}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet_gateway"
  }
}
