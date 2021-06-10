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
 resource "aws_subnet" "private-subnet" {
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.xwiggy-vpc.id
    tags = {
      Name = "xwiggy-private-subnet"
    }
  }


  resource "aws_internet_gateway" "xwiggy_igw" {
    vpc_id = aws_vpc.xwiggy-vpc.id
    tags = {
      Name = "xwiggy_igw"
    }
  }

  resource "aws_route_table" "public-RT" {
    vpc_id = aws_vpc.xwiggy-vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.xwiggy_igw.id
    }

    tags = {
      Name = "xwiggy-Public"
    }
  }
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NGW"
  }
}
 resource "aws_route_table" "Private-RT" {
   vpc_id = aws_vpc.xwiggy-vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw.id
    }

    tags = {
      Name = "xwiggy-Private"
    }
  }
 resource "aws_eip" "nat" {
   vpc = true
   associate_with_private_ip = "10.0.0.5"
   tags = {
     Name = "Production-EIP"
   }
 }

 resource "aws_route_table_association" "route" {
   subnet_id = aws_subnet.public-subnet.id
   route_table_id = aws_route_table.public-RT.id
 }
 resource "aws_route_table_association" "private" {
   subnet_id = aws_subnet.private-subnet.id
   route_table_id = aws_route_table.Private-RT.id
 }
  resource "aws_security_group" "public-security-group" {
    name = "xwiggy-public-secuty-group"
    vpc_id = aws_vpc.xwiggy-vpc.id
    ingress {
      from_port = 0
      protocol = "-1"
      to_port = 0
      cidr_blocks = ["10.0.0.0/16"]
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
  resource "aws_security_group" "private-security-group" {
    name = "xwiggy-private-secuty-group"
    vpc_id = aws_vpc.xwiggy-vpc.id
    ingress {
      from_port = 0
      protocol = "-1"
      to_port = 0
      cidr_blocks = ["10.0.0.0/16"]
    }
    egress {
      from_port = 0
      protocol = "-1"
      to_port = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "xwiggy-private-security-group"
    }
  }
 resource "aws_instance" "instance" {
  ami = "ami-0aeeebd8d2ab47354"
  instance_type  = "t2.micro"
  subnet_id      = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.public-security-group.id]
  associate_public_ip_address = true
  key_name = "NVkey"
  tags = {
    Name = "Web"
  }
}

resource "aws_security_group_rule" "my_ip_whitelist" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.public-security-group.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["49.207.119.12/32"]
}
resource "aws_security_group_rule" "http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.public-security-group.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "private" {
  from_port = 8080
  protocol = "tcp"
  security_group_id = aws_security_group.private-security-group.id
  to_port = 8080
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_instance" "AppServer" {
  ami = "ami-0aeeebd8d2ab47354"
  instance_type  = "t2.micro"
  subnet_id      = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.private-security-group.id]
  associate_public_ip_address = false
  key_name = "NVkey"
  tags = {
    Name = "Backend"
  }
}
resource "aws_instance" "DBServer" {
  ami = "ami-0aeeebd8d2ab47354"
  instance_type  = "t2.micro"
  subnet_id      = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.private-security-group.id]
  associate_public_ip_address = false
  key_name = "NVkey"
  tags = {
    Name = "DB"
  }
}