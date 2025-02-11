resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

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


resource "aws_subnet" "ecs_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
  tags = {
    Name = "ecs-1c-${var.env}"
  }
}

resource "aws_subnet" "ecs_1d" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.48.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1d"
  tags = {
    Name = "ecs-1d-${var.env}"
  }
}

resource "aws_subnet" "ecs_1e" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1e"
  tags = {
    Name = "ecs-1e-${var.env}"
  }
}

resource "aws_subnet" "ecs_1f" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.80.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1f"
  tags = {
    Name = "ecs-1f-${var.env}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_eip" "this" {
  count = var.eip_count # Number of Elastic IPs to allocate
}