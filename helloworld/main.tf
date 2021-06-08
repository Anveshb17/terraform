provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region = var.AWS_REGION
}

resource "aws_vpc" "xwiggy-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "teraform-xwiggy-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.xwiggy-vpc.id
  tags = {
    Name = "xwiggy-public-subnet"
  }
}


resource "aws_internet_gateway" "xwiggy_igw" {
  vpc_id = aws_vpc.xwiggy-vpc.id
  tags = {
    Name = "xwiggy_igw"
  }
}

resource "aws_default_route_table" "xwiggy-default-route-table" {
  default_route_table_id = aws_vpc.xwiggy-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.xwiggy_igw.id
  }

  tags = {
    Name = "xwiggy-default-route-table"
  }
}

resource "aws_security_group" "public-security-group" {
  name = "xwiggy-public-secuty-group"
  vpc_id = aws_vpc.xwiggy-vpc.id
  ingress {
    from_port = 0
    protocol = ""
    to_port = 0
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "xwiggy-public-security-group"
  }
}